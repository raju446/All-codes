/*
    Author      : Azmath.
    Date        : 05-Jul-2018
    Description : Batch Class to create Entry permit expiration alerts.
    -------------------------------------------------------------------------------------------
*/
global with sharing class Batch_EntryPermitExpirationAlerts implements Database.Batchable<sObject>,Database.Stateful
{
    list<Contact> consTobeDeleted = new list<contact>();
    set<string> emailslst = new set<string>(); 
    Id orgwideemailId = null;
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        date EntryPermitExpDate_30 = system.today().addDays(30);
        date EntryPermitExpDate_14 = system.today().addDays(14);
        
        OrgWideEmailAddress[] owea	= [select Id from OrgWideEmailAddress where Address =:Label.OrgWideEmailAddress];
        if(!owea.isEmpty())
        	orgwideemailId = owea.get(0).Id;
        	
        string query='SELECT Id,HexaBPM__Customer__c,HexaBPM__Customer__r.Portal_Lead_Admin__r.Email,Entry_Permit_Expiry_Date__c,First_Name__c,Last_Name__c FROM HexaBPM__Service_Request__c WHERE Entry_Permit_Expiry_Date__c=:EntryPermitExpDate_30 OR Entry_Permit_Expiry_Date__c=:EntryPermitExpDate_14';
        return database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,list<HexaBPM__Service_Request__c> SRsLst)
    {
        Id orgwideemailId=null;
        set<id> SRIDs = new set<id>();
        list<Notice__c> lstAlerts = new list<Notice__c>();
        
			
        list<Messaging.SingleEmailMessage> notificationsLst = new list<Messaging.SingleEmailMessage>();
        consTobeDeleted = new list<contact>();
        emailslst = new set<string>();
        Savepoint sp = Database.setSavepoint();
        try
        {
            
            for(HexaBPM__Service_Request__c sr : SRsLst)
            {
                list<HexaBPM__Step__c> OutiseidUAE = [SELECT Id FROM HexaBPM__Step__c WHERE HexaBPM__SR__c=:sr.id AND 
                                                                    HexaBPM__Summary__c='Change of Visa Status' AND
                                                                    HexaBPM__Step_Status__c =:system.label.Entry_Permit_Label LIMIT 1];
                
                list<HexaBPM__Step__c> isEmployeeArrived = [SELECT Id FROM HexaBPM__Step__c WHERE HexaBPM__SR__c=:sr.id AND 
                                                                    HexaBPM__Summary__c='Employee Arrival Intimation' AND
                                                                    HexaBPM__Step_Status__c = 'Arrived' LIMIT 1];
                system.debug('====record exists===='+isEmployeeArrived.size());
                if( (!OutiseidUAE.isEmpty()) && isEmployeeArrived.isEmpty())
                {
                    if(sr.Entry_Permit_Expiry_Date__c == system.today().addDays(14))
                    {
                        Notice__c alert = createAlerts(sr);
                        lstAlerts.add(alert);
                        Messaging.SingleEmailMessage mail = constructEmailMessage(sr,14);
                        if(mail != null){
                            notificationsLst.add(mail);
                        }
                        system.debug('===notificationsLst===='+notificationsLst);
                    }
                    else{
                        Messaging.SingleEmailMessage mail = constructEmailMessage(sr,30);
                        if(mail != null){
                            notificationsLst.add(mail);
                        }
                        system.debug('===mail===='+mail);
                    }
                }
            }
            if(!lstAlerts.isEmpty()){
                insert lstAlerts;
            }
            
            if(!notificationsLst.isEmpty()){
                Messaging.sendEmail(notificationsLst);
            }
            system.debug('===consTobeDeleted===='+consTobeDeleted.size());
            if(!consTobeDeleted.isEmpty()){
                delete consTobeDeleted;
            }
        }catch(Exception e)
        {
            Database.rollback(sp);
            //Create a log if there is any exception occurs.
            Log__c log = new Log__c(Cause__c=string.valueOf(e.getCause()),Line_Number__c=e.getLineNumber(),Message__c=e.getMessage(),
                                    Stack_Trace__c=e.getStackTraceString(),Type_Name__c=e.getTypeName(),
                                    User_Email__c=UserInfo.getUserEmail(),User_Name__c=UserInfo.getUserName());
            insert log;
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }
    public Notice__c createAlerts(HexaBPM__Service_Request__c sr)
    {
        Notice__c alert = new Notice__c();
        if(Schema.SObjectType.Notice__c.getRecordTypeInfosByName().get('Alert')!=null && Schema.SObjectType.Notice__c.getRecordTypeInfosByName().get('Alert').getRecordTypeId()!=null)
            alert.RecordTypeId = Schema.SObjectType.Notice__c.getRecordTypeInfosByName().get('Alert').getRecordTypeId();
        alert.Type__c = 'Company Alert';
        alert.Entity__c = sr.HexaBPM__Customer__c;
        alert.Start_Date__c = system.today();
        alert.End_Date__c = sr.Entry_Permit_Expiry_Date__c;
        alert.Expiry_Date__c = sr.Entry_Permit_Expiry_Date__c;
        alert.Status__c = 'Active';
        alert.Severity__c = 'High';
        alert.Sys_Alert_Unique_Key__c = sr.Id+'-'+sr.HexaBPM__Customer__c+'-'+sr.Entry_Permit_Expiry_Date__c;
        alert.Alert_Text__c = '';
        if(sr.First_Name__c !=null)
            alert.Alert_Text__c = sr.First_Name__c;
        if(sr.Last_Name__c !=null){
            if(alert.Alert_Text__c!='')
                alert.Alert_Text__c = alert.Alert_Text__c+' '+sr.Last_Name__c;
            else
                alert.Alert_Text__c = sr.Last_Name__c;
        }
        alert.Alert_Text__c = alert.Alert_Text__c+'\'s Entry Permit is going to expire';
        return alert;
    }
    public Messaging.SingleEmailMessage constructEmailMessage(HexaBPM__Service_Request__c sr,Integer days)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setOrgWideEmailAddressId(orgwideemailId);
        if(sr.HexaBPM__Customer__r.Portal_Lead_Admin__r.Email != null)
        {
            Contact objCon = new Contact();
            objCon.Email = sr.HexaBPM__Customer__r.Portal_Lead_Admin__r.Email;
            objCon.LastName = 'test@adgm.com';
            
            if(emailslst.contains('test@adgm.com')){
            	objCon.Unique_Email__c = 'test'+emailslst.size()+1+'@adgm.com';
            	
            }else
            	objCon.Unique_Email__c = 'test@adgm.com';
            insert objCon;
            
            emailslst.add(objCon.Unique_Email__c);
            consTobeDeleted.add(objCon);
            
            mail.setWhatId(sr.id);
            mail.setToAddresses(new list<string>{sr.HexaBPM__Customer__r.Portal_Lead_Admin__r.Email});
            mail.setTargetObjectId(objCon.Id);
            if(days==30){
                for(EmailTemplate temp:[Select Id from EmailTemplate where DeveloperName='Entry_Permit_Expiration_30']){
                    mail.setTemplateId(temp.Id);
                }
            }else{
                for(EmailTemplate temp:[Select Id from EmailTemplate where DeveloperName='Entry_Permit_Expiration_14']){
                    mail.setTemplateId(temp.Id);
                }
            }
            mail.setSaveAsActivity(false);
            
            return mail;
        }
        return null;
    }
}
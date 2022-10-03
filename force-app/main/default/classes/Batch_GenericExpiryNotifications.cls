/*
    Author      : Azmath
    Date        : 12-Nov-2018
    Description : Batch Class to send generic notifications on expiration of dco detail
    -------------------------------------------------------------------------------------------
*/
global without sharing class Batch_GenericExpiryNotifications implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        date beofore30Days = system.today().addDays(30);
        date beofore14Days = system.today().addDays(14);
        string dStatus = 'Active';
        string eStatus = 'Registered';// 'Residence Visa','Employee Work Permit',
        set<string> documentDetailTypes = new set<string>{'Alcohol Permit','E-Channels','Employee Work Permit(UAE/GCC National)','Establishment Card','P.O.Box','Shisha Permit'};
        string query='Select Id,Contact__c,Account__c,Document_Type__c,Document_Expiry_Date__c,Contact__r.FirstName,Contact__r.LastName,RecordType.DeveloperName from Document_Details__c where (Document_Expiry_Date__c=:beofore30Days or Document_Expiry_Date__c=:beofore14Days) and Document_Type__c IN:documentDetailTypes and Account__c !=null and Document_Status__c=:dStatus and Entity_Status__c=:eStatus';
        return database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,list<Document_Details__c> lstDocumentDetails)
    {
        set<id> AccountIds = new set<Id>();
        map<Id,list<User>> AccountsWithPortalUsers                  = new map<Id,list<User>>();
        list<Messaging.SingleEmailMessage> notificationsLst         = new list<Messaging.SingleEmailMessage>();
        
        //1. Createa a map of Account and Doc Details..
        for(Document_Details__c dd : lstDocumentDetails)
        {
            AccountIds.add(dd.Account__c);
        }
        //2. Create a map of Account and Portal Users..
        if(!AccountIds.isEmpty())
        {
            set<id> conIds = new set<Id>();
            for(Contact con : [Select Id,AccountId FROM Contact where AccountId IN:AccountIds and RecordType.Name = 'Contact - Portal User']){
                conIds.add(con.id);
            }
            
            for(User usr : [Select id,Contact.AccountId FROM User where ContactId IN:conIds and Contact.AccountId != null and isActive = true]){
                if(AccountsWithPortalUsers.containsKey(usr.Contact.AccountId)){
                    AccountsWithPortalUsers.get(usr.Contact.AccountId).add(usr);
                }else{
                    AccountsWithPortalUsers.put(usr.Contact.AccountId,new list<User>{usr});
                }
            }
        }
        
        //3. Construct email with Recipients..
        if(!AccountsWithPortalUsers.isEmpty())
        {
            list<EmailTemplate> temp = [Select Id from EmailTemplate where DeveloperName='Generic_Email_Template_Of_Doc_Expiration' LIMIT 1];
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:Label.OrgWideEmailAddress];
            if(!temp.isEmpty())
            {
                for(Document_Details__c dd : lstDocumentDetails)
                {
                    if(AccountsWithPortalUsers.containsKey(dd.Account__c))
                    {
                        for(User u : AccountsWithPortalUsers.get(dd.Account__c))
                        {
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setTargetObjectId(u.Id);
                            mail.setWhatId(dd.id);
                            mail.setTemplateId(temp[0].Id);
                            mail.setSaveAsActivity(false);
                            if(!owea.isEmpty())
                            mail.setOrgWideEmailAddressId(owea.get(0).Id);
                            notificationsLst.add(mail);
                        }
                    }
                }
            }
        }
        if(!notificationsLst.isEmpty()){
             Messaging.sendEmail(notificationsLst);
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }
    
}
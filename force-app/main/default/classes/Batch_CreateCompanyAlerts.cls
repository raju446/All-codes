/*
    Author      : Durga Prasad
    Date        : 02-Jan-2018
    Description : Batch Class to create the Company Alerts
    -------------------------------------------------------------------------------------------
*/
global without sharing class Batch_CreateCompanyAlerts implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        //date EmployeeDocumentsExpiryDate = system.today().addDays(30);
        //list<Document_Details__c> lstDocuments = new list<Document_Details__c>();
        /*for(Document_Details__c DD:[Select Id,Contact__c,Account__c,Document_Type__c,Document_Expiry_Date__c,Contact__r.FirstName,Contact__r.LastName,RecordType.DeveloperName from Document_Details__c where Document_Expiry_Date__c=:CompanyDocumentExpiryDate and RecordType.DeveloperName='Entity_Documents' and Document_Status__c='Active' and Account__c!=null]){
            lstDocuments.add(DD);
        }
        for(Document_Details__c DD:[Select Id,Contact__c,Account__c,Document_Type__c,Document_Expiry_Date__c,Contact__r.FirstName,Contact__r.LastName,RecordType.DeveloperName from Document_Details__c where Document_Expiry_Date__c=:EmployeeDocumentsExpiryDate and RecordType.DeveloperName='Employee_Documents' and Document_Status__c='Active' and Account__c!=null]){
            lstDocuments.add(DD);
        }*/
        date DocumentExpiryDate = system.today().addDays(14);
        set<string> documentDetailTypes = new set<string>{'Alcohol Permit','E-Channels','Employee Work Permit','Establishment Card','P.O.Box','Residence Visa','Shisha Permit'};
        string workPermitGCCNational = 'Employee Work Permit(UAE/GCC National)';
        string query='Select Id,Contact__c,Account__c,Document_Type__c,Document_Expiry_Date__c,Contact__r.FirstName,Contact__r.LastName,RecordType.DeveloperName from Document_Details__c where Document_Expiry_Date__c=:DocumentExpiryDate and Account__c !=null and ((Document_Type__c IN:documentDetailTypes AND Document_Status__c = \'Active\') OR (Document_Type__c = \'Employee Work Permit(UAE/GCC National)\' and Employment_Status__c = \'Active\'))';
        return database.getQueryLocator(query);
        
    }
    global void execute(Database.BatchableContext BC,list<Document_Details__c> lstDocumentDetails){
        list<Notice__c> lstAlerts = new list<Notice__c>();
        for(Document_Details__c dd:lstDocumentDetails){
            Notice__c alert = new Notice__c();
            if(Schema.SObjectType.Document_Details__c.getRecordTypeInfosByName().get('Alert')!=null && Schema.SObjectType.Document_Details__c.getRecordTypeInfosByName().get('Alert').getRecordTypeId()!=null)
                alert.RecordTypeId = Schema.SObjectType.Document_Details__c.getRecordTypeInfosByName().get('Alert').getRecordTypeId();
            alert.Type__c = 'Company Alert';
            alert.Entity__c = dd.Account__c;
            alert.Start_Date__c = system.today();
            alert.End_Date__c = dd.Document_Expiry_Date__c;
            alert.Expiry_Date__c = dd.Document_Expiry_Date__c;
            alert.Status__c = 'Active';
            alert.Severity__c = 'High';
            alert.Document_Detail__c = dd.Id;
            alert.Sys_Alert_Unique_Key__c = dd.Id+'-'+dd.Account__c+'-'+dd.Document_Expiry_Date__c;
            if(dd.Contact__c!=null){
                alert.Alert_Text__c = '';
                if(dd.Contact__r.FirstName!=null)
                    alert.Alert_Text__c = dd.Contact__r.FirstName;
                if(dd.Contact__r.LastName!=null){
                    if(alert.Alert_Text__c!='')
                        alert.Alert_Text__c = alert.Alert_Text__c+' '+dd.Contact__r.LastName;
                    else
                        alert.Alert_Text__c = dd.Contact__r.LastName;
                }
                alert.Alert_Text__c = alert.Alert_Text__c+'\'s '+dd.Document_Type__c+' is expiring';
            }else if(dd.Account__c!=null){
                alert.Alert_Text__c = 'Company\'s '+dd.Document_Type__c+' is expiring';
            }
            lstAlerts.add(alert);
        }
        try{
            Schema.SObjectField UpsertFld = Notice__c.Fields.Sys_Alert_Unique_Key__c;
            list<Database.UpsertResult> UpsertAlertsList = Database.upsert(lstAlerts,UpsertFld,false);
        }catch(Exception e){
            
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }
}
global without sharing class Batch_ReCreateOldFTJVs implements Database.Batchable<sObject>{

    global List<sObject> start(Database.BatchableContext BC){
        
        Date startDate = Date.newInstance(2021, 12, 01);
        List<Fund_Transfer__c> listFund_Transfer = new List<Fund_Transfer__c>();
        listFund_Transfer = [select id FROM Fund_Transfer__c WHERE GL_Date__c >= :startDate AND Journal_Created__c = true];
        
        return listFund_Transfer;
    }
    
    global void execute(Database.BatchableContext BC,List<Fund_Transfer__c> listFund_Transfer){
        
        BM_JournalEntryEngine.fundTransferJournalEntries(new List<Id>{listFund_Transfer[0].Id});
        
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
}
global without sharing class Batch_PushJEsToOracle_New implements Database.Batchable<sObject>, Database.AllowsCallouts
{
    global List<sObject> start(Database.BatchableContext BC)
    {
        List<Journal_Header__c> jhLst = new List<Journal_Header__c>();
        if(System.Label.EnableFusionIntegration == 'True' || test.isRunningTest()){
            Set<Date> avaDate = BM_JournalEntryEngine.getActiveGLDates();
            for(Journal_Header__c objSR : [SELECT Id FROM Journal_Header__c WHERE (Oracle_Status__c = 'Draft' /*OR Oracle_Status__c = 'Failed'*/) AND Sync_Not_Required__c = false AND GL_Date__c IN : avaDate]){
                jhLst.add(objSR);    
            }
        }
        
        return jhLst;   
        
    }
    
    global void execute(Database.BatchableContext BC,List<Journal_Header__c> jhLst){
        set<id> Recids = new set<id>();
        for(Journal_Header__c objJH : jhLst){
            Recids.add(objJH.id);
        }
        
        PushJEstoOracle_New.PushJEToOracle(Recids);  
        
    }
    
    global void finish(Database.BatchableContext BC){ 
    }
}
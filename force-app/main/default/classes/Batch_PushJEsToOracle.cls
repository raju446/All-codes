global without sharing class Batch_PushJEsToOracle implements Database.Batchable<sObject>, Database.AllowsCallouts{
    global List<sObject> start(Database.BatchableContext BC){
        List<Journal_Header__c> lstServiceRequests = new List<Journal_Header__c>();
        for(Journal_Header__c objSR : [SELECT Id FROM Journal_Header__c WHERE Oracle_Status__c = 'Draft' AND Sync_Not_Required__c = false]){
            lstServiceRequests.add(objSR);    
        }
        return lstServiceRequests;
    }
    global void execute(Database.BatchableContext BC,List<Journal_Header__c> lstServiceRequests){
        for(Journal_Header__c objSR : lstServiceRequests){
            PushJEstoOracle.PushJEToOracle(objSR.Id);
        }
    }
    global void finish(Database.BatchableContext BC){ 
    }
}
/*
    Author      : Kim Noceda
    Date        : 22-Nov-2017
    Description : Batch job to get all PO Box records with the expiry date plus 30 days is equal to current date and update the status Cancelled.
    --------------------------------------------------------------------------------------
*/
global without sharing class SetPOBoxtoCancelledBatch implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, Status__c, Start_Date__c, Expiry_Date__c, Cancelled_Date__c, Expiry_Date_Add_30_Days__c FROM PO_Box__c WHERE Expiry_Date_Add_30_Days__c=TODAY]);
    }
    
    global void execute(Database.BatchableContext BC,List<PO_Box__c> poBoxList){   
        System.debug('##POBOXLIST: '+poBoxList);
        
        Set<Id> poBoxIds = new Set<Id>(); 
        
        List<PO_Box__c> poBoxListToUpdate = new List<PO_Box__c>();
        for(PO_Box__c poBox : poBoxList){
            poBox.Status__c = 'Cancelled';
            poBox.Start_Date__c = null;
            poBox.Expiry_Date__c = null;
            poBox.Cancelled_Date__c = System.Today();
            poBox.Account__c = null;
            
            poBoxIds.add(poBox.Id);
            poBoxListToUpdate.add(poBox);
        }
        
        /*List<Account> entityListToUpdate = new List<Account>();
        for(Account acc : [SELECT Id, PO_Box__c FROM Account WHERE PO_Box__c IN :poBoxIds]){
            acc.PO_Box__c = null;
            entityListToUpdate.add(acc);
        }*/
        
        try{
            if(!poBoxListToUpdate.isEmpty()){
                update poBoxListToUpdate;
            }
            
            /*if(!entityListToUpdate.isEmpty()){
                update entityListToUpdate;
            }*/
        } catch(Exception e){
        }
    }
    
    global void finish(Database.BatchableContext BC){}
}
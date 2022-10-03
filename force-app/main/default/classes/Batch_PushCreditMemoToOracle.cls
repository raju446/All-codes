/**
 * @File Name          : Batch_PushCreditMemoToOracle.cls
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 4/8/2020, 2:02:50 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/8/2020   Jayanta Karmakar     Initial Version
**/
global with sharing class Batch_PushCreditMemoToOracle implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable{
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id FROM Invoice__c WHERE Recordtype.Name = \'Credit Memo\' AND Oracle_Invoice_Id__c = null and (Status__c = \'Success\' OR Status__c = \'Approved\')';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<Invoice__c> scope){
        for(Invoice__c eachInvoice : scope){
            //CreditMemoUtil.pushToOracleCreditMemo(new List<String>{eachInvoice.Id});
            CreditMemoUtil_New.updateCreditMemoAndCreateJVs(new List<String>{eachInvoice.Id});
        }
    }
    global void finish(Database.BatchableContext BC){
      
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new Batch_PushCreditMemoToOracle(), 1);
    }
}
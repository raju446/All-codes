/**
 * @File Name          : Batch_PushAdjustmentToOracle.cls
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 4/8/2020, 4:06:24 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/8/2020   Jayanta Karmakar     Initial Version
**/
global with sharing class Batch_PushAdjustmentToOracle implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable{
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id FROM Invoice_Line_Item__c WHERE Oracle_Adjustment_No__c = null AND (Status__c = \'Success\' OR Status__c = \'Approved\')';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<Invoice_Line_Item__c> scope){
        for(Invoice_Line_Item__c eachInvoiceLI : scope){
            InvoiceUtil.PushAdjToOracle(eachInvoiceLI.Id);
        }
    }
    global void finish(Database.BatchableContext BC){
      
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new Batch_PushAdjustmentToOracle(), 1);
    }
}
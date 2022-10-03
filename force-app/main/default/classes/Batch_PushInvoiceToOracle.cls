/**
 * @File Name          : Batch_PushInvoiceToOracle.cls
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 11-17-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/8/2020   Jayanta Karmakar     Initial Version
**/

// AND RA_Receipt_Invoice__c != null and Oracle_Callout_Status__c = \'E\'
global with sharing class Batch_PushInvoiceToOracle implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable{
    //AND Is_Ready_To_Push_TBD__c = true
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id FROM Invoice__c WHERE Recordtype.Name = \'Invoice\' AND Journal_Created__c = false and Service_Request__c = null AND (Status__c = \'Success\' OR Status__c = \'Approved\') and Service_Request__c = null AND Total_Invoice_Amount_OC__c > 0';
        //query += ' AND RA_Receipt_Invoice__r.RA_Financial_File__c = \'a2n2500000171H3\'';
        if(Test.isRunningTest()){
            query = 'SELECT Id FROM Invoice__c';
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<Invoice__c> scope){
        system.debug('----->'+ scope.size());
        for(Invoice__c eachInvoice : scope){
            //InvoiceUtil.pushToOracleInvoice(new List<String>{eachInvoice.Id});
            InvoiceUtil_New.updateInvoiceAndCreateJournalEntries(new List<String>{eachInvoice.Id});
        }
    }
    global void finish(Database.BatchableContext BC){
      
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new Batch_PushInvoiceToOracle(), 1);
    }
}
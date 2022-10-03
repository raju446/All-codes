/*
    Author      : Kim Noceda
    Date        : 30-Jan-2017
    Description : Batch class to Push Receipt records with Status is 'Success' or 'Approved' and Orcale Party Id is blank
    --------------------------------------------------------------------------------------
	 * @Change History
     * Author       	Date            Description
	 * Yogesh Mahajan	26jan2020		Added new webservice call

*/
global without sharing class Batch_PushReceiptsToOracle implements Database.Batchable<sObject>, Database.AllowsCallouts{
    global List<sObject> start(Database.BatchableContext BC){
        List<Receipt__c> lstReceipts = new List<Receipt__c>();
        //select id,oracle_receipt_id__c,RA_Receipt_Invoice__r.Oracle_Invoice_Id__c from Receipt__c where RA_Receipt_Invoice__c != null and RA_Receipt_Invoice__r.Oracle_Invoice_Id__c != null and RA_Receipt_Invoice__r.Oracle_Receipt_Id__c = null
        //
        //SELECT Id FROM Receipt__c 
                          //  WHERE (Status__c = 'Success' OR Status__c = 'Approved') 
                           // AND (Oracle_Receipt_Id__c = '' OR Oracle_Receipt_Id__c = null) and amount__c > 0
       //AND RA_Receipt_Invoice__c != null and RA_Receipt_Invoice__r.Oracle_Invoice_Id__c != null and RA_Receipt_Invoice__r.Oracle_Receipt_Id__c = null
        
        if(Test.isRunningTest()){
            for(Receipt__c rp : [SELECT Id FROM Receipt__c]){
                lstReceipts.add(rp);
            }
        } else {
            for(Receipt__c rp : [SELECT Id FROM Receipt__c WHERE (Status__c = 'Success' OR Status__c = 'Approved') AND Journal_Created__c = false and amount__c > 0 AND To_Be_Pushed_To_ERP_TBD__c = true]){
                lstReceipts.add(rp);    
            }
        }
        return lstReceipts;
    }
     global void execute(Database.BatchableContext BC,List<Receipt__c> lstReceipts){
        for(Receipt__c rp : lstReceipts){
            ///* comments by yogesh on 26jan2020
            //ReceiptUtil.PushReceiptToOracle(rp.Id);

            //ReceiptUtil.Prod_PushReceiptToOracle(rp.Id);
            // Added new web service call
            
            ReceiptUtil.UpdateAmountAndCreateJournalEntries(new List<String>{rp.id});
            /*if(system.label.Use_New_Receipt_Oracle_Service == 'Yes'){
                ReceiptUtil.PushReceiptToOracle_New(rp.Id);
            } else {
               // ReceiptUtil.PushReceiptToOracle(rp.Id);
                ReceiptUtil.Prod_PushReceiptToOracle(rp.Id);
            }*/
            
        }
     }
     global void finish(Database.BatchableContext BC){
      
    }
}
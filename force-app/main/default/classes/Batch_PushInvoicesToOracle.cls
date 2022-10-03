/*
    Author      : Kim Noceda
    Date        : 26-Apr-2018
    Description : Batch class to Push invoice records of the service requests which are open and oracle invoice number is blank
    --------------------------------------------------------------------------------------
	* @Change History
     * Author       	Date            Description
	 * Yogesh Mahajan	07Feb2020		Added new webservice call
*/
global without sharing class Batch_PushInvoicesToOracle implements Database.Batchable<sObject>, Database.AllowsCallouts{
    global List<sObject> start(Database.BatchableContext BC){
        List<HexaBPM__Service_Request__c> lstServiceRequests = new List<HexaBPM__Service_Request__c>();
        /*[SELECT Id FROM HexaBPM__Service_Request__c 
                                                WHERE (HexaBPM__IsClosedStatus__c = TRUE 
                                                OR HexaBPM__IsCancelled__c = TRUE 
                                                OR HexaBPM__Is_Rejected__c = TRUE)
                                                AND (Oracle_Invoice_Number__c = null OR Oracle_Invoice_Number__c = '')]*/
        for(HexaBPM__Service_Request__c objSR : [SELECT Id,HexaBPM__Customer__r.Is_ADGM_Company__c FROM HexaBPM__Service_Request__c 
                                                WHERE (HexaBPM__IsClosedStatus__c = TRUE 
                                                OR HexaBPM__IsCancelled__c = TRUE 
                                                OR HexaBPM__Is_Rejected__c = TRUE)
                                                AND (Oracle_Invoice_Number__c = null OR Oracle_Invoice_Number__c = '')
                                                 AND HexaBPM__Customer__r.Is_ADGM_Company__c = false]){
            lstServiceRequests.add(objSR);    
        }
        return lstServiceRequests;
    }
     global void execute(Database.BatchableContext BC,List<HexaBPM__Service_Request__c> lstServiceRequests){
        for(HexaBPM__Service_Request__c objSR : lstServiceRequests){
            //UAT Sandbox
            //WS_Inf_InvoiceProcess_Helper.ConstructInvoicePayload(objSR);
            //PROD
            //// comments by yogesh on 07Feb2020
            //WS_ERP_CreateInvoiceHelper.InvokeProcess(objSR.Id);
            // Add new web service call
            /*if(System.Label.Use_New_Invoice_Oracle_Service == 'Yes'){
            	InvoiceUtil.pushToOracle(new List<string>{objSR.Id});
            } else {
                WS_ERP_CreateInvoiceHelper.InvokeProcess(objSR.Id);
            }*/
            invoiceutil.createLineItemAddApplicationJournalEntries(new List<string>{objSR.Id});
        }
     }
     global void finish(Database.BatchableContext BC){
      
    }
}
/*
    Author      : Durga Prasad
    Date        : 07-Feb-2018
    Description : Custom code to create invoice in Oracle System on Closure of the SR
    --------------------------------------------------------------------------------------
    * @Change History
     * Author           Date            Description
     * Yogesh Mahajan   07Feb2020       Added new webservice call
*/
global without sharing class CC_SendInvoiceToOracle implements HexaBPM.iCustomCodeExecutable {
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step.HexaBPM__SR__c!=null){ 
            String srId = step.HexaBPM__SR__c;
            system.debug('SR ======>'+ step.HexaBPM__SR__c);
            /*List<Invoice__c> invoices = [SELECT id,gl_date__c from Invoice__c where Service_Request__c =: step.HexaBPM__SR__c LIMIT 1];
            if(invoices.size() == 1){
                invoices[0].GL_Date__c = datetime.now();
                invoices[0].Invoice_Date__c = datetime.now();
                update invoices; 
            }*/
            //InvoiceUtil_New.updateInvoiceAndCreateJournalEntries(new List<String>{eachInvoice.Id});
            InvoiceUtil.createLineItemAddApplicationJournalEntries(new List<string>{srId});
            //PushInvoiceToOracle_Future(step.HexaBPM__SR__c);
        }
            
        return strResult;
    }
    /*
        Method Name     :   PushInvoiceToOracle_Future
        Description     :   Http Callout to Informatica Cloud to create Invoice in Oracle
        Input Params    :   Service Request Record Id
    */
    @Future(callout=true)
    public static void PushInvoiceToOracle_Future(string ServiceRequestId){
        /*if(System.Label.BM_Stop_Invoice_Integration == 'No'){
            if(System.Label.Use_New_Invoice_Oracle_Service == 'Yes'){
                InvoiceUtil.pushToOracle(new List<string>{ServiceRequestId});
            } else {
                WS_ERP_CreateInvoiceHelper.InvokeProcess(ServiceRequestId);
            }
        }*/
        InvoiceUtil.createLineItemAddApplicationJournalEntries(new List<string>{ServiceRequestId});
               
         //// comments by yogesh on 07Feb2020
        //WS_Inf_InvoiceProcess.InvokeProcess(ServiceRequestId);//uat
        // Add new web service call
       //------ InvoiceUtil.pushToOracle(new List<string>{ServiceRequestId});
        //WS_ERP_CreateInvoiceHelper.InvokeProcess(ServiceRequestId);
    }
}
/**
 * @File Name          : PushAdjustmentToOracle.cls
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 5/15/2020, 3:13:15 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/4/2020   Jayanta Karmakar     Initial Version
**/
public without sharing class PushAdjustmentToOracle {
    
    @AuraEnabled
    public static string submitForApproval(String adjustmentId) {
        if(adjustmentId <> null && adjustmentId <> '') {
            List<Invoice_Line_Item__c> listInvoice_Line_Item = new List<Invoice_Line_Item__c>();
            listInvoice_Line_Item = [SELECT Id, Status__c FROM Invoice_Line_Item__c WHERE id = :adjustmentId ];
            if(listInvoice_Line_Item <> null && listInvoice_Line_Item.size() > 0 && (listInvoice_Line_Item[0].Status__c == 'Draft' || listInvoice_Line_Item[0].Status__c == 'Rejected')) {
                List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting Adjustment for approval ');
                
                req1.setObjectId(adjustmentId);
                requests.add(req1);
                if(requests <> null && requests.size() > 0 ) {
                    List<Approval.ProcessResult> processResults = new List<Approval.ProcessResult>();
                    try {
                        processResults = Approval.process(requests, true);
                    }catch (exception ex) {
                        System.debug('Exception Is ' + ex.getMessage());
                        //Database.rollback( sp );
                        return  ex.getMessage();
                    }
                }
                return 'Success';
            } else if(listInvoice_Line_Item <> null && listInvoice_Line_Item.size() > 0 && listInvoice_Line_Item[0].Status__c == 'Under Review') {
                return 'Record is already submitted for approval';
            } else if(listInvoice_Line_Item <> null && listInvoice_Line_Item.size() > 0 && (listInvoice_Line_Item[0].Status__c == 'Invoiced' || listInvoice_Line_Item[0].Status__c == 'Approved' )) {
                return 'Record is already processed';
            }
        }
        
        
        return 'Record not found';
    }
    
    
    @AuraEnabled
    public static string getDefaultValues(String invoiceId) {
        try{
            string authority = '';
            for(Invoice__c obj : [select Id,Entity__c,Entity__r.Source_System_Name__c, Entity__r.Oracle_Site_Id__c,Oracle_Invoice_Id__c from Invoice__c where Id=: invoiceId ]){
                /*if(obj.Oracle_Invoice_Id__c != null)
                    authority = obj.Entity__r.Oracle_Site_Id__c;
                else
                    authority = 'Not synced';*/
                return obj.Entity__r.Oracle_Site_Id__c;

            }
            return authority;
        }catch(Exception ex){            
        }
    	return null;
    }
    
    @AuraEnabled
    public static ResponseWrapper pushAdjustmentToOracle (String adjustmentId) {

        InvoiceUtil.AdjustmentResponseWrapper objAdResponseWrapper = new InvoiceUtil.AdjustmentResponseWrapper();
        objAdResponseWrapper = InvoiceUtil.PushAdjToOracle(adjustmentId);
        ResponseWrapper objResponseWrapper = new ResponseWrapper();
        if(objAdResponseWrapper.P_OP_ADJUSTMENT_NO!=null && objAdResponseWrapper.P_OP_ADJUSTMENT_NO!= '') {
            objResponseWrapper.P_OP_STATUS = 'Success';
            objResponseWrapper.P_OP_ERROR_MSG = objAdResponseWrapper.P_OP_ERROR_MSG;
        } else {
            objResponseWrapper.P_OP_STATUS = 'Error';
            objResponseWrapper.P_OP_ERROR_MSG = objAdResponseWrapper.P_OP_ERROR_MSG;
        }
            
        return objResponseWrapper;
    }
    
    @AuraEnabled
    public static Invoice_Line_Item__c getAdjustmentDetails(String recordId){
        Invoice_Line_Item__c listInvoice_Line_Item = [select id, Status__c, Invoice__r.Oracle_Invoice_Id__c from Invoice_Line_Item__c where id =:recordId AND recordtype.name = 'Adjustment'  ];
        return listInvoice_Line_Item;
    }
    
    @AuraEnabled
    public static string validateAdjustment(String recordId) {
        List<Invoice_Line_Item__c> listInvoice_Line_Item = new List<Invoice_Line_Item__c>();
        listInvoice_Line_Item = [select id, Status__c, Invoice__r.Oracle_Invoice_Id__c from Invoice_Line_Item__c where id =:recordId AND recordtype.name = 'Adjustment'  ];
        if(listInvoice_Line_Item <> null && listInvoice_Line_Item.size() > 0 && listInvoice_Line_Item[0].Status__c == 'Draft') {
            return 'Success';
        } else if(listInvoice_Line_Item <> null && listInvoice_Line_Item.size() > 0 && (listInvoice_Line_Item[0].Invoice__r.Oracle_Invoice_Id__c == null || listInvoice_Line_Item[0].Invoice__r.Oracle_Invoice_Id__c == '') ) {
            return 'Related invoice is not pushed to oracle yet';
        }else if(listInvoice_Line_Item <> null && listInvoice_Line_Item.size() > 0 && listInvoice_Line_Item[0].Status__c =='Invoiced' ) {
            return 'Adjustment already pushed to oracle';
        }
        return '';
    }
    
    public class ResponseWrapper {
        @AuraEnabled public string P_OP_STATUS;
        @AuraEnabled public string P_OP_ERROR_MSG;
    }
}
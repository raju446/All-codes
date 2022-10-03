/**
 * @description       : 
 * @author            : Jayanta Karmakar
 * @group             : 
 * @last modified on  : 02-16-2021
 * @last modified by  : Jayanta Karmakar
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   12-27-2020   Jayanta Karmakar   Initial Version
**/
public without sharing class ApproveRejectReceiptController {
    @AuraEnabled
    public static ApprovalWrapper returnProcessInstance(String receiptId){
        ApprovalWrapper pWrap = new ApprovalWrapper();
        try {
            List<Receipt__c> receipts = [SELECT Id,Payment_Status__c,Amount__c,Original_Receipt_Amount__c FROM Receipt__c WHERE Id =: receiptId LIMIT 1];
            List<processinstance> processInstances = [select id,Status from processinstance where TargetObjectId = : receiptId];
            if(processInstances.size() > 0){
                for (processinstance var : processInstances) {
                    if(var.Status == 'Pending'){
                        pWrap.recId = var.Id;
                        pWrap.isSuccess = true;
                        pWrap.receiptAmount = receipts[0].Amount__c;
                        pWrap.selectedPaymentStatus = receipts[0].Payment_Status__c;
                        pWrap.originalAmount = receipts[0].Original_Receipt_Amount__c;
                        for(Schema.PicklistEntry f : Receipt__c.Payment_Status__c.getDescribe().getPicklistValues()){
                            pWrap.paymentStatusVals.add(new PicklistVals(f.getLabel(), f.getValue()));
                        }
                        break;
                    }
                }
            } else {
                pWrap.msg = 'No Pending Approval Process Found.';
            }
        }
        catch (Exception ex) {
            pWrap.msg = ex.getMessage();
        }
        return pWrap;
    }
    
    @AuraEnabled
    public static ApprovalWrapper approveOrRejectReceipt(String recId, String act, String cmnt, String payeeName, String paymentStatus, Decimal rctAmount, Decimal originalAmount){
        System.debug('recId----->'+recId);
        System.debug('act----->'+act);
        System.debug('cmnt----->'+cmnt);
        System.debug('payeeName----->'+payeeName);
        ApprovalWrapper pWrap = new ApprovalWrapper();
        Savepoint sp = Database.setSavepoint();
        try {
            
            //if(processResults[0].isSuccess()){
                if(rctAmount < originalAmount){
                    List<Related_Invoice_Receipt__c> relatedInvRec = [SELECT id,Amount_Applied__c,Invoice__r.Invoice_Balance__c FROM Related_Invoice_Receipt__c WHERE Receipt__c =: recId];
                    Decimal remainingBalance = rctAmount;
                    for(Related_Invoice_Receipt__c eachRec : relatedInvRec){
                        if(remainingBalance <= 0){
                            eachRec.Amount_Applied__c = 0;
                        }else if(remainingBalance >= eachRec.Invoice__r.Invoice_Balance__c){
                            eachRec.Amount_Applied__c = eachRec.Invoice__r.Invoice_Balance__c;
                            remainingBalance = remainingBalance - eachRec.Invoice__r.Invoice_Balance__c;
                        } else {
                            eachRec.Amount_Applied__c = remainingBalance;
                            remainingBalance = 0;
                        }
                    }
                    update relatedInvRec;
                    system.debug('relatedInvRec==>>' + relatedInvRec);
                }
                
                update new Receipt__c(Id = recId, Payee_Name__c = payeeName,Rejection_Comments__c = cmnt, Payment_Status__c = paymentStatus, Amount__c = rctAmount);
                system.debug('rctAmount');
                
                List<ProcessInstanceWorkitem> workItems = [SELECT Id, ProcessInstanceId,ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :recId];
                List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
                for(ProcessInstanceWorkitem workItem : workItems){
                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                    req.setWorkitemId(workItem.Id);
                    req.setAction(act);
                    req.setComments(cmnt);
                    requests.add(req);
                }
                Approval.ProcessResult[] processResults = Approval.process(requests);
                
                
                pWrap.recId = processResults[0].getInstanceId();
                pWrap.msg = 'Receipt '+act;
                pWrap.isSuccess = true;
            //}
        } catch (Exception ex) {
            pWrap.msg = ex.getMessage();
            Database.rollback(sp);
            System.debug('===>'+ex.getStackTraceString());
            System.debug('===>'+ex.getLineNumber());
        }
        return pWrap;
    }
    
    public class ApprovalWrapper{
        @AuraEnabled
        public string msg;
        @AuraEnabled
        public string recId;
        @AuraEnabled
        public boolean isSuccess;
        @AuraEnabled
        public decimal receiptAmount;
        @AuraEnabled
        public decimal originalAmount;
        @AuraEnabled
        public List<PicklistVals> paymentStatusVals;
        @AuraEnabled
        public string selectedPaymentStatus;
        public ApprovalWrapper(){
            isSuccess = false;
            paymentStatusVals = new List<PicklistVals>{new PicklistVals('--None--','')};
        }
    }
    
    public class PicklistVals{
        @AuraEnabled
        public string txt;
        @AuraEnabled
        public string val;
        public PicklistVals(String inpTxt, String inpVal){
            txt = inpTxt;
            val = inpVal;
        }
    }
}
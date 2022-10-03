/**
 * @File Name          : WS_FetchRefundStatusService.cls
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 08-11-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    7/10/2020   Jayanta Karmakar     Initial Version
**/
global class WS_FetchRefundStatusService {
    webservice static ResponseDetails fetchRefundSts(String Source_Reference){
        ResponseDetails resp = new ResponseDetails();
        resp.SourceReference = Source_Reference;
        try{
            if(Source_Reference == null || Source_Reference == ''){
                resp.Messages = 'Refund Request Source_Reference can not be null.';
                resp.Success = false;
                resp.Status_Code = '600';
            } else {
                Refund__c refundObj = [SELECT Id,Status__c,AP_Invoice_No__c,Oracle_Message__c,Payment_Number__c,Payment_Status__c from Refund__c where Source_Refund_Reference_No__c =: Source_Reference LIMIT 1];
                resp.Messages = 'Refund Record Found.';
                resp.Success = true;
                resp.Status_Code = '200';
                resp.Refund_Request_Status = refundObj.Status__c == null ? '' : refundObj.Status__c;
                resp.AP_Invoice_No = refundObj.AP_Invoice_No__c == null? '' :refundObj.AP_Invoice_No__c;
                resp.Payment_Number = refundObj.Payment_Number__c == null? '' :refundObj.Payment_Number__c;
                resp.Payment_Status = refundObj.Payment_Status__c == null ? '' :refundObj.Payment_Status__c;
                resp.Oracle_Msg = refundObj.Oracle_Message__c == null ? '': refundObj.Oracle_Message__c;
            }
        } catch (Exception ex){
            resp.Messages = ex.getMessage();
            resp.Success = false;
            resp.Status_Code = '600';
        }
        system.debug('Response ----->'+ resp);
        return resp;
    }
    
    global class ResponseDetails{
        webservice string SourceReference;
        webservice boolean Success;
        webservice string Messages; 
        webservice string Status_Code;
        webservice string Refund_Request_Status;
        webservice string AP_Invoice_No;
        webservice string Payment_Number;
        webservice string Payment_Status;
        webservice string Oracle_Msg;
        global ResponseDetails(){
            Refund_Request_Status = '';
            AP_Invoice_No = '';
            Payment_Number = '';
            Payment_Status = '';
            Oracle_Msg = '';
        }
    }
}
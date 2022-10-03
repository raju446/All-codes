/**
 * @File Name          : WS_FetchReceiptStatusService.cls
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 12-21-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    7/9/2020   Jayanta Karmakar     Initial Version
**/
global without sharing class WS_FetchReceiptStatusService {
    webservice static ResponseDetails fetchReceiptSts(String Receipt_Id){
        ResponseDetails resp = new ResponseDetails();
        resp.ReceiptId = Receipt_Id;
        try{
            if(Receipt_Id == null || Receipt_Id == ''){
                resp.Messages = 'Receipt Id can not be null.';
                resp.Success = false;
                resp.Status_Code = '600';
            } else {
                Receipt__c recpt = [SELECT id,Payee_Name__c,Rejection_Comments__c,Status__c,Oracle_Receipt_Id__c,Message__c,Payment_Status__c,Original_Receipt_Amount__c,Amount__c from Receipt__c where Source_Receipt_Id__c =: Receipt_Id];    
                resp.Messages = 'Receipt record found.';
                resp.Success = true;
                resp.Status_Code = '200';
                resp.Receipt_Status = recpt.Status__c;
                resp.Payment_Status = recpt.Payment_Status__c;
                resp.Original_Amount = recpt.Original_Receipt_Amount__c != null ? String.valueOf(recpt.Original_Receipt_Amount__c) : '';
                resp.Receipt_Amount = recpt.Amount__c != null ? String.valueOf(recpt.Amount__c) : '';
                resp.Oracle_Receipt_Id = recpt.Oracle_Receipt_Id__c != null? recpt.Oracle_Receipt_Id__c : '';
                resp.Oracle_Msg = recpt.Message__c != null ? recpt.Message__c : '';
                resp.Payee_Name = recpt.Payee_Name__c != null ? recpt.Payee_Name__c : '';
                resp.Rejection_Comments = recpt.Rejection_Comments__c != null ? recpt.Rejection_Comments__c : '';
                
                system.debug(resp);
            }
        }catch(Exception ex){
            resp.Messages = ex.getMessage();
            resp.Success = false;
            resp.Status_Code = '600';
        }
        return resp;
    }
    
    global class ResponseDetails{
        webservice string ReceiptId;
        webservice boolean Success;
        webservice string Messages; 
        webservice string Status_Code;
        webservice string Receipt_Status;
        webservice string Oracle_Receipt_Id;
        webservice string Oracle_Msg;
        webservice string Payment_Status;
        webservice string Original_Amount;
        webservice string Receipt_Amount;
        webservice string Payee_Name;
        webservice string Rejection_Comments;
        global ResponseDetails(){
            Status_Code = '';
            Receipt_Status = '';
            Oracle_Receipt_Id = '';
            Payment_Status = '';
            ReceiptId = '';
            Messages = '';
            Oracle_Msg = '';
            Payee_Name = '';
            Rejection_Comments = '';
        }
    }
}
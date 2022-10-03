/*
    Author      : Durga Prasad
    Date        : 18-Jan-2018
    Description : Webservice class to create receipt in salesforce, this will be exposed as wsdl for Oracle ERP
    --------------------------------------------------------------------------------------------------
*/
global without sharing class WS_CreateReceipt {
    webservice static ResponseDetails PushReceiptInformation(ReceiptInformation Receipt) {
        ResponseDetails objResp = new ResponseDetails();
        objResp.Oracle_Party_Id = Receipt.OraclePartyId;
        Receipt__c objReceipt = new Receipt__c();
        for(Account acc:[Select Id,Oracle_Party_Id__c from Account where Oracle_Party_Id__c=:Receipt.OraclePartyId]){
            objReceipt.Entity__c = acc.Id;
        }
        if(objReceipt.Entity__c==null){
            objResp.Status = 'Error';
            objResp.Message = 'Customer not found :'+Receipt.OraclePartyId;
            objResp.SF_Id = '';
            objResp.SF_Receipt_Reference = '';
            return objResp;
        }
        
        
        objReceipt.Oracle_Receipt_Id__c = Receipt.OracleReceiptNumber;
        objReceipt.Description__c = Receipt.Description;
        objReceipt.Payment_Method__c = Receipt.PaymentMode;
        objReceipt.Payment_Currency__c= Receipt.CurrencyType;
        objReceipt.Payment_Purpose__c = Receipt.PaymentPurpose;
        objReceipt.Amount__c = Receipt.Amount;
        objReceipt.Created_By_Oracle__c = true;
        objReceipt.Status__c = 'Success';
        objReceipt.Receipt_Date__c = system.now();
        try{
            upsert objReceipt Oracle_Receipt_Id__c;
            for(Receipt__c rec:[select Id,Name from Receipt__c where Id=:objReceipt.Id]){
                objResp.SF_Id = rec.Id;
                objResp.SF_Receipt_Reference = rec.Name;
            }
            objResp.Status = 'Success';
            objResp.Message = '';
        }catch(Exception e){
            objResp.Status = 'Failed';
            objResp.Message = e.getMessage()+'';
        }      
        return objResp;
    }
    global class ReceiptInformation{
        webservice string OracleReceiptNumber;
        webservice decimal Amount;
        webservice string OraclePartyId;
        webservice string Description;
        webservice string PaymentMode;
        webservice string ReceiptDate;
        webservice string PaymentPurpose;
        webservice string CurrencyType;
    }
    global class ResponseDetails{
      webservice string SF_Id;
      webservice string SF_Receipt_Reference;
      webservice string Oracle_Party_Id;
      webservice string Status;
      webservice string Message;
    }
}
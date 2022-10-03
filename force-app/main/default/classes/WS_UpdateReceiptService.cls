/**
 * @description       : 
 * @author            : Jayanta Karmakar
 * @group             : 
 * @last modified on  : 11-24-2020
 * @last modified by  : Jayanta Karmakar
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   11-23-2020   Jayanta Karmakar   Initial Version
**/
global class WS_UpdateReceiptService {
    webservice static ResponseDetails processReceipt(ReceiptInformation receiptInfo) {
        system.debug('===>'+receiptInfo.Receipt_Id);
        ResponseDetails responseObj = new ResponseDetails();
        responseObj.ReceiptId = receiptInfo.Receipt_Id;
        responseObj.SF_Id = '';
        String MessageDetails = '';
        try{
            List<Receipt__c> receipts = [SELECT Id,Status__c from Receipt__c WHERE Source_Receipt_Id__c =: receiptInfo.Receipt_Id];
            system.debug('====>'+receipts);
            receipts[0].Status__c = receiptInfo.Receipt_Status;
            receipts[0].Payment_Status__c = receiptInfo.Receipt_Payment_Status;
            update receipts;
            
            responseObj.SF_Id = receipts[0].id;
            responseObj.Success = true;
            responseObj.Status_Code = '200';
            responseObj.Messages = 'Receipt updated successfully!';
        } catch(Exception ex){
            String sMessage = ex.getMessage();
            Log__c objLog = new Log__c(Line_Number__c = ex.getLineNumber(),Stack_Trace__c =  ex.getStackTraceString(),Type_Name__c = ex.getTypeName());
            if(sMessage .length() > 240) {
                objLog.Message__c = sMessage.subString(0,240);
            } else {
                objLog.Message__c = sMessage;
            }
            insert objLog;
            system.debug('==='+ex.getMessage());
            system.debug('==='+ex.getLineNumber());
            responseObj.Success = false;
            responseObj.Status_Code = '600';
            String errMsg = 'Please Review the below Error Messages :'+ ex.getMessage();
            responseObj.Messages = errMsg;
        }
        return responseObj;
    }
    
    global class ResponseDetails{
        webservice string SF_Id;
        webservice string ReceiptId;
        webservice boolean Success;
        webservice string Messages; 
        webservice string Status_Code;
    }
    
    global class ReceiptInformation{
        webservice string Receipt_Id;
        webservice string Receipt_Status;
        webservice string Receipt_Payment_Status;
    }
}
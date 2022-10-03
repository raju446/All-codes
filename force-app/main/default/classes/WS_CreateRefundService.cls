/**
 * @File Name          : WS_CreateRefundService.cls
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 02-12-2021
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    6/21/2020   Jayanta Karmakar     Initial Version
**/
global class WS_CreateRefundService {
    webservice static ResponseDetails ProcessRefund(Refund_Wrapper refundInfo){
        ResponseDetails resp = new ResponseDetails();
        resp.RefundId = refundInfo.Source_Reference;
        
        system.debug('refundInfo '+refundInfo);
        system.debug('refundInfo '+refundInfo.Credit_Memo_Id);
        
        try{
            // New Change to push receipt if oracle id not present and update certain fields.
            if(refundInfo.Receipt_Id != null && (refundInfo.Credit_Memo_Id == null || refundInfo.Credit_Memo_Id == '')){
                List<Receipt__c> rcptLst = [SELECT Id,Status__c,Payment_Status__c,Transaction_Type__c FROM Receipt__c where Id =: refundInfo.Receipt_Id LIMIT 1];
                if(rcptLst[0].Status__c == 'Rejected' && rcptLst[0].Payment_Status__c == 'Payment Received from Incorrect Source' && rcptLst[0].Transaction_Type__c == 'NonWallet'){
                    rcptLst[0].Transaction_Type__c = 'Wallet';
                    update rcptLst;
                }
                //ReceiptUtil.PushReceiptToOracle_Future_New(new List<String>{rcptLst[0].Id});
            }
            Refund__c refundObj = new Refund__c();
            refundObj.Source_Refund_Reference_No__c = refundInfo.Source_Reference;
            refundObj.Source_Refund_Reference_Id__c = refundInfo.Source_Reference_Id;
            refundObj.Scenario__c = refundInfo.Scenario; 
            refundObj.Source_System__c = refundInfo.Source_System;
            refundObj.Entity__c = refundInfo.Entity_Id;
            refundObj.Receipt__c = refundInfo.Receipt_Id;
            refundObj.Credit_Memo__c = string.isNotBlank(refundInfo.Credit_Memo_Id) ? refundInfo.Credit_Memo_Id : null;
            refundObj.Actual_Payment_Method__c = refundInfo.Original_Payment_Method;
            refundObj.Payment_Method__c = refundInfo.Refund_Payment_Method;
            refundObj.Transaction_Types__c = refundInfo.Transaction_Type;
            refundObj.Currency__c = refundInfo.Refund_Currency;
            refundObj.Amount__c = refundInfo.Refund_Amount;
            refundObj.Description__c = refundInfo.Description;
            refundObj.Vendor_Name__c = refundInfo.Vendor_Name;
            refundObj.Vendor_Number__c = refundInfo.Vendor_Number;
            refundObj.Bank_Name__c = refundInfo.Bank_Name;
            refundObj.Bank_Account_Number__c = refundInfo.Bank_Acc_No;
            refundObj.Card_First_Last_Digit__c = refundInfo.Credit_Card_No;
            refundObj.Authorization_Code__c = refundInfo.Authorization_Code;
            refundObj.Credit_Memo_Receipt__c = string.isNotBlank(refundInfo.Credit_Memo_Receipt_Id) ? refundInfo.Credit_Memo_Receipt_Id : null;
            refundObj.IBAN_Number__c = refundInfo.IBAN_Number;
            refundObj.Status__c = refundInfo.Status;
            insert refundObj;
            
            if(refundInfo.Attachment_List != null && refundInfo.Attachment_List.size() > 0){
                List<ContentVersion> conVersions = new List<ContentVersion>();
                for(Attachment_Wrapper eachItem : refundInfo.Attachment_List){
                    if(eachItem.File_Name != null && eachItem.File_Body != null && eachItem.File_Name != '' && eachItem.File_Body != ''){
                        ContentVersion contentVers = new ContentVersion();
                        contentVers.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
                        contentVers.PathOnClient = eachItem.File_Name; 
                        contentVers.Title = eachItem.File_Name;
                        contentVers.VersionData = EncodingUtil.base64Decode(eachItem.File_Body); // contentVersting your binary string to Blog
                        conVersions.add(contentVers);
                    }
                }
                
                if(conVersions.size() > 0){
                    insert conVersions;
                    List<ContentVersion> insertedCV = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :conVersions];
                    List<ContentDocumentLink> contentDocToInsert = new List<ContentDocumentLink>();
                    for(ContentVersion eachCV : insertedCV){
                        ContentDocumentLink contentLink = new ContentDocumentLink();
                        contentLink.ContentDocumentId = eachCV.ContentDocumentId;
                        contentLink.LinkedEntityId = refundObj.Id; 
                        contentLink.ShareType = 'I'; // Inferred permission
                        contentLink.Visibility = 'AllUsers';
                        contentDocToInsert.add(contentLink);
                    }
                    if(contentDocToInsert.size() > 0){
                        insert contentDocToInsert;
                    }
                } 
            }
            
            resp.Messages = 'Refund Created Successfully.';
            resp.SF_Id = refundObj.Id;
            resp.Status_Code = '200';
            resp.Success = true;
        } catch(Exception ex){
            resp.Messages = ex.getMessage();
            resp.Status_Code = '600';
            resp.Success = false;
            String sMessage = ex.getMessage();
            Log__c objLog = new Log__c();
            if(sMessage .length() > 240) {
                objLog.Message__c = sMessage.subString(0,240);
            } else {
                objLog.Message__c = sMessage;
            }
            objLog.Line_Number__c = ex.getLineNumber();
            objLog.Stack_Trace__c =  ex.getStackTraceString();
            objLog.Type_Name__c = ex.getTypeName();
            insert objLog;
        }
        return resp;
    }
    
    global class Refund_Wrapper{
        webservice String Source_Reference;
        webservice String Source_Reference_Id;
        webservice String Scenario;
        webservice String Source_System;
        webservice String Entity_Id;
        webservice String Receipt_Id;
        webservice String Credit_Memo_Id;
        webservice String Credit_Memo_Receipt_Id;
        webservice String Original_Payment_Method;
        webservice String Refund_Payment_Method;
        webservice String Transaction_Type;
        webservice String Refund_Currency;
        webservice String IBAN_Number;
        webservice Decimal Refund_Amount;
        webservice String Description;
        webservice String Vendor_Name;
        webservice String Vendor_Number;
        webservice String Bank_Name;
        webservice String Bank_Acc_No;
        webservice String Credit_Card_No;
        webservice String Authorization_Code;
        webservice String Status;
        webservice List<Attachment_Wrapper> Attachment_List;
        global Refund_Wrapper(){
            Attachment_List = new List<Attachment_Wrapper>();
        }
    }
    
    global class Attachment_Wrapper{
        webservice string File_Name;
        webservice string File_Body;
    }
    global class ResponseDetails{
        webservice string SF_Id;
        webservice string RefundId;
        webservice boolean Success;
        webservice string Messages; 
        webservice string Status_Code;
        global ResponseDetails(){
            RefundId = '';
            SF_Id = '';
        }
    }
}
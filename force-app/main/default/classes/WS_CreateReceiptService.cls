/*
    Author      : Jayanta Karmakar
    Date        : 03-Feb-2020
    Description : Webservice class to create the Receipt for billing management.
    --------------------------------------------------------------------------------------------
*/
global class WS_CreateReceiptService {
    webservice static ResponseDetails ProcessReceipt(ReceiptInformation receiptInfo) {
        ResponseDetails responseObj = new ResponseDetails();
        responseObj.ReceiptId = receiptInfo.Receipt_Id;
        responseObj.SF_Id = '';
        String MessageDetails = '';

        try{
           // List<Invoice__c> invoices = new List<Invoice__c>();
            List<String> errorMsgs = new List<String>();
            if(receiptInfo.Receipt_Id == null || receiptInfo.Receipt_Id == ''){
                errorMsgs.add('Receipt_Id can not be null / blank');    
            }
            if(receiptInfo.Amount == null || receiptInfo.Amount == ''){
                errorMsgs.add('Amount can not be null / blank');   
            }
            if(receiptInfo.Reference_Id == null || receiptInfo.Reference_Id == ''){
                errorMsgs.add('Reference_Id can not be null / blank');   
            }
            if(receiptInfo.Payment_Method == null || receiptInfo.Payment_Method == ''){
                errorMsgs.add('Payment_Method can not be null / blank');   
            }
            if(receiptInfo.Source_System_ID == null || receiptInfo.Source_System_ID == ''){
                errorMsgs.add('Source_System_ID can not be null / blank');   
            }
            if(receiptInfo.Receipt_Date == null || receiptInfo.Receipt_Date == ''){
                errorMsgs.add('Receipt_Date can not be null / blank');   
            }
            if(receiptInfo.Description == null || receiptInfo.Description == ''){
                errorMsgs.add('Description can not be null / blank');   
            }
            if(receiptInfo.Receipt_Currency == null || receiptInfo.Receipt_Currency == ''){
                errorMsgs.add('Receipt_Currency can not be null / blank');   
            }
           /* if(receiptInfo.Related_Invoice_NO == null || receiptInfo.Related_Invoice_NO == ''){
                errorMsgs.add('Related_Invoice_NO can not be null / blank');   
            } else {
                invoices = [SELECT Id from Invoice__c WHERE Name =: receiptInfo.Related_Invoice_NO];
                if(invoices.size() == 0){
                    errorMsgs.add('No Invoice Record found with Related_Invoice_NO');
                } 
            } */
            if(receiptInfo.Related_Invoice_NO != null && receiptInfo.Related_Invoice_NO != '' && (receiptInfo.Amount_Applied == null || receiptInfo.Amount_Applied == '')){
                errorMsgs.add('Amount_Applied can not be null / blank');   
            }

            if(errorMsgs.size() > 0){
                responseObj.Success = false;
                MessageDetails = 'Please Review the below Error Messages :';
                MessageDetails += String.join(errorMsgs,',');   
                responseObj.Status_Code = '600';
            }else{
                List<Receipt__c> receipts = [SELECT Id,Status__c from Receipt__c WHERE Source_Receipt_Id__c =: receiptInfo.Receipt_Id];
                List<Account> entities = [select id,Oracle_Site_id__c,Sys_Site_Id__c from Account where id =: receiptInfo.Reference_Id LIMIT 1];
                String operation = 'created';
                String recptSts = 'Draft';
                Receipt__c receiptObj = new Receipt__c();
                if(receipts.size() > 0){
                    receiptObj.Id = receipts[0].id;
                    operation = 'updated';
                    recptSts = receipts[0].Status__c;
                }

                receiptObj.Source_Receipt_Id__c = receiptInfo.Receipt_Id;
                receiptObj.Amount__c = Decimal.valueOf(receiptInfo.Amount);
                receiptObj.Entity__c = receiptInfo.Reference_Id;
                receiptObj.Payment_Method__c = receiptInfo.Payment_Method;
                receiptObj.Transaction_Reference__c = receiptInfo.Source_System_ID;//Transaction_Reference;
                List<String> receiptDate = receiptInfo.Receipt_Date.split('/');
                system.debug(receiptDate);
                receiptObj.Receipt_Date__c = date.newinstance(Integer.valueOf(receiptDate[2]), Integer.valueOf(receiptDate[0]), Integer.valueOf(receiptDate[1]));
                receiptObj.GL_Date__c = date.newinstance(Integer.valueOf(receiptDate[2]), Integer.valueOf(receiptDate[0]), Integer.valueOf(receiptDate[1]));
                receiptObj.Description__c = receiptInfo.Description;
                receiptObj.Payment_Purpose_Text__c = receiptInfo.Payment_Purpose;
                receiptObj.Payment_Currency__c = receiptInfo.Receipt_Currency;
                //receiptObj.Related_Invoice__c = receiptInfo.Related_Invoice_NO== '' ? null : receiptInfo.Related_Invoice_NO;
               // receiptObj.Invoice_Amount_Applied__c = (receiptInfo.Amount_Applied != '' || receiptInfo.Amount_Applied != null) ? Decimal.valueOf(receiptInfo.Amount_Applied) : 0.0;
                String sts = 'Success';
                if((entities[0].Oracle_Site_id__c == '103' || entities[0].Sys_Site_Id__c == '103') && recptSts != 'Rejected'){
                    sts = 'Draft';
                } else if((entities[0].Oracle_Site_id__c == '103' || entities[0].Sys_Site_Id__c == '103') && recptSts == 'Rejected'){
                    sts = 'Success';
                }
                receiptObj.Status__c = sts;
                receiptObj.Credit_Card_F_L_Four_Digits__c = receiptInfo.Credit_Card_No;
                receiptObj.EFT_Reference_No__c = receiptInfo.EFT_Ref_NO;
                receiptObj.Authorization_Code__c = receiptInfo.Auth_Code;
                if(receiptInfo.Related_Invoice_NO !='' && receiptInfo.Related_Invoice_NO !=null){
                    receiptObj.Transaction_Type__c = 'NonWallet';
                } else {
                    receiptObj.Transaction_Type__c = 'Wallet';
                }
                
                // for AL-Mudeer only
                receiptObj.Approved_Source_of_Payment__c = receiptInfo.Approved_Source_of_Payment;
                receiptObj.Other_Source_of_Payment__c = receiptInfo.Other_Source_of_Payment;
                receiptObj.Payer_Type__c = receiptInfo.Payee_Type;
                receiptObj.Corporate_Name__c = receiptInfo.Corporate_Name;
                receiptObj.First_Name__c = receiptInfo.First_Name;
                receiptObj.Last_Name__c = receiptInfo.Last_Name;
                receiptObj.Source_SFID__c = receiptInfo.SF_ID;

                upsert receiptObj;

                if(receiptInfo.Related_Invoice_NO !='' && receiptInfo.Related_Invoice_NO !=null){
                    List<String> InvoicesList = new List<String>();
                    InvoicesList = receiptInfo.Related_Invoice_NO.split(',');
                    List<String> amntApliedList = new List<String>();
                    amntApliedList = receiptInfo.Amount_Applied.split(',');
                    List<Related_Invoice_Receipt__c> relatedInvoice = new List<Related_Invoice_Receipt__c>();
                    
                    /*for(String eachInvoiceId : InvoicesList){
                        relatedInvoice.add(new Related_Invoice_Receipt__c(Invoice__c = eachInvoiceId,Receipt__c=receiptObj.id,Direction__c = 'From Receipt To Invoice',Amount_Applied__c=Decimal.valueof(receiptInfo.Amount_Applied)));
                    }*/
                    
                    for(Integer i =0; i < InvoicesList.size(); i++){
                        relatedInvoice.add(new Related_Invoice_Receipt__c(Invoice__c = InvoicesList[i],Receipt__c=receiptObj.id,Direction__c = 'From Receipt To Invoice',Amount_Applied__c=Decimal.valueof(amntApliedList[i])));
                    }

                    if(relatedInvoice.size() > 0){
                        insert relatedInvoice;
                    }
                }
                
                // ------------------- Insert Attachment -------------------------------
                if(receiptInfo.File_Name != null && receiptInfo.File_Body != null && receiptInfo.File_Name != '' && receiptInfo.File_Body != ''){
                    List<ContentVersion> conVersions = new List<ContentVersion>();
                    ContentVersion contentVers = new ContentVersion();
                    contentVers.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
                    contentVers.PathOnClient = receiptInfo.File_Name; 
                    contentVers.Title = receiptInfo.File_Name;
                    contentVers.VersionData = EncodingUtil.base64Decode(receiptInfo.File_Body); // contentVersting your binary string to Blog
                    conVersions.add(contentVers);
                    
    
                    if(conVersions.size() > 0){
                        insert conVersions;
                        List<ContentVersion> insertedCV = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :conVersions];
                        List<ContentDocumentLink> contentDocToInsert = new List<ContentDocumentLink>();
                        for(ContentVersion eachCV : insertedCV){
                            ContentDocumentLink contentLink = new ContentDocumentLink();
                            contentLink.ContentDocumentId = eachCV.ContentDocumentId;
                            contentLink.LinkedEntityId = receiptObj.Id; 
                            contentLink.ShareType = 'I'; // Inferred permission
                            contentLink.Visibility = 'AllUsers';
                            contentDocToInsert.add(contentLink);
                        }
                        if(contentDocToInsert.size() > 0){
                            insert contentDocToInsert;
                        }
                    }        
                }
                
                if(receiptObj.Status__c == 'Draft' && recptSts == 'Draft'){
                    // Create an approval request for the account
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setComments('Submitting request for approval.');
                    req1.setObjectId(receiptObj.id);
                    Approval.ProcessResult result = Approval.process(req1);
                }
                
                //----------------- Insert Attachment Finished -------------------------
                responseObj.SF_Id = receiptObj.id;
                responseObj.Success = true;
                responseObj.Status_Code = '200';
                MessageDetails = 'Receipt '+operation+' successfully!';
            }
        } catch (Exception ex){
            String sMessage = ex.getMessage();
            Log__c objLog = new Log__c();
            if(sMessage .length() > 240) {
                objLog.Message__c = sMessage.subString(0,240);
            } else {
                objLog.Message__c = sMessage;
            }//end if
            
            objLog.Line_Number__c = ex.getLineNumber();
            objLog.Stack_Trace__c =  ex.getStackTraceString();
            objLog.Type_Name__c = ex.getTypeName();
            //objLog.User_Email__c = UserInfo.getUserEmail();
            insert objLog;
            
            responseObj.Success = false;
            responseObj.Status_Code = '600';
            String errMsg = 'Please Review the below Error Messages :'+ ex.getMessage();
            responseObj.Messages = errMsg;
            return responseObj;
        }

        responseObj.Messages = MessageDetails;
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
        webservice string Amount;
        webservice string Reference_Id;
        webservice string Payment_Method;
        webservice string Credit_Card_No;
        webservice string Auth_Code;
        //webservice string Transaction_Reference;
        webservice string Source_System_ID;
        webservice string Receipt_Date;
        webservice string Description; 
        webservice string Payment_Purpose;
        webservice string Receipt_Currency;
        webservice string Related_Invoice_NO;
        webservice string Amount_Applied;
        webservice string EFT_Ref_NO;
        webservice string File_Name;
        webservice string File_Body;
        //webservice boolean Need_Approval;
        webservice string Approved_Source_of_Payment;
        webservice string Other_Source_of_Payment;
        webservice string Payee_Type;
        webservice string Corporate_Name;
        webservice string First_Name;
        webservice string Last_Name;
        webservice string SF_ID;
    }
}
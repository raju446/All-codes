/*
    Author      : Durga Prasad
    Date        : 30-Jan-2018
    Description : Receipt Utility Class to push the Recipts to Oracle
    ------------------------------------------------------------------
*/
public without sharing class ReceiptUtil {
    public static final string SUCCESS_MSG = 'Success';
    /* 
        Method Name     :   PushReceiptToOracle
        Description     :   Http Callout to Informatica Cloud to create Receipt in Oracle
        Input Params    :   Receipt Record Id
    */
    /*public static void PushReceiptToOracle(string ReceiptId){
        WS_Inf_ReceiptProcess.CreateReceiptUAT_Service  objReq = new WS_Inf_ReceiptProcess.CreateReceiptUAT_Service();
        WS_Inf_ReceiptProcess.CreateReceiptUATResponse_element objResp = new WS_Inf_ReceiptProcess.CreateReceiptUATResponse_element();
        
        WS_Inf_ReceiptProcess.CreateReceiptUATHeader_element HeaderElement = new WS_Inf_ReceiptProcess.CreateReceiptUATHeader_element();
        Receipt__c rp = new Receipt__c();
        for(Receipt__c Receipt:[Select Id,Name,Receipt_Reference__c,Oracle_Receipt_Id__c,Amount__c,Credit_Amount__c,Description__c,Entity__c,Entity__r.Oracle_Party_Id__c,Payment_Currency__c,Payment_Method__c,Payment_Purpose__c,GL_Date__c,Receipt_Date__c,Transaction_Reference__c,Status__c from Receipt__c where Id=:ReceiptId and Oracle_Receipt_Id__c=null and (Status__c='Success' or Status__c='Approved')]){
            rp = Receipt;
        }
        objReq.header = HeaderElement;
        objReq.timeout_x = 120000;
        try{//
            objResp = objReq.CreateReceiptUAT(rp.Entity__r.Oracle_Party_Id__c,rp.Id,rp.Receipt_Reference__c,rp.Amount__c,date.valueOf(rp.Receipt_Date__c),rp.Payment_Method__c,rp.Payment_Purpose__c,RP.Transaction_Reference__c);
            system.debug('objResp==>'+objResp);
            if(objResp!=null && objResp.P_OP_ORACLE_RECEIPT_NO!=null){rp.Pushed_to_Oracle__c = true;rp.Oracle_Receipt_Id__c = objResp.P_OP_ORACLE_RECEIPT_NO;rp.Message__c = objResp.P_OP_ERROR_MSG;}
            else if(objResp!=null && objResp.P_OP_STATUS!='S' && objResp.P_OP_ERROR_MSG!=null){rp.Message__c = objResp.P_OP_ERROR_MSG;}
            update rp;
        }catch(Exception e){
            system.debug(e.getMessage());
        }
    } */
    /*
        Method Name     :   PushReceiptToOracle
        Description     :   Http Callout to Informatica Cloud to create Receipt in Oracle
        Input Params    :   Receipt Record Id
    */
   /*@Future(callout=true)
    public static void PushReceiptToOracle_Future(string ReceiptId){
        WS_Inf_ReceiptProcess.CreateReceiptUAT_Service  objReq = new WS_Inf_ReceiptProcess.CreateReceiptUAT_Service();
        WS_Inf_ReceiptProcess.CreateReceiptUATResponse_element objResp = new WS_Inf_ReceiptProcess.CreateReceiptUATResponse_element();
        
        WS_Inf_ReceiptProcess.CreateReceiptUATHeader_element HeaderElement = new WS_Inf_ReceiptProcess.CreateReceiptUATHeader_element();
        Receipt__c rp = new Receipt__c();
        for(Receipt__c Receipt:[Select Id,Name,Receipt_Reference__c,Oracle_Receipt_Id__c,Credit_Amount__c,Description__c,Amount__c,Entity__c,Entity__r.Oracle_Party_Id__c,Payment_Currency__c,Payment_Method__c,Payment_Purpose__c,Receipt_Date__c,GL_Date__c,Transaction_Reference__c,Status__c from Receipt__c where Id=:ReceiptId and Oracle_Receipt_Id__c=null and (Status__c='Success' or Status__c='Approved')]){
            rp = Receipt;
        }
        system.debug('$$RECEIPT: '+rp);
        objReq.header = HeaderElement;
        objReq.timeout_x = 120000;
        try{
            //system.debug('$$RECEIPTDATE: '+Date.parse(date.valueOf(rp.Receipt_Date__c).format()));
            objResp = objReq.CreateReceiptUAT(rp.Entity__r.Oracle_Party_Id__c,rp.Id,rp.Receipt_Reference__c,rp.Amount__c,date.valueOf(rp.Receipt_Date__c),rp.Payment_Method__c,rp.Payment_Purpose__c,RP.Transaction_Reference__c);
            system.debug('objResp==>'+objResp);
            if(objResp!=null && objResp.P_OP_ORACLE_RECEIPT_NO!=null){rp.Pushed_to_Oracle__c = true; rp.Oracle_Receipt_Id__c = objResp.P_OP_ORACLE_RECEIPT_NO; rp.Message__c = objResp.P_OP_ERROR_MSG;}
            else if(objResp!=null && objResp.P_OP_STATUS!='S' && objResp.P_OP_ERROR_MSG!=null){rp.Message__c = objResp.P_OP_ERROR_MSG;}
            update rp;
        }catch(Exception e){
            system.debug('@@ERROR: '+e.getMessage());
        }
    }*/
    
    /*
        Method Name     :   Prod_PushReceiptToOracle
        Description     :   Http Callout to Informatica Cloud to create Receipt in Oracle
        Input Params    :   Receipt Record Id
    */
   /*public static void Prod_PushReceiptToOracle(string ReceiptId){
        WS_ERP_CreateReceipt.CreateReceipt_ERP_Service  objReq = new WS_ERP_CreateReceipt.CreateReceipt_ERP_Service();
        WS_ERP_CreateReceipt.CreateReceipt_ERPResponse_element objResp = new WS_ERP_CreateReceipt.CreateReceipt_ERPResponse_element();
        
        WS_ERP_CreateReceipt.CreateReceipt_ERPHeader_element HeaderElement = new WS_ERP_CreateReceipt.CreateReceipt_ERPHeader_element();
        Receipt__c rp = new Receipt__c();
        for(Receipt__c Receipt:[Select Id,Name,Receipt_Reference__c,Oracle_Receipt_Id__c,Amount__c,Credit_Amount__c,Description__c,Entity__c,Entity__r.Oracle_Party_Id__c,Payment_Currency__c,Payment_Method__c,Payment_Purpose__c,Receipt_Date__c,GL_Date__c,Transaction_Reference__c,Status__c from Receipt__c where Id=:ReceiptId and Oracle_Receipt_Id__c=null and (Status__c='Success' or Status__c='Approved')]){
            rp = Receipt;
        }
        objReq.header = HeaderElement;
        objReq.timeout_x = 120000;
        try{
            objResp = objReq.CreateReceipt_ERP(rp.Entity__r.Oracle_Party_Id__c,rp.Id,rp.Receipt_Reference__c,rp.Amount__c,date.valueOf(rp.Receipt_Date__c),rp.Payment_Method__c,rp.Payment_Purpose__c,RP.Transaction_Reference__c);
            system.debug('objResp==>'+objResp);
            if(objResp!=null && objResp.P_OP_ORACLE_RECEIPT_NO!=null){
                rp.Pushed_to_Oracle__c = true;
                rp.Oracle_Receipt_Id__c = objResp.P_OP_ORACLE_RECEIPT_NO;
                rp.Message__c = objResp.P_OP_ERROR_MSG;
            }else if(objResp!=null && objResp.P_OP_STATUS!='S' && objResp.P_OP_ERROR_MSG!=null){
                rp.Message__c = objResp.P_OP_ERROR_MSG;
            }
            update rp;
        }catch(Exception e){
            
        }
    } */
    /*
        Method Name     :   Prod_PushReceiptToOracle_Future
        Description     :   Http Callout to Informatica Cloud to create Receipt in Oracle
        Input Params    :   Receipt Record Id
    */
   /*@Future(callout=true)
    public static void Prod_PushReceiptToOracle_Future(string ReceiptId){
        WS_ERP_CreateReceipt.CreateReceipt_ERP_Service objReq = new WS_ERP_CreateReceipt.CreateReceipt_ERP_Service();
        WS_ERP_CreateReceipt.CreateReceipt_ERPResponse_element objResp = new WS_ERP_CreateReceipt.CreateReceipt_ERPResponse_element();
        WS_ERP_CreateReceipt.CreateReceipt_ERPHeader_element HeaderElement = new WS_ERP_CreateReceipt.CreateReceipt_ERPHeader_element();
        
        Receipt__c rp = new Receipt__c();
        for(Receipt__c Receipt:[Select Id,Name,Receipt_Reference__c,Oracle_Receipt_Id__c,Credit_Amount__c,Description__c,Amount__c,Entity__c,Entity__r.Oracle_Party_Id__c,Payment_Currency__c,Payment_Method__c,Payment_Purpose__c,Receipt_Date__c,Transaction_Reference__c,Status__c from Receipt__c where Id=:ReceiptId and Oracle_Receipt_Id__c=null and (Status__c='Success' or Status__c='Approved')]){
            rp = Receipt;
        }
        objReq.header = HeaderElement;
        objReq.timeout_x = 120000;
        try{
            objResp = objReq.CreateReceipt_ERP(rp.Entity__r.Oracle_Party_Id__c,rp.Id,rp.Receipt_Reference__c,rp.Amount__c,date.valueOf(rp.Receipt_Date__c),rp.Payment_Method__c,rp.Payment_Purpose__c,RP.Transaction_Reference__c);
            system.debug('objResp==>'+objResp);
            if(objResp!=null && objResp.P_OP_ORACLE_RECEIPT_NO!=null){
                rp.Pushed_to_Oracle__c = true;
                rp.Oracle_Receipt_Id__c = objResp.P_OP_ORACLE_RECEIPT_NO;
                rp.Message__c = objResp.P_OP_ERROR_MSG;
            }else if(objResp!=null && objResp.P_OP_STATUS!='S' && objResp.P_OP_ERROR_MSG!=null){
                rp.Message__c = objResp.P_OP_ERROR_MSG;
            }
            update rp;
        }catch(Exception e){
            
        }
    }*/
    
    /*
        Method Name     :  UpdateAmountAndCreateJournalEntries
        Description     :  Receipt Amount Update And Journal Creation
    */
    
    public static void UpdateAmountAndCreateJournalEntries(List<String> receiptId){
        try{
            List<Receipt__c> listReceipt = new List<Receipt__c>();
            List<Invoice__c> invoiceLst = new List<Invoice__c>();
            List<Related_Invoice_Receipt__c> relatedReceipts = new List<Related_Invoice_Receipt__c>();
            List<Id> applicationIds = new List<Id>();
            for(Receipt__c rp:[Select Id,Name,Receipt_Reference__c,Category__c,Reason__c,Oracle_Receipt_Id__c,Amount__c,Credit_Amount__c,Description__c,Entity__c,Entity__r.Oracle_Party_Id__c,EFT_Reference_No__c
                               ,Payment_Currency__c,Payment_Method__c,Payment_Purpose__c,Receipt_Date__c,GL_Date__c,Transaction_Reference__c,Status__c, Transaction_Type__c,Authorization_Code__c
                               , Entity__r.Oracle_Site_Id__c, Oracle_GL_Date__c, Converted_Amount__c, Source_Receipt_Id__c, Conversion_Rate__c
                               ,(SELECT Id,Invoice__c,Invoice__r.Source_Invoice_Id__c,Applied_Date__c,Amount_Applied__c,Oracle_Applied_Amount__c,Invoice__r.Invoice_Balance__c, Invoice__r.Converted_Invoice_Balance__c FROM Related_Invoices__r WHERE Direction__c = 'From Receipt To Invoice' AND Invoice__r.Journal_Created__c = true AND Journal_Created__c = false ORDER BY Invoice__r.Source_Invoice_Id__c ASC)
                               from Receipt__c 
                               where Id IN:receiptId and (Status__c='Success' or Status__c='Approved' or (Status__c='Rejected' AND Payment_Status__c = 'Payment Received from Incorrect Source')) AND From_Data_Migration__c = false AND Journal_Created__c = False]){
                                   List<String> invoiceNos = new List<String>();
                                   List<String> amntApplied = new List<String>();
                                   List<String> amountAppliedDates = new List<String>();
                                   system.debug('rp==>>' + rp);
                                   system.debug('rp.Related_Invoices__r==>>' + rp.Related_Invoices__r);
                                   rp.Journal_Created__c = true;
                                   rp.Oracle_Callout_Status__c = 'Receipts Journal Created';
                                   System.debug(rp.Converted_Amount__c + '==>' + rp.Payment_Currency__c + '==>' + rp.Amount__c + '==>' + rp.Conversion_Rate__c);
                                   rp.Converted_Amount__c = rp.Payment_Currency__c == 'USD' ? rp.Amount__c * rp.Conversion_Rate__c : rp.Amount__c;
                                   
                                   listReceipt.add(rp);
                                   
                                   if(!rp.Related_Invoices__r.isEmpty()){
                                       relatedReceipts = rp.Related_Invoices__r;
                                       //relatedReceipts = [SELECT Id,Invoice__c, Invoice__r.Oracle_Invoice_Id__c, Invoice__r.Invoice_Balance__c, Invoice__r.Converted_Invoice_Balance__c FROM Related_Invoice_Receipt__c WHERE Receipt__c =: rp.id AND Invoice__r.Oracle_Invoice_Id__c IN: invoiceNos1];
                                       
                                       for(Related_Invoice_Receipt__c obj : relatedReceipts){
                                           system.debug('obj.Amount_Applied__c==>>' + obj.Amount_Applied__c);
                                           obj.GL_Date__c = obj.Applied_Date__c;obj.Applied__c = true;obj.ORACLE_Applied_Amount__c = obj.Amount_Applied__c;obj.Amount_Applied__c = obj.Amount_Applied__c; obj.Journal_Created__c = true;obj.Oracle_Converted_Applied_Amount__c =  rp.Payment_Currency__c == 'USD' ? obj.Amount_Applied__c * rp.Conversion_Rate__c : obj.Amount_Applied__c;applicationIds.add(obj.Id);
                                           //
                                           invoiceLst.add(new Invoice__c(id = obj.Invoice__c, Invoice_Balance__c = obj.Invoice__r.Invoice_Balance__c == obj.Amount_Applied__c ? 0 : obj.Invoice__r.Invoice_Balance__c - obj.Amount_Applied__c, Converted_Invoice_Balance__c = obj.Invoice__r.Converted_Invoice_Balance__c == obj.Oracle_Converted_Applied_Amount__c ? 0 : obj.Invoice__r.Converted_Invoice_Balance__c - obj.Oracle_Converted_Applied_Amount__c));
                                           
                                       }
                                   }
                               }
            ReceiptTriggerHandler.isRunTrigger = False;
            if(listReceipt <> null && listReceipt.size() > 0) {
                
                update listReceipt;
                BM_JournalEntryEngine.receiptCreationJournal(receiptId);
            }
            if(invoiceLst.size() > 0){ update invoiceLst;}
               
            if(relatedReceipts.size() > 0){update relatedReceipts;BM_JournalEntryEngine.receiptApplicationJournalLines(applicationIds);} 
            
        }catch(exception ex){String sMessage = ex.getMessage();Log__c objLog = new Log__c();if(sMessage .length() > 240) {objLog.Message__c = sMessage.subString(0,240);} else {objLog.Message__c = sMessage;}//end if
            objLog.Line_Number__c = ex.getLineNumber();objLog.Stack_Trace__c =  ex.getStackTraceString();objLog.Type_Name__c = ex.getTypeName();insert objLog;
        }
    }
    
    
    /*
        Method Name     :   PushReceiptToOracle
        Description     :   Http Callout to Informatica Cloud to create Receipt in Oracle
        Input Params    :   Receipt Record Id
    */
    /*public static String PushReceiptToOracle_New(string ReceiptId){
        system.debug('Push to Oracle Receipt Called');
        try{
            Receipt__c rp = new Receipt__c();
            //AND From_Data_Migration__c = false
                for(Receipt__c Receipt:[Select Id,Name,Receipt_Reference__c,Category__c,Reason__c,Oracle_Receipt_Id__c,Amount__c,Credit_Amount__c,Description__c,Entity__c,Entity__r.Oracle_Party_Id__c
                                    ,Payment_Currency__c,Payment_Method__c,Payment_Purpose__c,Receipt_Date__c,GL_Date__c,Transaction_Reference__c,Status__c, Transaction_Type__c,EFT_Reference_No__c
                                    , Entity__r.Oracle_Site_Id__c, Source_Receipt_Id__c,Authorization_Code__c
                                    from Receipt__c 
                                    where Id=:ReceiptId and (Status__c='Success' or Status__c='Approved' or (Status__c='Rejected' AND Payment_Status__c = 'Payment Received from Incorrect Source')) AND From_Data_Migration__c = false]){
                                        rp = Receipt;
                                            
            ReceiptRequestWrapper objreceiptRequestWrapper = new ReceiptRequestWrapper();
            objreceiptRequestWrapper.P_IN_ORACLE_ID = rp.Entity__r.Oracle_Party_Id__c;
            objreceiptRequestWrapper.P_IN_SFID = rp.Id;
            //if(rp.Source_Receipt_Id__c <> null && rp.Source_Receipt_Id__c <> '') {
                //objreceiptRequestWrapper.P_IN_RECEIPT_REF = rp.Source_Receipt_Id__c == null ? '' : rp.Source_Receipt_Id__c;
            //} else {
                
            //}
            
            String transRef = '';
            if(rp.Payment_Method__c != null){
                if(rp.Payment_Method__c.contains('Card') && rp.Authorization_Code__c != null){
                    transRef = rp.Authorization_Code__c;
                    if([SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox){
                        //Integer randomNumber = Integer.valueof((Math.random() * 10000));
                        //transRef = transRef+randomNumber;
                        transRef = transRef+rp.Receipt_Reference__c;
                    }
                } else if(rp.Payment_Method__c == 'Electronic Funds Transfer' && rp.EFT_Reference_No__c != null){transRef = rp.EFT_Reference_No__c;} 
                else {transRef = rp.Transaction_Reference__c;}
            }else {transRef = rp.Transaction_Reference__c;}

            objreceiptRequestWrapper.P_IN_RECEIPT_REF = transRef == null || transRef == '' ? rp.Name : transRef;//rp.Source_Receipt_Id__c == null ? rp.Receipt_Reference__c :  rp.Source_Receipt_Id__c;
            List<String> oracleInvoices = new List<String>();
            List<String> amountApplieds = new List<String>();
            List<String> amountAppliedDates = new List<String>();
            for(Related_Invoice_Receipt__c eachIobj : [SELECT Id, Invoice__r.Oracle_Invoice_Id__c,Amount_Applied__c,Applied_Date__c FROM Related_Invoice_Receipt__c WHERE Receipt__c =: ReceiptId AND (Receipt__r.Status__c='Success' or Receipt__r.Status__c='Approved') AND Direction__c =: 'From Receipt To Invoice' ORDER BY Invoice__r.Oracle_Invoice_Id__c ASC]){
                oracleInvoices.add(eachIobj.Invoice__r.Oracle_Invoice_Id__c);
                if(eachIobj.Applied_Date__c <> null )
                    amountAppliedDates.add(eachIobj.Applied_Date__c.day()+'-'+eachIobj.Applied_Date__c.month()+'-'+eachIobj.Applied_Date__c.year());
                if(eachIobj.Amount_Applied__c <> null )
                    amountApplieds.add(String.valueOf(eachIobj.Amount_Applied__c));
            }
            system.debug('--->'+rp.Amount__c);
            if(rp.Amount__c <> null )
                objreceiptRequestWrapper.P_IN_RECEIPT_AMT = String.valueOf(rp.Amount__c);
            system.debug(rp.GL_Date__c != null ? rp.GL_Date__c.DAY()+'-'+rp.GL_Date__c.Month()+'-'+rp.GL_Date__c.Year() : rp.Receipt_Date__c.DAY()+'-'+rp.Receipt_Date__c.Month()+'-'+rp.Receipt_Date__c.Year());
            
            List<API_Payload__c> payloadList = [SELECT Id, Response__c FROM API_Payload__c WHERE Receipt__c = :rp.Id ORDER BY CreatedDate DESC LIMIT 1];
            if(!payloadList.isEmpty()){
                API_Payload__c payloadObj = payloadList[0];
                if(String.isNotBlank(payloadObj.Response__c) && payloadObj.Response__c.contains('Accounting periods must be defined for the GL Date')){
                    rp.GL_Date__c = System.today();
                }
            }

            objreceiptRequestWrapper.P_IN_RECEIPT_DATE = rp.GL_Date__c != null ? rp.GL_Date__c.DAY()+'-'+rp.GL_Date__c.Month()+'-'+rp.GL_Date__c.Year() : rp.Receipt_Date__c.DAY()+'-'+rp.Receipt_Date__c.Month()+'-'+rp.Receipt_Date__c.Year();
            objreceiptRequestWrapper.P_IN_PAYMENT_METHOD = rp.Payment_Method__c;
            objreceiptRequestWrapper.P_IN_PAYMENT_PURPOSE = rp.Payment_Purpose__c == null ? '' : rp.Payment_Purpose__c;
            objreceiptRequestWrapper.P_IN_TRANSACTION_REF = rp.Source_Receipt_Id__c == null ? rp.Receipt_Reference__c :  rp.Source_Receipt_Id__c;//rp.Transaction_Reference__c == null ? rp.Name : rp.Transaction_Reference__c;
            objreceiptRequestWrapper.P_IN_ORG_ID = rp.Entity__r.Oracle_Site_Id__c;        
            objreceiptRequestWrapper.P_IN_CURRENCY = rp.Payment_Currency__c;
            objreceiptRequestWrapper.P_IN_APPLY_DATE = amountAppliedDates.size() > 0 ? string.join(amountAppliedDates,',') :'';
            objreceiptRequestWrapper.P_IN_CATEGORY = rp.Category__c;
            objreceiptRequestWrapper.P_IN_REASON = rp.Reason__c;
            objreceiptRequestWrapper.P_IN_RECEIPT_DESC = rp.Source_Receipt_Id__c +' | '+ rp.Description__c.replace('\r\n',' ');
            objreceiptRequestWrapper.P_IN_INVOICE_NUMBER = String.join(oracleInvoices, ',');//rp.Related_Invoice__r.Oracle_Invoice_Id__c  == null ? '' : rp.Related_Invoice__r.Oracle_Invoice_Id__c;
                                        if(rp.Oracle_Receipt_Id__c == null || rp.Oracle_Receipt_Id__c == ''){objreceiptRequestWrapper.P_IN_REC_TYPE = rp.Transaction_Type__c;}
                                        else {objreceiptRequestWrapper.P_IN_REC_TYPE = 'Update';}
                
            objreceiptRequestWrapper.P_IN_AMT_APPLIED = String.join(amountApplieds,',');//String.valueOf(rp.Invoice_Amount_Applied__c) == null ? '' : String.valueOf(rp.Invoice_Amount_Applied__c);
            String sInputValue = JSON.serialize(objreceiptRequestWrapper);
            system.debug('Request Body---->'+sInputValue);
            // get endpoint details
            List<ERP_Endpoint_Details__mdt> listERPEndpointDetails = new List<ERP_Endpoint_Details__mdt>();
            listERPEndpointDetails = [SELECT ID,Endpoint_URL__c, Password__c, Username__c,HTTP_Method__c  FROM ERP_Endpoint_Details__mdt WHERE Is_Active__c = true AND DeveloperName =: 'Receipt_Creation' LIMIT 10];
            if(listERPEndpointDetails <> null && listERPEndpointDetails.size() > 0 ) {
                HTTPResponse objHTTPResponse = new HTTPResponse();
                objHTTPResponse = HTTPRestUtil.callWebservice(listERPEndpointDetails[0].Endpoint_URL__c, listERPEndpointDetails[0].HTTP_Method__c, sInputValue);
                system.debug('Response Body ---->'+objHTTPResponse.getBody());
                ReceiptResponseWrapper objReceiptResponseWrapper = new ReceiptResponseWrapper();       
                objReceiptResponseWrapper = (ReceiptResponseWrapper)JSON.deserialize(objHTTPResponse.getBody(), ReceiptResponseWrapper.class);
                system.debug('---->'+objReceiptResponseWrapper);
                system.debug('---->'+objReceiptResponseWrapper.P_OP_ORACLE_RECEIPT_NO);
                //save Payload on fail for reference purpose
                ApexCodeUtility.savePayload(listERPEndpointDetails[0].Endpoint_URL__c,sInputValue,ReceiptId,objHTTPResponse.getBody());
                
                List<Invoice__c> invoiceLst = new List<Invoice__c>();
                List<Related_Invoice_Receipt__c> relatedReceipts = new List<Related_Invoice_Receipt__c>();  
                rp.Message__c = objReceiptResponseWrapper.P_OP_ERROR_MSG;
                rp.Oracle_Callout_Status__c = objReceiptResponseWrapper.P_OP_STATUS;
                if(objReceiptResponseWrapper!=null && objReceiptResponseWrapper.P_OP_ORACLE_RECEIPT_NO!=null && objReceiptResponseWrapper.P_OP_STATUS =='S'){
                    rp.Pushed_to_Oracle__c = true;
                    if(rp.Oracle_Receipt_Id__c == null || rp.Oracle_Receipt_Id__c == ''){
                        rp.Oracle_Receipt_Id__c = objReceiptResponseWrapper.P_OP_ORACLE_RECEIPT_NO;
                    }
                    
                    //new field mapping
                    if(objReceiptResponseWrapper.P_OP_CONVERTED_AMT <> null && objReceiptResponseWrapper.P_OP_CONVERTED_AMT <> '')
                        rp.Converted_Amount__c = Decimal.valueOf(objReceiptResponseWrapper.P_OP_CONVERTED_AMT);
                    if(objReceiptResponseWrapper.P_OP_GL_DATE <> null && objReceiptResponseWrapper.P_OP_GL_DATE <> '') {
                        List<String> receiptDate = objReceiptResponseWrapper.P_OP_GL_DATE.split('-');
                        rp.Oracle_GL_Date__c = date.newinstance(Integer.valueOf(receiptDate[2]), Integer.valueOf(receiptDate[1]), Integer.valueOf(receiptDate[0]));
                    }
                    
                    if(objReceiptResponseWrapper.OP_APPL_INV_NO != null && objReceiptResponseWrapper.OP_APPL_INV_NO != ''){
                        List<String> invoiceNos1 = new List<String>();
                        List<String> appliedAmt = new List<String>();
                        List<String> unappliedAmt = new List<String>();
                        List<String> conAppliedAmt = new List<String>();
                        List<String> conUnappliedAmt = new List<String>();
                        List<String> invBalance = new List<String>();
                        List<String> conInvBalance = new List<String>();
                        if(objReceiptResponseWrapper.OP_APPL_INV_NO <> null && objReceiptResponseWrapper.OP_APPL_INV_NO <> '') {
                            invoiceNos1 = objReceiptResponseWrapper.OP_APPL_INV_NO.split(',');
                            invoiceNos1 = trimAllValues(invoiceNos1);
                        }
                            
                        if(objReceiptResponseWrapper.OP_AMT_APPLIED <> null && objReceiptResponseWrapper.OP_AMT_APPLIED <> '') {
                            appliedAmt = objReceiptResponseWrapper.OP_AMT_APPLIED.split(',');
                            appliedAmt = trimAllValues(appliedAmt);
                        }
                            
                        if(objReceiptResponseWrapper.OP_AMT_UNAPPLIED <> null && objReceiptResponseWrapper.OP_AMT_UNAPPLIED <> '') {
                            unappliedAmt = objReceiptResponseWrapper.OP_AMT_UNAPPLIED.split(',');
                            unappliedAmt = trimAllValues(unappliedAmt);
                        }
                        
                        if(objReceiptResponseWrapper.OP_AMT_UNAPPLIED <> null && objReceiptResponseWrapper.OP_AMT_UNAPPLIED <> '') {
                            unappliedAmt = objReceiptResponseWrapper.OP_AMT_UNAPPLIED.split(',');
                            unappliedAmt = trimAllValues(unappliedAmt);
                        }
                        
                        if(objReceiptResponseWrapper.P_OP_CONV_AMT_APPLIED <> null && objReceiptResponseWrapper.P_OP_CONV_AMT_APPLIED <> '') {
                            conAppliedAmt = objReceiptResponseWrapper.P_OP_CONV_AMT_APPLIED.split(',');
                            conAppliedAmt = trimAllValues(conAppliedAmt);
                        }
                        
                        if(objReceiptResponseWrapper.P_OP_CONV_RCPT_AMT_UNAPP <> null && objReceiptResponseWrapper.P_OP_CONV_RCPT_AMT_UNAPP <> '') {
                            conUnappliedAmt = objReceiptResponseWrapper.P_OP_CONV_RCPT_AMT_UNAPP.split(',');
                            conUnappliedAmt = trimAllValues(conUnappliedAmt);
                        }
                        
                        if(objReceiptResponseWrapper.OP_AMT_INV_BAL <> null && objReceiptResponseWrapper.OP_AMT_INV_BAL <> '') {
                            invBalance = objReceiptResponseWrapper.OP_AMT_INV_BAL.split(',');
                            invBalance = trimAllValues(invBalance);
                        }
                        
                        if(objReceiptResponseWrapper.P_OP_CONV_AMT_INV_BAL <> null && objReceiptResponseWrapper.P_OP_CONV_AMT_INV_BAL <> '') {
                            conInvBalance = objReceiptResponseWrapper.P_OP_CONV_AMT_INV_BAL.split(',');
                            conInvBalance = trimAllValues(conInvBalance);
                        }
                            
                        if(invoiceNos1 <> null && invoiceNos1.size() > 0) {
                            relatedReceipts = [SELECT Id,Invoice__c, Invoice__r.Oracle_Invoice_Id__c, Invoice__r.Invoice_Balance__c,Invoice__r.Converted_Invoice_Balance__c FROM Related_Invoice_Receipt__c WHERE Receipt__c =: rp.id AND Invoice__r.Oracle_Invoice_Id__c IN: invoiceNos1];
                            for(Integer i = 0; i< invoiceNos1.size(); i++){
                                for(Related_Invoice_Receipt__c obj : relatedReceipts){
                                    if(invoiceNos1[i] == obj.Invoice__r.Oracle_Invoice_Id__c){
                                        
                                        obj.ORACLE_Applied_Amount__c = (appliedAmt.size()-1) >= i ? Decimal.valueOf(appliedAmt[i]) : 0;
                                        obj.ORACLE_Unapplied_Amount__c = (unappliedAmt.size()-1) >= i ? Decimal.valueOf(unappliedAmt[i]) : 0;
                                        obj.Oracle_Converted_Applied_Amount__c = (conAppliedAmt.size()-1) >= i ? Decimal.valueOf(conAppliedAmt[i]) : 0;
                                        obj.Oracle_Converted_UnApplied_Amount__c = (conUnappliedAmt.size()-1) >= i ? Decimal.valueOf(conUnappliedAmt[i]) : 0;
                                        invoiceLst.add(new Invoice__c(id = obj.Invoice__c, Invoice_Balance__c = (invBalance.size()-1) >= i ? Decimal.valueof(invBalance[i]) : obj.Invoice__r.Invoice_Balance__c,
                                                                     Converted_Invoice_Balance__c = (conInvBalance.size()-1) >= i ? Decimal.valueof(conInvBalance[i]) : obj.Invoice__r.Invoice_Balance__c));
                                    }
                                }
                            }
                        }
                        
                    }
                }else if(objReceiptResponseWrapper!=null && objReceiptResponseWrapper.P_OP_STATUS!='S' && objReceiptResponseWrapper.P_OP_ERROR_MSG!=null){
                   
                    
                    rp.Message__c = objReceiptResponseWrapper.P_OP_ERROR_MSG;
                    update rp;
                    return objReceiptResponseWrapper.P_OP_ERROR_MSG;
                }
                 
                update rp;
                update invoiceLst;
                update relatedReceipts;
               
                if(objReceiptResponseWrapper.P_OP_ORACLE_RECEIPT_NO == null || objReceiptResponseWrapper.P_OP_ORACLE_RECEIPT_NO == '' ) {return 'Receipt oracle number not generated';}
            }
         }
        }catch(exception ex){
            System.debug(ex.getLineNumber());System.debug('---Receiptutil--->'+ex.getMessage());
            String sMessage = ex.getMessage();Log__c objLog = new Log__c();
            if(sMessage .length() > 240) {objLog.Message__c = sMessage.subString(0,240);} 
            else {objLog.Message__c = sMessage;}//end if
            objLog.Line_Number__c = ex.getLineNumber();objLog.Stack_Trace__c =  ex.getStackTraceString();objLog.Type_Name__c = ex.getTypeName();
            //objLog.User_Email__c = UserInfo.getUserEmail();
            insert objLog;
            return ex.getMessage();
        }
        
        return SUCCESS_MSG;
    }*/
    
    /*
        Method Name     :   PushReceiptToOracle
        Description     :   Http Callout to Informatica Cloud to create Receipt in Oracle
        Input Params    :   Receipt Record Id
    */
   /* @Future(callout=true)
    public static void PushReceiptToOracle_Future_New(List<string> listReceiptId){
        system.debug('Push to Oracle Receipt Called');
        //AND From_Data_Migration__c = false
        try{          
            List<Receipt__c> listReceipt = new List<Receipt__c>();
            List<Invoice__c> invoiceLst = new List<Invoice__c>();
            List<Related_Invoice_Receipt__c> relatedReceipts = new List<Related_Invoice_Receipt__c>();
            for(Receipt__c rp:[Select Id,Name,Receipt_Reference__c,Category__c,Reason__c,Oracle_Receipt_Id__c,Amount__c,Credit_Amount__c,Description__c,Entity__c,Entity__r.Oracle_Party_Id__c,EFT_Reference_No__c
                                    ,Payment_Currency__c,Payment_Method__c,Payment_Purpose__c,Receipt_Date__c,GL_Date__c,Transaction_Reference__c,Status__c, Transaction_Type__c,Authorization_Code__c
                                    , Entity__r.Oracle_Site_Id__c, Oracle_GL_Date__c, Converted_Amount__c, Source_Receipt_Id__c
                                    ,(SELECT Id,Invoice__r.Oracle_Invoice_Id__c,Applied_Date__c,Amount_Applied__c FROM Related_Invoices__r WHERE Direction__c =: 'From Receipt To Invoice' ORDER BY Invoice__r.Oracle_Invoice_Id__c ASC)
                                    from Receipt__c 
                                    where Id IN:listReceiptId and (Status__c='Success' or Status__c='Approved' or (Status__c='Rejected' AND Payment_Status__c = 'Payment Received from Incorrect Source')) AND From_Data_Migration__c = false]){
                List<String> invoiceNos = new List<String>();
                List<String> amntApplied = new List<String>();
                List<String> amountAppliedDates = new List<String>();
                if(rp.Related_Invoices__r.size() > 0 && rp.Status__c != 'Rejected'){
                    for(Related_Invoice_Receipt__c ri : rp.Related_Invoices__r){
                        invoiceNos.add(ri.Invoice__r.Oracle_Invoice_Id__c);
                         if(ri.Applied_Date__c <> null )
                            amountAppliedDates.add(ri.Applied_Date__c.day()+'-'+ri.Applied_Date__c.month()+'-'+ri.Applied_Date__c.year());
                        if(ri.Amount_Applied__c <> null)
                            amntApplied.add(String.valueOf(ri.Amount_Applied__c));
                    }
                }
                ReceiptRequestWrapper objreceiptRequestWrapper = new ReceiptRequestWrapper();
                objreceiptRequestWrapper.P_IN_ORACLE_ID = rp.Entity__r.Oracle_Party_Id__c;
                objreceiptRequestWrapper.P_IN_SFID = rp.Id;
                //if(rp.Source_Receipt_Id__c <> null && rp.Source_Receipt_Id__c <> '') {
                    //objreceiptRequestWrapper.P_IN_RECEIPT_REF = rp.Source_Receipt_Id__c;
                //} else {
                
                //}
                
                String transRef = '';
                if(rp.Payment_Method__c.contains('Card') && rp.Authorization_Code__c != null){
                    transRef = rp.Authorization_Code__c;
                    if([SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox){
                        //Integer randomNumber = Integer.valueof((Math.random() * 10000));
                        transRef = transRef+rp.Receipt_Reference__c;
                    }
                } else if(rp.Payment_Method__c == 'Electronic Funds Transfer' && rp.EFT_Reference_No__c != null){transRef = rp.EFT_Reference_No__c;}
                  else {transRef = rp.Transaction_Reference__c;}
                objreceiptRequestWrapper.P_IN_RECEIPT_REF = transRef == null || transRef == '' ? rp.Name : transRef;//rp.Source_Receipt_Id__c == null ? rp.Receipt_Reference__c :  rp.Source_Receipt_Id__c;
                
                List<API_Payload__c> payloadList = [SELECT Id, Response__c FROM API_Payload__c WHERE Receipt__c = :rp.Id ORDER BY CreatedDate DESC LIMIT 1];
                if(!payloadList.isEmpty()){
                    API_Payload__c payloadObj = payloadList[0];
                    if(String.isNotBlank(payloadObj.Response__c) && payloadObj.Response__c.contains('Accounting periods must be defined for the GL Date')){ rp.GL_Date__c = System.today();}
                }

                if(rp.Amount__c <> null )
                    objreceiptRequestWrapper.P_IN_RECEIPT_AMT = String.valueOf(rp.Amount__c);
                objreceiptRequestWrapper.P_IN_RECEIPT_DATE = rp.GL_Date__c != null ? rp.GL_Date__c.DAY()+'-'+rp.GL_Date__c.Month()+'-'+rp.GL_Date__c.Year() : rp.Receipt_Date__c.DAY()+'-'+rp.Receipt_Date__c.Month()+'-'+rp.Receipt_Date__c.Year();
                objreceiptRequestWrapper.P_IN_PAYMENT_METHOD = rp.Payment_Method__c;
                objreceiptRequestWrapper.P_IN_PAYMENT_PURPOSE = rp.Payment_Purpose__c == null ? '' : rp.Payment_Purpose__c;
                objreceiptRequestWrapper.P_IN_TRANSACTION_REF = rp.Source_Receipt_Id__c == null ? rp.Receipt_Reference__c :  rp.Source_Receipt_Id__c;//rp.Transaction_Reference__c == null ? rp.Name : rp.Transaction_Reference__c;
                objreceiptRequestWrapper.P_IN_ORG_ID = rp.Entity__r.Oracle_Site_Id__c;        
                objreceiptRequestWrapper.P_IN_CURRENCY = rp.Payment_Currency__c;
                objreceiptRequestWrapper.P_IN_APPLY_DATE = amountAppliedDates.size() > 0 ? string.join(amountAppliedDates,',') :'';
                objreceiptRequestWrapper.P_IN_CATEGORY = rp.Category__c;
                objreceiptRequestWrapper.P_IN_REASON = rp.Reason__c;
                objreceiptRequestWrapper.P_IN_RECEIPT_DESC = rp.Source_Receipt_Id__c +' | '+ rp.Description__c.replace('\r\n',' ');
                //objreceiptRequestWrapper.P_IN_INVOICE_NUMBER = rp.Related_Invoice__r.Oracle_Invoice_Id__c  == null ? '' : rp.Related_Invoice__r.Oracle_Invoice_Id__c;
                objreceiptRequestWrapper.P_IN_INVOICE_NUMBER = invoiceNos.size() > 0 ? string.join(invoiceNos,',') :'';
                if(rp.Oracle_Receipt_Id__c == null || rp.Oracle_Receipt_Id__c == '')
                    objreceiptRequestWrapper.P_IN_REC_TYPE = rp.Transaction_Type__c;
                else 
                    objreceiptRequestWrapper.P_IN_REC_TYPE = 'Update';
                //objreceiptRequestWrapper.P_IN_AMT_APPLIED = String.valueOf(rp.Invoice_Amount_Applied__c) == null ? '' : String.valueOf(rp.Invoice_Amount_Applied__c);
                objreceiptRequestWrapper.P_IN_AMT_APPLIED = amntApplied.size() > 0 ? string.join(amntApplied,',') :'';
                String sInputValue = JSON.serialize(objreceiptRequestWrapper);
                system.debug('Request Body----->'+sInputValue);
                // get endpoint details
                List<ERP_Endpoint_Details__mdt> listERPEndpointDetails = new List<ERP_Endpoint_Details__mdt>();
                listERPEndpointDetails = [SELECT ID,Endpoint_URL__c, Password__c, Username__c,HTTP_Method__c  FROM ERP_Endpoint_Details__mdt WHERE Is_Active__c = true AND DeveloperName =: 'Receipt_Creation' LIMIT 10];
                if(listERPEndpointDetails <> null && listERPEndpointDetails.size() > 0 ) {
                    HTTPResponse objHTTPResponse = new HTTPResponse();
                    objHTTPResponse = HTTPRestUtil.callWebservice(listERPEndpointDetails[0].Endpoint_URL__c, listERPEndpointDetails[0].HTTP_Method__c, sInputValue);
                    system.debug('Response Body----->'+objHTTPResponse.getBody());
                    ReceiptResponseWrapper objReceiptResponseWrapper = new ReceiptResponseWrapper();       
                    objReceiptResponseWrapper = (ReceiptResponseWrapper)JSON.deserialize(objHTTPResponse.getBody(), ReceiptResponseWrapper.class);
                    system.debug('---->'+objReceiptResponseWrapper);
                    system.debug('---->'+objReceiptResponseWrapper.P_OP_ORACLE_RECEIPT_NO);
                    
                    //save Payload on fail for reference purpose
                    ApexCodeUtility.savePayload(listERPEndpointDetails[0].Endpoint_URL__c,sInputValue,rp.Id,objHTTPResponse.getBody());
                    
                    if(objReceiptResponseWrapper!=null && objReceiptResponseWrapper.P_OP_ORACLE_RECEIPT_NO!=null){
                        rp.Pushed_to_Oracle__c = true;
                        if(rp.Oracle_Receipt_Id__c == null || rp.Oracle_Receipt_Id__c == ''){
                            rp.Oracle_Receipt_Id__c = objReceiptResponseWrapper.P_OP_ORACLE_RECEIPT_NO;
                        }
                        
                        rp.Message__c = objReceiptResponseWrapper.P_OP_ERROR_MSG; 
                        //new field mapping
                        if(objReceiptResponseWrapper.P_OP_CONV_AMOUNT <> null && objReceiptResponseWrapper.P_OP_CONV_AMOUNT <> '')
                            rp.Converted_Amount__c = Decimal.valueOf(objReceiptResponseWrapper.P_OP_CONV_AMOUNT);
                        if(objReceiptResponseWrapper.P_OP_GL_DATE <> null && objReceiptResponseWrapper.P_OP_GL_DATE <> '') {
                            List<String> receiptDate = objReceiptResponseWrapper.P_OP_GL_DATE.split('-');
                            rp.Oracle_GL_Date__c = date.newinstance(Integer.valueOf(receiptDate[2]), Integer.valueOf(receiptDate[1]), Integer.valueOf(receiptDate[0]));
                        }
                            
                        listReceipt.add(rp);

                        if(objReceiptResponseWrapper.OP_APPL_INV_NO != null && objReceiptResponseWrapper.OP_APPL_INV_NO != '' && objReceiptResponseWrapper.P_OP_STATUS =='S'){
                            List<String> invoiceNos1 = new List<String>();
                            List<String> appliedAmt = new List<String>();
                            List<String> unappliedAmt = new List<String>();
                            List<String> conAppliedAmt = new List<String>();
                            List<String> conUnappliedAmt = new List<String>();
                            List<String> invBalance = new List<String>();
                            List<String> conInvBalance = new List<String>();
                            if(objReceiptResponseWrapper.OP_APPL_INV_NO <> null && objReceiptResponseWrapper.OP_APPL_INV_NO <> ''){
                                invoiceNos1 = objReceiptResponseWrapper.OP_APPL_INV_NO.split(',');
                                invoiceNos1 = trimAllValues(invoiceNos1);
                            }
                            if(objReceiptResponseWrapper.OP_AMT_APPLIED <> null && objReceiptResponseWrapper.OP_AMT_APPLIED <> '') {
                                appliedAmt = objReceiptResponseWrapper.OP_AMT_APPLIED.split(',');
                                appliedAmt = trimAllValues(appliedAmt);
                            }
                                
                            if(objReceiptResponseWrapper.P_OP_CONV_AMT_APPLIED <> null && objReceiptResponseWrapper.P_OP_CONV_AMT_APPLIED <> '') {
                                conAppliedAmt = objReceiptResponseWrapper.P_OP_CONV_AMT_APPLIED.split(',');
                                conAppliedAmt = trimAllValues(conAppliedAmt);
                            }
                            
                            if(objReceiptResponseWrapper.P_OP_CONV_RCPT_AMT_UNAPP <> null && objReceiptResponseWrapper.P_OP_CONV_RCPT_AMT_UNAPP <> '') {
                                conUnappliedAmt = objReceiptResponseWrapper.P_OP_CONV_RCPT_AMT_UNAPP.split(',');
                                conUnappliedAmt = trimAllValues(conUnappliedAmt);
                            }
                                
                            if(objReceiptResponseWrapper.OP_AMT_INV_BAL <> null && objReceiptResponseWrapper.OP_AMT_INV_BAL <> '') {
                                invBalance = objReceiptResponseWrapper.OP_AMT_INV_BAL.split(',');
                                invBalance = trimAllValues(invBalance);
                            }
                            
                            if(objReceiptResponseWrapper.P_OP_CONV_AMT_INV_BAL <> null && objReceiptResponseWrapper.P_OP_CONV_AMT_INV_BAL <> '') {
                                conInvBalance = objReceiptResponseWrapper.P_OP_CONV_AMT_INV_BAL.split(',');
                                conInvBalance = trimAllValues(conInvBalance);
                            }

                                
                            if(invoiceNos1 <> null && invoiceNos1.size() > 0) {
                                relatedReceipts = [SELECT Id,Invoice__c, Invoice__r.Oracle_Invoice_Id__c, Invoice__r.Invoice_Balance__c, Invoice__r.Converted_Invoice_Balance__c FROM Related_Invoice_Receipt__c WHERE Receipt__c =: rp.id AND Invoice__r.Oracle_Invoice_Id__c IN: invoiceNos1];
                                for(Integer i = 0; i< invoiceNos1.size(); i++){
                                    for(Related_Invoice_Receipt__c obj : relatedReceipts){
                                        if(invoiceNos1[i] == obj.Invoice__r.Oracle_Invoice_Id__c){
                                            
                                            obj.ORACLE_Applied_Amount__c = (appliedAmt.size()-1) >= i ? Decimal.valueOf(appliedAmt[i]) : 0;
                                            obj.ORACLE_Unapplied_Amount__c = (unappliedAmt.size()-1) >= i ? Decimal.valueOf(unappliedAmt[i]) : 0;
                                            obj.Oracle_Converted_Applied_Amount__c = (conAppliedAmt.size()-1) >= i ? Decimal.valueOf(conAppliedAmt[i]) : 0;
                                            obj.Oracle_Converted_UnApplied_Amount__c = (conUnappliedAmt.size()-1) >= i ? Decimal.valueOf(conUnappliedAmt[i]) : 0;
                                            invoiceLst.add(new Invoice__c(id = obj.Invoice__c, Invoice_Balance__c = (invBalance.size()-1) >= i ? Decimal.valueof(invBalance[i]) : obj.Invoice__r.Invoice_Balance__c,
                                                                         Converted_Invoice_Balance__c = (conInvBalance.size()-1) >= i ? Decimal.valueof(conInvBalance[i]) : obj.Invoice__r.Invoice_Balance__c));
                                        }
                                    }
                                }
                            }
                            
                        }
                    }else if(objReceiptResponseWrapper!=null && objReceiptResponseWrapper.P_OP_STATUS!='S' && objReceiptResponseWrapper.P_OP_ERROR_MSG!=null){
                        
                        
                        rp.Message__c = objReceiptResponseWrapper.P_OP_ERROR_MSG;
                        listReceipt.add(rp);
                    }
                }
            }//end for
            if(listReceipt <> null && listReceipt.size() > 0) {update listReceipt;}
            if(invoiceLst.size() > 0){ update invoiceLst;}
               
            if(relatedReceipts.size() > 0){update relatedReceipts;}
                
        }catch(exception ex){
            String sMessage = ex.getMessage();Log__c objLog = new Log__c();
            if(sMessage .length() > 240) {objLog.Message__c = sMessage.subString(0,240);} 
            else {objLog.Message__c = sMessage;}//end if
            
            objLog.Line_Number__c = ex.getLineNumber();objLog.Stack_Trace__c =  ex.getStackTraceString();objLog.Type_Name__c = ex.getTypeName();
            //objLog.User_Email__c = UserInfo.getUserEmail();
            insert objLog;
        }
        
    }*/
    public static List<String> trimAllValues (List<String> listValues) {
        List<String> listTrimmedValues = new List<String>();
        for(String objVal : listValues) {listTrimmedValues.add(objVal.trim());}
        return listTrimmedValues;
    }
    
    public static String PushReceiptReversalToOracle(string ReceiptId){
        try{
            Receipt__c rectObj = new Receipt__c(Id = ReceiptId, Is_Reversed__c = true);
            UPDATE rectObj;
            String msg = 'SUCCESS';
            /*String sInputValue = '';
            List<Invoice__c> invoicesToUpdate = new List<Invoice__c>();
            List<Related_Invoice_Receipt__c> relatedReceiptstoUpdate = new List<Related_Invoice_Receipt__c>();
            for(Receipt__c rp:[Select Id,Name,Receipt_Reference__c,Oracle_Receipt_Id__c,Amount__c,Credit_Amount__c,Description__c,Entity__c,Entity__r.Oracle_Party_Id__c
                                ,Payment_Currency__c,Payment_Method__c,Payment_Purpose__c,Receipt_Date__c,GL_Date__c,Transaction_Reference__c,Status__c, Transaction_Type__c
                                , Entity__r.Oracle_Site_Id__c,Source_Receipt_Id__c,Category__c,Reason__c,Reversal_Date__c,Authorization_Code__c,
                                (SELECT id,Invoice__c,Invoice__r.Oracle_Invoice_Id__c,Invoice__r.Invoice_Balance__c FROM Related_Invoices__r)
                                from Receipt__c where Id=:ReceiptId and Pushed_to_Oracle__c = true AND Is_Reversed__c = false LIMIT 1]){
                ReceiptRequestWrapper objreceiptRequestWrapper = new ReceiptRequestWrapper();
                objreceiptRequestWrapper.P_IN_ORACLE_ID = rp.Entity__r.Oracle_Party_Id__c;
                objreceiptRequestWrapper.P_IN_SFID = rp.Id;
                String transRef = '';
                if(rp.Payment_Method__c != null){
                    if(rp.Payment_Method__c.contains('Card') && rp.Authorization_Code__c != null){
                        transRef = rp.Authorization_Code__c;
                        if([SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox){
                            //Integer randomNumber = Integer.valueof((Math.random() * 10000));
                            //transRef = transRef+randomNumber;
                            transRef = transRef+rp.Receipt_Reference__c;
                        }
                    } else if(rp.Payment_Method__c == 'Electronic Funds Transfer' && rp.EFT_Reference_No__c != null){
                        transRef = rp.EFT_Reference_No__c;
                    } else {
                        transRef = rp.Transaction_Reference__c;
                    }
                }else {
                    transRef = rp.Transaction_Reference__c;
                }

                List<API_Payload__c> payloadList = [SELECT Id, Response__c FROM API_Payload__c WHERE Receipt__c = :rp.Id ORDER BY CreatedDate DESC LIMIT 1];
                if(!payloadList.isEmpty()){
                    API_Payload__c payloadObj = payloadList[0];
                    if(String.isNotBlank(payloadObj.Response__c) && payloadObj.Response__c.contains('Accounting periods must be defined for the GL Date')){
                        rp.GL_Date__c = System.today();
                    }
                }

                objreceiptRequestWrapper.P_IN_RECEIPT_REF = transRef;//rp.Receipt_Reference__c == null ? '' : rp.Receipt_Reference__c;
                if(rp.Amount__c <> null)
                    objreceiptRequestWrapper.P_IN_RECEIPT_AMT = String.valueOf(rp.Amount__c);
                objreceiptRequestWrapper.P_IN_RECEIPT_DATE = rp.GL_Date__c != null ? rp.GL_Date__c.DAY()+'-'+rp.GL_Date__c.Month()+'-'+rp.GL_Date__c.Year() : rp.Receipt_Date__c.DAY()+'-'+rp.Receipt_Date__c.Month()+'-'+rp.Receipt_Date__c.Year();
                objreceiptRequestWrapper.P_IN_PAYMENT_METHOD = rp.Payment_Method__c;
                objreceiptRequestWrapper.P_IN_PAYMENT_PURPOSE = rp.Payment_Purpose__c == null ? '' : rp.Payment_Purpose__c;
                objreceiptRequestWrapper.P_IN_TRANSACTION_REF = rp.Transaction_Reference__c == null ? rp.Name : rp.Transaction_Reference__c;
                objreceiptRequestWrapper.P_IN_ORG_ID = rp.Entity__r.Oracle_Site_Id__c;        
                objreceiptRequestWrapper.P_IN_CURRENCY = rp.Payment_Currency__c;
                objreceiptRequestWrapper.P_IN_INVOICE_NUMBER = '';//invoiceNos.size() > 0 ? string.join(invoiceNos,',') :'';
                objreceiptRequestWrapper.P_IN_REC_TYPE = 'reverse';
                objreceiptRequestWrapper.P_IN_AMT_APPLIED = '';//amntApplied.size() > 0 ? string.join(amntApplied,',') :'';
                objreceiptRequestWrapper.P_IN_APPLY_DATE = rp.Reversal_Date__c != null ? rp.Reversal_Date__c.day()+'-'+rp.Reversal_Date__c.month()+'-'+rp.Reversal_Date__c.year() : Date.today().day()+'-'+Date.today().month()+'-'+Date.today().year();
                objreceiptRequestWrapper.P_IN_CATEGORY = rp.Category__c;
                objreceiptRequestWrapper.P_IN_REASON = rp.Reason__c;
                sInputValue = JSON.serialize(objreceiptRequestWrapper);
                system.debug('Request Body----->'+sInputValue);
                
                List<ERP_Endpoint_Details__mdt> listERPEndpointDetails = new List<ERP_Endpoint_Details__mdt>();
                listERPEndpointDetails = [SELECT ID,Endpoint_URL__c, Password__c, Username__c,HTTP_Method__c  FROM ERP_Endpoint_Details__mdt WHERE Is_Active__c = true AND DeveloperName =: 'Receipt_Creation' LIMIT 10];
                if(listERPEndpointDetails <> null && listERPEndpointDetails.size() > 0 ) {
                    HTTPResponse objHTTPResponse = new HTTPResponse();
                    objHTTPResponse = HTTPRestUtil.callWebservice(listERPEndpointDetails[0].Endpoint_URL__c, listERPEndpointDetails[0].HTTP_Method__c, sInputValue);
                    system.debug('Response Body----->'+objHTTPResponse.getBody());
                    ReceiptResponseWrapper objReceiptResponseWrapper = new ReceiptResponseWrapper();       
                    objReceiptResponseWrapper = (ReceiptResponseWrapper)JSON.deserialize(objHTTPResponse.getBody(), ReceiptResponseWrapper.class);
                    
                    rp.Message__c = objReceiptResponseWrapper.P_OP_ERROR_MSG;
                    msg = objReceiptResponseWrapper.P_OP_ERROR_MSG;
                    if(objReceiptResponseWrapper.P_OP_STATUS == 'S'){
                        rp.Is_Reversed__c = true;
                        if(objReceiptResponseWrapper.OP_APPL_INV_NO != null && objReceiptResponseWrapper.OP_APPL_INV_NO != null && objReceiptResponseWrapper.OP_AMT_INV_BAL != null && objReceiptResponseWrapper.OP_AMT_INV_BAL != null){
                            List<String> invNos = new List<String>();
                            List<String> invAmnts = new List<String>();
                            Map<String,Related_Invoice_Receipt__c> invOracleVsRelatedInvRec = new Map<String,Related_Invoice_Receipt__c>();
                            invNos = objReceiptResponseWrapper.OP_APPL_INV_NO.split(',');
                            invAmnts = objReceiptResponseWrapper.OP_AMT_INV_BAL.split(',');
                            for(Related_Invoice_Receipt__c relatedInv : rp.Related_Invoices__r){
                                relatedInv.Status__c = 'Receipt Reversed';
                                relatedReceiptstoUpdate.add(relatedInv);
                                invOracleVsRelatedInvRec.put(relatedInv.Invoice__r.Oracle_Invoice_Id__c, relatedInv);
                            }
                            for(Integer i =0; i < invNos.size(); i++){
                                if(invOracleVsRelatedInvRec.containskey(invNos[i])){
                                    invoicesToUpdate.add(new Invoice__c(Id=invOracleVsRelatedInvRec.get(invNos[i]).Invoice__c, Invoice_Balance__c=Decimal.valueof(invAmnts[i])));
                                    //Invoice_Balance__c=(invOracleVsRelatedInvRec.get(invNos[i]).Invoice__r.Invoice_Balance__c+ Decimal.valueof(invAmnts[i]))
                                }
                            }
                        }
                        msg = 'SUCCESS';
                    }
                    //save Payload on fail for reference purpose
                    ApexCodeUtility.savePayload(listERPEndpointDetails[0].Endpoint_URL__c,sInputValue,rp.Id,objHTTPResponse.getBody());
                    List<Id> headerIds = new List<Id>();
                    for(Journal_Header__c headerObj : [SELECT Id FROM Journal_Header__c WHERE Receipt__c = :rp.Id AND Transaction_Type__c = 'Receipt' LIMIT 1]){
                        headerIds.add(headerObj.Id);
                    }
                    BM_JournalEntryEngine.journalEntryCreationForHeaderReversal(headerIds, 'Receipt Reversal');
                    update rp;
                }
            }
            if(invoicesToUpdate.size() > 0){
                update invoicesToUpdate;
            }
            
            if(relatedReceiptstoUpdate.size() > 0){
                update relatedReceiptstoUpdate;
            }*/
            List<Id> headerIds = new List<Id>();
            for(Journal_Header__c headerObj : [SELECT Id FROM Journal_Header__c WHERE Receipt__c = :rectObj.Id AND Transaction_Type__c = 'Receipts' LIMIT 1]){headerIds.add(headerObj.Id);}
            BM_JournalEntryEngine.journalEntryCreationForHeaderReversal(headerIds, 'Receipt Reversal');
            return msg;
        } catch(Exception ex){String sMessage = ex.getMessage();Log__c objLog = new Log__c();if(sMessage .length() > 240) {objLog.Message__c = sMessage.subString(0,240);} else {objLog.Message__c = sMessage;}//end if
            objLog.Line_Number__c = ex.getLineNumber();objLog.Stack_Trace__c =  ex.getStackTraceString();objLog.Type_Name__c = ex.getTypeName();insert objLog;return ex.getMessage();
        }
    }
    
    public class ReceiptRequestWrapper {
        public string P_IN_ORACLE_ID;
        public string P_IN_SFID;
        public string P_IN_RECEIPT_REF;
        public string P_IN_RECEIPT_AMT;
        public string P_IN_RECEIPT_DATE;
        public string P_IN_PAYMENT_METHOD;
        public string P_IN_PAYMENT_PURPOSE;
        public string P_IN_TRANSACTION_REF;
        public string P_IN_ORG_ID;
        public string P_IN_CURRENCY;
        public string P_IN_INVOICE_NUMBER;
        public string P_IN_REC_TYPE;
        public string P_IN_AMT_APPLIED;
        public string P_IN_APPLY_DATE;
        public string P_IN_CATEGORY;
        public string P_IN_REASON;
        //public string P_IN_RECEIPT_NUMBER;
        public string P_IN_RECEIPT_DESC;
    }
    
    public class ReceiptResponseWrapper {
        public string P_OP_STATUS;
        public string P_OP_SFID;
        public string P_OP_ORACLE_RECEIPT_NO;
        public string P_OP_ERROR_MSG;
        public string P_OP_CUSTOMER_ID;
        public string P_OP_SITE_ID;
        public string P_OP_CONVERTED_AMT;
        public string P_OP_GL_DATE;
        public string OP_APPL_INV_NO;
        public string OP_AMT_APPLIED;
        public string OP_AMT_INV_BAL;
        public string OP_AMT_UNAPPLIED;
        public string P_OP_CONV_AMOUNT;
        public string P_OP_CONV_AMT_APPLIED;
        public string P_OP_CONV_AMT_INV_BAL;
        public string P_OP_CONV_RCPT_AMT_UNAPP;
    }
}
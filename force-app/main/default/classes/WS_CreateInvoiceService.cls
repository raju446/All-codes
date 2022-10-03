/*
    Author      : Jayanta Karmakar
    Date        : 06-Feb-2020
    Description : Webservice class to create the Invoice for billing management(ecourt).
    
    Version History:
    Prachi        07-Feb-2021    Changed the inv_date to String parameter and typecasted to Date
    --------------------------------------------------------------------------------------------
*/
global class WS_CreateInvoiceService {
    webservice static ResponseDetails ProcessInvoice(InputParameters_Class invoiceInfo){
        ResponseDetails responseObj = new ResponseDetails();
        responseObj.InvoiceId = invoiceInfo.Source_Invoice_Id;
        responseObj.SF_Id = '';
        String MessageDetails = '';
        system.debug(invoiceInfo);
        try{
            List<String> errorMsgs = new List<String>();
            for(Invoice_Lines_Wrapper objLineWrapper : invoiceInfo.Invoice_Lines) {
                if(objLineWrapper.ITEM_DESC == null || objLineWrapper.ITEM_DESC == ''){
                    errorMsgs.add('Item Description can not be null / blank');    
                }
            }

            if(invoiceInfo.REFERENCE_ID == null || invoiceInfo.REFERENCE_ID == ''){
                errorMsgs.add('REFERENCE_ID can not be null / blank');   
            } else {
                List<Account> accs = [select id from Account WHERE Id=: invoiceInfo.REFERENCE_ID];
                if(accs.size() < 1){
                    errorMsgs.add('No Customer found with the given REFERENCE_ID');
                }
            }
            if(invoiceInfo.INV_TYPE == null || invoiceInfo.INV_TYPE == ''){
                errorMsgs.add('INV_TYPE can not be null / blank');   
            }
            
            /*if(receiptInfo.Amount == null || receiptInfo.Amount == ''){
                errorMsgs.add('Amount can not be null / blank');   
            }
            if(receiptInfo.Reference_Id == null || receiptInfo.Reference_Id == ''){
                errorMsgs.add('Reference_Id can not be null / blank');   
            } */
            if(errorMsgs.size() > 0){
                responseObj.Success = false;
                MessageDetails = 'Please Review the below Error Messages :';
                MessageDetails += String.join(errorMsgs,',');   
                responseObj.Status_Code = '600';
            } else {
                List<Invoice__c> invoices =[SELECT id from Invoice__c WHERE Source_Invoice_Id__c =: invoiceInfo.SOURCE_INVOICE_ID LIMIT 1];
                String operation = 'created';
                Invoice__c invObj = new Invoice__c();
                if(invoices.size() > 0){
                    invObj.Id = invoices[0].id;
                    operation = 'updated';
                } else {
                    invObj.Source_Invoice_Id__c = invoiceInfo.SOURCE_INVOICE_ID;
                }
                
				invObj.Source_SFID__c = invoiceInfo.SOURCE_SF_ID;
                invObj.Description__c = invoiceInfo.INV_DESC;
                //invObj.Invoice_Type__c = invoiceInfo.INV_TYPE;
                invObj.Entity__c = invoiceInfo.REFERENCE_ID;
                invObj.Oracle_Invoice_Type__c = invoiceInfo.INV_TYPE;
                if(invoiceInfo.INV_DATE != null){
                    List<String> dtString = new List<String>();
                    dtString = invoiceInfo.INV_DATE.split('/');
                    system.debug('------>'+dtString);
                    invObj.Invoice_Date__c = datetime.newInstance(Integer.valueOf(dtString[0]), Integer.valueOf(dtString[1]), Integer.valueOf(dtString[2]));//invoiceInfo.INV_DATE;
                    invObj.GL_Date__c = datetime.newInstance(Integer.valueOf(dtString[0]), Integer.valueOf(dtString[1]), Integer.valueOf(dtString[2]));//invoiceInfo.INV_DATE;
                }
                
                String pTerm = '';
                if(invoiceInfo.PAYMENT_TERM == 'Immediate'){
                    pTerm = 'Immediate';
                } else if (invoiceInfo.PAYMENT_TERM == '21 NET'){
                    pTerm = '21 Net';
                } else {
                    pTerm = invoiceInfo.PAYMENT_TERM;
                }
                invObj.Payment_Term__c = pTerm;//invoiceInfo.PAYMENT_TERM;
                invObj.Payment_Currency__c = invoiceInfo.INV_CURRENCY;
                invObj.Status__c = 'Draft';
                invObj.Source_System__c = invoiceInfo.SOURCESYSTEM;
               // invObj.Related_Receipt__c = invoiceInfo.RECEIPT_NO ==''?null:invoiceInfo.RECEIPT_NO;
                invObj.Invoice_Class__c = 'Invoice';
                if(invoiceInfo.RECEIPT_NO !='' && invoiceInfo.RECEIPT_NO !=null){
                    invObj.Transaction_Type__c = 'Wallet';
                } else {
                    invObj.Transaction_Type__c = 'NonWallet';
                }
                
                upsert invObj;
                
                if(invoiceInfo.RECEIPT_NO !='' && invoiceInfo.RECEIPT_NO !=null){
                    List<String> receiptsList = new List<String>();
                    receiptsList = invoiceInfo.RECEIPT_NO.split(',');
                    List<Related_Invoice_Receipt__c> relatedReceipt = new List<Related_Invoice_Receipt__c>();
                    for(String eachReceiptId : receiptsList){
                        relatedReceipt.add(new Related_Invoice_Receipt__c(Invoice__c = invObj.id,Receipt__c=eachReceiptId, Direction__c = 'From Invoice To Receipt'));
                    }

                    if(relatedReceipt.size() > 0){
                        insert relatedReceipt;
                    }
                }

                if(invoiceInfo.Invoice_Lines.size() > 0){
                    List<Invoice_Line_Item__c> lineItemsToInsert = new List<Invoice_Line_Item__c>();
                    for(Invoice_Lines_Wrapper eachLine : invoiceInfo.Invoice_Lines){
                        Invoice_Line_Item__c lineObj = new Invoice_Line_Item__c();
                        lineObj.Amount__c = eachLine.AMOUNT;
                        lineObj.Tax_Amount__c = eachLine.TAX_AMOUNT;
                        lineObj.Item_Description__c = eachLine.ITEM_DESC;
                        lineObj.Item_Reference__c = eachLine.ITEM_REF;
                        lineObj.Discount_Amount__c = eachLine.INV_DISCOUNT_AMT;
                        lineObj.Taxable_Discount_Amount__c = eachLine.INV_DISCOUNT_TAX_AMT;
                        lineObj.Invoice__c = invObj.id;
                        lineObj.Source_Invoice_Line_Id__c = eachLine.SOURCE_INVOICE_LINE_ID;
                        lineObj.Line_Description__c = eachLine.LINE_ITEM_TYPE;
                        //it's a hot fix, we need to change this logic in future to use configuration.
                        if(String.isNotBlank(invoiceInfo.SOURCESYSTEM) && eachLine.TAX_CODE.contains('0%')){
                               lineObj.Tax__c = 'Out of scope 0%';
                           }else{
                               lineObj.Tax__c = eachLine.TAX_CODE;//'0%';       
                           }
                        
                        lineObj.Service_Type__c = eachLine.SERVICE_TYPE;
                        lineObj.Revenue_Type__c = eachLine.REVENUE_TYPE;
                        lineObj.Department__c = eachLine.DEPARTMENT;
                        lineObj.Quantity__c = eachLine.QUANTITY;
                        lineObj.Course_Type__c = eachLine.PROJECT_SEGMENT;
                        lineObj.Schools__c = eachLine.PROGRAM_CODE;
                        if(eachLine.REVENUE_TYPE.startsWith('Discount')){
                            lineObj.Is_Discount__c = true;
                        }
                        lineItemsToInsert.add(lineObj);
                    }

                    insert lineItemsToInsert;


                    for(Invoice_Line_Item__c eachLine : lineItemsToInsert){
                        Invoice_Line_Response lineRespObj = new Invoice_Line_Response();
                        lineRespObj.INV_LINE_SF_Id = eachLine.Id;
                        lineRespObj.InvoiceLineId = eachLine.Source_Invoice_Line_Id__c;
                        responseObj.InvoiceLines.add(lineRespObj);
                    }
                    invObj.Status__c = 'Approved';
                    UPDATE invObj;
                }

                responseObj.SF_Id = invObj.id;
                responseObj.Success = true;
                responseObj.Status_Code = '200';
                MessageDetails = 'Invoice '+operation+' successfully!';
            }    
        } catch(Exception e){
            responseObj.Success = false;
            responseObj.Status_Code = '600';
            String errMsg = 'Please Review the below Error Messages :'+ e.getMessage();
            responseObj.Messages = errMsg;
            return responseObj;
        }

        responseObj.Messages = MessageDetails;
        return responseObj;
    }

    global class InputParameters_Class{
        webservice string SOURCE_INVOICE_ID;
        webservice string SOURCE_SF_ID;
       // webservice string INV_SR_REF;
       // webservice string ORA_CUST_ID;
        webservice string INV_DESC;
        webservice String INV_DATE;
       // webservice string ORG_ID;
        //webservice string INV_CLASS;
        webservice string PAYMENT_TERM;
        webservice string INV_CURRENCY;
        //webservice string INV_STATUS;
        webservice string REFERENCE_ID; 
        webservice string RECEIPT_NO;
        webservice string INV_TYPE; //(can be refer as Transaction type)
        webservice string SOURCESYSTEM;
        webservice List<Invoice_Lines_Wrapper> Invoice_Lines;
        webservice string FUTURE_1;
        webservice string FUTURE_2;
        webservice string FUTURE_3;
    }

    global class Invoice_Lines_Wrapper{
        webservice String SOURCE_INVOICE_LINE_ID ;
        webservice Decimal INV_DISCOUNT_TAX_AMT;
        webservice Decimal INV_DISCOUNT_AMT;
        webservice string ITEM_REF;
        webservice Decimal AMOUNT;
        webservice Decimal TAX_AMOUNT;
        webservice Integer QUANTITY;
        webservice string TAX_CODE;
        webservice string ITEM_DESC; // Line Item Type
        webservice String LINE_ITEM_TYPE; // Free Text field
        webservice string SERVICE_TYPE;
        webservice string REVENUE_TYPE;
        webservice string DEPARTMENT;
        webservice string PROJECT_SEGMENT;
        webservice string PROGRAM_CODE;
    }

    global class ResponseDetails{
        webservice string SF_Id;
        webservice string InvoiceId;
        webservice boolean Success;
        webservice string Messages; 
        webservice string Status_Code;
        webservice List<Invoice_Line_Response> InvoiceLines;
        global ResponseDetails(){
            InvoiceLines = new List<Invoice_Line_Response>();
        }
    }

    global class Invoice_Line_Response{
        webservice string INV_LINE_SF_Id;
        webservice string InvoiceLineId;
    }
}
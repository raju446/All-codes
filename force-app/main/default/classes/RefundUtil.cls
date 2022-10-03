/**
 * @File Name          : RefundUtil.cls
 * @Description        : 
 * @Author             : Jayanta Karmakar 
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 11-30-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/29/2020   Jayanta Karmakar     Initial Version
**/
public class RefundUtil {
    
    //
    public static IBANElements getIBANDetail_New(String entityId, String IBANNum) {
        try{
            IBANElements ibanEle = new IBANElements();
            if(entityId <> null && entityId <> '' && IBANNum <> null && IBANNum <> '') {
                Account acc = [SELECT Id,Oracle_Site_Id__c FROM Account WHERE Id =: entityId];
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:FusionCloud/XXADGM_EXT_SUPPLIER_IBAN/1.0/getSupplier?iban='+IBANNum+'&org_code='+acc.Oracle_Site_Id__c);
            request.setMethod('GET');
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                System.debug('Response==='+response.getBody());
                
                List<IBANElements> ibanEl = new List<IBANElements>();
                ibanEl = (List<IBANElements>)JSON.deserialize(response.getBody(), List<IBANElements>.class);
                
                 System.debug('ibanEl==='+ibanEl);
                
                //ResponseIBANWrapper respObj = new ResponseIBANWrapper();
                //respObj = (ResponseIBANWrapper)JSON.deserialize(response.getBody(), ResponseIBANWrapper.class);
                
                for(IBANElements rt : ibanEl){
                    ibanEle.VENDOR_NAME = rt.VENDOR_NAME;
                    ibanEle.VENDOR_NUMBER = rt.VENDOR_NUMBER;
                    ibanEle.VENDOR_SITE_CODE = rt.VENDOR_SITE_CODE;
                    ibanEle.BANK_NAME = rt.BANK_NAME;
                    ibanEle.IBAN = rt.IBAN;
                    ibanEle.BANK_ACCOUNT_NUM = rt.BANK_ACCOUNT_NUM;
                }
                System.debug('ibanEle==='+ibanEle);
                
            }
            }
            return ibanEle;
        } catch(Exception ex){
            Log__c objLog = new Log__c(Line_Number__c = ex.getLineNumber(),Stack_Trace__c =  ex.getStackTraceString(),Type_Name__c = ex.getTypeName(),User_Email__c = UserInfo.getUserEmail());
            objLog.Message__c = ex.getMessage().length() > 250 ? ex.getMessage().substring(0,250) : ex.getMessage();
            insert objLog;
            return new IBANElements();
        }
    }    
    // refund parameter
    public static ResponseRefundWrapper getIBANDetail(String entityId, String IBANNum) {
        try {
            if(entityId <> null && entityId <> '' && IBANNum <> null && IBANNum <> '') {
                Account acc = [SELECT Id,Oracle_Site_Id__c FROM Account WHERE Id =: entityId];
                RequestRefundWrapper objRequestRefundWrapper = new RequestRefundWrapper();
                objRequestRefundWrapper.P_IN_IBAN = IBANNum;
                objRequestRefundWrapper.P_IN_ORG_ID = acc.Oracle_Site_Id__c;
                String sInputValue = JSON.serialize(objRequestRefundWrapper);
                system.debug('--->'+sInputValue);
                HTTPResponse objHTTPResponse = new HTTPResponse();
                // get endpoint details
                List<ERP_Endpoint_Details__mdt> listERPEndpointDetails = new List<ERP_Endpoint_Details__mdt>();
                listERPEndpointDetails = [SELECT ID,Endpoint_URL__c, Password__c, Username__c,HTTP_Method__c  FROM ERP_Endpoint_Details__mdt WHERE Is_Active__c = true AND DeveloperName =: 'IBAN_Check' LIMIT 10];
                if(listERPEndpointDetails <> null && listERPEndpointDetails.size() > 0 ) {
                	objHTTPResponse = HTTPRestUtil.callWebservice(listERPEndpointDetails[0].Endpoint_URL__c, listERPEndpointDetails[0].HTTP_Method__c, sInputValue);
                }
                
                system.debug('=====>'+ objHTTPResponse.getBody());
                ResponseRefundWrapper objResponseRefundWrapper = new ResponseRefundWrapper();
                objResponseRefundWrapper = (ResponseRefundWrapper)JSON.deserialize(objHTTPResponse.getBody(), ResponseRefundWrapper.class);
                system.debug(objResponseRefundWrapper);
                return objResponseRefundWrapper;
            }
        }catch(Exception ex){
            Log__c objLog = new Log__c(Line_Number__c = ex.getLineNumber(),Stack_Trace__c =  ex.getStackTraceString(),Type_Name__c = ex.getTypeName(),User_Email__c = UserInfo.getUserEmail());
            objLog.Message__c = ex.getMessage().length() > 250 ? ex.getMessage().substring(0,250) : ex.getMessage();
            insert objLog;
            return new ResponseRefundWrapper('E',ex.getMessage());
        }
        return null;
    }

    public static String pushRefundToOracle(String refundId) {
        /*(SELECT Id,Invoice_Line_Item__r.Item_Description__c,Invoice_Line_Item__r.Tax_Amount__c,Invoice_Line_Item__r.Taxable_Discount_Amount__c,Invoice_Line_Item__r.Amount__c,Refund_Amount__c, 
                                        Invoice_Line_Item__r.Discount_Amount__c,Invoice_Line_Item__r.Item_Reference__c,Invoice_Line_Item__c,Invoice_Line_Item__r.Invoice__r.Oracle_Invoice_Id__c FROM Refund_Line_Items__r) */
        try{
            String ref ='';
            List<ContentDocumentLink> docLinks =[SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: refundId];
            for(Refund__c eachRefund : [SELECT Id,Payment_Method__c,Entity__r.Oracle_Site_Id__c,Amount__c,createddate,Currency__c,Receipt__r.Source_Receipt_Id__c,Credit_Memo__r.Oracle_Invoice_Id__c,
                                        Entity__r.Oracle_Party_Id__c,Transaction_Types__c,Description__c,Supplier_Number__c,Vendor_Number__c,receipt__r.Payment_Method__c,
                                        Receipt__r.Authorization_Code__c,Receipt__r.Receipt_Reference__c,Receipt__r.EFT_Reference_No__c,Receipt__r.Transaction_Reference__c
                                        from Refund__c WHERE Id=: refundId]){
                                            
                InputParameters ipObj = new InputParameters();
                ipObj.P_PMT_METHOD = eachRefund.Payment_Method__c;
                ipObj.P_REF_AMOUNT = String.valueof(eachRefund.Amount__c *-1 );
                ipObj.P_ORG_ID = eachRefund.Entity__r.Oracle_Site_Id__c;
                ipObj.P_REFUND_DATE = eachRefund.createddate.DAY()+'-'+eachRefund.createddate.Month()+'-'+eachRefund.createddate.Year();
                ipObj.P_CURRENCY = eachRefund.Currency__c;
                ipObj.P_REFUND_DESC = eachRefund.Description__c;
                //public P_LINE_TBL P_LINE_TBL;
                ipObj.P_CM_TRX_TYPE =eachRefund.Transaction_Types__c;
                ipObj.P_SUPPLIER_NUM = eachRefund.Vendor_Number__c;//String.valueOf(eachRefund.Supplier_Number__c);
                ipObj.P_SFID = eachRefund.Id;
                ipObj.P_REFUND_SR_REF = eachRefund.Id;//+String.valueof(datetime.now());
                ref = eachRefund.Id;
                ipObj.P_AR_CM_NUM = eachRefund.Credit_Memo__r.Oracle_Invoice_Id__c;//Source Invoice ID
                ipObj.P_ORA_CUST_ID = eachRefund.Entity__r.Oracle_Party_Id__c;
                
                String transRef = '';
                                            if(eachRefund.Receipt__c != null){
                                                if(eachRefund.Receipt__r.Payment_Method__c.contains('Card') && eachRefund.Receipt__r.Authorization_Code__c != null){
                                                    transRef = eachRefund.Receipt__r.Authorization_Code__c;
                                                    if([SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox){
                                                        transRef = transRef+eachRefund.Receipt__r.Receipt_Reference__c;
                                                    }
                                                } else if(eachRefund.Receipt__r.Payment_Method__c == 'Electronic Funds Transfer' && eachRefund.Receipt__r.EFT_Reference_No__c != null){
                                                    transRef = eachRefund.Receipt__r.EFT_Reference_No__c;
                                                }else {
                                                    transRef = eachRefund.Receipt__r.Transaction_Reference__c;
                                                }
                                            }                            
                
                                
                ipObj.P_AR_RCPT_NUM = transRef;//eachRefund.Receipt__r.Source_Receipt_Id__c;
                //public P_REFUND_ATCH_TBL P_REFUND_ATCH_TBL;
                //ipObj.P_AR_INV_NUM = eachRefund;
                                            
               /* if(eachRefund.Refund_Line_Items__r.size() > 0){
                    P_LINE_TBL lineTable = new P_LINE_TBL();
                    lineTable.LINE_REC_TYPE = new List<LINE_REC_TYPE>();
                    List<String> invoices = new List<String>();
                    for(Refund_Line_Item__c eachRLI : eachRefund.Refund_Line_Items__r){
                        LINE_REC_TYPE lrt = new LINE_REC_TYPE();
                        lrt.X5_ITEM_DESC = eachRLI.Invoice_Line_Item__r.Item_Description__c;
                        lrt.X6_TAX_AMOUNT = '0';
                        lrt.X7_AMOUNT = String.valueOf(eachRLI.Refund_Amount__c * -1);//String.valueof((eachRLI.Invoice_Line_Item__r.Amount__c - eachRLI.Invoice_Line_Item__r.Discount_Amount__c)* -1);
                        lrt.X8_ITEM_SFID = eachRLI.Invoice_Line_Item__c;
                        lrt.X9_ITEM_REF = eachRLI.Invoice_Line_Item__r.Item_Reference__c;
                        lineTable.LINE_REC_TYPE.add(lrt);

                        if(! invoices.contains(eachRLI.Invoice_Line_Item__r.Invoice__r.Oracle_Invoice_Id__c)){
                            invoices.add(eachRLI.Invoice_Line_Item__r.Invoice__r.Oracle_Invoice_Id__c);
                        }
                        if(invoices.size() > 0)
                        ipObj.P_AR_INV_NUM = String.join(invoices, ',');
                        ipObj.P_LINE_TBL = lineTable;
                    }
                } */
                
                P_REFUND_ATCH_TBL refAttachObj = new P_REFUND_ATCH_TBL();
                refAttachObj.AR_REFUND_ATCH_REC = new List<AR_REFUND_ATCH_REC>();
                for(ContentDocumentLink docLink : docLinks){
                    AR_REFUND_ATCH_REC refundAttach = new AR_REFUND_ATCH_REC();
                    refundAttach.ATTACH_LINK = URL.getSalesforceBaseUrl().toExternalForm() + '/'+ ref;//docLink.ContentDocumentId;
                    refundAttach.REFUND_REF = ref;
                    refAttachObj.AR_REFUND_ATCH_REC.add(refundAttach);
                }
                ipObj.P_REFUND_ATCH_TBL = refAttachObj;

                ProcessRefund ProcessRefundObj = new ProcessRefund();
                ProcessRefundObj.InputParameters = ipObj;

                PRefund pref = new PRefund();
                pref.ProcessRefund = ProcessRefundObj;
                
                reqPara reqParaObj = new reqPara();
                reqParaObj.P_RefundRequest = JSON.serialize(pref);
                system.debug('===='+JSON.serialize(reqParaObj));
                HTTPResponse response = new HTTPResponse();                            
                // get endpoint details
                List<ERP_Endpoint_Details__mdt> listERPEndpointDetails = new List<ERP_Endpoint_Details__mdt>();
                listERPEndpointDetails = [SELECT ID,Endpoint_URL__c, Password__c, Username__c,HTTP_Method__c  FROM ERP_Endpoint_Details__mdt WHERE Is_Active__c = true AND DeveloperName =: 'Refund_Creation' LIMIT 1];
                if(listERPEndpointDetails <> null && listERPEndpointDetails.size() > 0 ) {                            
                	response = HTTPRestUtil.callWebservice(listERPEndpointDetails[0].Endpoint_URL__c, listERPEndpointDetails[0].HTTP_Method__c,JSON.serialize(reqParaObj));  
                }
                    system.debug('Response Body---->'+response.getBody());                                                                    
                OutputParameters respObj = (OutputParameters)JSON.deserialize(response.getBody() , OutputParameters.class);
                system.debug(respObj);

                eachRefund.Oracle_Message__c = respObj.P_OP_RETURN_MSG;
                eachRefund.Oracle_Callout_Status__c = respObj.P_OP_RETURN_STS;
                if(respObj.P_OP_RETURN_STS == 'S'){
                    eachRefund.Pushed_To_Oracle__c = true;
                    eachRefund.status__c = 'Processed';
                }
                //save Payload on fail for reference purpose
                ApexCodeUtility.savePayload(listERPEndpointDetails[0].Endpoint_URL__c,JSON.serialize(reqParaObj),eachRefund.ID,response.getBody() );
                                            
                update eachRefund;
                
                return 'Success';
            }   
        } catch(Exception ex){
            system.debug('exception is==='+ex.getMessage());
            system.debug(ex.getLineNumber());
            Log__c objLog = new Log__c(Line_Number__c = ex.getLineNumber(),Stack_Trace__c =  ex.getStackTraceString(),Type_Name__c = ex.getTypeName(),User_Email__c = UserInfo.getUserEmail());
            objLog.Message__c = ex.getMessage().length() > 250 ? ex.getMessage().substring(0,250) : ex.getMessage();
            insert objLog;
            
            return ex.getMessage();
        }
        return null;
    }

    @future(callout = true)
    public static void pushRefundToOracleFuture(List<String> refundIds){
        for(String eachRefundId : refundIds){
            //commented to accomodate ERP removal changes
            //pushRefundToOracle(eachRefundId);
            //added to accomodate ERP removal changes
            RefundToOracle.pushRefundToOracle(eachRefundId);
        }
    }
        
    // IBAN check Parameter
    public class RequestRefundWrapper {
        public string P_IN_IBAN;
        public string P_IN_ORG_ID;
    }
    
    public class ResponseRefundWrapper {
        @AuraEnabled public string P_OP_VENDOR_NAME;
        @AuraEnabled public string P_OP_VENDOR_NUMBER;
        @AuraEnabled public string P_OP_BANK_NAME;
        @AuraEnabled public string P_OP_BANK_ACCOUNT_NUM;
        @AuraEnabled public string P_OP_IBAN;
        @AuraEnabled public string P_OP_VENDOR_SITE_ID;
        @AuraEnabled public string P_OP_RETURN_STATUS;
        @AuraEnabled public string P_OP_RETURN_MSG;

        public ResponseRefundWrapper(){}
        public ResponseRefundWrapper(String sts, String msg){
            P_OP_RETURN_STATUS = sts;
            P_OP_RETURN_MSG = msg;
        }
    }
    
    public class ResponseIBANWrapper {
        @AuraEnabled public List<IBANElements> ibanElement;
    }
    
    public class IBANElements{
        @AuraEnabled public string VENDOR_NAME;
        @AuraEnabled public string VENDOR_NUMBER;
        @AuraEnabled public string VENDOR_SITE_CODE;
        @AuraEnabled public string BANK_NAME;
        @AuraEnabled public string IBAN;
        @AuraEnabled public string BANK_ACCOUNT_NUM;
        
        public IBANElements(){}
    }

    //---------------------------Push To Oracle Parameters-------------------------------------
    public class reqPara {
        public String P_RefundRequest;
    }

    public class PRefund{
        public ProcessRefund ProcessRefund;
    }
    
    public class ProcessRefund{
		public InputParameters InputParameters;
	}
	public class P_REFUND_ATCH_TBL{
		public list<AR_REFUND_ATCH_REC> AR_REFUND_ATCH_REC;
	}
	public class P_LINE_TBL{
		public list<LINE_REC_TYPE> LINE_REC_TYPE;
	}
	public class LINE_REC_TYPE{
		public String X8_ITEM_SFID;//ok
		public String X6_TAX_AMOUNT;//ok
		public String X5_ITEM_DESC;//ok
		public String X7_AMOUNT;//ok
		public String X9_ITEM_REF;//ok
	}
	public class InputParameters{
		public String P_PMT_METHOD;//ok
		public String P_REF_AMOUNT;//ok
		public String P_ORG_ID;//ok
		public String P_REFUND_DATE;//ok
		public String P_CURRENCY;//ok
		public String P_REFUND_DESC;//ok
		public P_LINE_TBL P_LINE_TBL;
		public String P_CM_TRX_TYPE;//ok
		public String P_SUPPLIER_NUM;//change
		public String P_SFID;//ok
		public String P_REFUND_SR_REF;//ok
		public String P_AR_CM_NUM;//ok
		public String P_ORA_CUST_ID;//ok
		public String P_AR_RCPT_NUM;//ok
		public P_REFUND_ATCH_TBL P_REFUND_ATCH_TBL;
		public String P_AR_INV_NUM;//ok
        //P_DESCRIPTION
        //P_SUPPLIER_SITE
        //P_INVOICE_RECEIVED_DATE
	}
	public class AR_REFUND_ATCH_REC{
		public String REFUND_REF;//ok
		public String FILE_NAME;//ok
		public String ATTACH_LINK;//ok
		public String FILE_DATA_BLOB;//ok
	}
    
    public class OutputParameters{
        public String P_OP_CUST_ID;//X_CUST_ID
        public String P_OP_CM_NUM;//X_CM_NUM
        public String P_OP_ORG_ID;//X_ORG_ID
        public String P_OP_AP_INV_NUM;//X_AP_INV_NUM
        public String P_OP_RETURN_STS;//X_RETURN_STS
        public String P_OP_SFID;//X_SFID
        public String P_OP_RETURN_MSG;//X_RETURN_MSG
    }
}
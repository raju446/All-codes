public class RefundToOracle {
    
    public static String pushRefundToOracle(String refundId) {
        
        try{
            String ref ='';
            Date dToday = System.Today();
            Datetime dt = datetime.newInstance(dToday.year(), dToday.month(),dToday.day());
            String TodayDate = dt.format('yyyy-MM-dd');
            System.debug('TodayDate===='+TodayDate);
            List<ContentDocumentLink> docLinks =[SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: refundId];
            for(Refund__c eachRefund : [SELECT Id,Name,Payment_Method__c,Entity__r.Oracle_Site_Id__c,Amount__c,createddate,Currency__c,Receipt__r.Source_Receipt_Id__c,Credit_Memo__r.Name,
                                        Entity__r.Oracle_Party_Id__c,Transaction_Types__c,Description__c,Supplier_Number__c,Vendor_Number__c,receipt__r.Payment_Method__c,
                                        Receipt__r.Authorization_Code__c,Receipt__r.Receipt_Reference__c,Receipt__r.EFT_Reference_No__c,Receipt__r.Transaction_Reference__c,Vendor_Name__c
                                        from Refund__c WHERE Id=: refundId]){
                                            
                                            InputParameters ipObj = new InputParameters();
                                            ipObj.P_PMT_METHOD = eachRefund.Payment_Method__c;
                                            ipObj.P_REF_AMOUNT = String.valueof(eachRefund.Amount__c *-1 );
                                            ipObj.P_ORG_ID = '101';//eachRefund.Entity__r.Oracle_Site_Id__c;
                                            ipObj.P_REFUND_DATE = eachRefund.createddate.format('yyyy-MM-dd');//eachRefund.createddate.Year()+'-'+eachRefund.createddate.Month()+'-'+eachRefund.createddate.DAY();
                                            ipObj.P_CURRENCY = eachRefund.Currency__c;
                                            ipObj.P_REFUND_DESC = eachRefund.Description__c;
                                            ipObj.P_CM_TRX_TYPE =eachRefund.Transaction_Types__c;
                                            ipObj.P_SUPPLIER = 'New York University in Abu Dhabi Corporation - Abu Dhabi';//eachRefund.Vendor_Name__c;
                                            ipObj.P_SFID = eachRefund.Id;
                                            ipObj.P_REFUND_SR_REF = eachRefund.Id;//+String.valueof(datetime.now());
                                            ref = eachRefund.Id;
                                            ipObj.P_AR_CM_NUM = eachRefund.Credit_Memo__r.Name;//Source Invoice ID
                                            ipObj.P_ORA_CUST_ID = eachRefund.Entity__r.Oracle_Party_Id__c;
                                            ipObj.P_SUPPLIER_SITE = 'Work' ;//eachRefund.Vendor_Number__c;
                                            ipObj.P_AR_INV_NUM = eachRefund.Name;
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
                                            ipObj.P_AR_RCPT_NUM = transRef;
                                            ipObj.P_INVOICE_RECEIVED_DATE = TodayDate;
                                            
                                            P_REFUND_ATCH_TBL refAttachObj = new P_REFUND_ATCH_TBL();
                                            refAttachObj.AR_REFUND_ATCH_REC = new List<AR_REFUND_ATCH_REC>();
                                            for(ContentDocumentLink docLink : docLinks){
                                                ContentVersion verRec = [select ID, Title from ContentVersion where ContentDocumentId = :docLink.ContentDocumentId LIMIT 1];
                                                Http h = new Http();
                                                HttpRequest req = new HttpRequest();
                                                req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v42.0/sobjects/ContentVersion/'+verRec.ID+'/VersionData');
                                                req.setMethod('GET');
                                                req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
                                                req.setHeader('Content-Type', 'application/json');
                                                HttpResponse res = h.send(req);
                                                system.debug(res.getBody());
                                                system.debug('Blob val===='+Blob.valueof(res.getbody()));
                                                system.debug('base64Encode val====: '+EncodingUtil.base64Encode(Blob.valueof(res.getbody())));
                                                AR_REFUND_ATCH_REC refundAttach = new AR_REFUND_ATCH_REC();
                                                refundAttach.ATTACH_LINK = '';
                                                refundAttach.REFUND_REF = ref;
                                                refundAttach.FILE_DATA_BLOB = EncodingUtil.base64Encode(Blob.valueof(res.getbody()));
                                                refundAttach.FILE_NAME = verRec.Title;
                                                refAttachObj.AR_REFUND_ATCH_REC.add(refundAttach);
                                            }
                                            ipObj.P_REFUND_ATCH_TBL = refAttachObj;
                                            
                                            ProcessRefund ProcessRefundObj = new ProcessRefund();
                                            ProcessRefundObj.InputParameters = ipObj;
                                            
                                            PRefund pref = new PRefund();
                                            pref.ProcessRefund = ProcessRefundObj;
                                            system.debug('pref===='+JSON.serialize(pref));
                                            //reqPara reqParaObj = new reqPara();
                                            //reqParaObj.P_RefundRequest = JSON.serialize(pref);
                                            //system.debug('reqParaObj===='+JSON.serialize(reqParaObj));
                                            HTTPResponse response = new HTTPResponse();                            
                                            Http http = new Http();
                                            HttpRequest request = new HttpRequest();
                                            request.setEndpoint('callout:FusionCloud/XXADG_REST_FUSIO_CREAT_REFUN_AP/1.0/');
                                            request.setMethod('POST');
                                            request.setTimeout(120000);
                                            request.setHeader('content-type','application/json');
                                            request.setBody(JSON.serialize(pref));
                                            //request.setBody(JSON.serialize(reqParaObj));
                                            response = http.send(request);
                                            system.debug('response--->'+response);
                                            system.debug('response Body--->'+response.getBody());
                                            
                                            system.debug('Response Body---->'+response.getBody());                                                                    
                                            OutputParameters respObj = (OutputParameters)JSON.deserialize(response.getBody() , OutputParameters.class);
                                            system.debug(respObj);
                                            
                                            eachRefund.Oracle_Message__c = respObj.X_RETURN_MSG;
                                            eachRefund.Oracle_Callout_Status__c = respObj.X_RETURN_STS;
                                            if(respObj.X_RETURN_STS == 'S'){
                                                eachRefund.Pushed_To_Oracle__c = true;
                                                eachRefund.status__c = 'Processed';
                                            }
                                            //save Payload on fail for reference purpose
                                            ApexCodeUtility.savePayload('FusionCloud/XXADG_REST_FUSIO_CREAT_REFUN_AP/1.0/',JSON.serialize(pref),eachRefund.ID,response.getBody() );
                                            
                                            update eachRefund;
                                            
                                            return 'Success';
                                        }   
        } catch(Exception ex){
            system.debug(ex.getMessage());
            system.debug(ex.getLineNumber());
            Log__c objLog = new Log__c(Line_Number__c = ex.getLineNumber(),Stack_Trace__c =  ex.getStackTraceString(),Type_Name__c = ex.getTypeName(),User_Email__c = UserInfo.getUserEmail());
            objLog.Message__c = ex.getMessage().length() > 250 ? ex.getMessage().substring(0,250) : ex.getMessage();
            insert objLog;
            
            return ex.getMessage();
        }
        return null;
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
        //public P_LINE_TBL P_LINE_TBL;
        public String P_CM_TRX_TYPE;//ok
        public String P_SUPPLIER;//change
        public String P_SFID;//ok
        public String P_REFUND_SR_REF;//ok
        public String P_AR_CM_NUM;//ok
        public String P_ORA_CUST_ID;//ok
        public String P_AR_RCPT_NUM;//ok
        public P_REFUND_ATCH_TBL P_REFUND_ATCH_TBL;
        public String P_AR_INV_NUM;//ok
        public String P_DESCRIPTION;
        public String P_SUPPLIER_SITE;
        public String P_INVOICE_RECEIVED_DATE;
    }
    public class AR_REFUND_ATCH_REC{
        public String REFUND_REF;//ok
        public String FILE_NAME;//ok
        public String ATTACH_LINK;//ok
        public String FILE_DATA_BLOB;//ok
    }
    
    public class OutputParameters{
        public String X_CUST_ID;//
        public String X_CM_NUM;//
        public String X_ORG_ID;//
        public String X_AP_INV_NUM;//
        public String X_RETURN_STS;//
        public String X_SFID;//
        public String X_RETURN_MSG;//
    }
    
}
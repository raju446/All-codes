public class JEsStatusFromOracle {
    
    public static map<id,GlJournals> doCalloutFromFuture(String reqId, String insId) {
        GlJournals_Store__c txnStatus;
        string successTnxn = '';
        try{
                String epVal = [SELECT DeveloperName, Endpoint FROM NamedCredential where DeveloperName = 'FusionCloud'].Endpoint + 'XXADGM_REST_DB_GL_DETAIL/1.0/?InstanceId='+insId+'&RequestId='+reqId;
                Http http = new Http();
            	HttpRequest request = new HttpRequest();
                request.setEndpoint('callout:FusionCloud/XXADGM_REST_DB_GL_DETAIL/1.0/?InstanceId='+insId+'&RequestId='+reqId);
                request.setMethod('GET');
                HttpResponse response = http.send(request);
                
            	savePayload(epVal,epVal,null,response.getBody(),null);
                if(response.getStatusCode() == 200)
                {
                    System.debug('Response==='+response.getBody());
                    map<id,GlJournals> resultmap = new map<id,GlJournals>();
                    GlJournalsFromJson responseClass = (GlJournalsFromJson)System.JSON.deserialize(response.getBody(), GlJournalsFromJson.class);
                    System.debug('respObj==='+responseClass.GlJournals[0]);
                    if(responseClass != null && responseClass.GlJournals != null){
                        for(GlJournals gi : responseClass.GlJournals){
                            if(gi.SfBatchId != null && gi.SfBatchId != ''){
                                resultmap.put(gi.SfBatchId,gi);
                            }
                        }
                        return resultmap;
                    }
                }
            	else{
                    txnStatus = new GlJournals_Store__c(Exception__c = response.getBody(),
                                                        Status_Code__c = string.valueof(response.getStatusCode()),
                                                        RequestId__c = reqId, InstanceId__c = insId,
                                                        Status__c = 'Failed');
                }
            }catch(Exception ex){
                txnStatus = new GlJournals_Store__c(Exception__c = ex.getMessage(),
                                                    Status__c = 'Failed', RequestId__c = reqId, 
                                                    InstanceId__c = insId);
        	}
            insert txnStatus;
            return null;
    }
    
    public class GlJournalsFromJson
    {
        public list<GlJournals> GlJournals{get;set;}
    }
    
    public class GlJournals{
        public String ImportChildId{get;set;}
        public String ImportId{get;set;}
        public String FailedJob{get;set;}
        public String FusionBatchName{get;set;}
        public String Status{get;set;}
        public String SfBatchId{get;set;}
        public String InstanceId{get;set;}
        public String SfBatchName{get;set;}
        public String RequestId{get;set;}
    }
	
    
    
    
    public static API_Payload__c savePayload(String endPoint,String reqBody, String recordId,String respBody,String relatedRecordId){
        API_Payload__c apiPayload = new API_Payload__c();
        try{
            String objectType = (String.isNotEmpty(relatedRecordId))?Id.valueOf(relatedRecordId).getSobjectType().getDescribe().getName():'';
            if(reqBody != null){
                apiPayload.End_Point__c      = endPoint;
                apiPayload.Payload__c        = reqBody;
                apiPayload.Response__c       = respBody;
                apiPayload.Related_Record__c = relatedRecordId;
                apiPayload.Status__c         = 'New';
                apiPayload.Journal_Voucher__c = recordId;
                if(objectType == 'Receipt__c'){apiPayload.Receipt__c = relatedRecordId;}
                else if(objectType == 'Fund_Transfer__c'){apiPayload.Fund_Transfer__c = relatedRecordId;}
                else if(objectType == 'Refund__c'){apiPayload.Refund__c = relatedRecordId;}
                else if(objectType == 'Invoice_Line_Item__c'){ apiPayload.Invoice_Line_Item__c = relatedRecordId;}
                else if(objectType == 'Related_Invoice_Receipt__c'){ apiPayload.Related_Invoice_Receipt__c = relatedRecordId; }
                else if(objectType == 'Invoice__c'){apiPayload.Invoice__c = relatedRecordId;}
                insert apiPayload;
            }
        }catch(exception e){}
        return apiPayload;
    }   
}
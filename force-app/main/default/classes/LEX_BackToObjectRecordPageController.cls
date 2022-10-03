public class LEX_BackToObjectRecordPageController {
    
    @AuraEnabled
    public static RespondWrap fetchRelatedObject(String requestWrapParam) {

        //declaration of wrapper
        RequestWrap reqWrap = new RequestWrap();
        RespondWrap respWrap = new RespondWrap();

        //deseriliaze.
        reqWrap = (RequestWrap) JSON.deserializeStrict(requestWrapParam, RequestWrap.class);
        system.debug(reqWrap);
        
        if(reqWrap.parentRecId != null){
            for(task taskObj : [SELECT id ,whatId from task where id =: reqWrap.parentRecId]){
                respWrap.relatedRecId = taskObj.whatId;
            }
        }
        return respWrap;


        
        }
    
    public class RequestWrap {
        @AuraEnabled
        public String parentRecId { get; set; }

        

        public RequestWrap() {
        }
    }

    public class RespondWrap {

        @AuraEnabled
        public String relatedRecId { get; set; }

        public RespondWrap() {
            
        }
    }

}
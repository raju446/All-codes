/*
@Author : Azmath
@Description : This class is used to invoke the ADP services.
@Version : v1.
*/
global without sharing class ADP_RestServicesHelper 
{
    webservice static void invokeADPService(string recType, Id srId, string parentId)
    {             
        try{
            ADPJson helper = new ADPJson(recType,srId);
            system.debug('===test==');
            string payload = JSON.serialize(helper);
            system.debug('==='+payload);
            
            string ep;
            HttpRequest req = new HttpRequest();
            if(system.label.IsSandBox == 'TRUE'){
                req.setEndpoint('callout:Informatica_URL/ADPServices_UAT');
                ep='callout:Informatica_URL/ADPServices_UAT';
            }
            else{
                req.setEndpoint('callout:Informatica_URL/ADPServices_Prod');
                ep='callout:Informatica_URL/ADPServices_Prod';
            }
            req.setMethod('POST');
            req.setTimeout(120000);
            req.setHeader('content-type','application/json;charset=UTF-8;');
            req.setBody(payload);
            Http http = new Http();
            system.debug('===request body--'+req);
            HTTPResponse res = http.send(req);
            system.debug('=response=='+res);
            system.debug('=response=='+res.getBody());
            if(res.getStatusCode() == 200)
            {
                string jsonstring           = res.getBody();
                jsonstring                  = jsonstring.replaceAll('return','return1');
                ADP_ResponseJson response   = (ADP_ResponseJson) System.JSON.deserialize(jsonstring, ADP_ResponseJson.class);
                string transactionId        = response.UD_Output.return1.transId;
                
                if(transactionId != null && transactionId != '')
                {
                    
                    HexaBPM__Service_Request__c sr = new HexaBPM__Service_Request__c(Id=srId,Transaction_Id__c=transactionId);
                    update sr;
                    
                    API_Response__c resp = new API_Response__c(Type__c='Application Submission', Service_Request__c=srId, Transaction_Id__c=transactionId);
                    insert resp;
                }
                system.debug('===response=='+response.UD_Output.return1.transId);
            }
            ApexCodeUtility.savePayload(ep,payload,srId,res.getBody());
        }catch(Exception ex){
            system.debug('=====exception is =='+ex.getMessage());
            API_Payload__c api = new API_Payload__c(Exception__c='Exception : '+ex.getMessage(),Service_Request__c=srId);
            insert api;
        }
        
    } 
}
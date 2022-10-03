/*
@Author : Azmath
@Description : This class is used to call the Establishment Card Real time status and to print card service related apis.
@Version : v1.
*/
global without sharing class ICA_EstablishmentCardUtil 
{
    /* Method : invokeRealtimeStatusUpdateapi
    *  Description : This method will invoke the EstablishmentRequestInfo api which is basically to check the current status of the application.
    */
    webservice static string invokeRealtimeStatusUpdateapi(Id srId)
    {
        list<HexaBPM__Service_Request__c> srreqno = [Select TransactionRef__c from HexaBPM__Service_Request__c where id=:srId and TransactionRef__c != null];
        API_Response__c apilog; 
        try{
            if(!srreqno.isEmpty())
            {
                string payload = '{"UD_RequestNumber": "'+srreqno[0].TransactionRef__c+'"}';
                HttpRequest req = new HttpRequest(); 
                string ep;
                if(system.label.IsSandBox == 'TRUE')
                {
                    //req.setEndpoint('callout:Informatica_Cloud/ICA_GetRealtimeStatus_Cloud'); 
                    req.setEndpoint('callout:Informatica_URL/ICA_GetRealtimeStatus_Stage');
                }
                else{
                    //req.setEndpoint('callout:Informatica_URL/ICA_GetRealtimeStatus');
                    if(system.Label.ICA_RunServicesOnCloud == 'True'){
                        req.setEndpoint('callout:Informatica_URL/ICA_GetRealtimeStatus_Cloud');
                        ep='callout:Informatica_URL/ICA_GetRealtimeStatus_Cloud';
                    }else{
                        req.setEndpoint('callout:Informatica_URL/ICA_GetRealtimeStatus');
                        ep='callout:Informatica_URL/ICA_GetRealtimeStatus';
                    }
                }
                req.setMethod('POST');
                req.setTimeout(120000);
                req.setHeader('content-type','application/json;charset=UTF-8;');
                req.setBody(payload);
                Http http = new Http();
                HTTPResponse res = http.send(req);
                system.debug('=response=='+res.getBody());
                
                system.debug('=status code=='+res.getStatusCode());
                string message = '';
                if(res.getStatusCode() == 200)
                {
                    ICA_GetRealtimeStatusResponseJson resp =  (ICA_GetRealtimeStatusResponseJson)System.JSON.deserialize(res.getBody(), ICA_GetRealtimeStatusResponseJson.class);
                    
                    if(resp != null && resp.O_isSucess != 'false' && resp.O_Number != null)
                    {
                        srreqno[0].ICA_Last_Refreshed_Status__c = resp.O_Status;
                        update srreqno;
                        message = 'Service Name : '+resp.O_ServiceName+'\n';
                        message +='Status : '+resp.O_Status+'\n';
                        message +='Date : '+resp.O_Date+'\n';
                        message +='Request Number : '+resp.O_Number+'\n';
                        message +='Receipt Number : '+resp.O_ReceiptNumber+'\n';
                        message +='Paid Amount : '+resp.O_PaidAmount;
                        
                    }else if(resp != null && resp.O_isSucess == 'false' && resp.O_ErrorMessage != null){
                        message = 'Error : \n'+resp.O_ErrorMessage;
                    }else{
                        message = 'Error : \n'+res.getBody();
                    }
                }
                else{
                    message = 'Something went wrong, please try again';
                }
                return message;
            }
        }catch(Exception ex){
            system.debug('---exception is --'+ex.getMessage());
            string message = 'Something went wrong, please try again';
            return message;
        }
        return 'No results found';
    }
    
    /* Method       : invokePrintIACopyapi
    *  Description  : This method will invoke the PrintInitialApproval api which is basically to fetch the Initial Approval copy from ICA.
    */
    webservice static void invokePrintIACopyapi(Id srId)
    {
        list<HexaBPM__Service_Request__c> srreqno = [Select TransactionRef__c from HexaBPM__Service_Request__c where id=:srId and TransactionRef__c != null];
        API_Response__c apilog; 
        try
        {
            if(!srreqno.isEmpty())
            {
                string payload = '{"UD_RequestNumber": "'+srreqno[0].TransactionRef__c+'"}';
                HttpRequest req = new HttpRequest(); 
                string ep;
                if(system.label.IsSandBox == 'TRUE'){
                    //req.setEndpoint('callout:Informatica_Cloud/ICA_PrintIACopy_Cloud');
                    req.setEndpoint('callout:Informatica_URL/ICA_PrintIACopy_Stage');
                    ep='callout:Informatica_URL/ICA_PrintIACopy_Stage';
                }
                else{
                    if(system.Label.ICA_RunServicesOnCloud == 'True'){
                        req.setEndpoint('callout:Informatica_URL/ICA_PrintIACopy_Cloud');
                        ep='callout:Informatica_URL/ICA_PrintIACopy_Cloud';
                    }else{
                        req.setEndpoint('callout:Informatica_URL/ICA_PrintIACopy');
                        ep='callout:Informatica_URL/ICA_PrintIACopy';
                    }
                }
                req.setMethod('POST');
                req.setTimeout(120000);
                req.setHeader('content-type','application/json;charset=UTF-8;');
                req.setBody(payload);
                Http http = new Http();
                HTTPResponse res = http.send(req);
                system.debug('=response=='+res.getBody());
                ApexCodeUtility.savePayload(ep,payload,srId,res.getBody());
                
                system.debug('=status code=='+res.getStatusCode());
                if(res.getStatusCode() == 200)
                {
                    ICA_GetInitialApprovalCopyRespJson resp =  (ICA_GetInitialApprovalCopyRespJson)System.JSON.deserialize(res.getBody(), ICA_GetInitialApprovalCopyRespJson.class);
                    if(resp != null && resp.O_isSucess != 'false' && resp.O_byteArrayBase64String != null)
                    {
                        srreqno[0].Download_Document_API_status__c = 'Success';
                        update srreqno; 
                        
                        list<HexaBPM__SR_Doc__c> srdocid = [Select id from HexaBPM__SR_Doc__c where HexaBPM__Service_Request__c=:srId and Name='Initial Approval/Rejection Letter'];
                        if(!srdocid.isEmpty())
                        {
                            Attachment att = new Attachment(Name='Initial Approval/Rejection Letter.pdf', ParentId=srdocid[0].id, 
                                            Body=EncodingUtil.base64Decode(resp.O_byteArrayBase64String), ContentType='application/pdf');
                            insert att;
                            
                            list<Initial_Approval_List__c> iarec = [Select id from Initial_Approval_List__c where Initial_Approval_Number__c=:srreqno[0].TransactionRef__c limit 1];
                            if(!iarec.isEmpty()){
                                Attachment at1 = att;
                                at1.id = null;
                                at1.ParentId=iarec[0].id;
                                insert att;
                            }
                            srdocid[0].HexaBPM__Status__c = 'Uploaded';
                            update srdocid;
                            
                            apilog = new API_Response__c(Type__c='Download IA Copy', Service_Request__c=srreqno[0].id);
                            insert apilog;
                        }
                        
                    }else{
                        apilog = new API_Response__c(Type__c='Download IA Copy', Service_Request__c=srreqno[0].id, Error__c=res.getBody());
                        insert apilog;
                    }
                    
                }else{
                    srreqno[0].Download_Document_API_status__c = 'Error';
                    update srreqno;
                    
                    apilog = new API_Response__c(Type__c='Download IA Copy', Service_Request__c=srreqno[0].id, Error__c=res.getBody());
                    insert apilog;
                }
            }
        }catch(Exception ex){
            srreqno[0].Download_Document_API_status__c = 'Exception'; 
            update srreqno;
            
            system.debug('---exception is --'+ex.getMessage());
            apilog = new API_Response__c(Type__c='Download IA Copy', Service_Request__c=srreqno[0].id, Error__c=ex.getMessage());
            insert apilog;
        }
    }
    
    /* Method       : invokePrintEstbCardCopyapi
    *  Description  : This method will invoke the PrintCard api which is basically to fetch the Estb. Card copy from ICA.
    */
    webservice static void invokePrintEstbCardCopyapi(Id srId)
    {
        list<HexaBPM__Service_Request__c> srreqno = [Select TransactionRef__c,Recordtype.Developername from HexaBPM__Service_Request__c where id=:srId and TransactionRef__c != null];
        API_Response__c apilog; 
        try
        {
            if(!srreqno.isEmpty())
            {
                string payload = '{"UD_RequestNumber": "'+srreqno[0].TransactionRef__c+'"}';
                HttpRequest req = new HttpRequest(); 
                string ep;
                if(system.label.IsSandBox == 'TRUE'){
                    //req.setEndpoint('callout:Informatica_Cloud/ICA_PrintCard_Cloud');
                    req.setEndpoint('callout:Informatica_URL/ICA_PrintCard_Stage');
                    ep='callout:Informatica_URL/ICA_PrintCard_Stage';
                }
                else
                {
                    if(system.Label.ICA_RunServicesOnCloud == 'True'){
                        req.setEndpoint('callout:Informatica_URL/ICA_PrintCard_Cloud');
                        ep='callout:Informatica_URL/ICA_PrintCard_Cloud';
                    }else{
                        req.setEndpoint('callout:Informatica_URL/ICA_PrintCard');
                        ep='callout:Informatica_URL/ICA_PrintCard';
                    }
                }
                req.setMethod('POST');
                req.setTimeout(120000);
                req.setHeader('content-type','application/json;charset=UTF-8;');
                req.setBody(payload);
                Http http = new Http();
                HTTPResponse res = http.send(req);
                system.debug('=response=='+res.getBody());
                ApexCodeUtility.savePayload(ep,payload,srId,res.getBody());
                
                system.debug('=status code=='+res.getStatusCode());
                if(res.getStatusCode() == 200)
                {
                    ICA_GetInitialApprovalCopyRespJson resp =  (ICA_GetInitialApprovalCopyRespJson)System.JSON.deserialize(res.getBody(), ICA_GetInitialApprovalCopyRespJson.class);
                    if(resp != null && resp.O_isSucess != 'false' && resp.O_byteArrayBase64String != null)
                    {
                        srreqno[0].Download_Document_API_status__c = 'Success';
                        update srreqno; 
                        
                        string docname='Establishment Card - Internal';
                        string attname = 'Establishment Card.pdf';
                        /*if(srreqno[0].Recordtype.Developername == 'Establishment_Card_Cancellation'){
                            docname = 'Establishment Card Cancellation Copy';
                            attname = 'Establishment Card Cancellation.pdf';
                        }*/
                        list<HexaBPM__SR_Doc__c> srdocid = [Select id from HexaBPM__SR_Doc__c where HexaBPM__Service_Request__c=:srId and Name=:docname];
                        if(!srdocid.isEmpty()){
                            Attachment att = new Attachment(Name=attname, ParentId=srdocid[0].id, 
                                            Body=EncodingUtil.base64Decode(resp.O_byteArrayBase64String), ContentType='application/pdf');
                            insert att;
                            
                            srdocid[0].HexaBPM__Status__c = 'Uploaded';
                            update srdocid;
                        }
                        apilog = new API_Response__c(Type__c='Download Estb. Card Copy', Service_Request__c=srreqno[0].id);
                        insert apilog;
                    }else{
                        srreqno[0].Download_Document_API_status__c = 'Error';
                        update srreqno; 
                        
                        apilog = new API_Response__c(Type__c='Download Estb. Card Copy', Service_Request__c=srreqno[0].id, Error__c=res.getBody());
                        insert apilog;
                    }
                }
                else
                {
                    srreqno[0].Download_Document_API_status__c = 'Error';
                    update srreqno;
                    
                    apilog = new API_Response__c(Type__c='Download Estb. Card Copy', Service_Request__c=srreqno[0].id, Error__c=res.getBody());
                    insert apilog;
                }
            }
        }catch(Exception ex){
            srreqno[0].Download_Document_API_status__c = 'Exception'; 
            update srreqno;
            
            system.debug('---exception is --'+ex.getMessage());
            apilog = new API_Response__c(Type__c='Download Estb. Card Copy', Service_Request__c=srreqno[0].id, Error__c=ex.getMessage());
            insert apilog;
        }
    }
}
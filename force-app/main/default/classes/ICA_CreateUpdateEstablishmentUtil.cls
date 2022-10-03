/*
@Author : Azmath
@Description : This class is used to call the Est. service related apis.
@Version : v1.
*/
global without sharing class ICA_CreateUpdateEstablishmentUtil
{
	/* Method 		: invokeEstbservice
	 * Description  : This method will invoke the CreateUpdateEstablishment api which is basically submit the Establishment related application to ICA.
	*/
    webservice static void invokeEstbservice(Id srId)
    {
        boolean isResubmission= false;
        list<HexaBPM__Service_Request__c> srrec = [Select TransactionRef__c, Draft_Number__c FROM HexaBPM__Service_Request__c where id=:srId];
        if(!srrec.isEmpty() && srrec[0].TransactionRef__c != null && srrec[0].Draft_Number__c != null)
        {
            isResubmission = true;
        }
        try{
            ICA_CreateUpdateEstablishmentJson helper = new ICA_CreateUpdateEstablishmentJson(srId); 
            string payload = JSON.serialize(helper);
            list<HexaBPM__Service_Request__c> srrectype = [Select HexaBPM__Customer__c,Initial_Approval_Number__c, Recordtype.DeveloperName from HexaBPM__Service_Request__c where id=:srId];
            if(!srrectype.isEmpty() && (srrectype[0].Recordtype.DeveloperName == 'Establishment_Card_Renewal' || srrectype[0].Recordtype.DeveloperName == 'Establishment_Card_Amendment' 
                || srrectype[0].Recordtype.DeveloperName == 'Establishment_Card_Cancellation')){
                payload = payload.replace('"establishmentRequestRelatedPersons":null,','');
            }
            system.debug('===payload=='+payload);
            HttpRequest req = new HttpRequest(); 
            string ep;
            if(system.label.IsSandBox == 'TRUE'){
                //req.setEndpoint('callout:Informatica_Cloud/ICA_Stage_CreateUpdateEstablishment_Cloud');ICA_Stage_CreateUpdateEstablishment
                req.setEndpoint('callout:Informatica_URL/ICA_CreateUpdateEstablishment');
                ep='callout:Informatica_Cloud/ICA_Stage_CreateUpdateEstablishment';
            }
            else
            {
            	if(system.Label.ICA_RunServicesOnCloud == 'True'){
            		req.setEndpoint('callout:Informatica_URL/ICA_CreateUpdateEstablishment_Cloud');
        			ep='callout:Informatica_URL/ICA_CreateUpdateEstablishment_Cloud';
            	}else{
            		req.setEndpoint('callout:Informatica_URL/ICA_CreateUpdateEstablishment');
        			ep='callout:Informatica_URL/ICA_CreateUpdateEstablishment';
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
            
            API_Response__c apilog;
            system.debug('=response=='+res.getStatusCode());
            HexaBPM__Service_Request__c sr = new HexaBPM__Service_Request__c(id=srId);
            if(res.getStatusCode() == 200)
            {
                //We can use the Initialapproval response json class for estb. card resp as the resp params for both are same.
                ICA_InitialApprovalRespParser resp =  (ICA_InitialApprovalRespParser)System.JSON.deserialize(res.getBody(), ICA_InitialApprovalRespParser.class);
                if(resp.UD_Output != null)
                {
                    if(resp.UD_Output.isSuccess == true)
                    {
                        if(!isResubmission)
                            sr.Application_Submission_Status__c = 'Success';
                        else
                            sr.Application_Resubmission_API_Status__c = 'Success';
                            
                        list<ICA_Document__c> existingdocs = [Select id from ICA_Document__c where Service_Request__c=:srId LIMIT 1];
                        
                        if(resp.UD_Output.Data != null)
                            sr.Draft_Number__c = resp.UD_Output.Data.requestNumber;
                        
                        String accountCode;
                        String token;
                        string bankCode;
                        
                        if(existingdocs.isEmpty())
                        {
                            if(resp.UD_Output.Data != null && resp.UD_Output.Data.requestFees != null)
                            sr.Total_Amount__c      = resp.UD_Output.Data.requestFees.totalWithVat;
                            sr.Application_Fee__c   = resp.UD_Output.Data.requestFees.totalAmountWithCommissionsIncludingVat;
                            
                            for(ICA_InitialApprovalRespParser.Wallets wallet : resp.UD_Output.Data.wallets)
                            {
                                sr.Balance__c   = string.valueof(wallet.balance);
                                accountCode     = wallet.accountCode;
                                token           = wallet.token;
                                bankCode        = wallet.bankCode;
                            }
                            
                            //Add required documents..
                            list<ICA_Document__c> atts = new list<ICA_Document__c>();
                            for(ICA_InitialApprovalRespParser.RequiredAttachments att : resp.UD_Output.Data.requiredAttachments)
                            {
                                ICA_Document__c ats = new ICA_Document__c(Atachment_Type_Id__c=att.attachmentTypeId, Attachment_Type_Text__c = att.attachmentTypeText, 
                                        Is_Attachment_Mandatory__c=att.isAttachmentTypeMandatory,Service_Request__c=srId);
                                atts.add(ats);
                            }
                            if(!atts.isEmpty())
                            {
                                set<id> atids = new set<id>(); 
                                insert atts;
                                for(ICA_Document__c i : atts){
                                    system.debug('==='+i.Attachment_Type_Text__c);
                                    if(i.id != null) atids.add(i.id);
                                }
                                
                                list<ICA_Document__c> docsList = [Select id,Name,Description__c FROM ICA_Document__c WHERE ID IN:atids];
                                
                                //1. Query Commercial License copy from Entity..
                                list<Attachment> commercialLicensecopy= [Select id, Name, ParentId,Body, BodyLength, ContentType, Description FROM Attachment where ParentID =:srrectype[0].HexaBPM__Customer__c 
                                    and Name Like '%commercial%' order by CreatedDate DESC LIMIT 1];
                                
                                //2. Query Internal Auth sig copy..
                                list<Document> internalAuthsigCopy = [Select id, Name, Body, ContentType,Type, Description from document where  id=:system.label.ICA_InternalPPCopyDocID];
                                
                                //3. Query ADGM Authority Establishment Card Copy
                                list<Document> adgmAuthEstbcopy = [Select id, Name, Body, ContentType,Type, Description from document where  id=:system.label.ICA_ADGMEstablishmentCopy];
                                 
                                //4. Query IA copy..
                                list<Attachment> IACopy = new list<Attachment>();
                                if(srrectype[0].Initial_Approval_Number__c != null && (srrectype[0].Recordtype.DeveloperName == 'Establishment_Card_New' || srrectype[0].Recordtype.DeveloperName == 'Establishment_Card_Amendment'))
                                {
                                    list<Initial_Approval_List__c> recid = [Select id from Initial_Approval_List__c where Initial_Approval_Number__c=:srrectype[0].Initial_Approval_Number__c and
                                        Active__c=true Order by LastModifiedDate LIMIT 1];
                                    if(!recid.isEmpty()){
                                        IACopy = [Select id, Name, ParentId, Body, BodyLength, ContentType, Description FROM Attachment where ParentID =:recid[0].id
                                            order by CreatedDate DESC LIMIT 1];
                                    }
                                }
                                
                                //Query cancellation doc if the SR is Estb. Cancellaiton.
                                list<Attachment> cancelledDoc = new list<Attachment>();
                                if(srrectype[0].Recordtype.DeveloperName == 'Establishment_Card_Cancellation')
                                {
                                    list<HexaBPM__SR_Doc__c> srdocid = [Select id from HexaBPM__SR_Doc__c where HexaBPM__Service_Request__c=:srId and Name='Establishment Card Cancellation Letter'];
                                    if(!srdocid.isEmpty()){
                                        cancelledDoc= [Select id, Name, ParentId,Body, BodyLength, ContentType, Description FROM Attachment where ParentID =:srdocid[0].id LIMIT 1];
                                    }
                                }
                                
                                //Upload attachments undre the specific placeholders.
                                list<Attachment> atlist = new list<Attachment>();
                                list<Document> authdoc = [Select id, Name, Body, ContentType,Type, Description from document where  id=:system.label.ICA_InternalPPCopyDocID];
                                for(ICA_Document__c ica : docsList)
                                {
                                    system.debug('=descr=='+ica.id);
                                    if(ica.Description__c == 'Commercial license copy' && !commercialLicensecopy.isEmpty())
                                    {
                                        Attachment ata = new Attachment(Name=commercialLicensecopy[0].name, Body=commercialLicensecopy[0].Body, 
                                            ContentType=commercialLicensecopy[0].ContentType, Description=commercialLicensecopy[0].Description, parentid=ica.id);
                                        atlist.add(ata);
                                    }
                                    else if(ica.Description__c == 'Internal Authorised signatories passport copies' && !internalAuthsigCopy.isEmpty())
                                    {
                                        Attachment ata = new Attachment(Name=internalAuthsigCopy[0].name+'.'+internalAuthsigCopy[0].type, Body=internalAuthsigCopy[0].Body, 
                                            ContentType=internalAuthsigCopy[0].ContentType, Description=internalAuthsigCopy[0].Description, parentid=ica.id);
                                        atlist.add(ata);
                                    }
                                    else if(ica.Description__c == 'ADGM Authority - Establishment card copy' && !adgmAuthEstbcopy.isEmpty())
                                    {
                                        Attachment ata = new Attachment(Name=adgmAuthEstbcopy[0].name+'.'+adgmAuthEstbcopy[0].type, Body=adgmAuthEstbcopy[0].Body, 
                                            ContentType=adgmAuthEstbcopy[0].ContentType, Description=adgmAuthEstbcopy[0].Description, parentid=ica.id);
                                        atlist.add(ata);
                                    }
                                    else if(ica.Description__c == 'Initial approval copy' && !IACopy.isEmpty())
                                    {
                                        Attachment ata = new Attachment(Name=IACopy[0].name, Body=IACopy[0].Body, 
                                            ContentType=IACopy[0].ContentType, Description=IACopy[0].Description, parentid=ica.id);
                                        atlist.add(ata);
                                    }
                                    else if(srrectype[0].Recordtype.DeveloperName == 'Establishment_Card_Cancellation' && !cancelledDoc.isEmpty() && 
                                             ica.Description__c == 'Letter from ADGM')
                                    {
                                        Attachment ata = new Attachment(Name=cancelledDoc[0].name,Body=cancelledDoc[0].Body,ContentType=cancelledDoc[0].ContentType,Description=cancelledDoc[0].Description,parentid=ica.id);
                                        atlist.add(ata);
                                    }
                                }
                                if(!atlist.isEmpty()){
                                    insert atlist;
                                }
                            }
                        }
                        apilog = new API_Response__c(Type__c='CreateUpdate Establishment Service', Service_Request__c=srId, Draft_Number__c=sr.Draft_Number__c, Total_Amount__c = sr.Total_Amount__c, 
                                Balance__c=sr.Balance__c, AccountCode__c = accountCode, Token__c=token, Bank_Code__c=bankCode);
                        insert apilog;
                    }
                    else if(resp.UD_Output.isSuccess == false)
                    {
                        if(!isResubmission)
                            sr.Application_Submission_Status__c = 'Error';
                        else
                            sr.Application_Resubmission_API_Status__c = 'Error';
                            
                        string errormsg = '';
                        for(ICA_InitialApprovalRespParser.Errors er : resp.UD_Output.errors){
                            errormsg += er.errorMessage+',';
                        }
                        if(errormsg == ''){
                            errormsg = 'Something went wrong, please see the logs for full details.';
                        }
                        apilog = new API_Response__c(Type__c='CreateUpdate Establishment Service', Service_Request__c=srId, Error__c=errormsg);
                        insert apilog;
                    }
                }
            }
            else
            {
                if(!isResubmission)
                    sr.Application_Submission_Status__c = 'Error';
                else
                    sr.Application_Resubmission_API_Status__c = 'Error';
                apilog = new API_Response__c(Type__c='CreateUpdate Establishment Service', Service_Request__c=srId, Error__c=res.getBody());
                insert apilog;
            }
            update sr;
        }catch(Exception ex){
            system.debug('===exception is=='+ex.getMessage());
            HexaBPM__Service_Request__c sr = new HexaBPM__Service_Request__c(id=srId);
            if(!isResubmission)
                sr.Application_Submission_Status__c = 'Exception';
            else
                sr.Application_Resubmission_API_Status__c = 'Exception';
            update sr;
            
            API_Response__c apilog = new API_Response__c(Type__c='CreaeUpdate Establishment Service', Service_Request__c=srId, Error__c=ex.getMessage());
            insert apilog;
        }
    }
    
    /* Method 		: invokeCreateIncompleteservice
	 * Description  : This method will invoke the CreateIncomplete api which is basically to get the new draft number to initiate the resubmission.
	*/
    webservice static void invokeCreateIncompleteservice(Id srId)
    {
        list<HexaBPM__Service_Request__c> srreqno = [Select TransactionRef__c from HexaBPM__Service_Request__c where id=:srId and TransactionRef__c != null];
        API_Response__c apilog; 
        try{
            if(!srreqno.isEmpty())
            {
                string payload = '{"UD_RequestNumber": "'+srreqno[0].TransactionRef__c+'"}';
                HttpRequest req = new HttpRequest(); 
                string ep;
                if(system.label.IsSandBox == 'TRUE'){
                    //req.setEndpoint('callout:Informatica_Cloud/ICA_CreateIncompleteRequest_Stage_Cloud');
                    req.setEndpoint('callout:Informatica_URL/ICA_CreateIncompleteRequest_Stage');
                    ep='callout:Informatica_URL/ICA_CreateIncompleteRequest_Stage';
                }
                else{
                	if(system.Label.ICA_RunServicesOnCloud == 'True'){
	            		req.setEndpoint('callout:Informatica_URL/ICA_CreateIncompleteRequest_Cloud');
                    	ep='callout:Informatica_URL/ICA_CreateIncompleteRequest_Cloud';
	            	}else{
	            		req.setEndpoint('callout:Informatica_URL/ICA_CreateIncompleteRequest');
                   	 	ep='callout:Informatica_URL/ICA_CreateIncompleteRequest';
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
                    ICA_CreateIncompleteRequest_RespJson resp =  (ICA_CreateIncompleteRequest_RespJson)System.JSON.deserialize(res.getBody(), ICA_CreateIncompleteRequest_RespJson.class);
                    if(resp != null && resp.O_isSucess != 'false' && resp.O_draftNumber != null)
                    {
                        srreqno[0].New_Draft_Number__c = resp.O_draftNumber;
                        srreqno[0].New_Draft_API_Status__c = 'Success';
                        update srreqno;
                        
                        apilog = new API_Response__c(Type__c='CreateIncompleteRequest Service', Service_Request__c=srreqno[0].id, Draft_Number__c=resp.O_draftNumber);
                        insert apilog;
                    }else{
                        apilog = new API_Response__c(Type__c='CreateIncompleteRequest Service', Service_Request__c=srreqno[0].id, Error__c=res.getBody());
                        insert apilog;
                    }
                    
                }else{
                    srreqno[0].New_Draft_API_Status__c = 'Error';
                    update srreqno;
                    
                    system.debug('=else part==');
                    apilog = new API_Response__c(Type__c='CreateIncompleteRequest Service', Service_Request__c=srreqno[0].id, Error__c=res.getBody());
                    insert apilog;
                }   
            }
        }catch(Exception ex){
            srreqno[0].New_Draft_API_Status__c = 'Exception';
            update srreqno;
            
            system.debug('---exception is --'+ex.getMessage());
            apilog = new API_Response__c(Type__c='CreateIncompleteRequest Service', Service_Request__c=srreqno[0].id, Error__c=ex.getMessage());
            insert apilog;
        }
    }
    
    /* Method 		: invokesubmitIncompleteservice
	 * Description  : This method will invoke the SubmitIncomplete api which is basically to to confirm the resubmission of an application.
	*/
    webservice static void invokesubmitIncompleteservice(Id srId)
    {
        list<HexaBPM__Service_Request__c> srreqno = [Select TransactionRef__c from HexaBPM__Service_Request__c where id=:srId and TransactionRef__c != null];
        API_Response__c apilog; 
        try{
            if(!srreqno.isEmpty())
            {
                string payload = '{"UD_RequestNumber": "'+srreqno[0].TransactionRef__c+'"}';
                HttpRequest req = new HttpRequest(); 
                string ep;
                if(system.label.IsSandBox == 'TRUE'){
                    //req.setEndpoint('callout:Informatica_Cloud/ICA_SubmitIncompleteservice_Stage_Cloud');
                    req.setEndpoint('callout:Informatica_URL/ICA_SubmitIncompleteservice_Stage');
                    ep='callout:Informatica_URL/ICA_CreateIncompleteRequest_Stage';
                }
                else{
                	if(system.Label.ICA_RunServicesOnCloud == 'True'){
	            		req.setEndpoint('callout:Informatica_URL/ICA_SubmitIncompleteservice_Cloud');
                		ep='callout:Informatica_URL/ICA_SubmitIncompleteservice_Cloud';
	            	}else{
	            		req.setEndpoint('callout:Informatica_URL/ICA_SubmitIncompleteservice');
               			ep='callout:Informatica_URL/ICA_SubmitIncompleteservice';
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
                
                if(res.getStatusCode() == 200)
                {
                    ICA_SubmitIncompleteRequest_RespJson resp =  (ICA_SubmitIncompleteRequest_RespJson)System.JSON.deserialize(res.getBody(), ICA_SubmitIncompleteRequest_RespJson.class);
                    if(resp != null && resp.O_isSucess != 'false' && resp.O_requestNumber != null)
                    {
                        srreqno[0].Resubmission_Confirmed__c = 'Success';
                        update srreqno;
                        apilog = new API_Response__c(Type__c='SubmitIncompleteRequest Service', Service_Request__c=srreqno[0].id);
                        insert apilog;
                    }else{
                        srreqno[0].Resubmission_Confirmed__c = 'Error';
                        apilog = new API_Response__c(Type__c='SubmitIncompleteRequest Service', Service_Request__c=srreqno[0].id,Error__c=res.getBody());
                        insert apilog;
                    }
                }else{
                    srreqno[0].Resubmission_Confirmed__c = 'Error';
                    update srreqno;
                    apilog = new API_Response__c(Type__c='SubmitIncompleteRequest Service', Service_Request__c=srreqno[0].id, Error__c=res.getBody());
                    insert apilog;
                }   
            }
        }catch(Exception ex){
            srreqno[0].Resubmission_Confirmed__c = 'Exception';
            update srreqno;
            system.debug('---exception is --'+ex.getMessage());
            apilog = new API_Response__c(Type__c='SubmitIncompleteRequest Service', Service_Request__c=srreqno[0].id, Error__c=ex.getMessage());
            insert apilog;
        }
    }
}
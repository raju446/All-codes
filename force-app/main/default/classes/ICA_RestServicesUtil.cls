/*
@Author : Azmath
@Description : This class is used to call the Initial Approval related apis.
@Version : v1.
*/
global  without sharing class ICA_RestServicesUtil 
{
    /* Method       : invokeInitialApprovalService
    *  Description  : This method will invoke the IntialApproval api which is basically to submit the Initial approval application to ICA.
    */
     webservice static void invokeInitialApprovalService(Id srId)
     {
        boolean isResubmission= false;
        list<HexaBPM__Service_Request__c> srrec = [Select TransactionRef__c, Draft_Number__c FROM HexaBPM__Service_Request__c where id=:srId];
        if(!srrec.isEmpty() && srrec[0].TransactionRef__c != null && srrec[0].Draft_Number__c != null)
        {
            isResubmission = true;
        }
        try{
            ICA_InitialApprovalJson helper = new ICA_InitialApprovalJson(srId); 
            string payload = JSON.serialize(helper);
            system.debug('===payload=='+payload);
            HttpRequest req = new HttpRequest();
            string ep;
            if(system.label.IsSandBox == 'TRUE')
            {
                //req.setEndpoint('callout:Informatica_Cloud/ICA_Stage_InitialApproval_Cloud');
                req.setEndpoint('callout:Informatica_URL/ICA_Stage_InitialApproval');//
                ep='callout:Informatica_Cloud/ICA_Stage_InitialApproval';
            }
            else
            {
                if(system.Label.ICA_RunServicesOnCloud == 'True'){
                    req.setEndpoint('callout:Informatica_URL/ICA_InitialApproval_Cloud');
                    ep='callout:Informatica_URL/ICA_InitialApproval_Cloud';
                }else{
                    req.setEndpoint('callout:Informatica_URL/ICA_InitialApproval');
                    ep='callout:Informatica_URL/ICA_InitialApproval';
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
             if(res.getStatusCode() == 200)
             {
                ICA_InitialApprovalRespParser resp =  (ICA_InitialApprovalRespParser)System.JSON.deserialize(res.getBody(), ICA_InitialApprovalRespParser.class);
                if(resp.UD_Output != null)
                {
                    system.debug('=====response mapping');
                    HexaBPM__Service_Request__c sr = new HexaBPM__Service_Request__c(id=srId);
                    
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
                        
                        //Note: In case of resubmit of an application , we dont need to create the document place holder again.
                        if(existingdocs.isEmpty())
                        {
                            if(resp.UD_Output.Data != null && resp.UD_Output.Data.requestFees != null)
                            sr.Total_Amount__c = resp.UD_Output.Data.requestFees.totalWithVat;
                            sr.Application_Fee__c = resp.UD_Output.Data.requestFees.totalAmountWithCommissionsIncludingVat;
                        
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
                                insert atts;
                                /*HexaBPM__Service_Request__c srwithAcid = [Select HexaBPM__Customer__c FROM HexaBPM__Service_Request__c where id=:srid];
                                list<Attachment> att= [Select id, Name, ParentId,Body, BodyLength, ContentType, Description FROM Attachment where ParentID =:srwithAcid.HexaBPM__Customer__c 
                                        and Name Like '%commercial%' order by CreatedDate DESC LIMIT 1];*/
                                list<Attachment> atlist = new list<Attachment>();
                                
                                //Query Internal Auth sig copy..
                                ///list<Document> doc = [Select id, Name, Body, ContentType,Type, Description from document where  id=:system.label.ICA_InternalPPCopyDocID];
                                
                                //Query generated lettter..
                                list<Attachment> adgmletter = new list<Attachment>();
                                list<HexaBPM__SR_Doc__c> srdocid = [Select id from HexaBPM__SR_Doc__c where HexaBPM__Service_Request__c=:srId and Name='Initial Approval'];
                                if(!srdocid.isEmpty()){
                                    adgmletter= [Select id, Name, ParentId,Body, BodyLength, ContentType, Description FROM Attachment where ParentID =:srdocid[0].id LIMIT 1];
                                }
                                
                                for(ICA_Document__c ica : atts)
                                {
                                    if(ica.Attachment_Type_Text__c == 'EXCEPTIONAL ATTACHMENT NO 2' && !adgmletter.isEmpty())
                                    {
                                        Attachment ata = new Attachment(Name=adgmletter[0].name,Body=adgmletter[0].Body,ContentType=adgmletter[0].ContentType,Description=adgmletter[0].Description,parentid=ica.id);
                                        atlist.add(ata);
                                    }
                                }
                                if(!atlist.isEmpty()){
                                    insert atlist;
                                }
                            }
                        }
                        
                        apilog = new API_Response__c(Type__c='Application Submission', Service_Request__c=srId, Draft_Number__c=sr.Draft_Number__c, Total_Amount__c = sr.Total_Amount__c, 
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
                        apilog = new API_Response__c(Type__c='Application Submission', Service_Request__c=srId, Error__c=errormsg);
                        insert apilog;
                    }
                    update sr;
                }
             }
             else{
                    HexaBPM__Service_Request__c sr = new HexaBPM__Service_Request__c(id=srId);
                    if(!isResubmission)
                            sr.Application_Submission_Status__c = 'Error';
                        else
                            sr.Application_Resubmission_API_Status__c = 'Error';
                    update sr;
                    apilog = new API_Response__c(Type__c='Application Submission', Service_Request__c=srId, Error__c=res.getBody());
                    insert apilog;
             }
        }
        catch(Exception ex){
            system.debug('-----Exception is --'+ex.getMessage());
            HexaBPM__Service_Request__c sr = new HexaBPM__Service_Request__c(id=srId);
            if(!isResubmission)
                sr.Application_Submission_Status__c = 'Error';
            else
                sr.Application_Resubmission_API_Status__c = 'Error';
            update sr;
             
            API_Response__c apilog = new API_Response__c(Type__c='Application Submission', Service_Request__c=srId, Error__c=ex.getMessage());
            insert apilog;
        }
     }
    
    /* Method       : invokepaymentservice
    *  Description  : This method will invoke the Payment api which is basically to pay the application fee.
    */
     webservice static void invokepaymentservice(Id srId)
     {
        try{
            HexaBPM__Service_Request__c sr = new HexaBPM__Service_Request__c();
            sr = [SELECT id, Draft_Number__c,Total_Amount__c FROM HexaBPM__Service_Request__c WHERE ID=:srId];
            
            if(sr.id != null && sr.Draft_Number__c != null)
            {
                API_Response__c bdetail = [Select id, Balance__c, AccountCode__c, Token__c, Bank_Code__c FROM API_Response__c 
                    WHERE Draft_Number__c=:sr.Draft_Number__c and (Type__c='Application Submission' or Type__c='CreateUpdate Establishment Service') and Service_Request__c=:srId Order by CreatedDate DESC LIMIT 1];
                if(bdetail.id != null)
                {
                    string ar = system.label.ICA_BankAccountCode;//'sd652tf4sd65f4 - الرصيد: 999390.9 درهم إماراتي';
                    ar = ar.replaceAll('sd652tf4sd65f4',bdetail.AccountCode__c);
                    ar = ar.replaceAll('999390.9',bdetail.Balance__c);
            
                    string paymenJson = '{"drafts":[{"draftNumber":"'+sr.Draft_Number__c+'","includeOptionallIds":[],"eligibleForSecondPayment":false}],"totalUIAmount":'+sr.Total_Amount__c;
                    paymenJson += ',"paymentType":"AmwalWallet","bankAccountToken":"'+bdetail.Token__c+'","bankCode":"'+bdetail.Bank_Code__c+'","BankAccountCode":"'+ar+'"}';
                    system.debug('payment json is =='+paymenJson);
                    
                    Blob eIv = EncodingUtil.convertFromHex('00000000000000000000000000000000');
                    Blob key = Blob.valueOf(SYSTEM.LABEL.ICA_KEY);
                    Blob data = Blob.valueOf(paymenJson);
                    Blob encrypted = Crypto.encrypt('AES128', key, eIv, data);
                    String encodedCipherText = EncodingUtil.base64Encode(encrypted);
                    system.debug(encodedCipherText);
                    
                    HttpRequest req = new HttpRequest();
                    string ep;
                    if(system.label.IsSandBox == 'TRUE'){
                        //req.setEndpoint('callout:Informatica_Cloud/ICA_Stage_PaymentService_Cloud');
                        req.setEndpoint('callout:Informatica_URL/ICA_Stage_PaymentService');
                        ep='callout:Informatica_Cloud/ICA_Stage_PaymentService';
                    }
                    else{
                        if(system.Label.ICA_RunServicesOnCloud == 'True'){
                            req.setEndpoint('callout:Informatica_URL/ICA_PaymentService_Cloud');
                            ep='callout:Informatica_URL/ICA_PaymentService_Cloud';
                        }else{
                            req.setEndpoint('callout:Informatica_URL/ICA_PaymentService');
                            ep='callout:Informatica_URL/ICA_PaymentService';
                        }
                    }
                    req.setMethod('POST');
                    req.setTimeout(120000);
                    req.setHeader('content-type','application/json;charset=UTF-8;');
                    req.setBody('{"UD_EJson":"'+encodedCipherText+'"}');
                    Http http = new Http();
                    HTTPResponse res = http.send(req);
                    system.debug('=response=='+res.getBody());
                    ApexCodeUtility.savePayload(ep,'{"UD_EJson":"'+encodedCipherText+'"}',srId,res.getBody());
                    
                    API_Response__c apilog;
                    if(res.getStatusCode() == 200)
                    {
                        ICA_DecryptJsonResp decryptcls = (ICA_DecryptJsonResp) System.JSON.deserialize(res.getBody(), ICA_DecryptJsonResp.class);
                        system.debug('==='+decryptcls.UD_Output);
                        Blob encodedEncryptedBlob = EncodingUtil.base64Decode(decryptcls.UD_Output);
                        Blob decryptedBlob = Crypto.decrypt('AES128', key, eIv, encodedEncryptedBlob);
                        String decryptedClearText = decryptedBlob.toString();
                        System.debug(decryptedClearText);
                        
                        ICA_PaymentRespJson pjson = (ICA_PaymentRespJson) System.JSON.deserialize(decryptedClearText, ICA_PaymentRespJson.class);
                        string draftNo;
                        string servicename;
                        for(ICA_PaymentRespJson.PaymentRequestDetails resp : pjson.PaymentRequestDetails)
                        {
                            if(sr.Draft_Number__c == resp.DraftNumber)
                            {
                                sr.PaymentRef__c        = resp.PaymentRef;
                                sr.ReceiptNumber__c     = resp.ReceiptNumber;
                                sr.TransactionRef__c    = resp.TransactionRef;
                                draftNo                 = resp.DraftNumber;
                                servicename             = resp.ServiceName;
                                sr.Payment_Status__c    = 'Success';
                            }
                        }
                        apilog = new API_Response__c(Type__c='Payment service', Service_Request__c=srId, Draft_Number__c=draftNo,Service_Name__c=servicename,TransactionRef__c=sr.TransactionRef__c);
                        insert apilog;
                        
                    }else{
                        sr.Payment_Status__c    = 'Error';
                        apilog = new API_Response__c(Type__c='Payment service', Service_Request__c=srId, Error__c=res.getBody());
                        insert apilog;
                    }
                    update sr;
                }
            }
        }catch(Exception ex){
            HexaBPM__Service_Request__c sr = new HexaBPM__Service_Request__c(id=srid,Payment_Status__c='Exception');
            update sr;
            API_Response__c apilog = new API_Response__c(Type__c='Payment service', Service_Request__c=srId, Error__c=ex.getMessage());
            insert apilog;
        }
     }
     
     /* Method      : invokepaymentservice
      * Description : This method will invoke the • UploadExternalAttachment api which is basically to upload the application related documents to ICA.
     */
     webservice static void invokeUploadattachmentservice(Id srId, string attachmenttypeid, Id docId, string docname, string draftno)
     {
        if(docId != null && srId != null && attachmenttypeid != null)
        {
            try{
                list<Attachment> att = [select id, Name, Body, ContentType, BodyLength  from attachment where parentid=:docId order by CreatedDate DESC Limit 1];
                if(!att.isEmpty())
                {
                    //public UD_Input(string fname, string mimetype, double fid, string name, string dno, string base64)
                    string base64 = Encodingutil.base64Encode(att[0].body);
                    ICA_UploadAttachmentReqJson helper = new ICA_UploadAttachmentReqJson(docname, att[0].ContentType, attachmenttypeid, att[0].Name, draftno, base64); 
                    string payload = JSON.serialize(helper);
                    system.debug('==payload'+payload);
                    
                    HttpRequest req = new HttpRequest();
                    string ep;
                    if(system.label.IsSandBox == 'TRUE'){
                        //req.setEndpoint('callout:Informatica_Cloud/ICA_Stage_UploadAttachment_C');
                        req.setEndpoint('callout:Informatica_URL/ICA_Stage_UploadAttachment');//
                        ep='callout:Informatica_Cloud/ICA_Stage_UploadAttachment';
                    }
                    else{
                        if(system.Label.ICA_RunServicesOnCloud == 'True'){
                            req.setEndpoint('callout:Informatica_URL/ICA_UploadAttachment_Cloud');
                            ep='callout:Informatica_URL/ICA_UploadAttachment_Cloud';
                        }else{
                            req.setEndpoint('callout:Informatica_URL/ICA_UploadAttachment');
                            ep='callout:Informatica_URL/ICA_UploadAttachment';
                        }
                    }
                    req.setMethod('POST');
                    req.setTimeout(120000);
                    req.setHeader('content-type','application/json;charset=UTF-8;');
                    req.setBody(payload);
                    Http http = new Http();
                    HTTPResponse res = http.send(req);
                    system.debug('=response=='+res.getBody());
                    //ApexCodeUtility.savePayload(ep,payload,srId,res.getBody());
                    
                    API_Response__c apilog;
                    if(res.getStatusCode() == 200)
                    {
                        ICA_UploadattachmentRespJson resp = (ICA_UploadattachmentRespJson) System.JSON.deserialize(res.getBody(), ICA_UploadattachmentRespJson.class);
                        if(resp != null && resp.UD_Output != null){
                            ICA_Document__c icadoc = new ICA_Document__c(Id=docId,Id__c=resp.UD_Output.id,Token__c=resp.UD_Output.token);
                            update icadoc;
                            
                            apilog = new API_Response__c(Type__c='Upload Document', Service_Request__c=srId, Token__c=resp.UD_Output.token , Id__c=resp.UD_Output.id, AttachmentType_Id__c=attachmenttypeid);
                            insert apilog;
                        }
                    }else{
                        apilog = new API_Response__c(Type__c='Upload Document', Service_Request__c=srId, Error__c=res.getBody());
                        insert apilog;
                    }
                }
            }catch(Exception ex){
                API_Response__c apilog = new API_Response__c(Type__c='Upload Document', Service_Request__c=srId, Error__c=ex.getMessage());
                insert apilog;
            }
        }
     }
}
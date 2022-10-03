/*
@Author     : Azmath
@Description   : This class is used to expose the status update api for ICA to consume to send the status of the application.
*/
@RestResource(urlMapping='/ICA_StatusUpdateServiceRequest/*')
global without sharing class ICA_StatusUpdateService 
{
    @HttpPost
    global static ResponseDetails updateStatus()
    {
        ResponseDetails objResp     = new ResponseDetails();
        StatusUpdateRequest srObj   = new StatusUpdateRequest();
        list<HexaBPM__service_request__c> serviceRequest = new list<HexaBPM__service_request__c>();
        string rejectedParticipants = '';
        Savepoint sp = Database.setSavepoint();
        try
        {
            srObj = (StatusUpdateRequest)System.JSON.deserialize(RestContext.request.requestBody.tostring(),StatusUpdateRequest.class);
            //Service type validations 
            if(srObj.ServiceType == null || (srObj.ServiceType != '1' &&  srObj.ServiceType != '2')){
                 objResp.O_Status        ='Error';
                 objResp.O_StatusCode    ='600';
                 objResp.O_Message       ='Invalid service type.';
                 return objResp;
            }
            //Status validation
            if(srObj.Status == null || (srObj.Status != '1' &&  srObj.Status != '2' &&  srObj.Status != '3' && srObj.Status != '4')){
                 objResp.O_Status        ='Error';
                 objResp.O_StatusCode    ='600';
                 objResp.O_Message       ='Invalid Status.';
                 return objResp;
            }
            if(srObj.RequestNumber !=null)
            {
                serviceRequest = [select id,HexaBPM__Parent_SR__c,HexaBPM__SR_Template__c, HexaBPM__external_status_name__c, recordtype.DeveloperName, Location__c, Start_Date__c, End_Date__c, 
                HexaBPM__Customer__c , IA_Reason__c, TransactionRef__c from HexaBPM__service_request__c where TransactionRef__c=:srObj.RequestNumber limit 1];
                  
                if(!serviceRequest.isEmpty())
                {
                    serviceRequest[0].ADP_Comments__c           = srObj.Comments;
                    serviceRequest[0].Status_Updated_Date__c    = srObj.UpdatedDate;
                    
                    //SR Level changes(Internal or external status and other details updates..) when the request is approved/rejected..
                    if(srObj.Status == '1' || srObj.Status == '2')
                    {
                        if(srObj.Status == '1')
                        {
                            serviceRequest[0].ADP_status__c                     = 'Approved';
                            if(serviceRequest[0].recordtype.DeveloperName != 'Initial_Approval'){
                                serviceRequest[0].HexaBPM__Internal_SR_Status__c    = system.Label.ICA_Estb_CardDownload;
                                serviceRequest[0].HexaBPM__External_SR_Status__c    = system.Label.ICA_ApplicationInProgress;//ICA_Estb_CardDownload
                            }
                            if(serviceRequest[0].recordtype.DeveloperName == 'Establishment_Card_New' || serviceRequest[0].recordtype.DeveloperName == 'Establishment_Card_Renewal')
                            {
                                if(serviceRequest[0].recordtype.DeveloperName == 'Establishment_Card_New')
                                {
                                    serviceRequest[0].Establishment_Card_Number__c      = srObj.EstablishmentCardNumber;
                                    serviceRequest[0].Establishment_Card_Issue_Date__c  = srObj.IssueDate;
                                }
                                serviceRequest[0].Establishment_Card_Expiry_Date__c = srObj.ExpiryDate;
                            }
                        }
                        else
                        {
                            serviceRequest[0].ADP_status__c = 'Rejected';
                            serviceRequest[0].HexaBPM__Internal_SR_Status__c = system.Label.Request_Rejected;
                            serviceRequest[0].HexaBPM__External_SR_Status__c = system.Label.CompletedStatus;
                        }
                        
                        //Intial approval Internal and external status updates..
                        if(serviceRequest[0].recordtype.DeveloperName == 'Initial_Approval'){
                            serviceRequest[0].HexaBPM__Internal_SR_Status__c = system.Label.ICA_SignatoryDetailsUpdate;
                            serviceRequest[0].HexaBPM__External_SR_Status__c = system.Label.ICA_SignatoryDetailsUpdate;
                        }
                        
                        //Populate Initial approval issue and exp dates.
                        if(serviceRequest[0].recordtype.DeveloperName == 'Initial_Approval' )
                        {
                            Initial_Approval_List__c ia     = new Initial_Approval_List__c();
                            ia.Entity__c                    = serviceRequest[0].HexaBPM__Customer__c;
                            ia.Service_Request__c           = serviceRequest[0].id;
                            ia.Initial_Approval_Number__c   = serviceRequest[0].TransactionRef__c;
                            ia.Reason__c                    = serviceRequest[0].IA_Reason__c;
                            ia.Active__c                        = true;
                            if(srObj.Status == '1')
                            {
                                Integer addExpiryDays = 0;
                                if(Label.CID_Expiry_Date_Days != ''){
                                    addExpiryDays = Integer.valueOf(Label.CID_Expiry_Date_Days);
                                }
                                serviceRequest[0].Initial_Approval_Issue_Date__c = ia.Issue_Date__c =  system.today();
                                serviceRequest[0].Initial_Approval_Expiry_Date__c = ia.Expiry_Date__c =  system.today().addDays(addExpiryDays);
                                ia.Status__c = 'Approved';
                            }else{
                                ia.Status__c = 'Rejected';
                                serviceRequest[0].Initial_Approval_Issue_Date__c = ia.Issue_Date__c = null;
                                serviceRequest[0].Initial_Approval_Expiry_Date__c = ia.Expiry_Date__c = null;
                            }
                            upsert ia Initial_Approval_Number__c;
                        }
                    }
                    else if(srObj.Status == '3')
                    {
                        serviceRequest[0].ADP_status__c = 'Incomplete';
                        serviceRequest[0].HexaBPM__Internal_SR_Status__c  = system.Label.Additonal_Info;
                        serviceRequest[0].New_Draft_Number__c = null;
                        serviceRequest[0].Resubmission_Confirmed__c = null;
                    }else{
                      serviceRequest[0].ADP_status__c = 'Roll back';
                    }
                    update serviceRequest;
                    
                    //New Draft step should be created after updating the SR status..
                    if(srObj.Status == '3')
                    {
                        getNewDraftNumber(serviceRequest[0].id, serviceRequest[0].HexaBPM__SR_Template__c);
                    }
                    
                    //Step level changes..
                    if(srObj.Status == '1' || srObj.Status == '2')
                    {
                        if(serviceRequest[0].recordtype.DeveloperName == 'Initial_Approval')
                        {
                            //ICAStatusUpdate__e ev1 = new ICAStatusUpdate__e(RecordId__c=serviceRequest[0].Id,TemplateId__c=serviceRequest[0].HexaBPM__SR_Template__c,Status__c=srObj.Status);
                            //EventBus.publish(ev1);
                            system.debug('===enqueue the job');
                            ICA_StatusUpdateQueue que = new ICA_StatusUpdateQueue(srObj.Status,serviceRequest[0].Id);
                            system.enqueueJob(que);
                            /*if(srObj.Status != '1')
                            {
                                list<HexaBPM__SR_Steps__c> srStep = [SELECT Id, HexaBPM__Summary__c, HexaBPM__Step_No__c, HexaBPM__Start_Status__c, HexaBPM__Step_Template__c
                                                    FROM HexaBPM__SR_Steps__c 
                                                    WHERE HexaBPM__SR_Template__c = :serviceRequest[0].HexaBPM__SR_Template__c 
                                                    AND HexaBPM__Step_Template_Code__c = 'Update Signatory Details'];
                                if(!srStep.isEmpty())
                                    ICA_StatusUpdateService.createStep(srStep[0],serviceRequest[0].Id,Label.Government_Services_Queue_Id);
                            }else{
                                ICAStatusUpdate__e ev1 = new ICAStatusUpdate__e(RecordId__c=serviceRequest[0].Id,TemplateId__c=serviceRequest[0].HexaBPM__SR_Template__c,Status__c=srObj.Status);
                                EventBus.publish(ev1);
                            }*/
                        }
                        else if(serviceRequest[0].recordtype.DeveloperName != 'Initial_Approval' && srObj.Status == '1' && serviceRequest[0].recordtype.DeveloperName != 'Establishment_Card_Cancellation')
                        {
                            list<HexaBPM__SR_Steps__c> srStep = [SELECT Id, HexaBPM__Summary__c, HexaBPM__Step_No__c, HexaBPM__Start_Status__c, HexaBPM__Step_Template__c
                                                FROM HexaBPM__SR_Steps__c 
                                                WHERE HexaBPM__SR_Template__c = :serviceRequest[0].HexaBPM__SR_Template__c 
                                                AND HexaBPM__Step_Template_Code__c = 'Download Estb. Card Copy'];
                            if(!srStep.isEmpty())
                                ICA_StatusUpdateService.createStep(srStep[0],serviceRequest[0].Id,Label.Government_Services_Queue_Id);    
                        }
                        else 
                        {
                            list<HexaBPM__SR_Steps__c> srStep = [SELECT Id, HexaBPM__Summary__c, HexaBPM__Step_No__c, HexaBPM__Start_Status__c, HexaBPM__Step_Template__c
                                                FROM HexaBPM__SR_Steps__c 
                                                WHERE HexaBPM__SR_Template__c = :serviceRequest[0].HexaBPM__SR_Template__c 
                                                AND HexaBPM__Step_Template_Code__c = 'Generate Invoice'];
                              if(!srStep.isEmpty())
                                ICA_StatusUpdateService.createStep(srStep[0],serviceRequest[0].Id,Label.System_Queue_Id);  
                        }
                    }
                    
                    //Create API Response log.
                    API_Response__c resp = new API_Response__c(Type__c='Status Update', Service_Request__c=serviceRequest[0].id, Comments__c=srObj.Comments, Status__c=srObj.Status);
                    insert resp;
                    
                    // set response as success
                    objResp.O_Status        ='Success';
                    objResp.O_StatusCode    ='200';
                    objResp.O_Message       ='Status updated successfully';
                    
                    ApexCodeUtility.savePayload('StatusUpdateServiceRequest', string.valueof(srObj), serviceRequest[0].id, null);
                }else{
                     objResp.O_Status        ='Error';
                     objResp.O_StatusCode    ='600';
                     objResp.O_Message       ='Request Number not found.';
                }
            }
            
        }catch(Exception ex){
            system.debug('====exception is=='+ex.getMessage());
            Database.rollback(sp);
            objResp.O_Status        = 'Error';
            objResp.O_StatusCode    ='500';
            objResp.O_Message       ='Error: Something went wrong.';
            if(!serviceRequest.isEmpty())
            {
                API_Response__c resp = new API_Response__c(Type__c='Status Update', Service_Request__c=serviceRequest[0].id, Error__c=ex.getMessage());
                insert resp;
            }
        }
        return objResp;
    }
    
    global class StatusUpdateRequest{
         global string ServiceType;// Lookup - "1" for Initial Approval, "2" for Establishment Card
         global string RequestNumber;
         global String Status; // Lookup - "1" for Approved , "2" for Rejected, "3" for Incomplete
         global string Comments;
         global Date UpdatedDate;//Datetime
         global string EstablishmentCardNumber;
         global Date IssueDate;
         global Date ExpiryDate;
    }
    
     global class ResponseDetails{
        global string O_Status;
        global string O_StatusCode;
        global String O_Message;
    }
    
    public static void createStep(HexaBPM__SR_Steps__c srStep, Id srId, string queueid)
    {
        HexaBPM__Step__c newStep            = new HexaBPM__Step__c();
        newStep.HexaBPM__Step_No__c         = srStep.HexaBPM__Step_No__c;
        newStep.HexaBPM__SR_Step__c         = srStep.Id; 
        newStep.HexaBPM__Summary__c         = srStep.HexaBPM__Summary__c;
        newStep.HexaBPM__Status__c          = srStep.HexaBPM__Start_Status__c;
        newStep.HexaBPM__SR__c              = srId;
        newStep.OwnerId                     = queueid;
        newStep.HexaBPM__Step_Template__c   = srStep.HexaBPM__Step_Template__c;
        newStep.HexaBPM__Start_Date__c      = Date.today();
        newStep.HexaBPM__Due_Date__c        = system.today();
        newStep.HexaBPM__Sys_Step_Loop_No__c = string.valueof(srStep.HexaBPM__Step_No__c)+'_1';
        insert newStep;
    }
    @future(callout=true)
    public static void getNewDraftNumber(Id srid,Id templateid)
    {
        ICA_CreateUpdateEstablishmentUtil.invokeCreateIncompleteservice(srid);
        
        list<HexaBPM__SR_Steps__c> srStep = [SELECT Id, HexaBPM__Summary__c, HexaBPM__Step_No__c, HexaBPM__Start_Status__c, HexaBPM__Step_Template__c
                                            FROM HexaBPM__SR_Steps__c 
                                            WHERE HexaBPM__SR_Template__c = :templateid 
                                            AND HexaBPM__Step_Template_Code__c = 'GET_NEW_DRAFT_NUMBER'];
                        
        list<HexaBPM__Step__c> geninvoice = new list<HexaBPM__Step__c>();
        if(!srStep.isEmpty()){
            //create step record
            HexaBPM__Step__c newStep        = new HexaBPM__Step__c();
            newStep.HexaBPM__Step_No__c     = srStep[0].HexaBPM__Step_No__c;
            newStep.HexaBPM__SR_Step__c     = srStep[0].Id; 
            newStep.HexaBPM__Summary__c     = srStep[0].HexaBPM__Summary__c;
            newStep.HexaBPM__Status__c      = srStep[0].HexaBPM__Start_Status__c;
            newStep.HexaBPM__SR__c          = srid;
            newStep.HexaBPM__Start_Date__c  = Date.today();
            newStep.HexaBPM__Due_Date__c    = system.today();
            newStep.HexaBPM__Sys_Step_Loop_No__c = string.valueof(srStep[0].HexaBPM__Step_No__c)+'_1';
            newStep.OwnerId                 = Label.System_Queue_Id;
            newStep.HexaBPM__Step_Template__c = srStep[0].HexaBPM__Step_Template__c;
            geninvoice.add(newStep);
        }
        if(!geninvoice.isEmpty())
            insert geninvoice;
        
    }
}
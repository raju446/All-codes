/*********************************************************************
 * Description: ADP will consume this webservice to update SR status
 * Version  Author              Description
 * 1.1      Azmath              Updated the code as per the APi changes.
 *********************************************************************/
 
@RestResource(urlMapping='/StatusUpdateServiceRequest/*')
global without sharing class REST_StatusUpdateServiceRequest {
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
            
            //Query Service Request based on Application Id passed by ADP.
            if(srObj.ApplicationId!=null){
                serviceRequest = [select id,HexaBPM__Parent_SR__c, HexaBPM__external_status_name__c, recordtype.DeveloperName, Location__c, 
                                  Start_Date__c, End_Date__c,HexaBPM__Required_Docs_not_Uploaded__c
                    from HexaBPM__service_request__c where Id=:srObj.ApplicationId limit 1];
            }
            
            //ADP can responde with the below status. Need More
            //1. APPROVED , 2. REJECTED 3.INCOMPLETE
            if(!serviceRequest.isEmpty())
            {
                if( serviceRequest[0].HexaBPM__Required_Docs_not_Uploaded__c == true){
                    serviceRequest[0].HexaBPM__Required_Docs_not_Uploaded__c = false;
                    update  serviceRequest[0];
                }
                system.debug('====status=='+srObj.Status+'==comments='+srObj.ADPComments);
                serviceRequest[0].ADP_status__c                = srObj.Status; 
                serviceRequest[0].ADP_Comments__c              = srObj.ADPComments;
                
                // Alcohol permit dates will be calculated post approval from ADP.
                if(serviceRequest[0].recordtype.DeveloperName == 'Permit_Alcohol' || serviceRequest[0].recordtype.DeveloperName == 'Renew_Alcohol_Permit'){
                    serviceRequest[0].Valid_From__c            = Date.today();
                    serviceRequest[0].Valid_To__c              = system.today().addYears(1);
                }
                
                // Update the Internal status of SR in case ADP responds with the status Need more info.
                if(srObj.Status != null && srObj.Status != '' && srObj.Status != 'APPROVED' && srObj.Status != 'REJECTED'){
                    serviceRequest[0].HexaBPM__Internal_SR_Status__c = system.label.ADP_AdditionalInfoByADP;
                }
                
                //Set the Int/Ext Status to "Rejected" in case of permit is Rejected.
                if(srObj.Status == 'REJECTED'){
                    serviceRequest[0].HexaBPM__Internal_SR_Status__c = system.label.Request_Rejected;
                    serviceRequest[0].HexaBPM__External_SR_Status__c = system.label.Request_Rejected;
                }
                update serviceRequest;
                
                //Query Typing step to change the status to Typing completed/Rejected based on ADP status.
                list<HexaBPM__Step__c> lststepTyping = new list<HexaBPM__Step__c>();
                lststepTyping = [SELECT id, HexaBPM__SR__c, HexaBPM__SR_Step__c, HexaBPM__Step_Status__c, HexaBPM__Status__c FROM HexaBPM__Step__c 
                        WHERE HexaBPM__SR__c=:srObj.ApplicationId AND Step_Template_Code__c='TYPING' limit 1];
                
                if(!lststepTyping.isEmpty())
                {
                    HexaBPM__Step__c stepTyping = lststepTyping[0];
                    Id srid = serviceRequest[0].id;
                    
                    //Once approved update the particpants status if approved/Rejected.
                    if(srObj.Status=='APPROVED')
                    {
                        rejectedParticipants = srObj.ADPComments;
                        //if(rejectedParticipants != null && rejectedParticipants != '')
                        //{
                            if(serviceRequest[0].recordtype.DeveloperName == 'ADGM_Permit_Amendment_Service_Request')
                            {
                                srid = serviceRequest[0].HexaBPM__Parent_SR__c;
                            }
                            
                            list<string> passports = new list<string>();
                            set<string> passportset = new set<string>();
                            if(rejectedParticipants != null)
                            {
                                rejectedParticipants = rejectedParticipants.trim();
                                if(rejectedParticipants.contains(';'))
                                    passports = rejectedParticipants.split(';');
                                else if(rejectedParticipants.contains(','))
                                    passports = rejectedParticipants.split(',');
                                else
                                    passports.add(rejectedParticipants);
                            }
                            
                            if(!passports.isEmpty()){
                                passportset.addAll(passports);
                                passports.clear();
                            }
                            //if(!passports.isEmpty())
                            //{
                                list<Amendment__c> updatePartslist = new list<Amendment__c>();
                                //Passport number is encypted and we cannot apply this in where condition. so need to query all the participants and match the PP.
                                for(Amendment__c am : [Select id, Passport_No__c FROM Amendment__c WHERE Service_Request__c=:srid])
                                {
                                    if(passportset.contains(am.Passport_No__c)){
                                        am.Is_Participant_Approved__c = 'No';
                                    }
                                    else{
                                            am.Is_Participant_Approved__c = 'Yes';
                                        }
                                    updatePartslist.add(am);
                                    
                                }
                                if(!updatePartslist.isEmpty()){
                                    update updatePartslist;
                                }
                            //}
                        //}
                        stepTyping.HexaBPM__Status__c = [SELECT id FROM HexaBPM__Status__c WHERE Name='Typing Completed' limit 1].Id;
                        
                        //Update ParentSR startDate, EndDate and Location if applicable.
                        if(serviceRequest[0].HexaBPM__Parent_SR__c != null)
                        {
                            boolean updateParetnSR = false;
                            HexaBPM__service_request__c paretnSR = new HexaBPM__service_request__c();
                            
                            if(serviceRequest[0].Start_Date__c != null)
                            {
                                paretnSR.Start_Date__c = serviceRequest[0].Start_Date__c;
                                paretnSR.Valid_From__c = serviceRequest[0].Start_Date__c;
                                updateParetnSR = true;
                            }
                            if(serviceRequest[0].End_Date__c != null)
                            {
                                paretnSR.End_Date__c = serviceRequest[0].End_Date__c;
                                paretnSR.Valid_To__c = serviceRequest[0].End_Date__c;
                                updateParetnSR = true;
                            }
                            if(serviceRequest[0].Location__c != null)
                            {
                                paretnSR.Location__c = serviceRequest[0].Location__c;
                                updateParetnSR = true;
                            }
                            if(updateParetnSR == true)
                            {
                                paretnSR.id = serviceRequest[0].HexaBPM__Parent_SR__c;
                                update paretnSR;
                            }
                        }
                    }
                    else if(srObj.Status=='REJECTED')
                        stepTyping.HexaBPM__Status__c = [SELECT id FROM HexaBPM__Status__c WHERE Name='Request Rejected' limit 1].Id;
                   
                    update stepTyping;
                    
                    //if the SR is amendment SR then we need to regnerate the permit doc on parent SR.
                    if(srObj.Status=='APPROVED' && serviceRequest[0].recordtype.DeveloperName == 'ADGM_Permit_Amendment_Service_Request')
                    {
                         list<string> permitdocs = new list<string>{'Entertainment Permit','Extended Business Hours Permit','Temporary Fit Out Security Clearance Permit'};
                         for(HexaBPM__SR_Doc__c srdoc : [Select id from HexaBPM__SR_Doc__c where Name IN:permitdocs and HexaBPM__Service_Request__c=:srid LIMIT 1])
                         {
                            srdoc.HexaBPM__Generate_Document__c = true;
                            update srdoc;
                         }
                    }
                }
                
                //Create API Response log.
                API_Response__c resp = new API_Response__c(Type__c='Status Update', Service_Request__c=serviceRequest[0].id, Comments__c=srObj.ADPComments, Status__c=srObj.Status);
                insert resp;
                               
                // set response as success
                objResp.O_Status        ='Success';
                objResp.O_StatusCode    ='200';
                objResp.O_Message       ='Status updated successfully';
            } 
            else {// if no record found with the Id
                objResp.O_Status        ='Error';
                objResp.O_StatusCode    ='600';
                objResp.O_Message       ='ApplicationId not found.';
            }
            ApexCodeUtility.savePayload('StatusUpdateServiceRequest',string.valueof(srObj),srObj.ApplicationId,null);
        }catch (Exception ex){
            system.debug('--exception--'+ex.getMessage());
            Database.rollback(sp);
            objResp.O_Status        = 'Error';
            objResp.O_StatusCode    ='500';
            objResp.O_Message       =' Error: Something went wrong.';
            API_Payload__c api = new API_Payload__c(Exception__c=ex.getMessage(),Service_Request__c=srObj.ApplicationId);
            insert api;
            API_Response__c resp = new API_Response__c(Type__c='Status Update', Service_Request__c=serviceRequest[0].id, Comments__c=ex.getMessage());
            insert resp;
        }
        return objResp;
    }
    
    global class ResponseDetails{
        global string O_Status;
        global string O_StatusCode;
        global String O_Message;
    }
    
    global class StatusUpdateRequest{
        global string ApplicationId;
        global string Status;
        global string ADPComments;
    }
}
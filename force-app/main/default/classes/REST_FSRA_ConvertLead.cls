/*
    Author      : Durga Kandula
    Date        : 10-Aug-2020
    Description : REST API class to convert Lead from FSRA.
    Version History
    Prachi       24-Mar-2021    Mapped the field Converted_By_User__c from FSRA
    Naman        7-Oct-2021     Removed debug statements having PII
    Naman        1-Nov-2021     Using custom label to assign lead converted status for FSRA leads
    Prachi       16-11-2021     Mapped From_FSRA__c as true for leads created in CRM
    ---------------------------------------------------------------
*/

@RestResource(urlMapping='/REST_FSRA_ConvertLead/*')
global without sharing class REST_FSRA_ConvertLead{

    @HttpPost
    global static ResponseDetails ConvertLead(){
        REST_FSRA_ConvertLead.ResponseDetails objResp = new REST_FSRA_ConvertLead.ResponseDetails();
        
        string RequestString = RestContext.request.requestBody.tostring();
        RequestDetails objRequestWrap = (RequestDetails)JSON.deserialize(RequestString,RequestDetails.class);
        if(objRequestWrap!=null && objRequestWrap.LeadId!=null){
            
            string LeadId;
            lead objLeadTBU;
            for(Lead objLead:[Select Id,First_Contact_Date__c,Last_Contact_Date__c,Converted_By_User__c,From_FSRA__c from Lead where Id=:objRequestWrap.LeadId]){
                LeadId = objLead.Id;
                objLeadTBU = objLead;
            }
            if(LeadId!=null){
                try{
                    if(objLeadTBU.First_Contact_Date__c==null || objLeadTBU.Last_Contact_Date__c==null){
                        objLeadTBU.First_Contact_Date__c = system.today();
                        objLeadTBU.Last_Contact_Date__c = system.today();
                        //update objLeadTBU;
                    }
                    
                    objLeadTBU.Converted_By_User__c = objRequestWrap.ConvertedByUser;
                    objLeadTBU.From_FSRA__c = true;
                    update objLeadTBU;
                    
                    Database.LeadConvert lc = new Database.LeadConvert();
                    lc.setLeadId(LeadId);
                    lc.setDoNotCreateOpportunity(false);
                    
                    //get the lead status from the LeadStatus obejct
                    LeadStatus convertStatus = [SELECT Id, MasterLabel, IsConverted FROM LeadStatus WHERE IsConverted=true limit 1];  
                    //lc.setConvertedStatus(convertStatus.MasterLabel);
                    lc.setConvertedStatus(Label.FSRA_Connect_Lead_Converted_Status);
                
                
                    Database.LeadConvertResult lcResults = Database.convertLead(lc);
                    objResp.bSuccess = true;
                    objResp.StatusCode = '201';
                    objResp.Message = 'Success';
                    
                    string AccountId = string.valueOf(lcResults.getAccountId());
                    
                    
                //  EntityUtil.PushEntityToOracle_Future(new List<String>{AccountId});   
                    
                    set<string> setAccountIds = new set<string>();                                                             
                    
                    if(AccountId!=null){
                        //OpportunityTriggerHelper.PushConvertedLeadToAM(AccountId);
                        //setAccountIds.add(AccountId);
                        //OpportunityTriggerHelper.processRecords_Future(setAccountIds);
                    }
                    
                }catch(DMLException e){
                    string DMLError = e.getdmlMessage(0)+'';
                    if(DMLError==null)
                        DMLError = e.getMessage()+'';
                    objResp.bSuccess = false;
                    objResp.StatusCode = '500';
                    objResp.Message = DMLError;
                }
            }else{
                objResp.bSuccess = false;
                objResp.StatusCode = '600';
                objResp.Message = 'Lead not found Id:'+objRequestWrap.LeadId;
            }
        }
        
        return objResp;
    }
    global class RequestDetails{
        global string LeadId;
        global string ConvertedByUser;
    }
    global class ResponseDetails{
        global boolean bSuccess;
        global string StatusCode;
        global string Message;
        global ResponseDetails(){
            bSuccess = true;
        }
    }
}
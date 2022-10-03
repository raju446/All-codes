/******************************************************************************************
    Author      : Durga Kandula
    Date        : 15-Dec-2020
    Description : REST API class to Update the Opportunity Stage based on Request Status in FSRA.
	History:
	Naman Sharma	5/7/'21		Added Date of FSP/RO to be mapped on Oppty record
	Naman Sharma 	7/10/'21	Removed debug statements having PII
 *******************************************************************************************/
@RestResource(urlMapping='/REST_FSRA_OpportunityStageUpdate/*')
global without sharing class REST_FSRA_OpportunityStageUpdate{
    @HttpPost
    global static ResponseDetails UpdateOpportunityStage(){
        REST_FSRA_OpportunityStageUpdate.ResponseDetails objResp = new REST_FSRA_OpportunityStageUpdate.ResponseDetails();
        objResp.StatusCode = '201';
        objResp.Message = 'Success';
        
        string RequestString = RestContext.request.requestBody.tostring();
        RequestDetails objRequestWrap = (RequestDetails)JSON.deserialize(RequestString,RequestDetails.class);
        if(objRequestWrap!=null && objRequestWrap.OpportunityId!=null && objRequestWrap.RequestStatus!=null){
            string OpportunityId;
            for(Opportunity opp:[Select Id from Opportunity where Id=:objRequestWrap.OpportunityId]){
                OpportunityId = opp.Id;
            }
            if(OpportunityId!=null){
                try{
                    Opportunity objOpp = new Opportunity(Id=OpportunityId,StageName=objRequestWrap.RequestStatus);
                    if (objRequestWrap.ApplicationSubmittedDate != null){
                        objOpp.Application_Submitted_Date__c = objRequestWrap.ApplicationSubmittedDate;
                    }
                    if (objRequestWrap.IPAIssueDate != null){
                        objOpp.IPA_Granted_On__c = objRequestWrap.IPAIssueDate;
                    }
                    if (objRequestWrap.IPAExpiryDate != null){
                        objOpp.IPA_Valid_Till__c = objRequestWrap.IPAExpiryDate;
                    }
                    if (objRequestWrap.DateOfWithdrawal != null){
                        objOpp.Date_of_Withdrawal__c = objRequestWrap.DateOfWithdrawal;
                    }
                    //Naman 5-7-'21
                    if (objRequestWrap.DateOfFSP != null){
                        objOpp.Date_of_FSP__c = objRequestWrap.DateOfFSP;
                    }
                    update objOpp;
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
                objResp.Message = 'Opportunity not found Id:'+objRequestWrap.OpportunityId;
            }
        }
        
        return objResp;
    }
    global class RequestDetails{
        global string OpportunityId;
        global string RequestStatus;
        global Date ApplicationSubmittedDate;
        global Date IPAIssueDate;
        global Date IPAExpiryDate;
        global Date DateOfWithdrawal;
        //Naman - 5-7-'21
        global Date DateOfFSP;
        
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
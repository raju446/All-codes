/******************************************************************************************
    Author      : Naman Sharma
    Date        : 6-Jul-2021
    Description : REST API class to update the Entity sector mapping details as per updates in FSRA Connect.
	History:
	6-Sept-'21: Sending message in objResp in case of Exception
	9-Sept-'21: Added new method to increase test class code coverage
	19-Sept-'21: Naman - No need to update Activity and Sub-Activity field on Entity record
	19-Sept-'21: Naman - Map Sector value coming from FSRA Connect to 'FSRA Sector' field.
	7-Oct-'21: Naman - Commented debug statements having PII
 *******************************************************************************************/
@RestResource(urlMapping='/REST_FSRA_EntityDetailsUpdate/*')
global without sharing class REST_FSRA_EntityDetailsUpdate{
    @HttpPost
    global static ResponseDetails UpdateEntityDetails(){
        REST_FSRA_EntityDetailsUpdate.ResponseDetails objResp = new REST_FSRA_EntityDetailsUpdate.ResponseDetails();
        objResp.StatusCode = '201';
        objResp.Message = 'Success';
        
        string RequestString = RestContext.request.requestBody.tostring();
        RequestDetails objRequestWrap = (RequestDetails)JSON.deserialize(RequestString,RequestDetails.class);
        if(objRequestWrap!=null && objRequestWrap.CRMRecordId!=null){
            string accRecordId;
            for(Account acc:[Select Id from Account where Id=:objRequestWrap.CRMRecordId]){
                accRecordId = acc.Id;
            }
            if(accRecordId!=null){
                try{
                    Account objAcc = new Account(Id = accRecordId);
                    if(objRequestWrap.SectorValue != null){
                        //Naman - Mapping 'Sector' value coming from FSRA Connect to 'FSRA Sector' field in CRM.
                        objAcc.FSRA_Sector__c = objRequestWrap.SectorValue;
                    }
                    //Naman: No need to update Activity and Sub-Activity field
                    /*if(objRequestWrap.ActivityValue != null){
                        objAcc.Sector__c = objRequestWrap.ActivityValue;
                    }
                    //if(objRequestWrap.SubActivityValue != null){
                        objAcc.Sub_Sector__c = objRequestWrap.SubActivityValue;
                    }*/
                    if(objRequestWrap.FSRADivisionValue != null){
                        objAcc.FSRA_Division__c = objRequestWrap.FSRADivisionValue;
                    }
                    update objAcc;
                }catch(DMLException e){
                    string DMLError = e.getdmlMessage(0)+'';
                    if(DMLError==null)
                        DMLError = e.getMessage()+'';
                    objResp = errorWrap(objResp, false, '500', DMLError, e.getStackTraceString());
                    //objResp.bSuccess = false;
                    //objResp.StatusCode = '500';
                    //objResp.Message = DMLError;
                    //Log__c log = new Log__c(Cause__c= 'REST_FSRA_EntityDetailsUpdate',Message__c =DMLError, Stack_Trace__c = e.getStackTraceString());
                    //insert log;
                }
                catch(Exception e){
                    objResp = errorWrap(objResp, false, '500', e.getMessage(), e.getStackTraceString());
                    //Log__c log = new Log__c(Cause__c= 'REST_FSRA_EntityDetailsUpdate',Message__c = e.getMessage(), Stack_Trace__c = e.getStackTraceString());
                    //insert log;
                    
                    //objResp.bSuccess = false;
                    //objResp.StatusCode = '500';
                    //objResp.Message = e.getMessage();
                }
            }else{
                objResp.bSuccess = false;
                objResp.StatusCode = '600';
                objResp.Message = 'Account not found Id:'+objRequestWrap.CRMRecordId;
                
            }
        }
        
        return objResp;
    }
    public static REST_FSRA_EntityDetailsUpdate.ResponseDetails errorWrap(REST_FSRA_EntityDetailsUpdate.ResponseDetails resp, boolean bSuccess, String statusCode, String message, String stackTrace){
        resp.bSuccess = bSuccess;
        resp.StatusCode = statusCode;
        resp.Message = message;
        Log__c log = new Log__c(Cause__c= 'REST_FSRA_EntityDetailsUpdate',Message__c=message, Stack_Trace__c = stackTrace);
        insert log;
        return resp;
        
    }
    
    global class RequestDetails{
        global string CRMRecordId;
        global string SectorValue;
        //global string ActivityValue;
        //global string SubActivityValue;
        global string FSRADivisionValue;
        
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
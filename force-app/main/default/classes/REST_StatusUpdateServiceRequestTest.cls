/*
*Author : Azmath
Description : Test class for REST_StatusUpdateServiceRequest class.
*/
@isTest
public class REST_StatusUpdateServiceRequestTest {
    static testmethod void statusUpdateTestApproved(){
        List<HexaBPM__Service_Request__c> createdSRList = ADPTestDataFactory.createcustomerandSR('Permit_Alcohol',2);
        createdSRList[0].HexaBPM__Parent_SR__c = createdSRList[1].id;
        createdSRList[0].Start_Date__c = Date.today();
        createdSRList[0].End_Date__c = Date.today();
        createdSRList[0].Location__c = 'ADGM Galleria Mall';
        update createdSRList[0];
        
        HexaBPM__Status__c status = ADPTestDataFactory.createStatus('Application Submitted','APPLICATION_SUBMITTED');
        HexaBPM__Status__c statusTC = ADPTestDataFactory.createStatus('Typing Completed','Typing_Completed');
        HexaBPM__Status__c statusrej = ADPTestDataFactory.createStatus('Request Rejected','Request Rejected');
        HexaBPM__Step_Template__c temp = ADPTestDataFactory.createstepTemplate('TYPING','Test');
        HexaBPM__Step__c step = ADPTestDataFactory.createactionitem('Test',temp.id, createdSRList[0].id,status.id);
        
        REST_StatusUpdateServiceRequest.StatusUpdateRequest statusUpdate = new REST_StatusUpdateServiceRequest.StatusUpdateRequest();
        statusUpdate.ApplicationId=createdSRList[0].Id;
        statusUpdate.Status='Approved';
        statusUpdate.ADPComments='testcomments here';
        
        String JsonMsg = JSON.serialize(statusUpdate);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/StatusUpdateServiceRequest/';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        
        test.startTest();
        REST_StatusUpdateServiceRequest.ResponseDetails respDetails = new REST_StatusUpdateServiceRequest.ResponseDetails();
        respDetails = REST_StatusUpdateServiceRequest.updateStatus();
        statusUpdate.Status='Rejected';
        JsonMsg = JSON.serialize(statusUpdate);
        req.requestBody = Blob.valueof(JsonMsg);
        
        REST_StatusUpdateServiceRequest.updateStatus();
        
        statusUpdate.Status=null;
        JsonMsg = JSON.serialize(statusUpdate);
        req.requestBody = Blob.valueof(JsonMsg);
        
        REST_StatusUpdateServiceRequest.updateStatus();
        delete statusrej;
        REST_StatusUpdateServiceRequest.updateStatus();
        test.stopTest();
    }
    static testmethod void statusUpdateTestRejected(){
        List<HexaBPM__Service_Request__c> createdSRList = ADPTestDataFactory.createcustomerandSR('Permit_Alcohol',2);
        HexaBPM__Status__c status = ADPTestDataFactory.createStatus('Application Submitted','APPLICATION_SUBMITTED');
        HexaBPM__Status__c statusTC = ADPTestDataFactory.createStatus('Typing Completed','Typing_Completed');
        HexaBPM__Step_Template__c temp = ADPTestDataFactory.createstepTemplate('TYPING','Test');
        HexaBPM__Step__c step = ADPTestDataFactory.createactionitem('Test',temp.id, createdSRList[0].id,status.id);
        
        REST_StatusUpdateServiceRequest.StatusUpdateRequest statusUpdate = new REST_StatusUpdateServiceRequest.StatusUpdateRequest();
        statusUpdate.ApplicationId=createdSRList[0].Id;
        statusUpdate.Status='Rejected';
        statusUpdate.ADPComments='testcomments here';
        
        String JsonMsg = JSON.serialize(statusUpdate);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/StatusUpdateServiceRequest/';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        
        test.startTest();
        REST_StatusUpdateServiceRequest.ResponseDetails respDetails = new REST_StatusUpdateServiceRequest.ResponseDetails();
        respDetails = REST_StatusUpdateServiceRequest.updateStatus();
    }
    
}
/**
*   Author      : Azmath
*   Descritpion : Test class for ICA_StatusUpdateService
*/
@isTest
private class ICA_StatusUpdateService_Test 
{
    static testMethod void updateStatusEstbTest()
    {
    	Account acc 					= ICA_TestDataFactory.CreateAccountwithRolesandAddress();
        HexaBPM__Service_Request__c srrec = ICA_TestDataFactory.CreateNewEstbSR(acc.id);
        srrec.TransactionRef__c			= '1234';
        update srrec;
        
    	ICA_StatusUpdateService.StatusUpdateRequest sr = new ICA_StatusUpdateService.StatusUpdateRequest();
    	sr.ServiceType = '1';
    	sr.RequestNumber = '1234';
    	sr.Status = '1';
    	sr.Comments = 'test';
    	sr.UpdatedDate = Date.today();
    	sr.EstablishmentCardNumber = '1234';
    	sr.IssueDate = Date.today();
    	sr.ExpiryDate = Date.today().addDays(360);
    	String JsonMsg = JSON.serialize(sr);
    	
    	RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/ICA_StatusUpdateServiceRequest/';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        
    	test.startTest();
    	ICA_StatusUpdateService.updateStatus();
    	test.stopTest();
    }
    static testMethod void updateStatusIATest()
    {
    	Account acc 					= ICA_TestDataFactory.CreateAccountwithRolesandAddress();
        HexaBPM__Service_Request__c srrec = ICA_TestDataFactory.CreateInitialApprovalSR(acc.id);
        srrec.TransactionRef__c			= '1234';
        update srrec;
        
    	ICA_StatusUpdateService.StatusUpdateRequest sr = new ICA_StatusUpdateService.StatusUpdateRequest();
    	sr.ServiceType = '1';
    	sr.RequestNumber = '1234';
    	sr.Status = '1';
    	sr.Comments = 'test';
    	sr.UpdatedDate = Date.today();
    	sr.EstablishmentCardNumber = '1234';
    	sr.IssueDate = Date.today();
    	sr.ExpiryDate = Date.today().addDays(360);
    	String JsonMsg = JSON.serialize(sr);
    	
    	RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/ICA_StatusUpdateServiceRequest/';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        
        HexaBPM__SR_Template__c template 		= ICA_TestDataFactory.createTemplate('Initial_Approval');
        HexaBPM__Step_Template__c steptemplate 	= ICA_TestDataFactory.createstepTemplate(template.id, 'GET_NEW_DRAFT_NUMBER', 'Get New Draft Number');
        HexaBPM__SR_Steps__c SRstep 			= ICA_TestDataFactory.createSRstep('Get New Draft Number',template.id,steptemplate.id);
        
    	test.startTest();
    	ICA_StatusUpdateService.updateStatus();
    	ICA_StatusUpdateService.createStep(srstep,srrec.id,Label.System_Queue_Id);
    	ICA_StatusUpdateService.getNewDraftNumber(srrec.id,template.id);
    	test.stopTest();
    }
    static testMethod void updateStatusIATest1()
    {
    	Account acc 					= ICA_TestDataFactory.CreateAccountwithRolesandAddress();
        HexaBPM__Service_Request__c srrec = ICA_TestDataFactory.CreateInitialApprovalSR(acc.id);
        srrec.TransactionRef__c			= '1234';
        update srrec;
        
    	ICA_StatusUpdateService.StatusUpdateRequest sr = new ICA_StatusUpdateService.StatusUpdateRequest();
    	sr.ServiceType = '1';
    	sr.RequestNumber = '1234';
    	sr.Status = '3';
    	sr.Comments = 'test';
    	String JsonMsg = JSON.serialize(sr);
    	
    	RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/ICA_StatusUpdateServiceRequest/';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        
    	test.startTest();
    	ICA_StatusUpdateService.updateStatus();
    	test.stopTest();
    }
    static testMethod void updateStatusIATest2()
    {
    	ICA_StatusUpdateService.StatusUpdateRequest sr = new ICA_StatusUpdateService.StatusUpdateRequest();
    	sr.ServiceType = null;
    	String JsonMsg = JSON.serialize(sr);
    	
    	RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/ICA_StatusUpdateServiceRequest/';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        
    	test.startTest();
    	ICA_StatusUpdateService.updateStatus();
    	test.stopTest();
    }
     static testMethod void updateStatusIATest3()
    {
    	ICA_StatusUpdateService.StatusUpdateRequest sr = new ICA_StatusUpdateService.StatusUpdateRequest();
    	sr.ServiceType = '1';
    	sr.Status = null;
    	String JsonMsg = JSON.serialize(sr);
    	
    	RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/ICA_StatusUpdateServiceRequest/';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        
    	test.startTest();
    	ICA_StatusUpdateService.updateStatus();
    	test.stopTest();
    }
}
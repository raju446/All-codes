/**
*   Author      : Azmath
*   Descritpion : Test class for ICA_RestServicesUtil
*/
@isTest
private class ICA_RestServicesUtil_Test {

    static testMethod void invokeInitialApprovalServiceTest() 
    {
        Account acc 					= ICA_TestDataFactory.CreateAccountwithRolesandAddress();
        HexaBPM__Service_Request__c sr 	= ICA_TestDataFactory.CreateInitialApprovalSR(acc.id);
        
        test.startTest();
        test.setMock(HttpCalloutMock.class, new ICA_MockHttpResponseIAService());
        ICA_RestServicesUtil.invokeInitialApprovalService(sr.id);
        test.stopTest();
    }
    static testMethod void invokeInitialApprovalServiceNegTest() 
    {
        Account acc 					= ICA_TestDataFactory.CreateAccountwithRolesandAddress();
        HexaBPM__Service_Request__c sr 	= ICA_TestDataFactory.CreateInitialApprovalSR(acc.id);
        
        test.startTest();
        test.setMock(HttpCalloutMock.class, new ICA_MockHttpResponseIAServiceNeg());
        ICA_RestServicesUtil.invokeInitialApprovalService(sr.id);
        test.stopTest();
    }
    static testMethod void invokeInitialApprovalServiceNegTest2() 
    {
        Account acc 					= ICA_TestDataFactory.CreateAccountwithRolesandAddress();
        HexaBPM__Service_Request__c sr 	= ICA_TestDataFactory.CreateInitialApprovalSR(acc.id);
        
        test.startTest();
        test.setMock(HttpCalloutMock.class, new ICA_MockHttpResponseIAServiceNeg2());
        ICA_RestServicesUtil.invokeInitialApprovalService(sr.id);
        test.stopTest();
    }
    
    static testMethod void invokepaymentserviceTest() 
    {
        Account acc 					= ICA_TestDataFactory.CreateAccountwithRolesandAddress();
        HexaBPM__Service_Request__c sr 	= ICA_TestDataFactory.CreateInitialApprovalSR(acc.id);
        sr.Draft_Number__c = '12345';
        update sr;
        API_Response__c	resp = ICA_TestDataFactory.createapilog(sr.id);
        
        test.startTest();
        test.setMock(HttpCalloutMock.class, new ICA_MockHttpResponsePaymentService());
        ICA_RestServicesUtil.invokepaymentservice(sr.id);
        test.stopTest();
    }
    
    static testMethod void invokeUploadattachmentserviceTest() 
    {
        Account acc 					= ICA_TestDataFactory.CreateAccountwithRolesandAddress();
        HexaBPM__Service_Request__c sr 	= ICA_TestDataFactory.CreateInitialApprovalSR(acc.id);
        sr.Draft_Number__c = '12345';
        update sr;
        Attachment att					= ICA_TestDataFactory.createAttachment(sr.id);
        
        test.startTest();
        test.setMock(HttpCalloutMock.class, new ICA_MockHttpResponseUploaddocService());
        ICA_RestServicesUtil.invokeUploadattachmentservice(sr.id, 'pdf', sr.id, 'test','12345');
        test.stopTest();
    }
}
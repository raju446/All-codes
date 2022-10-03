/**
*   Author      : Azmath
*   Descritpion : Test class for ICA_CreateUpdateEstablishmentUtil
*/
@isTest
private class ICA_CreateUpdateEstablishmentUtil_Test 
{
	//1. CreateupateEstablishment Request info - success case
    static testMethod void invokeEstbserviceTest()
    {
        Account acc 					= ICA_TestDataFactory.CreateAccountwithRolesandAddress();
        Attachment att					= ICA_TestDataFactory.createAttachment(acc.id);
        HexaBPM__Service_Request__c sr 	= ICA_TestDataFactory.CreateNewEstbSR(acc.id);
        Initial_Approval_List__c ia 	= ICA_TestDataFactory.createIACopy(acc.id);
        sr.TransactionRef__c			= '1234';
        sr.Draft_Number__c				= '1111';
        update sr;
        
        test.startTest();
        test.setMock(HttpCalloutMock.class, new ICA_MockHttpRespCreateUpdateEstbService());
        ICA_CreateUpdateEstablishmentUtil.invokeEstbservice(sr.id);
        
        test.stopTest();
    }
    //2. CreateupateEstablishment Request info - error case
    static testMethod void invokeEstbserviceNegTest1()
    {
        Account acc 					= ICA_TestDataFactory.CreateAccountwithRolesandAddress();
        Attachment att					= ICA_TestDataFactory.createAttachment(acc.id);
        HexaBPM__Service_Request__c sr 	= ICA_TestDataFactory.CreateNewEstbSR(acc.id);
        Initial_Approval_List__c ia 	= ICA_TestDataFactory.createIACopy(acc.id);
        sr.TransactionRef__c			= '1234';
        sr.Draft_Number__c				= '1111';
        update sr;
        
        test.startTest();
        test.setMock(HttpCalloutMock.class, new ICA_MockHttpRespCreateUpdEstbServiceNeg1());
        ICA_CreateUpdateEstablishmentUtil.invokeEstbservice(sr.id);
        test.stopTest();
    }
    //3. CreateupateEstablishment Request info - exception case
    static testMethod void invokeEstbserviceNegTest2()
    {
        Account acc 					= ICA_TestDataFactory.CreateAccountwithRolesandAddress();
        Attachment att					= ICA_TestDataFactory.createAttachment(acc.id);
        HexaBPM__Service_Request__c sr 	= ICA_TestDataFactory.CreateNewEstbSR(acc.id);
        Initial_Approval_List__c ia 	= ICA_TestDataFactory.createIACopy(acc.id);
        sr.TransactionRef__c			= '1234';
        sr.Draft_Number__c				= '1111';
        update sr;
        
        test.startTest();
        test.setMock(HttpCalloutMock.class, new ICA_MockHttpRespCreateUpdEstbServiceErr());
        ICA_CreateUpdateEstablishmentUtil.invokeEstbservice(sr.id);
        test.stopTest();
    }
    //1. Create incomplete Request info - success case
    static testMethod void invokeCreateIncompleteserviceTest()
    {
        Account acc 					= ICA_TestDataFactory.CreateAccountwithRolesandAddress();
        Attachment att					= ICA_TestDataFactory.createAttachment(acc.id);
        HexaBPM__Service_Request__c sr 	= ICA_TestDataFactory.CreateNewEstbSR(acc.id);
        Initial_Approval_List__c ia 	= ICA_TestDataFactory.createIACopy(acc.id);
        sr.TransactionRef__c			= '1234';
        sr.Draft_Number__c				= '1111';
        update sr;
        
        test.startTest();
        test.setMock(HttpCalloutMock.class, new ICA_MockHttpRespCreateIncompleteService());
        ICA_CreateUpdateEstablishmentUtil.invokeCreateIncompleteservice(sr.id);
        
        test.stopTest();
    }
    //2. Create incomplete Request info - error case
    static testMethod void invokeCreateIncompleteserviceNegTest()
    {
        Account acc 					= ICA_TestDataFactory.CreateAccountwithRolesandAddress();
        Attachment att					= ICA_TestDataFactory.createAttachment(acc.id);
        HexaBPM__Service_Request__c sr 	= ICA_TestDataFactory.CreateNewEstbSR(acc.id);
        Initial_Approval_List__c ia 	= ICA_TestDataFactory.createIACopy(acc.id);
        sr.TransactionRef__c			= '1234';
        sr.Draft_Number__c				= '1111';
        update sr;
        
        test.startTest();
        test.setMock(HttpCalloutMock.class, new ICA_MockHttpRespCreateIncompServiceNeg());
        ICA_CreateUpdateEstablishmentUtil.invokeCreateIncompleteservice(sr.id);
        
        test.stopTest();
    }
     //3. Create incomplete Request info - exception case
    static testMethod void invokeCreateIncompleteserviceNegTest2()
    {
        Account acc 					= ICA_TestDataFactory.CreateAccountwithRolesandAddress();
        Attachment att					= ICA_TestDataFactory.createAttachment(acc.id);
        HexaBPM__Service_Request__c sr 	= ICA_TestDataFactory.CreateNewEstbSR(acc.id);
        Initial_Approval_List__c ia 	= ICA_TestDataFactory.createIACopy(acc.id);
        sr.TransactionRef__c			= '1234';
        sr.Draft_Number__c				= '1111';
        update sr;
        
        test.startTest();
        test.setMock(HttpCalloutMock.class, new ICA_MockHttpRespCreateIncompServiceErr());
        ICA_CreateUpdateEstablishmentUtil.invokeCreateIncompleteservice(sr.id);
        
        test.stopTest();
    }
     //1. Create submit incmplete Request info - success case
    static testMethod void invokesubmitIncompleteserviceTest()
    {
        Account acc 					= ICA_TestDataFactory.CreateAccountwithRolesandAddress();
        Attachment att					= ICA_TestDataFactory.createAttachment(acc.id);
        HexaBPM__Service_Request__c sr 	= ICA_TestDataFactory.CreateNewEstbSR(acc.id);
        Initial_Approval_List__c ia 	= ICA_TestDataFactory.createIACopy(acc.id);
        sr.TransactionRef__c			= '1234';
        sr.Draft_Number__c				= '1111';
        update sr;
        
        test.startTest();
        test.setMock(HttpCalloutMock.class, new ICA_MockHttpRespSubmitIncompleteService());
        ICA_CreateUpdateEstablishmentUtil.invokesubmitIncompleteservice(sr.id);
        
        test.stopTest();
    }
    //2. Create submit incmplete Request info - error case
    static testMethod void invokesubmitIncompleteserviceNegTest1()
    {
        Account acc 					= ICA_TestDataFactory.CreateAccountwithRolesandAddress();
        Attachment att					= ICA_TestDataFactory.createAttachment(acc.id);
        HexaBPM__Service_Request__c sr 	= ICA_TestDataFactory.CreateNewEstbSR(acc.id);
        Initial_Approval_List__c ia 	= ICA_TestDataFactory.createIACopy(acc.id);
        sr.TransactionRef__c			= '1234';
        sr.Draft_Number__c				= '1111';
        update sr;
        
        test.startTest();
        test.setMock(HttpCalloutMock.class, new ICA_MockHttpRespSubmitIncompNegService());
        ICA_CreateUpdateEstablishmentUtil.invokesubmitIncompleteservice(sr.id);
        
        test.stopTest();
    }
    //3. Create submit incmplete Request info - exception case
    static testMethod void invokesubmitIncompleteserviceNegTest2()
    {
        Account acc 					= ICA_TestDataFactory.CreateAccountwithRolesandAddress();
        Attachment att					= ICA_TestDataFactory.createAttachment(acc.id);
        HexaBPM__Service_Request__c sr 	= ICA_TestDataFactory.CreateNewEstbSR(acc.id);
        Initial_Approval_List__c ia 	= ICA_TestDataFactory.createIACopy(acc.id);
        sr.TransactionRef__c			= '1234';
        sr.Draft_Number__c				= '1111';
        update sr;
        
        test.startTest();
        test.setMock(HttpCalloutMock.class, new ICA_MockHttpRespSubmitIncompErrService());
        ICA_CreateUpdateEstablishmentUtil.invokesubmitIncompleteservice(sr.id);
        
        test.stopTest();
    }
    
}
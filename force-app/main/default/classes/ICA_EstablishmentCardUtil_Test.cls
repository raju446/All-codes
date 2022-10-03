/**
*   Author      : Azmath
*   Descritpion : Test class for ICA_EstablishmentCardUtil
*/
@isTest
private class ICA_EstablishmentCardUtil_Test 
{
    //1. invokeRealtimeStatusUpdateapi Request info - success case
    static testMethod void invokeRealtimeStatusUpdateapiTest()
    {
        Account acc 					= ICA_TestDataFactory.CreateAccountwithRolesandAddress();
        HexaBPM__Service_Request__c sr 	= ICA_TestDataFactory.CreateNewEstbSR(acc.id);
        sr.TransactionRef__c			= '1234';
        update sr;
        
        test.startTest();
        test.setMock(HttpCalloutMock.class, new ICA_MockHttpRespEstbServiceUtil());
        ICA_EstablishmentCardUtil.invokeRealtimeStatusUpdateapi(sr.id);
        
        test.stopTest();
    }
    //1. invokePrintIACopyapi Request info - success case 
    static testMethod void invokePrintIACopyapitest()
    {
        Account acc 					= ICA_TestDataFactory.CreateAccountwithRolesandAddress();
        Attachment att					= ICA_TestDataFactory.createAttachment(acc.id);
        HexaBPM__Service_Request__c sr 	= ICA_TestDataFactory.CreateInitialApprovalSR(acc.id);
        Initial_Approval_List__c ia 	= ICA_TestDataFactory.createIACopy(acc.id);
        sr.TransactionRef__c			= '1234';
        sr.Draft_Number__c				= '1111';
        update sr;
        HexaBPM__SR_Doc__c newSRDocs = ICA_TestDataFactory.createSRDoc(sr.id);
        
        Test.startTest();
        test.setMock(HttpCalloutMock.class, new ICA_MockHttpRespIAcopy());
        ICA_EstablishmentCardUtil.invokePrintIACopyapi(sr.id);
        test.stopTest();
    }
    //2. invokePrintIACopyapi Request info - success case
    static testMethod void invokePrintIACopyapitesterr()
    {
        Account acc 					= ICA_TestDataFactory.CreateAccountwithRolesandAddress();
        Attachment att					= ICA_TestDataFactory.createAttachment(acc.id);
        HexaBPM__Service_Request__c sr 	= ICA_TestDataFactory.CreateInitialApprovalSR(acc.id);
        Initial_Approval_List__c ia 	= ICA_TestDataFactory.createIACopy(acc.id);
        sr.TransactionRef__c			= '1234';
        sr.Draft_Number__c				= '1111';
        update sr;
        HexaBPM__SR_Doc__c newSRDocs = ICA_TestDataFactory.createSRDoc(sr.id);
        
        Test.startTest();
        test.setMock(HttpCalloutMock.class, new ICA_MockHttpRespIAcopyErr());
        ICA_EstablishmentCardUtil.invokePrintIACopyapi(sr.id);
        test.stopTest();
    }
    //3. invokePrintIACopyapi Request info - success case
    static testMethod void invokePrintIACopyapitestexcep()
    {
        Account acc 					= ICA_TestDataFactory.CreateAccountwithRolesandAddress();
        Attachment att					= ICA_TestDataFactory.createAttachment(acc.id);
        HexaBPM__Service_Request__c sr 	= ICA_TestDataFactory.CreateInitialApprovalSR(acc.id);
        Initial_Approval_List__c ia 	= ICA_TestDataFactory.createIACopy(acc.id);
        sr.TransactionRef__c			= '1234';
        sr.Draft_Number__c				= '1111';
        update sr;
        HexaBPM__SR_Doc__c newSRDocs = ICA_TestDataFactory.createSRDoc(sr.id);
        
        Test.startTest();
        test.setMock(HttpCalloutMock.class, new ICA_MockHttpRespIAcopyExcep());
        ICA_EstablishmentCardUtil.invokePrintIACopyapi(sr.id);
        test.stopTest();
    }
    //1. invokePrintEstbCardCopyapi Request info - success case
    static testMethod void invokePrintEstbCardCopyapiTest()
    {
    	
        Account acc 					= ICA_TestDataFactory.CreateAccountwithRolesandAddress();
        Attachment att					= ICA_TestDataFactory.createAttachment(acc.id);
        HexaBPM__Service_Request__c sr 	= ICA_TestDataFactory.CreateInitialApprovalSR(acc.id);
        Initial_Approval_List__c ia 	= ICA_TestDataFactory.createIACopy(acc.id);
        sr.TransactionRef__c			= '1234';
        sr.Draft_Number__c				= '1111';
        update sr;
        HexaBPM__SR_Doc__c newSRDocs = ICA_TestDataFactory.createSRDoc(sr.id);
        newSRDocs.Name='Establishment Card - Internal';
        update newSRDocs;
        
        Test.startTest();
        test.setMock(HttpCalloutMock.class, new ICA_MockHttpRespPrintCardcopy());
        ICA_EstablishmentCardUtil.invokePrintEstbCardCopyapi(sr.id);
        test.stopTest();
    }
    //2. invokePrintEstbCardCopyapi Request info - Error case
    static testMethod void invokePrintEstbCardCopyapiErrTest()
    {
        Account acc 					= ICA_TestDataFactory.CreateAccountwithRolesandAddress();
        Attachment att					= ICA_TestDataFactory.createAttachment(acc.id);
        HexaBPM__Service_Request__c sr 	= ICA_TestDataFactory.CreateInitialApprovalSR(acc.id);
        Initial_Approval_List__c ia 	= ICA_TestDataFactory.createIACopy(acc.id);
        sr.TransactionRef__c			= '1234';
        sr.Draft_Number__c				= '1111';
        update sr;
        HexaBPM__SR_Doc__c newSRDocs = ICA_TestDataFactory.createSRDoc(sr.id);
        newSRDocs.Name='Establishment Card - Internal';
        update newSRDocs;
        
       Test.startTest();
        test.setMock(HttpCalloutMock.class, new ICA_MockHttpRespPrintCardcopyError());
        ICA_EstablishmentCardUtil.invokePrintEstbCardCopyapi(sr.id);
        test.stopTest();
    }
    //3. invokePrintEstbCardCopyapi Request info - exception case
    static testMethod void invokePrintEstbCardCopyapiExcepTest()
    {
        Account acc 					= ICA_TestDataFactory.CreateAccountwithRolesandAddress();
        Attachment att					= ICA_TestDataFactory.createAttachment(acc.id);
        HexaBPM__Service_Request__c sr 	= ICA_TestDataFactory.CreateInitialApprovalSR(acc.id);
        Initial_Approval_List__c ia 	= ICA_TestDataFactory.createIACopy(acc.id);
        sr.TransactionRef__c			= '1234';
        sr.Draft_Number__c				= '1111';
        update sr;
        HexaBPM__SR_Doc__c newSRDocs = ICA_TestDataFactory.createSRDoc(sr.id);
        newSRDocs.Name='Establishment Card - Internal';
        update newSRDocs;
        
       Test.startTest();
        test.setMock(HttpCalloutMock.class, new ICA_MockHttpRespPrintCardcopyExcep());
        ICA_EstablishmentCardUtil.invokePrintEstbCardCopyapi(sr.id);
        test.stopTest();
    }
}
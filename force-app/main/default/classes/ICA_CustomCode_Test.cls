/**
*   Author      : Azmath
*   Descritpion : Test class for custom codes.
*/
@isTest
public with sharing class ICA_CustomCode_Test
{
	@testSetup
	public static void init()
	{
		Account acc 							= ICA_TestDataFactory.CreateAccountwithRolesandAddress();
        HexaBPM__Service_Request__c srrec 		= ICA_TestDataFactory.CreateNewEstbSR(acc.id);
        HexaBPM__SR_Template__c template 		= ICA_TestDataFactory.createTemplate('Initial_Approval');
        HexaBPM__Step_Template__c steptemplate 	= ICA_TestDataFactory.createstepTemplate(template.id, 'GET_NEW_DRAFT_NUMBER', 'Get New Draft Number');
        HexaBPM__SR_Steps__c SRstep 			= ICA_TestDataFactory.createSRstep('Get New Draft Number',template.id,steptemplate.id);
        HexaBPM__Step__c createStep				= ICA_TestDataFactory.createStep(srrec.id,'Get New Draft Number',SRstep.id);
        Initial_Approval_List__c ia				= ICA_TestDataFactory.createIACopy(acc.id);
	}
    static testMethod void updateStatusEstbTest()
    {
    	Account acc = [Select id from Account limit 1];
    	HexaBPM__Service_Request__c srrec = [Select id,Recordtype.DeveloperName from HexaBPM__Service_Request__c limit 1];
    	HexaBPM__Step__c createStep	= [Select id,HexaBPM__SR__c from HexaBPM__Step__c limit 1];
    	
       	CC_ICA_SubmitIncomplete cc = new CC_ICA_SubmitIncomplete();
       	cc.EvaluateCustomCode(srrec,createStep);
       	
       	CC_ICA_VerifyNewDraftNumber cv = new CC_ICA_VerifyNewDraftNumber();
       	cv.EvaluateCustomCode(srrec,createStep);
       	
       	CC_PushPaymentReqtoICA cp = new CC_PushPaymentReqtoICA();
       	cp.EvaluateCustomCode(srrec,createStep);
       	
       	CC_PushtoICA pi = new CC_PushtoICA();
       	pi.EvaluateCustomCode(srrec,createStep);
       	
       	CC_ValidateDocumentsICA cvv = new CC_ValidateDocumentsICA();
       	cvv.EvaluateCustomCode(srrec,createStep);
       	
       	srrec.Draft_Number__c='1234';
       	update srrec;
       	cvv.EvaluateCustomCode(srrec,createStep);
       	
       	CC_ValidateICAServices vd = new CC_ValidateICAServices();
       	vd.EvaluateCustomCode(srrec,createStep);
       	
       	ICA_CC_DownloadIACopy vdd = new ICA_CC_DownloadIACopy();
       	vdd.EvaluateCustomCode(srrec,createStep);
       	
       	HexaBPM__Service_Request__c srrec1 	= ICA_TestDataFactory.CreateNewEstbSR(acc.id);
       	srrec.HexaBPM__Linked_SR__c = srrec1.id;
       	update srrec;
       	
       	ICA_ValidateEstbCardAmendmentSR vec = new ICA_ValidateEstbCardAmendmentSR();
       	vec.EvaluateCustomCode(srrec,createStep);
    }
    static testMethod void ICA_UpdateIANumberTest()
    {
    	Account acc = [Select id from Account limit 1];
    	HexaBPM__Service_Request__c srrec = [Select id,Recordtype.DeveloperName from HexaBPM__Service_Request__c limit 1];
    	HexaBPM__Step__c createStep	= [Select id,HexaBPM__SR__c from HexaBPM__Step__c limit 1];
    	Initial_Approval_List__c ia = [Select id,Initial_Approval_Number__c,Assigned_To__c from Initial_Approval_List__c LIMIT 1];
    	HexaBPM__Service_Request__c srrec1 	= ICA_TestDataFactory.CreateNewEstbSR(acc.id);
    	
       	srrec.Draft_Number__c='1234';
       	srrec.TransactionRef__c='1234';
       	srrec.ADP_Status__c='Approved';
       	srrec.HexaBPM__Parent_SR__c = srrec1.id;
       	update srrec;
       	
       	HexaBPM__Service_Request__c srrec2 	= ICA_TestDataFactory.CreateNewEstbSR(acc.id);
       	srrec2.HexaBPM__Linked_SR__c = srrec.id;
       	update srrec2;
       	
       	test.startTest();
	    	ICA_UpdateIANumber ian = new ICA_UpdateIANumber();
	       	ian.EvaluateCustomCode(srrec,createStep);
       	test.stopTest();
    }
    static testMethod void ICA_ValidateServicetest()
    {
    	Account acc = [Select id from Account limit 1];
    	acc.Initial_Approval_Issue_Date__c = Date.today();
    	update acc;
    	HexaBPM__Service_Request__c srrec = [Select id,Recordtype.DeveloperName from HexaBPM__Service_Request__c limit 1];
    	srrec.Initial_Approval_Number__c = null;
    	srrec.HexaBPM__Submitted_Date__c=Date.today();
    	update srrec;
    	ICA_ValidateService.validateRoles(acc.id,srrec.id);
    	
    	//HexaBPM__Service_Request__c srrec 	= ICA_TestDataFactory.CreateInitialApprovalSR(acc.id);
    }
    static testMethod void ICA_PaymentJsonTest()
    {
    	ICA_PaymentJson pay = new ICA_PaymentJson(100);
    	ICA_PaymentJson.Drafts dr = new ICA_PaymentJson.Drafts('123');
    }
}
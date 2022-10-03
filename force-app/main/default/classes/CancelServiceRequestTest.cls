@isTest
public with sharing class CancelServiceRequestTest {
    
    public static List<HexaBPM__Service_Request__c> createdSRList; 
    public static List<Account> createdAccountList;
    
    private static void init(){
        createdAccountList = TestClassUtility.createAccounts(1);
        createdAccountList[0].Oracle_Party_Id__c = 'test';
        insert createdAccountList;
        
        HexaBPM__SR_Template__c srtemp = new HexaBPM__SR_Template__c();
        srtemp.Name = 'Initial Approval';
        srtemp.HexaBPM__SR_RecordType_API_Name__c = 'Initial_Approval';
        insert srtemp;
        
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        //createdSRList[0].HexaBPM__SR_Template__c = srtemp.Id;
        createdSRList[0].HexaBPM__Customer__c = createdAccountList[0].Id;
        insert createdSRList;
        
        HexaBPM__Status__c stepStatus = new HexaBPM__Status__c();
        stepStatus.HexaBPM__Code__c ='Cancellation_Request_by_Customer';
        insert stepStatus;
        
        HexaBPM__Step_Template__c steptemplate = new HexaBPM__Step_Template__c();
        steptemplate.HexaBPM__Code__c = 'Cancellation_Request_by_Customer';
        steptemplate.HexaBPM__Step_RecordType_API_Name__c = 'Courier_Step';
        insert steptemplate;
        
        HexaBPM__SR_Steps__c srStep = new HexaBPM__SR_Steps__c();
        srStep.HexaBPM__Summary__c = 'Test';
        srStep.HexaBPM__Step_No__c = 22;
        srStep.HexaBPM__Start_Status__c = stepStatus.Id; 
        srStep.HexaBPM__Step_Template__c = steptemplate.Id;
        srStep.HexaBPM__SR_Template__c = srtemp.Id;
        insert srStep;
        
    }   

    
    public static testmethod void TestCancelServiceRequest(){
        
        init();
        
        Test.startTest();
            String st = createdSRList[0].Id;
            CancelServiceRequest.createCancelStep(st);
            CancelServiceRequest.deleteDraftSR(st);
        Test.stopTest();
    }
    
    public static testmethod void TestCancelServiceRequest2(){
        
        init();
        
        HexaBPM__Status__c stepStatus = new HexaBPM__Status__c();
        stepStatus.HexaBPM__Code__c = 'AWAITING_APPROVAL';
        insert stepStatus;
        
        HexaBPM__Step__c step = new HexaBPM__Step__c();
        step.HexaBPM__SR__c = createdSRList[0].Id;
        step.HexaBPM__Summary__c = 'Cancellation Request by Client';
        step.HexaBPM__Status__c = stepStatus.Id;
        insert step;
        
        Test.startTest();
            String st = createdSRList[0].Id;
            CancelServiceRequest.checkExistingCancelRequest(st);
        Test.stopTest();
    }
}
@isTest
public with sharing class CC_Cancel_OpenStepsTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;
    
    private static void init(){
    	
    	createdSRList = TestUtility.createSR(1,'Initial_Approval');
        insert createdSRList;
        
        HexaBPM__Status__c status = new HexaBPM__Status__c();
        status.HexaBPM__Type__c = 'End';
        status.HexaBPM__Code__c = 'CANCELLED_BY_CUSTOMER';
        insert status;
        
        HexaBPM__Status__c status1 = new HexaBPM__Status__c();
        status1.HexaBPM__Type__c = 'Start';
        status1.HexaBPM__Code__c = 'DRAFT';
        insert status1;
        
        createdstepList = TestUtility.createSteps(2,createdSRList[0].Id,null);
        createdstepList[0].HexaBPM__Status__c = status1.Id;
        createdstepList[1].HexaBPM__Status__c = status.Id;
        insert createdstepList;
    }
    public static testmethod void TestCC_Cancel_OpenSteps(){
        init();
        CC_Cancel_OpenSteps con = new CC_Cancel_OpenSteps();
        //List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Customer__c,HexaBPM__SR__r.HexaBPM__Contact__c,HexaBPM__SR__r.HexaBPM__Record_Type_Name__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        con.EvaluateCustomCode(null,createdstepList[1]);
    }
    private static void init2(){
    	
    	createdSRList = TestUtility.createSR(1,'Initial_Approval');
        insert createdSRList;
        
        HexaBPM__Status__c status = new HexaBPM__Status__c();
        status.HexaBPM__Type__c = 'Start';
        status.HexaBPM__Code__c = 'CANCELLED_BY_CUSTOMER';
        insert status;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        createdstepList[0].HexaBPM__Status__c = status.Id;
        insert createdstepList;
    }
    public static testmethod void TestCC_Cancel_OpenSteps2(){
        init2();
        CC_Cancel_OpenSteps con = new CC_Cancel_OpenSteps();
        //List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Customer__c,HexaBPM__SR__r.HexaBPM__Contact__c,HexaBPM__SR__r.HexaBPM__Record_Type_Name__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        con.EvaluateCustomCode(null,createdstepList[0]);
    }
}
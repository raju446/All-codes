@isTest
public with sharing class CC_ValidateDuplicateSRTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList; 
    
    private static void init(){
    	
    	createdSRList = TestUtility.createSR(1,'Initial_Approval');
    	insert createdSRList;
    	
    	createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList; 
    	
    }
    public static testmethod void TestCC_ValidateDuplicateSR(){
       init();
       CC_ValidateDuplicateSR con = new CC_ValidateDuplicateSR();
       List<HexaBPM__Step__c> lstOfSteps = [SELECT Id,HexaBPM__SR__c, HexaBPM__SR__r.HexaBPM__Record_Type_Name__c,HexaBPM__SR__r.HexaBPM__Customer__c,HexaBPM__SR__r.HexaBPM__Customer__r.Entity_Status__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
       con.EvaluateCustomCode(null,lstOfSteps[0]);
    }
}
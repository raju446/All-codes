@isTest
public with sharing class CC_ValidateDuplicateVisaSRTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList; 
    
    private static void init(){
    	
    	createdSRList = TestUtility.createSR(1,'Initial_Approval');
    	createdSRList[0].Passport_Number__c = '12mj3k';
    	insert createdSRList;
    	
    	createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList; 
    	
    }
    public static testmethod void TestCC_ValidateDuplicateVisaSR(){
       init();
       CC_ValidateDuplicateVisaSR con = new CC_ValidateDuplicateVisaSR();
       List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Record_Type_Name__c,HexaBPM__SR__r.Passport_Number__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
       con.EvaluateCustomCode(null,lstOfSteps[0]);
    }
    
}
@isTest
public with sharing class CC_FAWRI_CancellationValidationsTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    
    public static testmethod void TestCC_FAWRI_CancellationValidations(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts; 
        
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        insert createdSRList;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList; 
        
        CC_FAWRI_CancellationValidations con = new CC_FAWRI_CancellationValidations();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Customer__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        con.EvaluateCustomCode(null,lstOfSteps[0]);
    }
}
@isTest
public with sharing class CC_RemoveEstablishmentCardEntityClsTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    private static List<Account> createdAccountList; 
    
    private static void init(){
    	
    	createdAccountList = TestClassUtility.createAccounts(1);
        insert createdAccountList;
    	
    	createdSRList = TestUtility.createSR(1,'Initial_Approval');
    	createdSRList[0].HexaBPM__Customer__c = createdAccountList[0].Id;
        insert createdSRList;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList; 
    	
    }
    public static testmethod void TestCC_RemoveEstablishmentCardEntityCls(){
       init();
       CC_RemoveEstablishmentCardEntityCls con = new CC_RemoveEstablishmentCardEntityCls();
       List<HexaBPM__Step__c> lstOfSteps = [SELECT Id,HexaBPM__SR__r.HexaBPM__Customer__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
       con.EvaluateCustomCode(null,lstOfSteps[0]);
    }
        
		   
}
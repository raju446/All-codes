@isTest
public with sharing class CC_EChannelApprovalTest {
   
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    
    private static void init(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts; 
                          
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        createdSRList[0].EChannel_Account_Number__c = 'Test';
        createdSRList[0].EChannel_Transaction_Number__c = 'Tester';
        createdSRList[0].EChannel_Issue_Date__c= system.today();
        insert createdSRList;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList;     
       
    }
    public static testmethod void TestCC_EChannelApproval(){
        init();
        Test.startTest();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Customer__c,HexaBPM__SR__r.EChannel_Issue_Date__c, HexaBPM__SR__r.EChannel_Account_Number__c, HexaBPM__SR__r.EChannel_Transaction_Number__c
                                                                                                                         FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        CC_EChannelApproval con = new CC_EChannelApproval();
        con.EvaluateCustomCode(null,lstOfSteps[0]);
        Test.stopTest();
    }
}
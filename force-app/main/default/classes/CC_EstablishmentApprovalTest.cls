@isTest
public with sharing class CC_EstablishmentApprovalTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    
    private static void init(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts; 
                                  
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        createdSRList[0].Establishment_Card_Issue_Date__c = system.today();
        createdSRList[0].Establishment_Arabic_Name__c= 'test';
        createdSRList[0].Establishment_English_Name__c = 'tester';
        insert createdSRList;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList;     

    }
    public static testmethod void TestCC_EstablishmentApproval(){
        init();
        Test.startTest();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id,HexaBPM__SR__r.Establishment_Card_Expiry_Date__c,HexaBPM__SR__r.Establishment_English_Name__c ,HexaBPM__SR__r.Establishment_Arabic_Name__c, HexaBPM__SR__r.HexaBPM__Customer__c,HexaBPM__SR__r.Establishment_Card_Issue_Date__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        CC_EstablishmentApproval con = new CC_EstablishmentApproval();
        con.EvaluateCustomCode(null,lstOfSteps[0]);
        Test.stopTest();
    }
    
}
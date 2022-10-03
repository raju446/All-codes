@isTest
public with sharing class CC_VisaAmendmentsEntityTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    
    public static testmethod void TestCC_VisaAmendmentsEntity(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        insert newContacts;
        
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].Passport_Number__c = '322dd2';
        createdSRList[0].Passport_Expiry_Date__c = system.today();
        createdSRList[0].Passport_Issue_Date__c = system.today().addDays(-1);
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        insert createdSRList;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList; 
        
        CC_VisaAmendmentsEntity con = new CC_VisaAmendmentsEntity();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Contact__c, HexaBPM__SR__r.Passport_Number__c,HexaBPM__SR__r.Passport_Expiry_Date__c,HexaBPM__SR__r.Passport_Issue_Date__c 
        FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        con.EvaluateCustomCode(null,lstOfSteps[0]);
    }
}
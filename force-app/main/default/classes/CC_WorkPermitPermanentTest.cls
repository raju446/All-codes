@isTest
public with sharing class CC_WorkPermitPermanentTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    
   /* private static void init(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Nationality__c = 'AFGHANISTAN';
        newContacts[0].Passport_Number__c = '27272627';
        
        insert newContacts;  
        system.debug('@@@@@ con  ' +newContacts);     
        createdSRList = TestUtility.createSR(1,'CID_Approval');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        createdSRList[0].Passport_Number__c = '27272627'; 
        createdSRList[0].Nationality__c = 'AFGHANISTAN'; 
        insert createdSRList;
        
        system.debug(' ==> createdSRList '+createdSRList);
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList;     
       
    }*/ 
    
    public static testmethod void TestCC_WorkPermitPermanent(){
        //init();
        Test.startTest();
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Nationality__c = 'AFGHANISTAN';
        newContacts[0].Passport_No__c = 'JHP6483ER';
        newContacts[0].Emirates_ID_Number__c='12345';
        
        insert newContacts;  
        system.debug('@@@@@ con  ' +newContacts);     
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        createdSRList[0].Passport_Number__c = 'JHP6483ER'; 
        createdSRList[0].Nationality__c = 'AFGHANISTAN'; 
        createdSRList[0].Emirates_ID_Number__c= '12345'; 
        insert createdSRList;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList;     
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.Emirates_ID_Number__c, HexaBPM__SR__r.HexaBPM__Customer__c, HexaBPM__SR__r.Passport_Number__c, HexaBPM__SR__r.Nationality__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        system.debug('@@@@@  ' +lstOfSteps[0].HexaBPM__SR__r.HexaBPM__Customer__c);
        system.debug('####   '+lstOfSteps[0].HexaBPM__SR__r.Passport_Number__c);
        system.debug('####   '+lstOfSteps[0].HexaBPM__SR__r.Nationality__c);
        CC_WorkPermitPermanent con = new CC_WorkPermitPermanent();
        con.EvaluateCustomCode(null,lstOfSteps[0]);
        Test.stopTest();
    }
    
}
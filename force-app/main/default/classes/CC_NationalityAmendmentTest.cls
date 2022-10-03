@isTest
public with sharing class CC_NationalityAmendmentTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    private static HexaBPM__SR_Steps__c createSRstep;
    
    private static void init(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
		insert newAccounts; 
		
        List<Contact> newContacts = TestClassUtility.createContacts(2, newAccounts[0].Id);
		insert newContacts;  
		newContacts[1].Sponsor__c = newContacts[0].id;     
        update newContacts[1];          
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        createdSRList[0].Dependent__c = newContacts[1].Id;
        createdSRList[0].Nationality__c = 'AFGHANISTAN';
        insert createdSRList;
        
        createSRstep = new  HexaBPM__SR_Steps__c();
        insert createSRstep;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,createSRstep.Id);
        insert createdstepList;     
    }
    public static testmethod void TestCC_NationalityAmendment(){
        init();
        Test.startTest();   
        CC_NationalityAmendment con = new CC_NationalityAmendment();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Contact__c, HexaBPM__SR__r.Dependent__c, 
        																	HexaBPM__SR__r.Nationality__c	 FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        con.EvaluateCustomCode(null,lstOfSteps[0]);
        Test.stopTest();
    }
    
    private static void init2(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
		insert newAccounts; 
		
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
		insert newContacts;  
		          
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        //createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        createdSRList[0].Dependent__c = null;
        createdSRList[0].First_Name__c = 'first';
        createdSRList[0].Middle_Name__c = 'middle';
        createdSRList[0].First_Name_Arabic__c = 'firstarab';
        createdSRList[0].Middle_Name_Arabic__c = 'middlearab';
        createdSRList[0].Last_Name_Arabic__c = 'lastarab';
        insert createdSRList;
        
        createSRstep = new  HexaBPM__SR_Steps__c();
        insert createSRstep;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,createSRstep.Id);
        insert createdstepList;     
    }
     public static testmethod void TestCC_NationalityAmendment2(){
        init2();
        Test.startTest();   
        CC_NationalityAmendment con = new CC_NationalityAmendment();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Contact__c, HexaBPM__SR__r.Dependent__c, 
        																	HexaBPM__SR__r.Nationality__c	 FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        con.EvaluateCustomCode(null,lstOfSteps[0]);
        Test.stopTest();
    }
    
}
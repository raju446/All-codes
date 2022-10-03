@isTest
public with sharing class CC_UpdateEmployeeStatusOnAbscondingTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    
    private static void init(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '0000001';
		insert newAccounts; 
		
		List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
		insert newContacts;  
		                  
        createdSRList = TestUtility.createSR(1,'Report_Absconding_Employee');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        insert createdSRList;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList;     

         Document_Details__c docs = new Document_Details__c();  
	     docs.Document_Status__c='Active';
	     docs.Document_Type__c= 'Employee Work Permit(UAE/GCC National)';
	     docs.Account__c = newAccounts[0].Id;
	     docs.Contact__c = newContacts[0].Id;
	     docs.Service_Request__c = createdSRList[0].Id;
	     insert docs; 
    }
    public static testmethod void TestCC_UpdateEmployeeStatusOnAbsconding(){
       	init();
        Test.startTest();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Record_Type_Name__c,HexaBPM__SR__r.HexaBPM__Contact__c, HexaBPM__SR__r.HexaBPM__Customer__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        CC_UpdateEmployeeStatusOnAbsconding con = new CC_UpdateEmployeeStatusOnAbsconding();
        
        con.EvaluateCustomCode(null,lstOfSteps[0]);
        Test.stopTest();
    }
    
    private static void init2(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '0000002';
		insert newAccounts; 
		
		List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
		newContacts[0].Employment_Status__c  = 'Absconded';
		insert newContacts;  
		                  
        createdSRList = TestUtility.createSR(1,'Withdraw_Absconding_Status_Employee');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        insert createdSRList;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList;     

         Document_Details__c docs = new Document_Details__c();  
	     docs.Document_Status__c='Active';
	     docs.Document_Type__c= 'Employee Work Permit(UAE/GCC National)';
	     docs.Account__c = newAccounts[0].Id;
	     docs.Contact__c = newContacts[0].Id;
	     docs.Service_Request__c = createdSRList[0].Id;
	     insert docs; 
    }
    public static testmethod void TestCC_UpdateEmployeeStatusOnAbsconding2(){
       	init2();
        Test.startTest();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Record_Type_Name__c, HexaBPM__SR__r.HexaBPM__Contact__c, HexaBPM__SR__r.HexaBPM__Customer__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        CC_UpdateEmployeeStatusOnAbsconding con = new CC_UpdateEmployeeStatusOnAbsconding();
        
        con.EvaluateCustomCode(null,lstOfSteps[0]);
        Test.stopTest();
    }
}
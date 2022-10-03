@isTest
public with sharing class CC_EstablishmentCardRenewalTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    
    private static void init(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
		insert newAccounts; 
		
		List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
		insert newContacts; 
				                  
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        insert createdSRList;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList;    
        
        Document_Details__c docs = new Document_Details__c();  
	     docs.Document_Status__c='Active';
	     docs.Document_Type__c= 'Establishment Card';
	     docs.Account__c = newAccounts[0].Id;
	     docs.Document_Cancel_Date__c = system.today();
	     docs.Contact__c = newContacts[0].Id;
	     docs.Service_Request__c = createdSRList[0].Id;
	     docs.Document_Expiry_Date__c = system.today();
	     docs.Document_Last_Renewed_Date__c = system.today();
	     insert docs;
    }
    public static testmethod void TestCC_EstablishmentCardRenewal(){
       	init();
        Test.startTest();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Customer__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        CC_EstablishmentCardRenewal con = new CC_EstablishmentCardRenewal();
        con.EvaluateCustomCode(null,lstOfSteps[0]);
        Test.stopTest();
    }  
}
@isTest
public with sharing class NewCaseOverrideControllerTest {
    
    public static testmethod void TestNewCaseOverrideController(){

    	List<Account> newAccounts = TestClassUtility.createAccounts(1);
		insert newAccounts; 
		
		List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
		newContacts[0].Portal_User_Creation__c = true;

        newContacts[0].Community_Username__c = 'test1@adgm.portal';
		insert newContacts;  
		
		User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
		
		system.runAs(portalUser){
		
		NewCaseOverrideController cic = new NewCaseOverrideController(new ApexPages.StandardController(portalUser));   
		cic.RedirectToCasePage();
		
    	}
   } 
   
   public static testmethod void TestNewCaseOverrideController2(){

    	List<Account> newAccounts = TestClassUtility.createAccounts(1);
		insert newAccounts; 
		
		NewCaseOverrideController cic = new NewCaseOverrideController(new ApexPages.StandardController(newAccounts[0]));   
		cic.RedirectToCasePage();
		
    	
   }    
}
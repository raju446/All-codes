@isTest
public with sharing class CompanyInfoCntlrTest {
    
    public static testmethod void TestCompanyInfoCntlr(){
    	//init();

    	List<Account> newAccounts = TestClassUtility.createAccounts(1);
		insert newAccounts; 
		
		List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
		newContacts[0].Portal_User_Creation__c = true;

        newContacts[0].Community_Username__c = 'test1@adgm.portal';
		insert newContacts;  
		
		User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
		
		system.runAs(portalUser){
		CompanyInfoCntlr cic = new CompanyInfoCntlr();   
    	}
		
   } 
    
}
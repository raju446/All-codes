@isTest
public with sharing class CustomCodeUtilClsTest {
    
    public static testmethod void TestCustomCodeUtilCls(){
    
    	List<Account> newAccounts = TestClassUtility.createAccounts(1);
  		insert newAccounts; 
		
		List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
		newContacts[0].Employment_Status__c = 'Active';
		insert newContacts;
		
		string EntityId = newAccounts[0].Id;
    
        Test.startTest();
        
        CustomCodeUtilCls con = new CustomCodeUtilCls();
        CustomCodeUtilCls.HasActiveEmployees(EntityId);
        
        Test.stopTest();
    }
     
}
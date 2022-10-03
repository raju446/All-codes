@isTest
public with sharing class ValidationsUtilityClsTest {
    
    public static testmethod void testcase(){
    	List<Account> newAccounts = TestClassUtility.createAccounts(1);
		insert newAccounts; 
		String id = newAccounts[0].Id;
 		ValidationsUtilityCls.AllVisasCancelled(id);
    }
    
}
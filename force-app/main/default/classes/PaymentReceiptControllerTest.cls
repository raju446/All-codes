@isTest
public with sharing class PaymentReceiptControllerTest {
    
    public static testmethod void TestPaymentReceiptController(){
	    
	    List<Account> newAccounts = TestClassUtility.createAccounts(1);
		insert newAccounts; 
					
		List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
		newContacts[0].Portal_User_Creation__c = true;
		
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
		insert newContacts;  
		
		User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
		
		
		system.runAs(portalUser){
	
		    PaymentReceiptController prc = new PaymentReceiptController();
		    prc.formDataMap.put('req_amount','123');
		    prc.formDataMap.put('message','test');
		    prc.formDataMap.put('req_currency','AED');
		    prc.formDataMap.put('req_payment_method','Cash');
			prc.checkParameters();
		} 
 
	}
    
}
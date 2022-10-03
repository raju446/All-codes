@isTest
public with sharing class SRStepsControllerTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList;
    private static List<HexaBPM__Step__c> createdstepList;  
    
    public static testmethod void TestSRStepsController(){
	    
	    List<Account> newAccounts = TestClassUtility.createAccounts(1);
	    insert newAccounts; 
		
		createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        insert createdSRList;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList;
			
		List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
		newContacts[0].Portal_User_Creation__c = true;
		
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
		insert newContacts;  
		
		User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
		
		
		system.runAs(portalUser){
			
			system.currentPageReference().getParameters().put('Id', portalUser.Id);
		    
		    SRStepsController src = new SRStepsController();
		
		} 
 
	}
    
}
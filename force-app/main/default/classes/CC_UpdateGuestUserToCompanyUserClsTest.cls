@isTest
public with sharing class CC_UpdateGuestUserToCompanyUserClsTest {
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    private static HexaBPM__SR_Steps__c createSRstep;
    
  	public static testmethod void testcase(){
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
		insert newAccounts; 
		
        
		List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
		newContacts[0].Portal_User_Creation__c = true;

        newContacts[0].Community_Username__c = 'test1@adgm.portal';
		insert newContacts;  
		
		User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
		system.debug('###portal user '+portalUser);
		
		system.runAs(portalUser){
		createdSRList = TestUtility.createSR(1,'Initial_Approval');
        insert createdSRList;
        createSRstep = new  HexaBPM__SR_Steps__c();
        insert createSRstep;
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,createSRstep.Id);
        insert createdstepList; 
		
			
        CC_UpdateGuestUserToCompanyUserCls con = new CC_UpdateGuestUserToCompanyUserCls();
        con.EvaluateCustomCode(createdSRList[0],createdstepList[0]);
		}
    }
    public static testmethod void testcase2(){
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
		insert newAccounts; 
		
        
		List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
		newContacts[0].Portal_User_Creation__c = true;

        newContacts[0].Community_Username__c = 'test1@adgm.portal';
		insert newContacts;  
		
		User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
		system.debug('###portal user '+portalUser);
		
		system.runAs(portalUser){
		createdSRList = TestUtility.createSR(1,'Initial_Approval');
		createdSRList[0].Role__c = 'Lead Admin';
        insert createdSRList;
        createSRstep = new  HexaBPM__SR_Steps__c();
        insert createSRstep;
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,createSRstep.Id);
        insert createdstepList; 
		
			
        CC_UpdateGuestUserToCompanyUserCls con = new CC_UpdateGuestUserToCompanyUserCls();
        con.EvaluateCustomCode(createdSRList[0],createdstepList[0]);
		}
    }
    public static testmethod void testcase3(){
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
		insert newAccounts; 
		
        
		List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
		newContacts[0].Portal_User_Creation__c = true;

        newContacts[0].Community_Username__c = 'test1@adgm.portal';
		insert newContacts;  
		
		User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
		system.debug('###portal user '+portalUser);
		
		system.runAs(portalUser){
		createdSRList = TestUtility.createSR(1,'Initial_Approval');
		createdSRList[0].Role__c = 'Admin';
        insert createdSRList;
        createSRstep = new  HexaBPM__SR_Steps__c();
        insert createSRstep;
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,createSRstep.Id);
        insert createdstepList; 
		
			
        CC_UpdateGuestUserToCompanyUserCls con = new CC_UpdateGuestUserToCompanyUserCls();
        con.EvaluateCustomCode(createdSRList[0],createdstepList[0]);
		}
    }
}
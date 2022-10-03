/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 * 
 * Modified by 			Description
 * Shagufta Murshad		Vip_Status__c is renamed to Key_Account__c
 */
@isTest
private class ContactTriggerHandlerTest {

    	static testMethod void createPortalUserTest() {
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts; 
        
        Test.startTest();
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        insert newContacts; 
        
        List<User> userList = [Select Id, UserName FROM User WHERE ContactId = :newContacts[0].Id];
        System.assert(userList <> null);
        
        System.assertEquals('test1@adgm.portal',userList[0].UserName);
        Test.stopTest();
    }
    
    static testMethod void createPortalUserTest2() {
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts; 
        
        Test.startTest();
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        newContacts[0].Role__c = 'Lead Admin';
        insert newContacts; 
        
        List<User> userList = [Select Id, UserName FROM User WHERE ContactId = :newContacts[0].Id];
        System.assert(userList <> null);
 
        
        System.assertEquals('test1@adgm.portal',userList[0].UserName);
        Test.stopTest();
    }
    
    static testMethod void createPortalUserTest3() {
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts; 
        
        Test.startTest();
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        newContacts[0].Is_Guest_User__c = true;
        insert newContacts; 
        
        List<User> userList = [Select Id, UserName FROM User WHERE ContactId = :newContacts[0].Id];
        System.assert(userList <> null);
 		ContactTriggerHandler.getContactRecTypeId('Contact – ADGM BR&P');
        ContactTriggerHandler.mergeContactPhoneFields(newContacts);
        System.assertEquals('test1@adgm.portal',userList[0].UserName);
        Test.stopTest();
    }
    
    static testMethod void createPortalUserTest4() {
        List<Account> newAccounts = TestClassUtility.createAccounts(2);
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        insert newContacts; 
        
        Test.startTest();
        
        newContacts[0].AccountId = newAccounts[1].Id;
        update newContacts[0];

        Test.stopTest();
    }
    
    static testMethod void coverPopulateAccountForContact(){
        Trigger_Settings__c TS = new Trigger_Settings__c();
        TS.Name = 'ContactTrgr_PopulateAccountForContact';
        TS.is_Active__c = TRUE;
        insert TS;
    	List<Contact> lstContact = new List<Contact>();
        Id contactRecordTypeId = ContactTriggerHandler.getRecTypeId('Contact','Contact - ADGM Court');
        Contact c1 = new Contact(RecordTypeId = contactRecordTypeId,LeadSource='Full Contact Business Card',Key_Account__c = 'Yes',firstname='firstname', lastname='lastname', email='mail1@gmail.com',CRM_Company_Name__c='JAckernewRaj');
		lstContact.add(c1);
		Contact c = new Contact(RecordTypeId = contactRecordTypeId,LeadSource='Full Contact Business Card',Key_Account__c = 'Yes',firstname='firstname', lastname='lastname', email='mail2@gmail.com',CRM_Company_Name__c='JAckernewRaj');
		lstContact.add(c);
		insert  lstContact;
        
    }
    
    static testMethod void coverTranslateContact(){
        Test.setMock(HttpCalloutMock.class, new GoogleTranslateMockHttpRes());
        Trigger_Settings__c TS = new Trigger_Settings__c();
        TS.Name = 'ContactTrgr_TranslateField';
        TS.is_Active__c = TRUE;
        insert TS;
    	List<Contact> lstContact = new List<Contact>();
        Id contactRecordTypeId = ContactTriggerHandler.getRecTypeId('Contact','Contact – ADGM BR&P');
        Contact c1 = new Contact(RecordTypeId = contactRecordTypeId,LeadSource='Full Contact Business Card',Key_Account__c = 'Yes',firstname='firstname', lastname='lastname', email='mail1@gmail.com',CRM_Company_Name__c='JAckernewRaj');
		lstContact.add(c1);
        insert  lstContact;
    }
}
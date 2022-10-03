@isTest
public class ADNIC_FormControllerTest {
 	@testSetup
    public static void init()
    {
    	List<Account> newAccounts 	= TestClassUtility.createAccounts(1);
     	newAccounts[0].Category__c 	= 'Non-Financial (Category B)';
        insert newAccounts;
        
        Business_Activity__c act = new Business_Activity__c(Activity_Name__c='test', Activity_Code__c='000786-6210', Entity__c=newAccounts[0].id);
        insert act; 
        
        ADNIC_Health_Insurance__c cset = new ADNIC_Health_Insurance__c();
        insert cset;
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Profile_Picture_Id__c = '12345';
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Is_Guest_User__c = false;
        newContacts[0].Community_Username__c = 'agtbtest2@adgm.portal';
        insert newContacts;
    }
   public static testMethod void testForm()
    {
        ADNIC_FormController adnic = new ADNIC_FormController();
        adnic.NameContact = 'testCon';
        adnic.MobileNumber='123123123';
        adnic.emailId ='test@test.com';
        adnic.Entity_name= [select id from account limit 1].Id;
        adnic.Account_Name = 'test';
        adnic.License_number ='1234';
        adnic.Legal_entity_type ='';
        
        adnic.AltContPerson = 'alCon';
        adnic.AltContNumber ='321321321';
    
        adnic.AccountId =[select id from account limit 1].Id;
    
    	Contact con = [Select id from Contact];
    	User portalUser = [SELECT Id FROM User WHERE ContactId = :con.Id];
    	test.startTest();
        system.runAs(portalUser)
        {
            adnic.doSave();
            ADNIC_Health_Insurance__c adnic1 = new ADNIC_Health_Insurance__c();
            adnic1.Name_of_the_person_to_be_contacted__c = adnic.NameContact;
            adnic1.Mobile_number__c = adnic.MobileNumber;
            adnic1.Email_address__c = adnic.emailId;
            adnic1.Account_Name__c = adnic.Account_Name;
            adnic1.License_number__c = adnic.License_number;
            adnic1.Legal_entity_type__c = adnic.Legal_entity_type;
            adnic1.entity_name__c= adnic.AccountId;
            adnic1.Alternate_Contact_Person__c = adnic.AltContPerson;
            adnic1.Alternate_Contact_Number__c = adnic.AltContNumber;
            insert adnic1;
        	adnic.doEdit();
        }
        test.stopTest();
    }
   

}
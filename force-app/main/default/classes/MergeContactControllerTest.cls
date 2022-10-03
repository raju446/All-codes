@isTest
public class MergeContactControllerTest {
    public static testmethod void test1(){
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '1000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(2, newAccounts[0].Id);
        //newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Community_Username__c = 'test1+4@adgm.portal';
        insert newContacts;
        
        //MergeContactController.getContactList('conEmail', 'firstNam', 'lastNam');
        MergeContactController.mergeContacts(newContacts[0].Id, new List<String>{newContacts[1].Id});
    }
    
    public static testmethod void test2(){
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '1000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(2, newAccounts[0].Id);
        //newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Email = 'test1@adgm.com';
        insert newContacts;
        
        MergeContactController.getContactList('test1@adgm.com', 'firstNam', 'lastNam');
    }
}
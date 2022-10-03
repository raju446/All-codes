@istest
public without sharing class PortalUserTestController{
     public static testmethod void TestPortalUserController(){
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts; 
        if(newAccounts != null && newAccounts.size() > 0){
            List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
            
            newContacts[0].RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact - Portal User').getRecordTypeId();
            insert newContacts[0];
            PageReference pageRef = Page.PortalUsers;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('Id', String.valueOf(newAccounts[0].Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(newAccounts[0]);
            PortalUserController testPortalUserController = new PortalUserController(sc);
            
        }
     }
}
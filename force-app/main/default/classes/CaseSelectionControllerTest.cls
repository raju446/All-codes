@isTest
public with sharing class CaseSelectionControllerTest {
 
    private static Case_Types__c c;
    private static void init(){
        c = new Case_Types__c();
        c.Name = 'Test';
        c.Record_Type_API_Name__c = 'Feedback';
        c.Seq_No__c = 1;
        insert c;
    }
    public static testmethod void TestCaseSelectionController(){
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts; 
                    
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        insert newContacts;  
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        
        
        system.runAs(portalUser){
        init();
        ApexPages.StandardController sc = new ApexPages.StandardController(c);
        CaseSelectionController cpb = new CaseSelectionController(sc);
        }
        
    }
    public static testmethod void TestCaseSelectionController2(){
        
        init();
        ApexPages.StandardController sc = new ApexPages.StandardController(c);
        CaseSelectionController cpb = new CaseSelectionController(sc);
        
    }
    
}
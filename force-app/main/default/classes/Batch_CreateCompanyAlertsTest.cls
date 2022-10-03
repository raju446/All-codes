@isTest
public with sharing class Batch_CreateCompanyAlertsTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList;
    
    private static void init(){
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        //newAccounts[0].Oracle_Party_Id__c = '0000001';
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Employment_Status__c = 'Active';
        insert newContacts;  
                          
        //createdSRList = TestUtility.createSR(1,'Entity_Documents');
        //createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        //createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        //insert createdSRList;
        
        String recId = Schema.Sobjecttype.Document_Details__c.getRecordTypeInfosByName().get('Entity Documents').getRecordTypeId();
        Document_Details__c docs = new Document_Details__c();  
        docs.RecordTypeId  = recId;
        docs.Document_Status__c='Active';
        docs.Document_Type__c= 'Employee Work Permit(UAE/GCC National)';
        docs.Account__c = newAccounts[0].Id;
        docs.Contact__c = newContacts[0].Id;
        //docs.Service_Request__c = createdSRList[0].Id;
        docs.Document_Expiry_Date__c = system.today().addDays(14);
        insert docs; 
    }
    public static testmethod void testcase(){
        init();
        Test.startTest();
        
        Batch_CreateCompanyAlerts con = new Batch_CreateCompanyAlerts();
        DataBase.executeBatch(con);
             
        Test.stopTest();
        
    }
    private static void init2(){
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        //newAccounts[0].Oracle_Party_Id__c = '0000001';
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        insert newContacts;  
                          
        //createdSRList = TestUtility.createSR(1,'Employee_Documents');
        //createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        //createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        //insert createdSRList;
        String recId = Schema.Sobjecttype.Document_Details__c.getRecordTypeInfosByName().get('Employee Documents').getRecordTypeId();
        Document_Details__c docs = new Document_Details__c();  
        docs.RecordTypeId  = recId;
        docs.Document_Status__c='Active';
        docs.Document_Type__c= 'Employee Work Permit(UAE/GCC National)';
        docs.Account__c = newAccounts[0].Id;
        docs.Contact__c = newContacts[0].Id;
        //docs.Service_Request__c = createdSRList[0].Id;
        docs.Document_Expiry_Date__c = system.today().addDays(30);
        insert docs; 
    }
    public static testmethod void testcase2(){
        init2();
        Test.startTest();
        
        Batch_CreateCompanyAlerts con = new Batch_CreateCompanyAlerts();
        DataBase.executeBatch(con);
             
        Test.stopTest();
        
    }
}
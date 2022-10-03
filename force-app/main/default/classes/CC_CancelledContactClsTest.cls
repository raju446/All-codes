@isTest
public with sharing class CC_CancelledContactClsTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    private static List<Account> createdAccountList; 
    
    private static void init(){
        createdAccountList = TestClassUtility.createAccounts(1);
        createdAccountList[0].Oracle_Party_Id__c = '0000001';
        insert createdAccountList;
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, createdAccountList[0].Id);
        insert newContacts;  
        
        createdSRList = TestUtility.createSR(1,'Dependent_Visa_Cancellation');
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        createdSRList[0].HexaBPM__Customer__c = createdAccountList[0].Id;
        insert createdSRList;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList;     
        
         Cancellation_SRs_Document_Types__c csr = new Cancellation_SRs_Document_Types__c();
         csr.Document_Type__c = 'Residence Visa';
         csr.Service_Request_Recordtype_API__c = 'Dependent_Visa_Cancellation';
         csr.Name = '1';
         insert csr;
         
         Document_Details__c docs = new Document_Details__c();  
         docs.Document_Status__c='Active';
         docs.Document_Type__c= 'Residence Visa';
         docs.Account__c = createdAccountList[0].Id;
         docs.Contact__c = newContacts[0].Id;
         docs.Service_Request__c = createdSRList[0].Id;
         insert docs; 
    }
    
    public static testmethod void TestCC_CancelledContactCls(){
        init();
        CC_CancelledContactCls con = new CC_CancelledContactCls();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id,HexaBPM__SR__r.Dependent__c, HexaBPM__SR__r.HexaBPM__Customer__c,HexaBPM__SR__r.HexaBPM__Contact__c,HexaBPM__SR__r.HexaBPM__Record_Type_Name__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        con.EvaluateCustomCode(null,lstOfSteps[0]);
    }
    private static void init2(){
        createdAccountList = TestClassUtility.createAccounts(1);
        createdAccountList[0].Oracle_Party_Id__c = '0000001';
        insert createdAccountList;
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, createdAccountList[0].Id);
        insert newContacts;  
        
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        createdSRList[0].HexaBPM__Customer__c = createdAccountList[0].Id;
        insert createdSRList;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList;     
        
        Document_Details__c docs = new Document_Details__c();  
         docs.Document_Status__c='Active';
         docs.Document_Type__c= 'Initial_Approval';
         docs.Account__c = createdAccountList[0].Id;
         docs.Contact__c = newContacts[0].Id;
         docs.Service_Request__c = createdSRList[0].Id;
         insert docs; 
    }
    
    public static testmethod void TestCC_CancelledContactCls2(){
        init2();
        CC_CancelledContactCls con = new CC_CancelledContactCls();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id,HexaBPM__SR__r.Dependent__c, HexaBPM__SR__r.HexaBPM__Customer__c,HexaBPM__SR__r.HexaBPM__Contact__c,HexaBPM__SR__r.HexaBPM__Record_Type_Name__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        con.EvaluateCustomCode(null,lstOfSteps[0]);
    }
}
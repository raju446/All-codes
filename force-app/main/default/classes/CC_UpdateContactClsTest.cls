@isTest
public with sharing class CC_UpdateContactClsTest {
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;
    
    private static void init(){
        HexaBPM__SR_Template__c srtemp = new HexaBPM__SR_Template__c();
        srtemp.HexaBPM__Sub_menu__c = 'Employee';
        srtemp.HexaBPM__SR_RecordType_API_Name__c = 'Employment_Visa_New';
        insert srtemp;
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '0000001';
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        insert newContacts;  
                          
        createdSRList = TestUtility.createSR(1,'Employment_Visa_New');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        createdSRList[0].I_Agree__c = true;
        createdSRList[0].HexaBPM__SR_Template__c = srtemp.Id;
        insert createdSRList;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList;     
        
        Document_Detail_SR_Field_Mapping__c srf = new Document_Detail_SR_Field_Mapping__c();
        srf.Active__c =true;
        srf.Service_Request_Recordtype_API__c = 'Employment_Visa_New';
        srf.SR_Field_API_Name__c = 'HexaBPM__Customer__c';
        srf.Document_Type__c = 'Residence Visa';
        srf.Document_Detail_Field_API_Name__c = 'Account__c';
        srf.Name = '1';
        insert srf;
        
        Document_Detail_SR_Field_Mapping__c srf2 = new Document_Detail_SR_Field_Mapping__c();
        srf2.Active__c =true;
        srf2.Service_Request_Recordtype_API__c = 'Temporary_Work_Permit_New';
        srf2.SR_Field_API_Name__c = 'Country_of_Issue__c';
        srf2.Document_Type__c = 'Temporary Employee Work Permit';
        srf2.Document_Detail_Field_API_Name__c = 'Document_Number__c';
        srf2.Name = '2';
        insert srf2;
        
        Contact_SR_Field_Mapping__c csf = new Contact_SR_Field_Mapping__c();
        csf.Active__c = true;
        csf.Contact_Field_API_Name__c = 'AccountId';
        csf.SR_Field_API_Name__c = 'HexaBPM__Customer__c';
        csf.Name = 'AccountId';
        insert csf;
        
        Document_Details__c docs = new Document_Details__c();  
         docs.Document_Status__c='Active';
         docs.Document_Type__c= 'Residence Visa';
         docs.Account__c = newAccounts[0].Id;
         docs.Contact__c = newContacts[0].Id;
         docs.Service_Request__c = createdSRList[0].Id;
         insert docs; 
         
         Document_Details__c docs2 = new Document_Details__c();  
         docs2.Document_Status__c='Active';
         docs2.Document_Type__c= 'Temporary Employee Work Permit';
         docs2.Account__c = newAccounts[0].Id;
         docs2.Contact__c = newContacts[0].Id;
         docs2.Service_Request__c = createdSRList[0].Id;
         insert docs2; 
    }
    
    private static void init1(){
        HexaBPM__SR_Template__c srtemp = new HexaBPM__SR_Template__c();
        srtemp.HexaBPM__Sub_menu__c = 'Dependent';
        srtemp.HexaBPM__SR_RecordType_API_Name__c = 'Employment_Visa_New';
        insert srtemp;
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '0000001';
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        insert newContacts;  
                          
        createdSRList = TestUtility.createSR(1,'Employment_Visa_New');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        createdSRList[0].I_Agree__c = true;
        createdSRList[0].HexaBPM__SR_Template__c = srtemp.Id;
        insert createdSRList;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList;     
        
        Document_Detail_SR_Field_Mapping__c srf = new Document_Detail_SR_Field_Mapping__c();
        srf.Active__c =true;
        srf.Service_Request_Recordtype_API__c = 'Employment_Visa_New';
        srf.SR_Field_API_Name__c = 'HexaBPM__Customer__c';
        srf.Document_Type__c = 'Residence Visa';
        srf.Document_Detail_Field_API_Name__c = 'Account__c';
        srf.Name = '1';
        insert srf;
        
        Document_Detail_SR_Field_Mapping__c srf2 = new Document_Detail_SR_Field_Mapping__c();
        srf2.Active__c =true;
        srf2.Service_Request_Recordtype_API__c = 'Dependent_Visa_Renewal';
        srf2.SR_Field_API_Name__c = 'Country_of_Issue__c';
        srf2.Document_Type__c = 'Temporary Employee Work Permit';
        srf2.Document_Detail_Field_API_Name__c = 'Document_Number__c';
        srf2.Name = '2';
        insert srf2;
        
        Contact_SR_Field_Mapping__c csf = new Contact_SR_Field_Mapping__c();
        csf.Active__c = true;
        csf.Contact_Field_API_Name__c = 'AccountId';
        csf.SR_Field_API_Name__c = 'HexaBPM__Customer__c';
        csf.Name = 'AccountId';
        insert csf;
        
        Contact_SR_Field_Mapping__c csf1 = new Contact_SR_Field_Mapping__c();
        csf1.Active__c = true;
        csf1.Contact_Field_API_Name__c = 'Lastname';
        csf1.SR_Field_API_Name__c = 'Last_Name__c';
        csf1.Name = 'Last Name';
        insert csf1;
        
        Document_Details__c docs = new Document_Details__c();  
         docs.Document_Status__c='Active';
         docs.Document_Type__c= 'Residence Visa';
         docs.Account__c = newAccounts[0].Id;
         docs.Contact__c = newContacts[0].Id;
         docs.Service_Request__c = createdSRList[0].Id;
         insert docs; 
         
         Document_Details__c docs2 = new Document_Details__c();  
         docs2.Document_Status__c='Active';
         docs2.Document_Type__c= 'Temporary Employee Work Permit';
         docs2.Account__c = newAccounts[0].Id;
         docs2.Contact__c = newContacts[0].Id;
         docs2.Service_Request__c = createdSRList[0].Id;
         insert docs2; 
    }
    
    public static testmethod void TestCC_UpdateContactCls_employee(){
      
        init();
        Test.startTest();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Record_Type_Name__c,HexaBPM__SR__r.HexaBPM__Contact__c, HexaBPM__SR__r.HexaBPM__Customer__c,HexaBPM__SR__r.Sub_Menu__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        CC_UpdateContactCls con = new CC_UpdateContactCls();
        con.EvaluateCustomCode(null,lstOfSteps[0]);
        Test.stopTest();
    }
    public static testmethod void TestCC_UpdateContactCls_Dependent()
    {
        init1();
        test.startTest();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Record_Type_Name__c,HexaBPM__SR__r.HexaBPM__Contact__c, HexaBPM__SR__r.HexaBPM__Customer__c,HexaBPM__SR__r.Sub_Menu__c,HexaBPM__SR__r.Dependent__c,HexaBPM__SR__r.Last_Name__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        CC_UpdateContactCls con = new CC_UpdateContactCls();
        con.EvaluateCustomCode(null,lstOfSteps[0]);
        test.stopTest();
    }

}
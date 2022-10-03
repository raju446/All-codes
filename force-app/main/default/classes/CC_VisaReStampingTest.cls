@isTest
public with sharing class CC_VisaReStampingTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    
    private static void init(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts; 
        
        List<Recordtype> employeeRectypeId = [SELECT Id FROM Recordtype WHERE SObjectType = 'Contact' AND DeveloperName = 'Contact_Employee' LIMIT 1];
        List<Recordtype> dependentRectypeId = [SELECT Id FROM Recordtype WHERE SObjectType = 'Contact' AND DeveloperName = 'Contact_Dependent' LIMIT 1];
        List<Contact> newContacts = TestClassUtility.createContacts(2, newAccounts[0].Id);
        newContacts[0].RecordtypeId = employeeRectypeId[0].Id;
        newContacts[0].Gross_Monthly_Salary__c = 20000;
        newContacts[0].Employment_Status__c = 'Active';
        newContacts[0].UAE_Residence_Visa_Expiry_Date__c = System.Today().addYears(1);
        newContacts[0].Passport_No__c = 'PASS-8326418735';
        newContacts[0].Passport_Expiry_Date__c = System.Today().addYears(3);
        newContacts[0].Work_Permit_Expiry_Date__c = System.Today().addYears(1);
        
        
        newContacts[1].RecordtypeId = dependentRectypeId[0].Id;
        newContacts[1].Sponsor__c = newContacts[0].Id;
        newContacts[1].Dependent_Status__c = 'Active';
        newContacts[1].Dependent_not_found__c = true;
        insert newContacts;  
                  
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        createdSRList[0].Dependent__c = newContacts[1].Id;
        createdSRList[0].Passport_Issue_Date__c = system.today().addYears(-2);
        createdSRList[0].Passport_Expiry_Date__c = system.today().addYears(2);
        createdSRList[0].Passport_Number__c = '413245';
        createdSRList[0].Residence_Visa_Number__c = '445355435';
        createdSRList[0].Residence_Visa_Date_of_Issue__c = system.today();
        createdSRList[0].Residence_Visa_Date_of_Expiry__c = system.today();
        createdSRList[0].Residence_Visa_Date_of_Issue__c = system.today();
        
        insert createdSRList;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList;     
       
         Document_Details__c docs = new Document_Details__c();  
         docs.Document_Status__c='Active';
         docs.Document_Type__c= 'Residence Visa';
         docs.Account__c = newAccounts[0].Id;
         docs.Document_Cancel_Date__c = system.today();
         docs.Contact__c = newContacts[0].Id;
         docs.Service_Request__c = createdSRList[0].Id;
         insert docs; 
    }
    
    public static testmethod void TestCC_VisaReStamping(){
        init();
        Test.startTest();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Customer__c, HexaBPM__SR__r.Dependent__c, HexaBPM__SR__r.Passport_Issue_Date__c,
                                             HexaBPM__SR__r.Passport_Expiry_Date__c, HexaBPM__SR__r.Passport_Number__c,
                                             HexaBPM__SR__r.Residence_Visa_Number__c, HexaBPM__SR__r.Residence_Visa_Date_of_Issue__c, HexaBPM__SR__r.Residence_Visa_Date_of_Expiry__c,
                                             HexaBPM__SR__r.HexaBPM__Contact__c
                                             FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        CC_VisaReStamping con = new CC_VisaReStamping();
        con.EvaluateCustomCode(null,lstOfSteps[0]);
        Test.stopTest();
    }
    
    private static void init2(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        insert newContacts;  
                  
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        createdSRList[0].Dependent__c = null;
        createdSRList[0].Passport_Issue_Date__c = system.today().addYears(-2);
        createdSRList[0].Passport_Expiry_Date__c = system.today().addYears(2);
        createdSRList[0].Passport_Number__c = '413245';
        createdSRList[0].Residence_Visa_Number__c = '445355435';
        createdSRList[0].Residence_Visa_Date_of_Issue__c = system.today();
        createdSRList[0].Residence_Visa_Date_of_Expiry__c = system.today();
        createdSRList[0].Residence_Visa_Date_of_Issue__c = system.today();
        
        insert createdSRList;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList;     
       
         Document_Details__c docs = new Document_Details__c();  
         docs.Document_Status__c='Active';
         docs.Document_Type__c= 'Residence Visa';
         docs.Account__c = newAccounts[0].Id;
         docs.Document_Cancel_Date__c = system.today();
         docs.Contact__c = newContacts[0].Id;
         docs.Service_Request__c = createdSRList[0].Id;
         insert docs; 
    }
    
    public static testmethod void TestCC_VisaReStamping2(){
        init2();
        Test.startTest();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Customer__c, HexaBPM__SR__r.Dependent__c, HexaBPM__SR__r.Passport_Issue_Date__c,
                                             HexaBPM__SR__r.HexaBPM__Contact__c,  HexaBPM__SR__r.Passport_Expiry_Date__c, HexaBPM__SR__r.Passport_Number__c,
                                             HexaBPM__SR__r.Residence_Visa_Number__c, HexaBPM__SR__r.Residence_Visa_Date_of_Issue__c, HexaBPM__SR__r.Residence_Visa_Date_of_Expiry__c 
                                             FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        CC_VisaReStamping con = new CC_VisaReStamping();
        con.EvaluateCustomCode(null,lstOfSteps[0]);
        Test.stopTest();
    }
}
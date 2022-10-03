@isTest
public with sharing class CC_WorkPermitTemporaryTest {
     
    public static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    
    public static void init(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Nationality__c = 'AFGHANISTAN';
        newContacts[0].Passport_Number__c = 'JHP6483ER';
        insert newContacts;  
                  
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        createdSRList[0].Residence_Visa_Date_of_Expiry__c = system.today().addDays(6);
        createdSRList[0].Passport_Number__c = 'JHP6483ER'; 
        createdSRList[0].Nationality__c = 'AFGHANISTAN'; 
        createdSRList[0].Work_Permit_Validity__c = '3';
        insert createdSRList;
        
        system.debug('##SERVICE_REQUEST: '+createdSRList);
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList;     
       
         
    }
    public static testmethod void TestCC_WorkPermitTemporary(){
        init();
        Test.startTest();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Customer__c ,HexaBPM__SR__r.Residence_Visa_Date_of_Expiry__c, HexaBPM__SR__r.Work_Permit_Validity__c,
                                                HexaBPM__SR__r.Passport_Number__c, HexaBPM__SR__r.Nationality__c     FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        system.debug('##STEP: '+lstOfSteps);
        CC_WorkPermitTemporary con = new CC_WorkPermitTemporary();
        con.EvaluateCustomCode(null,lstOfSteps[0]);
        Test.stopTest();
    }
    private static void init2(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Nationality__c = 'AFGHANISTAN';
        newContacts[0].Passport_Number__c = 'JHP6483ER';
        insert newContacts;  
                  
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        createdSRList[0].Residence_Visa_Date_of_Expiry__c = system.today().addDays(6);
        createdSRList[0].Passport_Number__c = 'JHP6483ER'; 
        createdSRList[0].Nationality__c = 'AFGHANISTAN'; 
        createdSRList[0].Work_Permit_Validity__c = '6';
        insert createdSRList;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList;     
       
         
    }
    public static testmethod void TestCC_WorkPermitTemporary2(){
        init2();
        Test.startTest();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Customer__c ,HexaBPM__SR__r.Residence_Visa_Date_of_Expiry__c,HexaBPM__SR__r.Work_Permit_Validity__c,
                                                HexaBPM__SR__r.Passport_Number__c, HexaBPM__SR__r.Nationality__c     FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        CC_WorkPermitTemporary con = new CC_WorkPermitTemporary();
        con.EvaluateCustomCode(null,lstOfSteps[0]);
        Test.stopTest();
    }
    private static void init3(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Nationality__c = 'AFGHANISTAN';
        newContacts[0].Passport_Number__c = 'JHP6483ER';
        insert newContacts;  
                  
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        createdSRList[0].Residence_Visa_Date_of_Expiry__c = system.today().addDays(6);
        createdSRList[0].Passport_Number__c = 'JHP6483ER'; 
        createdSRList[0].Nationality__c = 'AFGHANISTAN'; 
        createdSRList[0].Work_Permit_Validity__c = '12';
        insert createdSRList;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList;     
       
         
    }
    public static testmethod void TestCC_WorkPermitTemporary3(){
        init3();
        Test.startTest();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Customer__c ,HexaBPM__SR__r.Residence_Visa_Date_of_Expiry__c,HexaBPM__SR__r.Work_Permit_Validity__c,
                                                HexaBPM__SR__r.Passport_Number__c, HexaBPM__SR__r.Nationality__c     FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        CC_WorkPermitTemporary con = new CC_WorkPermitTemporary();
        con.EvaluateCustomCode(null,lstOfSteps[0]);
        Test.stopTest();
    }
    private static void init4(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Nationality__c = 'AFGHANISTAN';
        newContacts[0].Passport_Number__c = 'JHP6483ER';
        insert newContacts;  
                  
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        createdSRList[0].Residence_Visa_Date_of_Expiry__c = system.today().addDays(-120);  
        createdSRList[0].Passport_Number__c = 'JHP6483ER'; 
        createdSRList[0].Nationality__c = 'AFGHANISTAN'; 
        createdSRList[0].Work_Permit_Validity__c = '3';
        insert createdSRList;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList;     
       
         
    }
    public static testmethod void TestCC_WorkPermitTemporary4(){
        init4();
        Test.startTest();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Customer__c ,HexaBPM__SR__r.Residence_Visa_Date_of_Expiry__c,HexaBPM__SR__r.Work_Permit_Validity__c,
                                                HexaBPM__SR__r.Passport_Number__c, HexaBPM__SR__r.Nationality__c     FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        CC_WorkPermitTemporary con = new CC_WorkPermitTemporary();
        con.EvaluateCustomCode(null,lstOfSteps[0]);
        Test.stopTest();
    }
     private static void init5(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c  = '12345';
        insert newAccounts; 
        
        HexaBPM__SR_Template__c hst = new HexaBPM__SR_Template__c();
        hst.HexaBPM__Active__c = true;
        hst.Name='Trainings and Seminars Permit';
        hst.HexaBPM__SR_RecordType_API_Name__c = 'Employment_Visa_New';
        insert hst;
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Nationality__c = 'AFGHANISTAN';
        newContacts[0].Passport_Number__c = 'JHP6483ER';
        insert newContacts;  
                  
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        createdSRList[0].Residence_Visa_Date_of_Expiry__c = system.today().addDays(120);  
        createdSRList[0].Passport_Number__c = 'JHP6483ER'; 
        createdSRList[0].Nationality__c = 'AFGHANISTAN'; 
        createdSRList[0].Work_Permit_Validity__c = '3';
        createdSRList[0].HexaBPM__SR_Template__c = hst.id;
        insert createdSRList;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList;     
       
         
    }
    public static testmethod void TestCC_WorkPermitTemporary5(){
        init5();
        Test.startTest();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Customer__c ,HexaBPM__SR__r.Residence_Visa_Date_of_Expiry__c,HexaBPM__SR__r.Work_Permit_Validity__c,
                                                HexaBPM__SR__r.Passport_Number__c, HexaBPM__SR__r.Nationality__c     FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        CC_WorkPermitTemporary con = new CC_WorkPermitTemporary();
        con.EvaluateCustomCode(null,lstOfSteps[0]);
        
        CC_WorkPermitEmployee cc = new CC_WorkPermitEmployee();
        cc.EvaluateCustomCode(null,lstOfSteps[0]);
        
        createdSRList[0].HexaBPM__SR_Template__c = null;
        update createdSRList;
        
        lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Customer__c ,HexaBPM__SR__r.Residence_Visa_Date_of_Expiry__c,HexaBPM__SR__r.Work_Permit_Validity__c,
                                                HexaBPM__SR__r.Passport_Number__c, HexaBPM__SR__r.Nationality__c     FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
       
        cc = new CC_WorkPermitEmployee();
        cc.EvaluateCustomCode(null,lstOfSteps[0]);
                                                
        Test.stopTest();
    }
}
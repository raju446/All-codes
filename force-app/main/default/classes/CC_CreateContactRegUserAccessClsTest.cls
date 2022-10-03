@isTest
public with sharing class CC_CreateContactRegUserAccessClsTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    private static HexaBPM__SR_Steps__c createSRstep;
    private static List<Account> createdAccountList; 
    
    private static void init(){
        
        createdAccountList = TestClassUtility.createAccounts(1);
        insert createdAccountList;
                
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = createdAccountList[0].Id;
        createdSRList[0].First_Name__c = 'Ravi';
        createdSRList[0].HexaBPM__Email__c = 'test@gmail.com';
        createdSRList[0].HexaBPM__Send_SMS_to_Mobile__c = '+912828282937';
        createdSRList[0].Guest_Username__c = 'user@acme.com';
        createdSRList[0].Role__c = 'Lead Admin';
        createdSRList[0].Sponsored_Employee__c = 'Yes';
        createdSRList[0].Tax_Registration_Number__c = '1234';
        insert createdSRList;
        
        createSRstep = new  HexaBPM__SR_Steps__c();
        insert createSRstep;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,createSRstep.Id);
        insert createdstepList;     
    }
    public static testmethod void TestCC_CreateContactRegUserAccessCls(){
        init();
        
        Test.startTest();
        CC_CreateContactRegUserAccessCls con = new CC_CreateContactRegUserAccessCls();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Customer__c,HexaBPM__SR__r.Types_of_Services_Accessible__c,HexaBPM__SR__r.First_Name__c,HexaBPM__SR__r.Last_Name__c, HexaBPM__SR__r.HexaBPM__Email__c, 
        														HexaBPM__SR__r.HexaBPM__Send_SMS_to_Mobile__c, HexaBPM__SR__r.Guest_Username__c,HexaBPM__SR__r.Role__c, 
        														 HexaBPM__SR__r.Sponsored_Employee__c,HexaBPM__SR__r.Tax_Registration_Number__c
        														FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        con.EvaluateCustomCode(null,lstOfSteps[0]);
        Test.stopTest();
    }
    private static void init2(){
    	
        createdAccountList = TestClassUtility.createAccounts(1);
        insert createdAccountList;
                
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = createdAccountList[0].Id;
        createdSRList[0].First_Name__c = 'Ravi';
        createdSRList[0].HexaBPM__Email__c = 'test@gmail.com';
        createdSRList[0].HexaBPM__Send_SMS_to_Mobile__c = '+912828282937';
        createdSRList[0].Guest_Username__c = 'user';
        createdSRList[0].Role__c = 'Lead Admin';
        createdSRList[0].Sponsored_Employee__c = 'Yes';
        createdSRList[0].Tax_Registration_Number__c = '1234';
        insert createdSRList;
        
        createSRstep = new  HexaBPM__SR_Steps__c();
        insert createSRstep;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,createSRstep.Id);
        insert createdstepList;     
    }
    public static testmethod void TestCC_CreateContactRegUserAccessCls2(){
        init2();
        Test.startTest();
        CC_CreateContactRegUserAccessCls con = new CC_CreateContactRegUserAccessCls();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Customer__c,HexaBPM__SR__r.Types_of_Services_Accessible__c,HexaBPM__SR__r.First_Name__c,HexaBPM__SR__r.Last_Name__c, HexaBPM__SR__r.HexaBPM__Email__c, 
        														HexaBPM__SR__r.HexaBPM__Send_SMS_to_Mobile__c, HexaBPM__SR__r.Guest_Username__c,HexaBPM__SR__r.Role__c, 
        														 HexaBPM__SR__r.Sponsored_Employee__c,HexaBPM__SR__r.Tax_Registration_Number__c
        														 FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        con.EvaluateCustomCode(null,lstOfSteps[0]);
        Test.stopTest();
    }
    public static testMethod void updateUserRoles(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 

        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        newContacts[0].Types_of_Services_Accessible__c = 'Company Services; Permits Services; Visa & Letter Services';
        newContacts[0].RecordTypeId = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('Contact - Portal User').getRecordTypeId();
        insert newContacts; 
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        system.runAs(portalUser)
        {
            test.startTest();
                string AccessType = 'Company Services;';
                string role = 'Lead Admin';
                CC_CreateContactRegUserAccessCls.updateUserRoles(portalUser.id,AccessType,role, true);
            test.stopTest();
        }
    }
    public static testmethod void TestCC_CreateContactRegUserAccessClsNew(){
         List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 

        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Community_Username__c = 'user@acme.com';
        newContacts[0].Types_of_Services_Accessible__c = 'Company Services; Permits Services; Visa & Letter Services';
        newContacts[0].RecordTypeId = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('Contact - Portal User').getRecordTypeId();
        insert newContacts; 
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        // portalUser.username = 'user@acme.com';
        // update portalUser; 

        List<HexaBPM__Service_Request__c> createdSRLst = TestUtility.createSR(1,'Initial_Approval');
        createdSRLst[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRLst[0].First_Name__c = 'Ravi';
        createdSRLst[0].HexaBPM__Email__c = 'test@gmail.com';
        createdSRLst[0].HexaBPM__Send_SMS_to_Mobile__c = '+912828282937';
        createdSRLst[0].Guest_Username__c = 'user@acme.com';
        createdSRLst[0].Role__c = 'Lead Admin';
        createdSRLst[0].Sponsored_Employee__c = 'Yes';
        createdSRLst[0].Tax_Registration_Number__c = '1234';
        insert createdSRLst;
        
        createSRstep = new  HexaBPM__SR_Steps__c();
        insert createSRstep;
        
        createdstepList = TestUtility.createSteps(1,createdSRLst[0].Id,createSRstep.Id);
        insert createdstepList;     
        
        Test.startTest();
        CC_CreateContactRegUserAccessCls con = new CC_CreateContactRegUserAccessCls();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Customer__c,HexaBPM__SR__r.Types_of_Services_Accessible__c,HexaBPM__SR__r.First_Name__c,HexaBPM__SR__r.Last_Name__c, HexaBPM__SR__r.HexaBPM__Email__c, 
        														HexaBPM__SR__r.HexaBPM__Send_SMS_to_Mobile__c, HexaBPM__SR__r.Guest_Username__c,HexaBPM__SR__r.Role__c, 
        														 HexaBPM__SR__r.Sponsored_Employee__c,HexaBPM__SR__r.Tax_Registration_Number__c
        														FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        con.EvaluateCustomCode(null,lstOfSteps[0]);
        Test.stopTest();
    }
}
@isTest
public with sharing class CC_Update_EmployeeDetailsTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    private static List<Account> createdAccountList; 
    
    private static void init(){
        
        createdAccountList = TestClassUtility.createAccounts(1);
        insert createdAccountList;
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, createdAccountList[0].Id);
        insert newContacts;  
        
        Lookup__c l1 = new Lookup__c();
        l1.Type__c = 'Job Title';
        insert l1;  
        
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = createdAccountList[0].Id;
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        createdSRList[0].Gross_Monthly_Salary__c = 2000;
        createdSRList[0].Marital_Status__c = 'SINGLE';
        createdSRList[0].Job_Title__c = l1.Id;
        createdSRList[0].Passport_Number__c = '12345';
        createdSRList[0].Passport_Expiry_Date__c = Date.today()+100;
        createdSRList[0].Passport_Issue_Date__c = date.today()-100;
        createdSRList[0].Nationality__c = 'India';
        insert createdSRList;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList; 
        
        
    }
    public static testmethod void TestCC_Update_EmployeeDetails(){
        init();
       CC_Update_EmployeeDetails con = new CC_Update_EmployeeDetails();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Contact__c, HexaBPM__SR__r.Gross_Monthly_Salary__c, 
                                                HexaBPM__SR__r.Marital_Status__c,HexaBPM__SR__r.Job_Title__c,
                                                HexaBPM__SR__r.Passport_Number__c,HexaBPM__SR__r.Passport_Expiry_Date__c,
                                                HexaBPM__SR__r.Passport_Place_of_Issue__c ,HexaBPM__SR__r.Passport_Issue_Date__c,
                                                HexaBPM__SR__r.Nationality__c
                                                     FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        con.EvaluateCustomCode(null,lstOfSteps[0]);
    }
}
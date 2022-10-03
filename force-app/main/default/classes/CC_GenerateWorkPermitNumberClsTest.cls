@isTest
public with sharing class CC_GenerateWorkPermitNumberClsTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    
    private static void init(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '0000001';
		insert newAccounts; 
				                  
        createdSRList = TestUtility.createSR(1,'Employee_Work_Permit_UAE_GCC_National_New');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        insert createdSRList;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList;    

		Work_Permit_Running_Number__c workPermit = new Work_Permit_Running_Number__c();
		workPermit.Work_Permit_Name__c = 'Temporary Work Permit';
		workPermit.Work_Permit_Running_Number__c = 1234;
		workPermit.Name = 'Temporary Work Permit';
		insert workPermit;
		
		Work_Permit_Running_Number__c workPermit2 = new Work_Permit_Running_Number__c();
		workPermit2.Work_Permit_Name__c = 'Permanent Work Permit';
		workPermit2.Work_Permit_Running_Number__c = 5678;
		workPermit2.Name = 'Permanent Work Permit';
		insert workPermit2;

    }
    public static testmethod void TestCC_GenerateWorkPermitNumber(){
       	init();
        Test.startTest();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Record_Type_Name__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        CC_GenerateWorkPermitNumberCls con = new CC_GenerateWorkPermitNumberCls();
        
        con.EvaluateCustomCode(null,lstOfSteps[0]);
        Test.stopTest();
    }
    private static void init2(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
		newAccounts[0].Oracle_Party_Id__c = '0000002';
		insert newAccounts; 
				                  
        createdSRList = TestUtility.createSR(1,'Temporary_Work_Permit_New');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        insert createdSRList;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList;    

		Work_Permit_Running_Number__c workPermit = new Work_Permit_Running_Number__c();
		workPermit.Work_Permit_Name__c = 'Temporary Work Permit';
		workPermit.Work_Permit_Running_Number__c = 1234;
		workPermit.Name = 'Temporary Work Permit';
		insert workPermit;
		
		Work_Permit_Running_Number__c workPermit2 = new Work_Permit_Running_Number__c();
		workPermit2.Work_Permit_Name__c = 'Permanent Work Permit';
		workPermit2.Work_Permit_Running_Number__c = 5678;
		workPermit2.Name = 'Permanent Work Permit';
		insert workPermit2;
		 
    }
    public static testmethod void TestCC_GenerateWorkPermitNumber2(){
       	init2();
        Test.startTest();
       	List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Record_Type_Name__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        CC_GenerateWorkPermitNumberCls con = new CC_GenerateWorkPermitNumberCls();
        con.EvaluateCustomCode(null,lstOfSteps[0]);
        Test.stopTest();
    }
    
}
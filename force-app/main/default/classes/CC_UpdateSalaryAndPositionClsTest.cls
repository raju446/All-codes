@isTest
public with sharing class CC_UpdateSalaryAndPositionClsTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    private static HexaBPM__SR_Steps__c createSRstep;
    
    private static void init(){
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
		insert newAccounts; 
		Lookup__c l1 = new Lookup__c();
        insert l1;
		List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
		//newContacts[0].Job_Code__c  = l1.Id;
		insert newContacts;  
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        createdSRList[0].Job_Title__c = l1.Id;
        insert createdSRList;
        createSRstep = new  HexaBPM__SR_Steps__c();
        insert createSRstep;
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,createSRstep.Id);
        insert createdstepList;     
    }
    
    public static testmethod void testcase(){
        init();
        CC_UpdateSalaryAndPositionCls con = new CC_UpdateSalaryAndPositionCls();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id,HexaBPM__SR__r.HexaBPM__Contact__c,HexaBPM__SR__r.Job_Title__c,HexaBPM__SR__r.Gross_Monthly_Salary__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        con.EvaluateCustomCode(null,lstOfSteps[0]);
    }
     
    
    
}
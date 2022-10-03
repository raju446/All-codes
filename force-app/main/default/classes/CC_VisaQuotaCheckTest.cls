@isTest
public with sharing class CC_VisaQuotaCheckTest {
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    private static HexaBPM__SR_Steps__c createSRstep;
    private static List<Account> createdAccountList; 
    
    private static void init(){
        createdAccountList = TestClassUtility.createAccounts(1);
        createdAccountList[0].Total_Visas_Allowed__c = 6;
        insert createdAccountList;
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = createdAccountList[0].Id;
        insert createdSRList;
        createSRstep = new  HexaBPM__SR_Steps__c();
        insert createSRstep;
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,createSRstep.Id);
        insert createdstepList;     
    }
     public static testmethod void testcase(){
        init();
        CC_VisaQuotaCheck con = new CC_VisaQuotaCheck();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Customer__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        con.EvaluateCustomCode(null,lstOfSteps[0]);
    }
}
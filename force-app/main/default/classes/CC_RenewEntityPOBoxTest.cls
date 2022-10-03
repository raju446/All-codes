@isTest
public with sharing class CC_RenewEntityPOBoxTest {
   
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    private static HexaBPM__SR_Steps__c createSRstep;
    private static List<Account> createdAccountList; 
    private static  List<PO_Box__c> createdPOBoxtList; 
    
    private static void init(){
        PO_Box__c pb = new PO_Box__c();
		pb.Type__c	= 'EziMAIL Bronze';
		pb.Status__c = 'Available';
		pb.Start_Date__c = system.today();
        pb.PO_Box_Number__c = '12345678';
		pb.Expiry_Date__c = system.today();
		createdPOBoxtList = new List<PO_Box__c>();    	
		createdPOBoxtList.add(pb);
		insert createdPOBoxtList;
        createdAccountList = TestClassUtility.createAccounts(1);
        createdAccountList[0].Oracle_Party_Id__c = '000001';
        createdAccountList[0].PO_Box__c = createdPOBoxtList[0].Id;
        insert createdAccountList;
        createdSRList = TestUtility.createSR(1,'P_O_Box_New');
        createdSRList[0].HexaBPM__Customer__c = createdAccountList[0].Id;
        createdSRList[0].PO_Box__c = createdPOBoxtList[0].Id;
        createdSRList[0].issue_date__c = system.Today();
        createdSRList[0].expiry_date__c = system.Today().addYears(1);
        createdSRList[0].agent_name__c='';
        createdSRList[0].agent_mobile_Number__c='';
        createdSRList[0].Agent_Emirates_ID_Number__c='';
        insert createdSRList;
        createSRstep = new  HexaBPM__SR_Steps__c();
        insert createSRstep;
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,createSRstep.Id);
        createdstepList[0].HexaBPM__SR__c = createdSRList[0].Id;
        insert createdstepList;     
    }
    
    
    public static testmethod void testcase(){
        init();
        CC_RenewEntityPOBox con = new CC_RenewEntityPOBox();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.Issue_date__c, HexaBPM__SR__r.expiry_date__c, HexaBPM__SR__r.P_O_Box_Type__c, HexaBPM__SR__r.HexaBPM__Customer__c,HexaBPM__SR__r.PO_Box__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];    
        con.EvaluateCustomCode(null,lstOfSteps[0]);
    }
    
    
}
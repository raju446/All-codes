@isTest
public class CC_SetPOBoxOnEntityTest {

 	private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    private static HexaBPM__SR_Steps__c createSRstep;
    private static List<Account> createdAccountList; 
    private static PO_Box__c pobox;
    
    private static void init(){
        createdAccountList = TestClassUtility.createAccounts(1);
        insert createdAccountList;
        pobox = new PO_Box__c();
        pobox.Status__c = 'Available';
        pobox.Start_Date__c = system.today();
        pobox.Expiry_Date__c = system.today();
        pobox.Type__c = 'EziMAIL Bronze';
        insert pobox;  
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = createdAccountList[0].Id;
        createdSRList[0].P_O_Box_Type__c = 'EziMAIL Bronze';
        insert createdSRList;
        createSRstep = new  HexaBPM__SR_Steps__c();
        insert createSRstep;
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,createSRstep.Id);
        insert createdstepList;     
    }
	 public static testmethod void testcase(){
        init();
        CC_SetPOBoxOnEntity con = new CC_SetPOBoxOnEntity();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Customer__c,HexaBPM__SR__r.P_O_Box_Type__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        con.EvaluateCustomCode(null,lstOfSteps[0]);
    }
     
}
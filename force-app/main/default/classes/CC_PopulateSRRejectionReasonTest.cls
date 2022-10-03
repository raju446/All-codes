@isTest
public with sharing class CC_PopulateSRRejectionReasonTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    private static HexaBPM__SR_Steps__c createSRstep;
    
    private static void init(){
    	createdSRList = TestUtility.createSR(1,'Initial_Approval');
        insert createdSRList;
        createSRstep = new  HexaBPM__SR_Steps__c();
        insert createSRstep;
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,createSRstep.Id);
        insert createdstepList;     
    }
    
    public static testmethod void testcase(){
        init();
        CC_PopulateSRRejectionReason con = new CC_PopulateSRRejectionReason();
        con.EvaluateCustomCode(null,createdstepList[0]);
    }
    
}
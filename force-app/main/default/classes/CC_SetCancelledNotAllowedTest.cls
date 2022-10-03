@isTest
public with sharing class CC_SetCancelledNotAllowedTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    
    public static testmethod void TestCC_SetCancelledNotAllowed(){
        
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        insert createdSRList;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList; 
        
        CC_SetCancelledNotAllowed con = new CC_SetCancelledNotAllowed();
        con.EvaluateCustomCode(null,createdstepList[0]);
    }
}
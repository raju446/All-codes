@isTest
public with sharing class CC_AutoCloseStepTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;
    private static HexaBPM__SR_Steps__c createSRstep;
    
    private static void init(){
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        insert createdSRList;
        
        createSRstep = new  HexaBPM__SR_Steps__c();
        insert createSRstep;
        
        HexaBPM__Status__c status = new HexaBPM__Status__c();
        status.HexaBPM__Type__c = 'End';
        status.HexaBPM__Code__c = 'Test';
        insert status;
        
        HexaBPM__Status__c status1 = new HexaBPM__Status__c();
        status1.HexaBPM__Type__c = 'Start';
        status1.HexaBPM__Code__c = 'Start_TEST';
        insert status1;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,createSRstep.Id);
        createdstepList[0].HexaBPM__Status__c = status1.Id;
        insert createdstepList;   
       
        HexaBPM__Transition__c trans = new HexaBPM__Transition__c();
        trans.HexaBPM__To__c = status.Id;
        trans.HexaBPM__From__c = status1.Id;
        insert trans;    
        
        HexaBPM__SR_Status__c srStatus = new HexaBPM__SR_Status__c();
        srStatus.HexaBPM__Code__c = 'Test';
        insert srStatus;
        
        HexaBPM__Step_Transition__c stepTransition = new HexaBPM__Step_Transition__c();
        stepTransition.HexaBPM__SR_Status_Internal__c = srStatus.Id;
        stepTransition.HexaBPM__SR_Status_External__c = srStatus.Id;
        stepTransition.HexaBPM__SR_Step__c = createSRstep.Id;
        stepTransition.HexaBPM__Transition__c = trans.Id;
        insert stepTransition;
        
          
    }
    public static testmethod void testcase(){
        init();
        CC_AutoCloseStep con = new CC_AutoCloseStep();
        //List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Customer__c,HexaBPM__SR__r.P_O_Box_Type__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        con.EvaluateCustomCode(null,createdstepList[0]);
    }
}
@isTest
public with sharing class CC_CreateFineLineItemTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    private static HexaBPM__SR_Steps__c createSRstep;
    
    private static void init(){
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].Fine_Amount__c = 250;
        insert createdSRList;
        createSRstep = new  HexaBPM__SR_Steps__c();
        insert createSRstep;
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,createSRstep.Id);
        insert createdstepList;     
        Product2 p = new Product2();
        p.productcode = 'AUTOMATIC_FINES';
        p.Name = 'Rishu';
        insert p;
    }
    public static testmethod void TestCC_CreateFineLineItem(){
        init();
        Test.startTest();
        CC_CreateFineLineItem con = new CC_CreateFineLineItem();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.Fine_Amount__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        con.EvaluateCustomCode(null,lstOfSteps[0]);
        Test.stopTest();
    }
    
}
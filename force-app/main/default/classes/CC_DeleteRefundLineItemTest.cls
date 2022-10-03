@isTest
public with sharing class CC_DeleteRefundLineItemTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    
    private static void init(){
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        insert createdSRList;
       
        HexaBPM__SR_Price_Item__c srprice = new HexaBPM__SR_Price_Item__c();
        srprice.HexaBPM__ServiceRequest__c = createdSRList[0].Id; 
        srprice.Is_Refund_Line__c = true;
        insert srprice; 
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList;     
    }
    
    public static testmethod void TestCC_DeleteRefundLineItem(){
        init();
        CC_DeleteRefundLineItem con = new CC_DeleteRefundLineItem();
        //List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Customer__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        con.EvaluateCustomCode(null,createdstepList[0]);
    }
    
    
}
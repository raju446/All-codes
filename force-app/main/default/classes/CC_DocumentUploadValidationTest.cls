@isTest
public with sharing class CC_DocumentUploadValidationTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    private static HexaBPM__SR_Steps__c createSRstep;
    private static List<HexaBPM__SR_Doc__c> createSRDoc;
    
    private static void init(){
        List<HexaBPM__Document_Master__c> docmas = TestUtility.createDocMasters(1);
        insert docmas;
        
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        insert createdSRList;
        
        List<SR_Doc_Running_Number__c> srDocRunNumList = TestClassUtility.createSRDocRunningNumber();
        insert srDocRunNumList;
        
        createSRstep = new  HexaBPM__SR_Steps__c();
        insert createSRstep;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,createSRstep.Id);
        insert createdstepList;  
        
        createSRDoc = TestUtility.createDocMasters(1,docmas[0].Id,createdSRList[0].Id);
        createSRDoc[0].Name = 'test';
        createSRDoc[0].HexaBPM__Status__c = 'Approved';
        createSRDoc[0].HexaBPM__Doc_ID__c = null;
        createSRDoc[0].HexaBPM__Step__c = createdstepList[0].Id;
        insert createSRDoc;
           
    }
    public static testmethod void TestCC_DocumentUploadValidation(){
        init();
        CC_DocumentUploadValidation con = new CC_DocumentUploadValidation();
        //List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Customer__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        con.EvaluateCustomCode(createdSRList[0],createdstepList[0]);
    }
}
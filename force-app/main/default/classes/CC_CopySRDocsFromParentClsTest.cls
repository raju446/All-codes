@isTest
public with sharing class CC_CopySRDocsFromParentClsTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Service_Request__c> createdSRList1;
    private static List<HexaBPM__Step__c> createdstepList;  
    private static HexaBPM__SR_Steps__c createSRstep;
    private static List<Account> createdAccountList; 
    private static List<Account> createdAccountList1; 
    private static List<HexaBPM__SR_Doc__c> createdSRDocList; 
    private static List<HexaBPM__Document_Master__c> createdDocMasterList; 
    private static List<Attachment> createdAttachmentList;
   
   	private static void init(){
    	
        createdDocMasterList = TestUtility.createDocMasters(1);
        insert createdDocMasterList;
    
        createdAccountList = TestClassUtility.createAccounts(1);
        createdAccountList[0].Oracle_Party_Id__c = '0000001';
        insert createdAccountList;
        
        createdAccountList1 = TestClassUtility.createAccounts(1);
        createdAccountList1[0].Oracle_Party_Id__c = '0000002';
        insert createdAccountList1;
        
        createdSRList1 = TestUtility.createSR(1,'Permit_Entertainment');
        createdSRList1[0].HexaBPM__Customer__c = createdAccountList1[0].Id;
        insert createdSRList1;
        
        List<SR_Doc_Running_Number__c> srDocRunNumList = TestClassUtility.createSRDocRunningNumber();
        insert srDocRunNumList;
        
        createdSRDocList = TestUtility.createDocMasters(1,createdDocMasterList[0].Id,createdSRList1[0].Id);
        insert createdSRDocList;
        
        createdAttachmentList = TestClassUtility.createAttachment(new List<Attachment>{new Attachment(ParentId =createdSRDocList[0].Id)});
        
        createdSRList = TestUtility.createSR(1,'Permit_Entertainment');
        createdSRList[0].HexaBPM__Customer__c = createdAccountList[0].Id;
        createdSRList[0].HexaBPM__Parent_SR__c = createdSRList1[0].Id;
        insert createdSRList;
        
        createSRstep = new  HexaBPM__SR_Steps__c();
        insert createSRstep;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,createSRstep.Id);
        insert createdstepList;     
    }
    public static testmethod void TestCC_CopySRDocsFromParentCls(){
        init();
        Test.startTest();
        CC_CopySRDocsFromParentCls con = new CC_CopySRDocsFromParentCls();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Record_Type_Name__c,HexaBPM__SR__r.HexaBPM__Parent_SR__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        con.EvaluateCustomCode(null,lstOfSteps[0]);
        Test.stopTest();
    }
}
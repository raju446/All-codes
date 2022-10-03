@isTest
public with sharing class CC_CID_EmailNotificationsTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    
    private static void init(){
        
        HexaBPM__Status__c status = new HexaBPM__Status__c();
        status.HexaBPM__Rejection__c = true;
        status.HexaBPM__Code__c = 'test';
        insert status;
                  
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        insert createdSRList;
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
		insert newAccounts; 
		
        List<Attachment> att = TestClassUtility.createAttachment(new List<Attachment>{new Attachment(ParentId = newAccounts[0].Id)});
        String id = att[0].Id;
        
        List<HexaBPM__Document_Master__c> docmaster = TestUtility.createDocMasters(1);
        docmaster[0].HexaBPM__Code__c = 'INITIAL_APPROVAL_REJECTION_LETTER';
        insert docmaster;
        
        List<SR_Doc_Running_Number__c> srDocRunNumList = TestClassUtility.createSRDocRunningNumber();
 		insert srDocRunNumList;
        
        List<HexaBPM__SR_Doc__c> srdoc = TestUtility.createDocMasters(1,docmaster[0].Id,createdSRList[0].Id);
        srdoc[0].HexaBPM__Doc_ID__c = id;
        insert srdoc;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        createdstepList[0].HexaBPM__Status__c = status.Id;
        insert createdstepList;     
        
        
        
       
    }
    public static testmethod void TestCC_CID_EmailNotifications(){
       	init();
       	
        Test.startTest();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Customer__c, HexaBPM__SR__r.HexaBPM__Contact__c,HexaBPM__Step__c.Is_Rejected__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        CC_CID_EmailNotifications con = new CC_CID_EmailNotifications();
        con.EvaluateCustomCode(null,lstOfSteps[0]);
        Test.stopTest();
    }
    private static void init2(){
        
        HexaBPM__Status__c status = new HexaBPM__Status__c();
        status.HexaBPM__Rejection__c = false;
        status.HexaBPM__Code__c = 'test';
        insert status;
                  
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        insert createdSRList;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        createdstepList[0].HexaBPM__Status__c = status.Id;
        insert createdstepList;     
        
        
       
    }
    public static testmethod void TestCC_CID_EmailNotifications2(){
       	init2();
        Test.startTest();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Customer__c, HexaBPM__SR__r.HexaBPM__Contact__c,HexaBPM__Step__c.Is_Rejected__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        CC_CID_EmailNotifications con = new CC_CID_EmailNotifications();
        con.EvaluateCustomCode(null,lstOfSteps[0]);
        Test.stopTest();
    }
    
}
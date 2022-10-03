@isTest
public with sharing class AccountTriggerHelperTest {
    
    //insert listSkipWords;
    public List<Account> createdAccountList; 
    public List<HexaBPM__Service_Request__c> createdSRList; 
    
    private void init(){
    createdAccountList = TestClassUtility.createAccounts(2);    
    createdAccountList[0].License_Expiry_Date__c = System.Today();
    insert createdAccountList;
    createdSRList = TestUtility.createSR(1,'Initial_Approval');
    insert createdSRList;
    
    }
    
    public static testmethod void testcase(){
        HexaBPM__SR_Status__c srStatus = new HexaBPM__SR_Status__c();
        srStatus.HexaBPM__Code__c = 'SUBMITTED';
        insert srStatus;
        AccountTriggerHelper.findDuplicate();
        AccountTriggerHelper.removeDuplicate();
        List<Account> createdAccountList = TestClassUtility.createAccounts(1);
        //createdAccountList[0].recordtypeid = recid;
        createdAccountList[0].License_Expiry_Date__c = System.Today();
        
        insert createdAccountList;
        
        Role__c objRole = new Role__c();
        objRole.Status__c  = 'Active';
        objRole.Type__c = 'Authorised Signatory';
        objRole.Subject_Account__c = createdAccountList[0].Id;
        insert objRole;
        
        Business_Activity__c objBusAc = new Business_Activity__c();
        objBusAc.Entity__c = createdAccountList[0].Id;
        objBusAc.Activity_Code__c = '1234';
        insert objBusAc;
        
        Test.startTest();
            createdAccountList[0].Name = 'Test Name 2';
            createdAccountList[0].License_Expiry_Date__c = System.Today().addDays(30);
            createdAccountList[0].Initial_Approval_Flag__c = true;
            update createdAccountList;
        Test.stopTest();
        
    }
    
    public static testmethod void testcase2(){
    
        List<Recordtype> rectype = [SELECT Id FROM Recordtype WHERE SObjectType = 'Notice__c' AND DeveloperName = 'Announcement' LIMIT 1];
        id recid;
        for(RecordType rt : [SELECT Id FROM Recordtype WHERE SObjectType = 'Account' AND (DeveloperName = 'ADGM_Guest' OR DeveloperName = 'ADGM_Registered_Company')])
        {
            recid = rt.id;
        }
        Notice__c objNotice = new Notice__c();
        objNotice.recordtypeId = rectype[0].Id;
        objNotice.Publish__c = true;
        insert objNotice;

        
        Test.startTest();
            List<Account> createdAccountList = TestClassUtility.createAccounts(1);
            createdAccountList[0].recordtypeid = recid;
            insert createdAccountList;
        createdAccountList[0].name = 'Test66637';
        createdAccountList[0].License_Expiry_Date__c = system.Today();
        update createdAccountList;
        Test.stopTest();
        
    }
    
    public static testmethod void test1(){
        List<Recordtype> rcs = [SELECT id from recordtype where sobjecttype = 'Notice__c'];
        AccountTriggerHelper.queryAllNoticeFields(rcs[0].id);
        
        List<Account> createdAccountList1 = TestClassUtility.createAccounts(1);
        insert createdAccountList1;
        AccountTriggerHelper.CreateGeneralAnnouncements(createdAccountList1);
    }
    
    public static testmethod void testDuplicate(){
        /*
        List<Account> createdAccountList = new List<Account>(); 
        createdAccountList = TestClassUtility.createAccounts(2);    
        createdAccountList[0].Name = createdAccountList[0].Name +' Test';
        insert createdAccountList;
        Test.startTest();
            createdAccountList = new List<Account>();
            createdAccountList = TestClassUtility.createAccounts(2);
            createdAccountList[0].Name = createdAccountList[0].Name +' ADGM';
            insert createdAccountList;
        	DuplicateCheck.createExceptionLog('Test', 2, 'Test', 'Test');
        Test.stopTest();
*/
    }//end testDuplicate()
}
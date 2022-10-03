@isTest
public with sharing class Schedule_DeleteInitialApprovalsTest{
    
    public static testmethod void testcase()
    {
        HexaBPM__SR_Status__c objSRStatus = new HexaBPM__SR_Status__c();
        objSRStatus = new HexaBPM__SR_Status__c();
        objSRStatus.Name = 'Submitted';
        objSRStatus.HexaBPM__Code__c = 'SUBMITTED';
        insert objSRStatus;
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].License_Expiry_Date__c  = System.today().addYears(1);
        newAccounts[0].recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM Registered Company').getRecordTypeId();
        insert newAccounts; 

        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].HexaBPM__Internal_SR_Status__c = objSRStatus.Id; 
        createdSRList[0].HexaBPM__External_SR_Status__c = objSRStatus.Id; 
        insert createdSRList;
        
        List<HexaBPM__Service_Request__c> createdSRList1 = TestUtility.createSR(1,'Initial_Approval');
        createdSRList1[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList1[0].HexaBPM__Internal_SR_Status__c = objSRStatus.Id; 
        createdSRList1[0].HexaBPM__External_SR_Status__c = objSRStatus.Id; 
        insert createdSRList1;
        
        system.debug('========='+createdSRList.size());
        Test.startTest();
          Schedule_DeleteInitialApprovals con = new Schedule_DeleteInitialApprovals();
          String sch = '0 0 23 * * ?';
          system.schedule('Test Delete approvals Check', sch, con); 
        Test.stopTest();
    }
}
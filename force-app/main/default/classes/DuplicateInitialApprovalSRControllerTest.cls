@isTest
private class DuplicateInitialApprovalSRControllerTest{

    static testMethod void duplicateTest1(){
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        insert newAccounts; 
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(2,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        insert createdSRList;
        
        
        test.startTest();
            system.currentPageReference().getParameters().put('Id', createdSRList[0].Id);
             ApexPages.StandardController sc = new ApexPages.StandardController(createdSRList[0]);
            DuplicateInitialApprovalSRController dupeCtrlr = new DuplicateInitialApprovalSRController(sc);
            
        test.stopTest();
    }
}
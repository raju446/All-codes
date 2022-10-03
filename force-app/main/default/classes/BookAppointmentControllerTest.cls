@isTest
private class BookAppointmentControllerTest{
    static testmethod void bookAnAppointmenTest(){
        List<Account> createdAccountList = TestClassUtility.createAccounts(1);
        createdAccountList[0].Oracle_Party_Id__c = '0000001';
        insert createdAccountList;
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = createdAccountList[0].Id;
        insert createdSRList;
        
        test.startTest();
            Apexpages.currentPage().getParameters().put('id',createdSRList[0].Id);
            BookAppointmentController bookApptCtrlr = new BookAppointmentController();
        test.stopTest();
    }
}
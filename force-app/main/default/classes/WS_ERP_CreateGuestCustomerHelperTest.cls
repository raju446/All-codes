@isTest
private class WS_ERP_CreateGuestCustomerHelperTest {
    @isTest static void test1(){

        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].Entity_Id__c = '12345';
        insert newAccounts; 
        
        
        User objUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Admin'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
            //UserRoleId = r.Id
        );
        
        insert objUser;
        
        test.startTest();
            system.runAs(objUser){
                // This causes a fake response to be generated
                Test.setMock(WebServiceMock.class, new WS_ERP_CreateGuestCustomerMockTest());
                WS_ERP_CreateGuestCustomerHelper.SendEntityToOracle(newAccounts[0].Id);
            }
        test.stoptest();

        
        
    }
}
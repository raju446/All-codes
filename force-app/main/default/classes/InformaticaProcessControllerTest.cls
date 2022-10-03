@isTest
private class InformaticaProcessControllerTest{
    static testMethod void informaticaProcessTest1(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 
            
        test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(newAccounts[0]);
            system.currentPageReference().getParameters().put('Id', newAccounts[0].Id);
            InformaticaProcessController infoProcess = new InformaticaProcessController(sc);
            infoProcess.InvokeProcess();
        test.stopTest();

    }
    
    static testMethod void informaticaProcessTest2(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        //newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
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
                ApexPages.StandardController sc = new ApexPages.StandardController(newAccounts[0]);
                system.currentPageReference().getParameters().put('Id', newAccounts[0].Id);
                InformaticaProcessController infoProcess = new InformaticaProcessController(sc);
                Test.setMock(WebServiceMock.class, new WS_ERP_CreateGuestCustomerMockTest());
                //infoProcess.InvokeProcess();
                infoProcess.ViewAccount();
            }
        test.stopTest();

    }
}
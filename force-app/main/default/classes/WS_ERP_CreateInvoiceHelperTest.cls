@isTest
private class WS_ERP_CreateInvoiceHelperTest {
    @isTest static void test1(){

        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Permit_Alcohol');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        insert createdSRList;
        
        List<HexaBPM__SR_Price_Item__c> newPriceItems = new List<HexaBPM__SR_Price_Item__c>();
        HexaBPM__SR_Price_Item__c priceItem = new HexaBPM__SR_Price_Item__c();
        priceItem.HexaBPM__Status__c = 'Added';
        priceItem.HexaBPM__ServiceRequest__c = createdSRList[0].Id;
        priceItem.Cost__c = 2000;
        priceItem.Is_Refund_Line__c = true;
        newPriceItems.add(priceItem);
        
        priceItem = new HexaBPM__SR_Price_Item__c();
        priceItem.HexaBPM__Status__c = 'Added';
        priceItem.HexaBPM__ServiceRequest__c = createdSRList[0].Id;
        priceItem.Cost__c = 1000;
        newPriceItems.add(priceItem);
        
        insert newPriceItems;
        
        
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
                Test.setMock(WebServiceMock.class, new WS_ERP_CreateInvoiceMockTest());
                String srIdStr = createdSRList[0].Id;
                WS_ERP_CreateInvoiceHelper.InvokeProcess(srIdStr);
            }
        test.stoptest();

        
        
    }
}
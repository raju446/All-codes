@isTest
private class ReceiptUtilTest {
    @isTest static void test1(){
    	Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '103';
        acc[0].Source_System_Name__c = 'FSRA';
        insert acc;
        
        Receipt__c objReceipt = new Receipt__c(Entity__c = acc[0].Id);
        objReceipt.Status__c = 'Success';
        objReceipt.Payment_Method__c = 'Electronic Funds Transfer';
        insert objReceipt;
        
        
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
                Test.setMock(WebServiceMock.class, new WS_ERP_CreateReceiptMockTest());
                String receiptIdStr = objReceipt.Id;
                //ReceiptUtil.PushReceiptToOracle_New(receiptIdStr);
                //ReceiptUtil.PushReceiptToOracle(receiptIdStr);
                //ReceiptUtil.PushReceiptToOracle_Future(receiptIdStr);
                //ReceiptUtil.PushReceiptToOracle_Future(receiptIdStr);
                //ReceiptUtil.Prod_PushReceiptToOracle(receiptIdStr);
                //ReceiptUtil.Prod_PushReceiptToOracle_Future(receiptIdStr);
            }
        test.stoptest();

        
        
    }
    
    public static testmethod void doTest(){
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '103';
        acc[0].Source_System_Name__c = 'FSRA';
        insert acc;
        
        List<Receipt__c> listReceipt = TestClassUtility.createReceipt(1,acc);
        listReceipt[0].Amount__c = 100;
        listReceipt[0].Status__c = 'Success';
        listReceipt[0].Payment_Method__c = 'Card';
        listReceipt[0].Authorization_Code__c = '123456';
        listReceipt[0].Source_Receipt_Id__c = 'RA-RT-12345';
        listReceipt[0].Description__c = 'testing testing';
        listReceipt[0].Journal_Created__c = true;
        insert listReceipt;
        
        List<Invoice__c> listInvoice = TestClassUtility.createInvoice(1,acc);
        listInvoice[0].Oracle_Invoice_Id__c = '1';
        listInvoice[0].Journal_Created__c = true;
        listInvoice[0].Status__c = 'Success';
        insert listInvoice;
        List<Related_Invoice_Receipt__c> listReceiptInvoice = TestClassUtility.createRelatedInvoiceReceipt(1,listInvoice, listReceipt );
        listReceiptInvoice[0].Direction__c = 'From Receipt To Invoice';
        listReceiptInvoice[0].Amount_Applied__c = 10;
        listReceiptInvoice[0].Applied_Date__c = system.today();
        upsert listReceiptInvoice;
		test.startTest();
        Test.setMock(HttpCalloutMock.class, new ReceiptMockCallout());
        
        //ReceiptUtil.PushReceiptToOracle_New(listReceipt[0].id);
        //ReceiptUtil.PushReceiptToOracle_Future_New(new List<String>{listReceipt[0].id});
        //ReceiptUtil.PushReceiptToOracle(listReceipt[0].id);
        //ReceiptUtil.PushReceiptToOracle_Future(listReceipt[0].id);
        ReceiptUtil.UpdateAmountAndCreateJournalEntries(new List<String>{listReceipt[0].id});
        RelatedInvoiceReceiptTriggerHelper.updateCloseDateErrorJVs(new Set<Related_Invoice_Receipt__c>{listReceiptInvoice[0]});
        test.stopTest();
    }
    
    public static testmethod void testReversal(){
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '103';
        acc[0].Source_System_Name__c = 'FSRA';
        insert acc;
        
        List<Receipt__c> listReceipt = TestClassUtility.createReceipt(1,acc);
        listReceipt[0].Amount__c = 100;
        listReceipt[0].Status__c = 'Success';
        listReceipt[0].Pushed_to_Oracle__c = true;
        listReceipt[0].Payment_Method__c = 'Electronic Funds Transfer';
        insert listReceipt;
        List<Invoice__c> listInvoice = TestClassUtility.createInvoice(1,acc);
        listInvoice[0].Oracle_Invoice_Id__c = '1';
        listInvoice[0].Journal_Created__c = true;
        listInvoice[0].Status__c = 'Success';
        insert listInvoice;
        List<Related_Invoice_Receipt__c> listReceiptInvoice = TestClassUtility.createRelatedInvoiceReceipt(1,listInvoice, listReceipt );
        listReceiptInvoice[0].Direction__c = 'From Receipt To Invoice';
        listReceiptInvoice[0].Amount_Applied__c = 10;
        listReceiptInvoice[0].Applied_Date__c = system.today();
        upsert listReceiptInvoice;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ReceiptMockCallout());
        ReceiptUtil.PushReceiptReversalToOracle(listReceipt[0].Id);
        ReceiptUtil.trimAllValues(new List<String>{'test'});
        Test.stopTest();
    }
}
@isTest
Private class InvoiceUtil_NewTest {
    public static testmethod void doTestInvoice(){
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        insert acc;
        
        List<Receipt__c> listReceipt = TestClassUtility.createReceipt(1,acc);
        listReceipt[0].Amount__c = 100;
        listReceipt[0].Status__c = 'Success';
        listReceipt[0].Receipt_Reference__c = '1';
        listReceipt[0].Payment_Method__c = 'Electronic Funds Transfer';
        insert listReceipt;
        
        List<Invoice__c> listInvoice = TestClassUtility.createInvoice(1,acc);
        listInvoice[0].GL_Date__c = system.today();
        listInvoice[0].Invoice_Date__c = system.today();
        listInvoice[0].Payment_Term__c = 'IMMEDIATE';
        listInvoice[0].Payment_Currency__c = 'USD';
        insert listInvoice;
        listInvoice[0].Status__c='Approved' ;  
        listInvoice[0].Generate_Document__c = true;
        listInvoice[0].Document_Version__c = 0;
        update listInvoice;
        
        List<Invoice_Line_Item__c> listInvoiceLineItem = TestClassUtility.createInvoiceLineItem(1,listInvoice);
        listInvoiceLineItem[0].Revenue_Type__c = 'Corporate Services';
        listInvoiceLineItem[0].Amount__c = 100;
        listInvoiceLineItem[0].Tax_Amount__c = 5;
        insert listInvoiceLineItem;
        List<Related_Invoice_Receipt__c> listReceiptInvoice = TestClassUtility.createRelatedInvoiceReceipt(1,listInvoice, listReceipt );
        listReceiptInvoice[0].Direction__c = 'From Invoice To Receipt';
        listReceiptInvoice[0].Amount_Applied__c = 10;
        listReceiptInvoice[0].Applied_Date__c = system.today();
        upsert listReceiptInvoice;
        
        test.startTest();
        InvoiceUtil_New.checkRevenueType(listInvoice[0]);
        InvoiceUtil_New.updateInvoiceAndCreateJournalEntries_Future(new List<String>{listInvoice[0].Id});
        
        
        InvoiceUtil_New.updateCloseDateErrorJVs(new Set<Invoice__c>{listInvoice[0]});
        test.stopTest();
        
    }

}
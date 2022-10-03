@isTest
public class BalanceHistoryTest{
    
    public static TestMethod void runTest1(){
        
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        insert acc;
        
        List<Receipt__c> listReceipt = TestClassUtility.createReceipt(1,acc);
        listReceipt[0].Amount__c = 100;
        listReceipt[0].Status__c = 'Success';
        listReceipt[0].Receipt_Reference__c = '1';
        listReceipt[0].Payment_Method__c = 'Credit Card';
        listReceipt[0].GL_Date__c = System.today().addDays(-2);
        listReceipt[0].Oracle_Receipt_Id__c = '23231';
        insert listReceipt;
        List<Invoice__c> listInvoice = TestClassUtility.createInvoice(1,acc);
        listInvoice[0].GL_Date__c = System.today().addDays(-2);
        listInvoice[0].Invoice_Date__c = System.today().addDays(-2);
        listInvoice[0].Oracle_Invoice_Id__c = '2354321';
        listInvoice[0].Status__c = 'Approved';
        insert listInvoice;
        
        List<Invoice_Line_Item__c> listInvoiceLineItem = TestClassUtility.createInvoiceLineItem(1,listInvoice);
        insert listInvoiceLineItem;
        
        Id creditMemoRecType = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Credit Memo').getRecordTypeId();
        List<Invoice__c> creditListInvoice = TestClassUtility.createInvoice(1,acc);
        creditListInvoice[0].RecordtypeId = creditMemoRecType;
        creditListInvoice[0].GL_Date__c = System.today().addDays(-2);
        creditListInvoice[0].Invoice_Date__c = System.today().addDays(-2);
        creditListInvoice[0].Oracle_Invoice_Id__c = '2354323';
        creditListInvoice[0].Status__c = 'Approved';
        insert creditListInvoice;
        List<Invoice_Line_Item__c> creditlistInvoiceLineItem = TestClassUtility.createInvoiceLineItem(1,creditListInvoice);
        creditlistInvoiceLineItem[0].GL_Date__c = System.today().addDays(-2);
        creditlistInvoiceLineItem[0].Amount__c = 100;
        insert creditlistInvoiceLineItem;
        
        List<Related_Invoice_Receipt__c> listReceiptInvoice = TestClassUtility.createRelatedInvoiceReceipt(1,listInvoice, listReceipt );
        listReceiptInvoice[0].Direction__c = 'From Invoice To Receipt';
        listReceiptInvoice[0].Amount_Applied__c = 10;
        listReceiptInvoice[0].Applied_Date__c = System.today().addDays(-2);
        upsert listReceiptInvoice;
        Test.startTest();
            BalanceHistoryController.createInvoiceReceiptRecords(System.today().addDays(2));
            /*Financial_Report__c financeReport = new Financial_Report__c(GL_Date__c = system.today());
            INSERT financeReport;
            BalanceHistoryBatch batchController = new BalanceHistoryBatch(System.today(), financeReport);
            Database.executeBatch(batchController, 1);*/
        Test.stopTest();
    }
}
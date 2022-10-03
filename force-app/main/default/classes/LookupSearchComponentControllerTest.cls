@isTest
public class LookupSearchComponentControllerTest {
	public static testmethod void test1(){
        List<Account> createdAccountList = TestClassUtility.createAccounts(1);
        insert createdAccountList;
        
        List<Invoice__c> listInvoice = TestClassUtility.createInvoice(1,createdAccountList);
        listInvoice[0].GL_Date__c = system.today();
        listInvoice[0].Invoice_Date__c = system.today();
        listInvoice[0].oracle_invoice_id__c = '123';
        listInvoice[0].Invoice_Balance__c = 123;
        insert listInvoice;
        
        List<Invoice_Line_Item__c> listInvoiceLineItem = TestClassUtility.createInvoiceLineItem(1,listInvoice);
        insert listInvoiceLineItem;
        
        LookupSearchComponentController.getResults('Invoice__c', 'oracle_invoice_id__c','123' ,'');
    }
}
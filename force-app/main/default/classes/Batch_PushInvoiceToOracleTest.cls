@isTest
public class Batch_PushInvoiceToOracleTest {
    public static testmethod void test1(){
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        insert acc;
        
        List<Invoice__c> listInvoice = TestClassUtility.createInvoice(1,acc);
        listInvoice[0].GL_Date__c = system.today();
        listInvoice[0].Invoice_Date__c = system.today();
        listInvoice[0].Status__c = 'Approved';
        insert listInvoice;
        
        List<Invoice_Line_Item__c> listInvoiceLineItem = TestClassUtility.createInvoiceLineItem(1,listInvoice);
        insert listInvoiceLineItem;
        
        Test.startTest();
        	Batch_PushInvoiceToOracle invoiceSched = new Batch_PushInvoiceToOracle ();
            String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, invoiceSched);
        Test.stopTest();
    }
}
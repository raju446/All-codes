@isTest
public class Batch_PushAdjustmentToOracleTest {
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
        
        List<Invoice_Line_Item__c> listInvoiceLineItem1 = TestClassUtility.createInvoiceLineItem(1,listInvoice);
        listInvoiceLineItem1[0].recordtypeid = Schema.SObjectType.Invoice_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Adjustment').getRecordTypeId();
        listInvoiceLineItem1[0].Activity_Name__c = 'Invoice Cancellation';
        //listInvoiceLineItem1[0].Amount__c = 500.00;
        listInvoiceLineItem1[0].Date_Of_Adjustment__c = Date.today();
        listInvoiceLineItem1[0].Amount__c = 5;
        listInvoiceLineItem1[0].Tax__c = '5%';
        listInvoiceLineItem1[0].Status__c = 'Approved';
        insert listInvoiceLineItem1;
        
        
        Test.startTest();
        	Batch_PushAdjustmentToOracle invoiceSched = new Batch_PushAdjustmentToOracle ();
            String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, invoiceSched);
        Test.stopTest();
    }
}
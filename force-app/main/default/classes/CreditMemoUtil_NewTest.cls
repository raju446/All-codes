@isTest
public class CreditMemoUtil_NewTest {
    public static testmethod void doTest(){
        
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        insert acc;
        List<Invoice__c> listOldInvoice = TestClassUtility.createInvoice(1,acc);
        insert listOldInvoice;
        
        List<Invoice_Line_Item__c> listOldInvoiceLineItem = TestClassUtility.createInvoiceLineItem(1,listOldInvoice);
        insert listOldInvoiceLineItem;
        
        Id creditMemoRecType = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Credit Memo').getRecordTypeId();
        List<Invoice__c> listInvoice = TestClassUtility.createInvoice(1,acc);
        listInvoice[0].RecordtypeId = creditMemoRecType;
        insert listInvoice;
        listInvoice[0].Status__c='Approved' ;  
        listInvoice[0].Generate_Document__c = true;
        listInvoice[0].Document_Version__c = 0;
        update listInvoice;
        List<Invoice_Line_Item__c> listInvoiceLineItem = TestClassUtility.createInvoiceLineItem(1,listInvoice);
        insert listInvoiceLineItem;
        Test.startTest();
        
        CreditMemoUtil_New.updateCreditMemoAndCreateJVsFuture(new List<String>{listInvoice[0].Id});
        
        Test.stopTest();
    }
}
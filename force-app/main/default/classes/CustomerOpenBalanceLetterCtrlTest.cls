@isTest
public class CustomerOpenBalanceLetterCtrlTest {
    public static testmethod void test1(){
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        insert acc;
        
        List<Receipt__c> listReceipt = TestClassUtility.createReceipt(1,acc);
        listReceipt[0].Amount__c = 100;
        listReceipt[0].Status__c = 'Success';
        listReceipt[0].Receipt_Reference__c = '1';
        insert listReceipt;
        List<Invoice__c> listInvoice = TestClassUtility.createInvoice(1,acc);
        listInvoice[0].GL_Date__c = system.today();
        listInvoice[0].Invoice_Date__c = system.today();
        insert listInvoice;
        
        PageReference pageRef = Page.CustomerOpenBalanceLetterPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',acc[0].id);
        CustomerOpenBalanceLetterCtrl obj = new CustomerOpenBalanceLetterCtrl();
        
    }
}
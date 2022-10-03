@isTest
public class UpdateAllInvoicesBatchTest {
    public static testmethod void runTest1(){
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        insert acc;
        
        List<Invoice__c> listInvoice = TestClassUtility.createInvoice(1,acc);
        listInvoice[0].GL_Date__c = system.today();
        listInvoice[0].Invoice_Date__c = system.today();
        insert listInvoice;
        
        Database.executeBatch(new UpdateAllInvoicesBatch(), 1);
    }
}
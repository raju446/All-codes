@isTest
public class UpdateInvoiceReceiptEntityControllerTest {
    public static testmethod void runtest1(){
        Account[] acc = TestClassUtility.createAccounts(2);
        acc[0].Oracle_Party_Id__c = '103';
        acc[0].Source_System_Name__c = 'FSRA';
        
        
        acc[1].Oracle_Party_Id__c = '103';
        acc[1].Source_System_Name__c = 'FSRA';
        insert acc;
        
        Receipt__c objReceipt = new Receipt__c(Entity__c = acc[0].Id);
        objReceipt.Status__c = 'Success';
        insert objReceipt;
        
        Invoice__c invObject = new Invoice__c(Entity__c = acc[0].Id);
        invObject.Status__c = 'Success';
        insert invObject;
        
        UpdateInvoiceReceiptEntityController.getSelectedObjectDetails('Invoice', invObject.Id);
        UpdateInvoiceReceiptEntityController.getSelectedObjectDetails('Receipt', objReceipt.Id);
        UpdateInvoiceReceiptEntityController.updateInvoiceReceiptEntity('Invoice', acc[1].Id, acc[1].Id, 'Test Invoice', acc[1].Name, acc[0].Name);
        UpdateInvoiceReceiptEntityController.updateInvoiceReceiptEntity('Invoice', invObject.Id, acc[1].Id, 'Test Invoice', acc[1].Name, acc[0].Name);
        UpdateInvoiceReceiptEntityController.updateInvoiceReceiptEntity('Receipt', objReceipt.Id, acc[1].Id, 'Test Invoice', acc[1].Name, acc[0].Name);
        UpdateInvoiceReceiptEntityController.fetchAccountDetails(acc[1].Id);
        UpdateInvoiceReceiptEntityController.fetchAccountDetails(objReceipt.Id);
        UpdateInvoiceReceiptEntityController.fetchAccountDetails('1234567890');
    }
}
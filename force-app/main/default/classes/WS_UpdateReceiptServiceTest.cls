@isTest
public class WS_UpdateReceiptServiceTest {
    public static testmethod void test1(){
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '103';
        acc[0].Source_System_Name__c = 'FSRA';
        insert acc;
        
        Receipt__c objReceipt = new Receipt__c(Entity__c = acc[0].Id);
        objReceipt.Status__c = 'Draft';
        objReceipt.Source_Receipt_Id__c = 'abc123';
        insert objReceipt;
      
        
        WS_UpdateReceiptService.ReceiptInformation receiptinfo = new WS_UpdateReceiptService.ReceiptInformation();
        receiptinfo.Receipt_Id = null;
        receiptinfo.Receipt_Payment_Status = 'Payment Verified';
        receiptinfo.Receipt_Status = 'Success';

        test.startTest();
        	WS_UpdateReceiptService.processReceipt(receiptinfo);
        	receiptinfo.Receipt_Id = '12';
        	WS_UpdateReceiptService.processReceipt(receiptinfo);
        test.stopTest();
    }
}
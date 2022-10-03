@isTest
public class WS_FetchReceiptStatusServiceTest {
    public static testmethod void test1(){
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '103';
        acc[0].Source_System_Name__c = 'FSRA';
        insert acc;
        
        Receipt__c objReceipt = new Receipt__c(Entity__c = acc[0].Id);
        objReceipt.Status__c = 'Draft';
        insert objReceipt;
        
        test.startTest();
        	WS_FetchReceiptStatusService.fetchReceiptSts(null);
        	WS_FetchReceiptStatusService.fetchReceiptSts('null');
        	objReceipt.Source_Receipt_Id__c = 'abc123';
        	update objReceipt;
        	WS_FetchReceiptStatusService.fetchReceiptSts('abc123');
        test.stopTest();
    }
}
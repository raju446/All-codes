@isTest
public class ReceiptReversalControllerTest {
    public static testmethod void doTest(){
        List<Account> accs = TestClassUtility.createAccounts(1);
        insert accs;
        List<Receipt__c> receipts = TestClassUtility.createReceipt(1, accs);
        receipts[0].Gl_date__c = date.today();
        receipts[0].Payment_Method__c = 'Electronic Funds Transfer';
        insert receipts;
        
        Test.startTest();
        	ReceiptReversalController.getReceiptDetails(receipts[0].id);
        	ReceiptReversalController.pushReceiptToOracle(receipts[0].Id);
        Test.stopTest();
    }
}
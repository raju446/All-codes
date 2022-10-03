@isTest
public class ReceiptViewControllerTest {

	@isTest
    public static void runTest(){
        
        List<Account> accs = TestClassUtility.createAccounts(1);
        insert accs;
        List<Receipt__c> receipts = TestClassUtility.createReceipt(2, accs);
        receipts[0].Gl_date__c = date.today();
        receipts[0].Payment_Method__c = 'Credit Card';
        receipts[0].Transaction_Reference__c = 'TRTEST123';
        receipts[1].Gl_date__c = date.today();
        receipts[1].Payment_Method__c = 'Credit Card';
        receipts[1].Transaction_Reference__c = 'TRTEST1234';
        insert receipts;
        ApexPages.currentpage().getParameters().put('Id',receipts[0].id);
        ReceiptViewController controller = new ReceiptViewController();
        controller.checkAccessibility();
    }
}
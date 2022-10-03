@isTest
public class Batch_PushRefundToOracleTest {
    public static testmethod void test1(){
        List<Account> accs = TestClassUtility.createAccounts(1);
        insert accs;
        List<Receipt__c> receipts = TestClassUtility.createReceipt(1, accs);
        receipts[0].Gl_date__c = date.today();
        insert receipts;
        List<Refund__c> refunds = TestClassUtility.createRefund(1,accs,receipts);
        refunds[0].Amount__c = 100.00;
        refunds[0].Status__c = 'Approved';
        insert refunds;
        
        Test.startTest();
        	Batch_PushRefundToOracle invoiceSched = new Batch_PushRefundToOracle();
            String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, invoiceSched);
        Test.stopTest();
    }
}
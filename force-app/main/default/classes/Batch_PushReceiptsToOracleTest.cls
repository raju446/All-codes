@isTest
public class Batch_PushReceiptsToOracleTest
{
    public static testmethod void Batch_PushReceiptsToOracle(){
        List<Account> accs = TestClassUtility.createAccounts(1);
        insert accs;
        List<Receipt__c> receipts = TestClassUtility.createReceipt(1, accs);
        receipts[0].Gl_date__c = date.today();
        receipts[0].Payment_Method__c = 'Electronic Funds Transfer';
        insert receipts;
        Test.startTest();
          Database.executeBatch(new Batch_PushReceiptsToOracle());
        Test.stopTest();
    }
}
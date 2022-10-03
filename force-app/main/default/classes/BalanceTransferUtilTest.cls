/*
    Author      : Jayanta Karmakar
    Date        : 1-July-2020
    Description : Test class for BalanceTransferUtil class. Mock Class name : BalanceTransferUtilMock
    ------------------------------------------------------------------
*/
@isTest
public class BalanceTransferUtilTest {
    public static testmethod void btMethod1(){
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
        List<Fund_Transfer__c> fts = TestClassUtility.createFundTransfer(1,accs,accs);
        fts[0].Reference_Receipt__c = receipts[0].Id;
        fts[0].to_receipt__c = receipts[1].Id;
        insert fts;
        
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new BalanceTransferUtilMock());
        	BalanceTransferUtil.pushFundTransferToOracleFuture(new List<String>{fts[0].Id});
        	BalanceTransferUtil.updateReceiptAndCreateJournalEntriesFuture(new List<String>{fts[0].Id});
        
        Test.stopTest();
    } 
    
    public static testmethod void btMethod2(){
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
        List<Fund_Transfer__c> fts = TestClassUtility.createFundTransfer(1,accs,accs);
        fts[0].Reference_Receipt__c = receipts[0].Id;
        insert fts;
        
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new BalanceTransferUtilMock());
        	BalanceTransferUtil.pushFundTransferToOracleFuture(new List<String>{fts[0].Id});
        
        Test.stopTest();
    } 
}
@isTest
public class RefundTriggerHandlerTest {
    public static testmethod void doTest(){
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        insert acc;
        List<Receipt__c> listReceipt = TestClassUtility.createReceipt(1,acc);
        listReceipt[0].Payment_Method__c = 'Electronic Funds Transfer';
        insert listReceipt;
        List<Refund__c> listRefund = TestClassUtility.createRefund(1, acc, listReceipt);
        insert listRefund;
        
        listRefund[0].Generate_Document__c = true;
        listRefund[0].Document_Version__c = 1;
        listRefund[0].Status__c = 'Approved';
        listRefund[0].Journal_Created__c=false;
        listRefund[0].Payment_Method__c='Credit Card';
        //listRefund[0].Scenario__c='Credit Memo';
        //listRefund[0].Amount__c=100;
        update listRefund;
    }
}
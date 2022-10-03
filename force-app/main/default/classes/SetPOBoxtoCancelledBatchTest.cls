@isTest
public with sharing class SetPOBoxtoCancelledBatchTest {
    private static PO_Box__c pobox;
    private static List<Account> createdAccountList; 
    private static void init(){
    	pobox = new PO_Box__c();
        pobox.Status__c = 'Available';
        pobox.Start_Date__c = system.today();
        pobox.Expiry_Date__c = system.today().addDays(-30);
        pobox.Cancelled_Date__c = system.today();
        pobox.Type__c = 'EziMAIL Bronze';
        insert pobox;
        createdAccountList = TestClassUtility.createAccounts(1);
        createdAccountList[0].PO_Box__c = pobox.Id;
        insert createdAccountList;
    }
    public static testmethod void testcase(){
        init();
        Test.startTest();
        
        SetPOBoxtoCancelledBatch con = new SetPOBoxtoCancelledBatch();
        DataBase.executeBatch(con);
             
        Test.stopTest();
        
    }
}
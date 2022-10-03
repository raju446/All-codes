@isTest
public class Batch_PushFundTransferToOracleTest {
    public static testmethod void test1(){
        Account[] fromAcc = TestClassUtility.createAccounts(1);
        fromAcc[0].Oracle_Party_Id__c = '123';
        fromAcc[0].Source_System_Name__c = 'FSRA';
        fromAcc[0].Name = 'FSRA';
      //  fromAcc[0].recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM FSRA').getRecordTypeId();
        insert fromAcc;
        
        Account[] toAcc = TestClassUtility.createAccounts(1);
        toAcc[0].Oracle_Party_Id__c = '456';
        toAcc[0].Source_System_Name__c = 'Academy';
        toAcc[0].Name = 'Academy';
        //toAcc[0].recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM Academy').getRecordTypeId();
        insert toAcc;
        List<Fund_Transfer__c> listFundTransfer = TestClassUtility.createFundTransfer(1, fromAcc, toAcc);
        listFundTransfer[0].Status__c = 'Approved';
        insert listFundTransfer;
        
        Test.startTest();
        	Batch_PushFundTransferToOracle invoiceSched = new Batch_PushFundTransferToOracle();
            String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, invoiceSched);
        Test.stopTest();
    }
}
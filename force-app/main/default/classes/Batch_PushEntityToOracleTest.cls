@isTest
public class Batch_PushEntityToOracleTest {
    public static testmethod void test1(){
        Account[] fromAcc = TestClassUtility.createAccounts(1);
        fromAcc[0].Source_System_Name__c = 'FSRA';
        fromAcc[0].Name = 'FSRA';
      //  fromAcc[0].recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM FSRA').getRecordTypeId();
        insert fromAcc;
        
        Test.startTest();
        	Batch_PushEntityToOracle invoiceSched = new Batch_PushEntityToOracle();
            String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, invoiceSched);
        Test.stopTest();
    }
}
@isTest
public class AddressTriggerHandlerTest {
    public static testmethod void test1(){
         Account[] acc = TestClassUtility.createAccounts(1);
        //acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        insert acc;

        List<Address__c> listAddress = TestClassUtility.createAddress(1,acc);
        listAddress[0].Type__c = 'Physical';
        listAddress[0].Country__c = 'India';
        insert listAddress;
        
        listAddress[0].Country__c = 'Oman';
        update listAddress;
    }
}
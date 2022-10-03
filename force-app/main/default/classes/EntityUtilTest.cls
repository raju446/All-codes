/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class EntityUtilTest {
    public static testmethod void doTestWithoutAddress(){
        Account[] acc = TestClassUtility.createAccounts(1);
       // acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        insert acc;
        Test.setMock(HttpCalloutMock.class, new EntityMockCallout());
        Test.startTest();

        EntityUtil.PushEntityToOracle(string.valueof(acc[0].id), false);
        EntityUtil.PushEntityToOracle_Future(new List<String>{string.valueof(acc[0].id)});
        Test.stopTest();

    }
    
    public static testmethod void doTestWithAddress(){
        Account[] acc = TestClassUtility.createAccounts(1);
        //acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        insert acc;
        List<Address__c> listAddress = TestClassUtility.createAddress(1,acc);
        listAddress[0].Type__c = 'Physical';
        insert listAddress;
        Test.setMock(HttpCalloutMock.class, new EntityMockCallout());
        Test.startTest();

        EntityUtil.PushEntityToOracle(string.valueof(acc[0].id), false);
        EntityUtil.PushEntityToOracle_Future(new List<String>{string.valueof(acc[0].id)});
        Test.stopTest();

    }
}
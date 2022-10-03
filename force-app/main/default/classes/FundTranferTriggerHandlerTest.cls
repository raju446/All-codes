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
public class FundTranferTriggerHandlerTest {
    public static testmethod void doTest(){
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
        insert listFundTransfer;
        
        update listFundTransfer;
        
        FundTranferTriggerHandler.updateCloseDateErrorJVs(new Set<Fund_Transfer__c>{listFundTransfer[0]});
        
    }
}
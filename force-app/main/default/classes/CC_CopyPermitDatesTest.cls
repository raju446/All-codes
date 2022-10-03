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
private class CC_CopyPermitDatesTest {

    static testMethod void myUnitTest() {
        list<Account> createdAccountList = TestClassUtility.createAccounts(1);
        createdAccountList[0].Oracle_Party_Id__c = '0000001';
        insert createdAccountList;
        
        list<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Permit_Sales_and_Promotion');
        createdSRList[0].HexaBPM__Customer__c = createdAccountList[0].Id;
        createdSRList[0].License_Number__c = '12345';
        createdSRList[0].Start_Date__c = system.today();
        createdSRList[0].End_Date__c = system.today().adddays(2);
        insert createdSRList;
        
        List<HexaBPM__Step__c>  createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList;     
        
        test.startTest();
            CC_CopyPermitDates conCC = new CC_CopyPermitDates();
            List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Customer__c, HexaBPM__SR__r.Start_Date__c, HexaBPM__SR__r.End_Date__c, HexaBPM__SR__r.Valid_From__c, HexaBPM__SR__r.Valid_To__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
            conCC.EvaluateCustomCode(null,lstOfSteps[0]);
        test.stopTest();
    }
}
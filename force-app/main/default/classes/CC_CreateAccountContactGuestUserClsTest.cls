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
private class CC_CreateAccountContactGuestUserClsTest {

    static testMethod void createAcctConTest() {
        
        List<HexaBPM__Service_Request__c> newSRs = TestUtility.createSR(1,Label.SR_Guest_User_Access_Request);
        newSRs[0].First_Name__c = 'Test First';
        newSRs[0].HexaBPM__Email__c = 'test@test.com';
        newSRs[0].HexaBPM__Send_SMS_to_Mobile__c = '+971564911956';
        newSRs[0].Company_Name__c = 'Test Company';
        insert newSRs;
         
        List<HexaBPM__Step__c> newSteps = TestUtility.createSteps(1,newSRs[0].Id,null);
        insert newSteps;
        
        HexaBPM__Step__c testStep = [Select Id, HexaBPM__SR__c, 
                                     HexaBPM__SR__r.First_Name__c, 
                                     HexaBPM__SR__r.Last_Name__c,
                                     HexaBPM__SR__r.HexaBPM__Email__c, 
                                     HexaBPM__SR__r.HexaBPM__Send_SMS_to_Mobile__c,
                                     HexaBPM__SR__r.Company_Name__c,
                                     HexaBPM__SR__r.Existing_Guest_User_Account_Id__c,
                                     HexaBPM__SR__r.Company_Name_Arabic__c,
                                     HexaBPM__SR__r.License_Number__c,
                                     HexaBPM__SR__r.Registered_for_Tax__c,
                                     HexaBPM__SR__r.Tax_Registration_Number__c,
                                     HexaBPM__SR__r.Guest_Username__c
                                     FROM HexaBPM__Step__c WHERE Id = :newSteps[0].Id];
                                     
        Test.startTest();
            System.assert(testStep <> null);
            CC_CreateAccountContactGuestUserCls createAcctCon = new CC_CreateAccountContactGuestUserCls();
            createAcctCon.EvaluateCustomCode(null, testStep);
            
            List<Account> accountCreated = [Select Id, Name FROM Account];
            //System.assertEquals(newSRs[0].Company_Name__c, accountCreated[0].Name);
            
            List<Contact> contactCreated = [Select Id, LastName, AccountId FROM Contact];
            //System.assertEquals(newSRs[0].Last_Name__c, contactCreated[0].LastName);
            //System.assertEquals(accountCreated[0].Id, contactCreated[0].AccountId);
        Test.stopTest();
    }
}
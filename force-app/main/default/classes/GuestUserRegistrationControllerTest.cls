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
private class GuestUserRegistrationControllerTest {

    private static List<HexaBPM__Service_Request__c> createdSRList; 
    
    static testmethod void guestRegistrationCancel(){
        Test.startTest();
            GuestUserRegistrationController regCtrlr = new GuestUserRegistrationController();
            regCtrlr.cancelReg();
        Test.stopTest();
    }
    
    static testmethod void guestRegistrationCheckValidation(){
        
        HexaBPM__SR_Status__c submitStatus = new HexaBPM__SR_Status__c();
        submitStatus.Name = 'Submitted';
        submitStatus.HexaBPM__Code__c = 'SUBMITTED';
        insert submitStatus;
        
        Test.startTest();
            GuestUserRegistrationController regCtrlr = new GuestUserRegistrationController();
            regCtrlr.SubmitSR();
        
            regCtrlr.objSR.Title__c = 'Mr.';
            regCtrlr.objSR.First_Name__c = 'FirstName';
            regCtrlr.objSR.Last_Name__c = 'LastName';
            regCtrlr.objSR.Date_of_Birth__c = System.Today();
            regCtrlr.objSR.HexaBPM__Email__c = 'test001@test.com';
            regCtrlr.objSR.HexaBPM__Send_SMS_to_Mobile__c = '0564312431432';
            regCtrlr.objSR.Company_Name__c = 'Test Company Name';
            regCtrlr.SubmitSR();
        
            regCtrlr.objSR.Date_of_Birth__c = Date.newInstance(1980, 1, 1); 
            regCtrlr.guestUsername = '';
            regCtrlr.checkUName();
            regCtrlr.SubmitSR();
            
        Test.stopTest();
    }
    
    static testmethod void guestRegistrationExistingUser(){
        
        HexaBPM__SR_Status__c submitStatus = new HexaBPM__SR_Status__c();
        submitStatus.Name = 'Submitted';
        submitStatus.HexaBPM__Code__c = 'SUBMITTED';
        insert submitStatus;
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Name = 'Test Company Name'; 
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].FirstName = 'FirstName';
        newContacts[0].LastName = 'LastName';
        newContacts[0].Community_Username__c = 'firstname.lastname@adgm.portal';
        newContacts[0].Portal_User_Creation__c = true;
        insert newContacts; 
        
        Test.startTest();
            GuestUserRegistrationController regCtrlr = new GuestUserRegistrationController();
        
            regCtrlr.objSR.Title__c = 'Mr.';
            regCtrlr.objSR.First_Name__c = 'FirstName';
            regCtrlr.objSR.Last_Name__c = 'LastName';
            regCtrlr.objSR.Date_of_Birth__c = System.Today();
            regCtrlr.objSR.HexaBPM__Email__c = 'testemail1@test.com';
            regCtrlr.objSR.Date_of_Birth__c = Date.newInstance(1980, 1, 1); 
            regCtrlr.objSR.Company_Name__c = 'Test Company Name';
            regCtrlr.objSR.Nationality__c = 'United Arab Emirates';
            regCtrlr.objSR.Passport_Number__c = '0123456789';
            regCtrlr.objSR.Passport_Issue_Date__c = System.Today().addDays(-30);
            regCtrlr.objSR.Passport_Expiry_Date__c = System.Today().addDays(200);
            regCtrlr.guestUsername = 'firstname.lastname';
            regCtrlr.checkUName();
            regCtrlr.SubmitSR();
            
        Test.stopTest();
    }
    
    static testmethod void guestRegistrationSubmit(){
        
        /*List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '0000001';
        insert newAccounts; 
        
        createdSRList = TestUtility.createSR(1,'Report_Absconding_Employee');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].Guest_Username__c = 'test'; 
        insert createdSRList;*/
        
        HexaBPM__SR_Status__c submitStatus = new HexaBPM__SR_Status__c();
        submitStatus.Name = 'Submitted';
        submitStatus.HexaBPM__Code__c = 'SUBMITTED';
        insert submitStatus;
        
        HexaBPM__Status__c approvedStatus = new HexaBPM__Status__c();
        approvedStatus.Name = 'Approved';
        approvedStatus.HexaBPM__Code__c = 'APPROVED';
        approvedStatus.HexaBPM__Type__c = 'End';
        insert approvedStatus;
        
        HexaBPM__SR_Status__c approvedSRStatus = new HexaBPM__SR_Status__c();
        approvedSRStatus.Name = 'Approved';
        approvedSRStatus.HexaBPM__Code__c = 'APPROVED';
        approvedStatus.HexaBPM__Type__c = 'End';
        insert approvedSRStatus;
        
        Test.startTest();
            GuestUserRegistrationController regCtrlr = new GuestUserRegistrationController();
            regCtrlr.SubmitSR();
        
            regCtrlr.objSR.Title__c = 'Mr.';
            regCtrlr.objSR.First_Name__c = 'FirstName';
            regCtrlr.objSR.Last_Name__c = 'LastName';
            regCtrlr.objSR.Date_of_Birth__c = System.Today().addYears(-20);
            regCtrlr.objSR.HexaBPM__Email__c = 'test001@test.com';
            regCtrlr.objSR.HexaBPM__Send_SMS_to_Mobile__c = '+971563883829';
            regCtrlr.objSR.Company_Name__c = 'Test Company Name';
            regCtrlr.objSR.I_Agree__c = true;
            regCtrlr.guestUsername = 'firstname.lastname';
            regCtrlr.checkUName();
            regCtrlr.SubmitSR();
        
            System.debug('@@ACTION: '+[SELECT Id, HexaBPM__Status__c FROM HexaBPM__Step__c WHERE HexaBPM__SR__c =:regCtrlr.objSR.Id]);
        Test.stopTest();
    }
}
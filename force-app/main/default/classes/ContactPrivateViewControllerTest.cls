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
public class ContactPrivateViewControllerTest {
    static testMethod void contactPrivateViewTest() {
        // Create Account
        List<Account> newAccounts = TestClassUtility.createAccounts(2);
        newAccounts[1].Is_ADGM_Company__c = true;
        insert newAccounts;
        // Create Contact
        List<Contact> newContacts = TestClassUtility.createContacts(2, newAccounts[0].Id);
        newContacts[1].AccountId = newAccounts[1].id;
        newContacts[1].CRM_Private__c = true;
        insert newContacts; 
        Test.startTest();
        ContactPrivateViewController.checkContactPrivate(String.valueOf(newContacts[0].id));
        ContactPrivateViewController.checkContactPrivate(String.valueOf(newContacts[1].id));
        Test.stopTest();
    }
    
}
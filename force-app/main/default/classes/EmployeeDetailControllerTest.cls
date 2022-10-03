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
public class EmployeeDetailControllerTest {
    static testMethod void employeeDetailTest() {
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts;
        List<Contact> newContacts = TestClassUtility.createContacts(3, newAccounts[0].Id);
        
        newContacts[0].Employment_Status__c = 'Active';
        newContacts[1].Employment_Status__c = 'Cancelled';
        newContacts[2].Portal_User_Creation__c = true;
        newContacts[2].Community_Username__c = 'test1++@adgm.portal';        
        insert newContacts; 
        
        List<Transferred_Employees__c> listTransferredEmployees = TestClassUtility.createTransferredEmployees(3, newAccounts);
        insert listTransferredEmployees; 


        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[2].Id];
        Role__c role = new Role__c();
        role.Subject_Account__c = newAccounts[0].Id;
        role.Object_Contact__c = newContacts[0].Id;
        role.Type__c = 'Authorized Signatory';
        role.Status__c = 'Active';
        insert role;
        system.runAs(portalUser){
            PageReference myVfPage = Page.EmployeeDetails;
            Test.setCurrentPage(myVfPage);
            
            // Put Id into the current page Parameters
            ApexPages.currentPage().getParameters().put('id',newAccounts[0].id);
            EmployeeDetailController objEmployeeDetailController = new EmployeeDetailController();
            List<EmployeeDetailController.ExcelData> listEmployeeData = objEmployeeDetailController.getEmployeeDetails();
            objEmployeeDetailController.getTransferredEmployeeDetails();
        }
    }
}
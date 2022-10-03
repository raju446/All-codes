@isTest
public with sharing class CompanyProfileControllerTest {
    
    public static testmethod void TestCompanyProfileController(){
        //init();
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        
        newContacts[0].Community_Username__c = 'test1++@adgm.portal';
        insert newContacts;  
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        Role__c role = new Role__c();
        role.Subject_Account__c = newAccounts[0].Id;
        role.Object_Contact__c = newContacts[0].Id;
        role.Type__c = 'Authorized Signatory';
        role.Status__c = 'Active';
        insert role;
        system.runAs(portalUser){
            
            CompanyProfileController cic = new CompanyProfileController(new ApexPages.StandardController(portalUser));  
            cic.searchValue = 'Test';
            cic.getPOBoxes();
            cic.getPOBoxTotalPages();
            
            //cic.getSignatory();
            cic.searchEmployees();
            cic.getEmployees();
            cic.getEmpTotalPages();
            //cic.getSignatoryTotalPages();
            cic.searchValue=newContacts[0].Firstname;
            
            cic.getCancelledEmployees();
            cic.getCETotalPages();
            
            cic.getTeEmployees();
            cic.getTeTotalPages();
            cic.exportEmpData();
        }
        
    } 
    
}
@isTest
public class LeadControllerTest {
    
    static Lead testLead = new Lead(); 
    
    static testMethod void LeadController_Test(){
           
        testLead.Company = 'Test Company 501';
        testLead.License_Number__c = 'Test-501';
        testLead.FirstName = 'Primary';
        testLead.LastName = '501';
        testLead.email = 'primary@501.com';
        testLead.Received_Consent__c = 'Business Card';
        testLead.Received_Consent_Date__c = date.today();
        testLead.Role__c ='CEO';
        testLead.LeadSource = 'BD/FCD Direct Approach';
        testLead.Status = 'New';
        testLead.Category__c = 'Financial';
        testLead.Main_Sector__c = 'Banking';
        testLead.Industry = 'Commerce';
        testLead.Country = 'Pakistan';
        testLead.City = 'Lahore';
        testLead.Lead_City__c = 'Lahore';
        testLead.Lead_Country__c = 'Pakistan';
        //testLead.First_Contact_Date__c = date.today();
        //testLead.Last_Contact_Date__c = date.today();
        testLead.PostalCode = '38000';
        testLead.Website = 'test501.com';
        
        insert testLead;
        
        // runs LeadController.getUserInfo();
        User testUser = LeadController.getUserInfo();
        
        // runs LeadController.getUserLead();
        LeadController.getUserLead(testLead.Id);
        // runs LeadController.getRecordTypeId(); - incomplete
       
    }
       
}
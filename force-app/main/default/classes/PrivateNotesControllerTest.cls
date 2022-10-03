@isTest
public class PrivateNotesControllerTest {

    static testMethod void PrivateNotesControllerTest(){
        
        Lead testLead = new Lead();
        
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
        testLead.First_Contact_Date__c = date.today();
        testLead.Last_Contact_Date__c = date.today();
        testLead.PostalCode = '38000';
        testLead.Website = 'test501.com';
        insert testLead;
        
       Note__c tmpNote = new Note__c();
       tmpNote.Lead__c = testLead.Id;
       tmpNote.Share_Note_With__c = 'None';
       tmpNote.Private__c = true;
       tmpNote.Notes__c = ' Test class private note';

       insert tmpNote;
       
       apexpages.currentPage().getParameters().put('Id', testLead.Id);
       ApexPages.StandardController sc = new ApexPages.StandardController(tmpNote);      
       PrivateNotesController pnc = new PrivateNotesController(sc);
       
       
     
    }
}
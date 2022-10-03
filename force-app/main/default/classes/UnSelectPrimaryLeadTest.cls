@isTest
public class UnSelectPrimaryLeadTest {

    public static testMethod void UnSelectPrimaryLeadTest(){
        
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
        
        Lead testContact1 = new Lead();
        
        Id RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead Contact').getRecordTypeId();
        testContact1.RecordTypeId = RecordTypeId;
        testContact1.FirstName = 'Secondary';
        testContact1.LastName = '11';
        testContact1.Email = 'secondary11@501.com';
        testContact1.Role__c = 'Partner';
        testContact1.Received_Consent__c = 'Email';
        testContact1.Received_Consent_Date__c = date.today().toStartOfMonth();
        testContact1.Country = 'Pakistan';
        testContact1.city = 'Lahore';
        testContact1.Lead_City__c = 'Lahore';
        testContact1.Lead_Country__c = 'Pakistan';
        testContact1.Country_Code__c = '+1';
        testContact1.Primary_Phone_Number_1__c = '+987654321234';
        testContact1.Related_Lead_Entity__c = testLead.Id;
        testContact1.Company = testLead.Company;
        insert testContact1;
        
        Lead testContact = new Lead();
        
        testContact.RecordTypeId = RecordTypeId;
        testContact.FirstName = 'Secondary';
        testContact.LastName = '1';
        testContact.Email = 'secondary1@501.com';
        testContact.Role__c = 'Partner';
        testContact.Received_Consent__c = 'Email';
        testContact.Received_Consent_Date__c = date.today().toStartOfMonth();
        testContact.Country = 'Pakistan';
        testContact.city = 'Lahore';
        testContact.Lead_City__c = 'Lahore';
        testContact.Lead_Country__c = 'Pakistan';
        testContact.Country_Code__c = '+1';
        testContact.Primary_Phone_Number_1__c = '+987654321234567890';
        testContact.Related_Lead_Entity__c = testLead.Id;
        testContact.Company = testLead.Company;
        
        insert testContact;
        testContact.Primary__c = True ;
        update testContact;

        list<id> lstleadId = new list<id>();
        lstleadId.add(testLead.id);
        lstleadId.add(testContact1.id);
        UnSelectPrimaryLead.updateLead(lstleadId);
        
    }
    
}
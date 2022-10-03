@isTest
public class REST_FSRA_LeadsTest {
    public static testmethod void test1(){

     	Lead testLead = new Lead(recordtypeid = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead Contact').getRecordTypeId());
        testLead.Company = 'Test Company 50123';
        testLead.License_Number__c = 'Test-501';
        testLead.FirstName = 'Primary test';
        testLead.LastName = '501';
        testLead.email = 'primary@501.com';
        testLead.Received_Consent__c = 'Business Card';
        testLead.Received_Consent_Date__c = date.today();
        testLead.Role__c ='CEO';
        testLead.LeadSource = 'BD/FCD Direct Approach';
        testLead.Status = 'Evaluating';
        testLead.Category__c = 'Financial';
        testLead.Main_Sector__c = 'Banking';
        testLead.Industry = 'Commerce';
        testLead.Country = 'Pakistan';
        testLead.City = 'Lahore';
        testLead.Lead_City__c = 'Lahore';
        testLead.Lead_Country__c = 'Pakistan';
        testLead.PostalCode = '38000';
        testLead.Website = 'test501.com';
        
        insert testLead;
        
        Lead testLead1 = new Lead(recordtypeid = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Lead_Entity').getRecordTypeId());
        testLead1.Company = 'Test Company 50123';
        testLead1.License_Number__c = 'Test-501';
        testLead1.FirstName = 'Primary test';
        testLead1.LastName = '501';
        testLead1.email = 'primary@501.com';
        testLead1.Received_Consent__c = 'Business Card';
        testLead1.Received_Consent_Date__c = date.today();
        testLead1.Role__c ='CEO';
        testLead1.LeadSource = 'BD/FCD Direct Approach';
        testLead1.Status = 'Evaluating';
        testLead1.Category__c = 'Financial';
        testLead1.Main_Sector__c = 'Banking';
        testLead1.Industry = 'Commerce';
        testLead1.Country = 'Pakistan';
        testLead1.City = 'Lahore';
        testLead1.Lead_City__c = 'Lahore';
        testLead1.Lead_Country__c = 'Pakistan';
        testLead1.PostalCode = '38000';
        testLead1.Website = 'test501.com';
        
        insert testLead1;
        
        
        REST_FSRA_Leads.RequestDetails reqObj = new REST_FSRA_Leads.RequestDetails();
        //reqObj.LeadContacts = new List<Lead>();
        //reqObj.LeadContacts.add(testLead);
        reqObj.LeadEntity = testLead1;
        
        Test.startTest();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/REST_FSRA_Leads';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueof(JSON.serialize(reqObj));
            RestContext.request = req;
            RestContext.response= res;
            
            REST_FSRA_Leads.ProcessLeadData();
        Test.stopTest();
    }
}
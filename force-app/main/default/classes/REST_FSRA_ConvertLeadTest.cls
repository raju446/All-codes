@isTest
public class REST_FSRA_ConvertLeadTest {
    public static testmethod void test1(){
        Lead testLead = new Lead();
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
        //testLead.First_Contact_Date__c = date.today();
        //testLead.Last_Contact_Date__c = date.today();
        testLead.PostalCode = '38000';
        testLead.Website = 'test501.com';
        
        insert testLead;
        
        REST_FSRA_ConvertLead.RequestDetails reqObj = new REST_FSRA_ConvertLead.RequestDetails();
        reqObj.LeadId = testLead.id;
        
        Test.startTest();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/REST_FSRA_ConvertLead';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueof(JSON.serialize(reqObj));
            RestContext.request = req;
            RestContext.response= res;
            
            REST_FSRA_ConvertLead.ConvertLead();
            
            reqObj.LeadId = '0000';
            req.requestBody = Blob.valueof(JSON.serialize(reqObj));
            RestContext.request = req;
            REST_FSRA_ConvertLead.ConvertLead();
        Test.stopTest();
    }
}
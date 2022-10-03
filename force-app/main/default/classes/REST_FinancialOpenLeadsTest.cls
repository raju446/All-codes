@isTest
public class REST_FinancialOpenLeadsTest {
	public static testmethod void test1(){
     	REST_FinancialOpenLeads.searchWrapper wrap = new REST_FinancialOpenLeads.searchWrapper();
        wrap.companyName ='test';
        wrap.leadEmail = 'test@test.com';
        wrap.leadSector = 'test';
        wrap.leadSource = 'source';
        wrap.leadStatus = 'New';
        
        Test.startTest();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/REST_FinancialOpenLeads';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueof(JSON.serialize(wrap));
            RestContext.request = req;
            RestContext.response= res;
            
            REST_FinancialOpenLeads.SearchLeads();
        Test.stopTest();
    }
}
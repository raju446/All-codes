/******************************************************************************************
    Author      : Naman Sharma
    Date        : 6-Sept-2021
    Description : Test Class for REST_FSRA_EntityDetailsUpdate
	History:
	19-Sept-'21: Naman - No need to provide Activity and Sub-Activity value
 *******************************************************************************************/
@isTest
public class REST_FSRA_EntityDetailsUpdateTest {
    public static testmethod void test1(){
        Account acct = new Account(Name='Test Account');
        insert acct;
        
        REST_FSRA_EntityDetailsUpdate.RequestDetails reqDetails = new REST_FSRA_EntityDetailsUpdate.RequestDetails();
        reqDetails.CRMRecordId = '123';
        
        Test.startTest();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/REST_FSRA_EntityDetailsUpdate';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JSON.serialize(reqDetails));
        RestContext.request = req;
        RestContext.response= res;
        
        REST_FSRA_EntityDetailsUpdate.UpdateEntityDetails();
        
        reqDetails.CRMRecordId = acct.Id;
        //reqDetails.ActivityValue = 'Test';
        reqDetails.FSRADivisionValue = 'Test';
        reqDetails.SectorValue = 'Test';
        //reqDetails.SubActivityValue = 'Test';
        
        req.requestBody = Blob.valueof(JSON.serialize(reqDetails));
        RestContext.request = req;
        RestContext.response= res;
        
        REST_FSRA_EntityDetailsUpdate.UpdateEntityDetails();
        
        REST_FSRA_EntityDetailsUpdate.ResponseDetails resp = new REST_FSRA_EntityDetailsUpdate.ResponseDetails();
        resp = REST_FSRA_EntityDetailsUpdate.errorWrap(resp, false, '500', 'test', 'stackTrace');
        
        Test.stopTest();
    }
    

}
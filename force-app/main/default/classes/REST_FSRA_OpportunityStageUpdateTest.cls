@isTest
public class REST_FSRA_OpportunityStageUpdateTest {
    public static testmethod void test1(){
        Account acct = new Account(Name='Test Account', From_FSRA__c=true);
        insert acct;
        Opportunity opp = new Opportunity(Name='Test Opportunity',
                                       StageName='Pre-Application',
                                       CloseDate=System.today().addMonths(2),
                                       recordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId(),
                                       AccountId=acct.Id);
        insert opp;
        
        REST_FSRA_OpportunityStageUpdate.RequestDetails reqObj = new REST_FSRA_OpportunityStageUpdate.RequestDetails();
        reqObj.OpportunityId = 'null';//opp.Id;
        reqObj.RequestStatus = 'New';
        
        Test.startTest();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/REST_FSRA_OpportunityStageUpdate';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueof(JSON.serialize(reqObj));
            RestContext.request = req;
            RestContext.response= res;
            
            REST_FSRA_OpportunityStageUpdate.UpdateOpportunityStage();
        
            reqObj.OpportunityId = opp.Id;
            req.requestBody = Blob.valueof(JSON.serialize(reqObj));
            RestContext.request = req;
            RestContext.response= res;
            REST_FSRA_OpportunityStageUpdate.UpdateOpportunityStage();
        
        
            opp.StageName = 'Pre-Application';
            //opp.Date_of_FSP__c = Date.today();
        	//opp.Date_of_IPA_Conditions_Completion__c = Date.today();
        	//opp.IPA_Granted_On__c = Date.today();
        	//opp.Date_of_Withdrawal__c = Date.today();
            update opp;
            opp.StageName = 'Authorised'; 
        	//opp.Account.From_FSRA__c = true;
            update opp;
            
            reqObj.OpportunityId = opp.Id;
        	reqObj.ApplicationSubmittedDate = Date.today();
        	reqObj.IPAIssueDate = Date.today();
        	reqObj.IPAExpiryDate = Date.today();
        	reqObj.DateOfFSP = Date.today();
        	reqObj.DateOfWithdrawal = Date.today();
            req.requestBody = Blob.valueof(JSON.serialize(reqObj));
            RestContext.request = req;
            RestContext.response= res;
            REST_FSRA_OpportunityStageUpdate.UpdateOpportunityStage();
        Test.stopTest();
    }
}
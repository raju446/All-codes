@isTest
public class GetAccountDetailsTest
{
    public static testMethod void getaccounts()
    {
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM Registered Company').getRecordTypeId();
        Account acc = new Account(Name='Test',Account_Name_Arabic__c='DED Test',Entity_Id__c='00001',License_Expiry_Date__c=Date.today().addDays(360),
              Entity_Type__c='Private Company Limited By Shares',Entity_Status__c='Registered',Registration_Date__c=Date.today(),Recordtypeid=accRecordTypeId);
        insert acc;
        
    
        Address__c addr = new Address__c(Entity__c=acc.id,State__c='Al Maryah Island',Street_Name_of_Cluster_on_the_Island__c='Test',Building_Name__c='Test',Type__c='Physical');
        insert addr;
    
        Business_Activity__c ba = new Business_Activity__c(Entity__c=acc.id,Activity_Code__c='1234',Status__c='Active',Activity_Name_Arabic__c='test',Activity_Name__c='Test');
        insert ba;
        
        Role__c role = new Role__c(Subject_Account__c=acc.id,Forenames__c='test',Title__c='Mr',Forenames_in_Arabic__c='test');
        insert role; 
        
        Trade_Name__c tr = new Trade_Name__c(Name_in_English__c='Test',Name_in_Arabic__c='Test',Status__c='Active',Entity__c=acc.id);
        insert tr;
        
        test.startTest();
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/GetRegEntityDetails/GetAccountDetails/getAccountDetails?Status=Registered';  
            req.httpMethod = 'Get';        	
            RestContext.request = req;
        	RestContext.request.params.put('Status', 'Registered');
            RestContext.response= res;
            GetAccountDetails.getAccountDetails();


        	RestContext.request.params.put('Status', 'Active');
        	RestContext.response= res;
        	GetAccountDetails.getAccountDetails();        
        test.stopTest();
    }

}
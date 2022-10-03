@isTest
public with sharing class CC_MigratedEmployeesTest 
{
    private static testMethod void CC_MigratedEmployees(){
    	Work_Permit_Running_Number__c wpn = new Work_Permit_Running_Number__c(Name='Permanent Work Permit',Work_Permit_Running_Number__c=1);
    	insert wpn;
    	
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '123456';
        insert newAccounts; 
        
        list<contact> createdContactList = TestClassUtility.createContacts(1,newAccounts[0].Id);
    	insert createdContactList;  
    	                           
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Establishment_Card_Amendment');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        createdSRList[0].HexaBPM__Contact__c = createdContactList[0].id;
        createdSRList[0].Unified_ID_No__c= '12345';
        createdSRList[0].Residence_Visa_Number__c = '1234';
        createdSRList[0].Residence_Visa_Number__c = '1234';
        createdSRList[0].Residence_Visa_Number__c = '1234';
        createdSRList[0].Residence_Visa_Number__c = '1234';
        
        
        insert createdSRList;
         	
        HexaBPM__Status__c stepStatus = new HexaBPM__Status__c(Name='Application Verified',HexaBPM__Type__c='Start',HexaBPM__Code__c='APPLICATION_VERIFIED');
        insert stepStatus;
        
        
        List<HexaBPM__Step__c> createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        createdstepList[0].HexaBPM__Status__c = stepStatus.id;
        insert createdstepList;  
        
        Document_Details__c doc =  new Document_Details__c(Document_Status__c='Active',Account__c=newAccounts[0].id,Document_Type__c='Establishment Card');
        insert doc; 
        
        Test.startTest();
	        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id,HexaBPM__Status__c,HexaBPM__Status__r.HexaBPM__Code__c,HexaBPM__SR__r.HexaBPM__Contact__c,HexaBPM__SR__r.Establishment_English_Name__c ,
	        							HexaBPM__SR__r.Establishment_Arabic_Name__c, HexaBPM__SR__r.HexaBPM__Customer__c,HexaBPM__SR__r.Establishment_Card_Issue_Date__c,
	        							HexaBPM__SR__r.Work_Permit_Card_Number__c,HexaBPM__SR__r.Work_Permit_Issue_Date__c,HexaBPM__SR__r.Work_Permit_Expiry_Date__c,
	        							HexaBPM__SR__r.Residence_Visa_Number__c,HexaBPM__SR__r.Nationality_Lookup__c,HexaBPM__SR__r.Unified_ID_No__c
	        							FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
	        CC_MigratedEmployees con = new CC_MigratedEmployees();
	        con.EvaluateCustomCode(null,lstOfSteps[0]);
	        
	        stepStatus.HexaBPM__Code__c = 'APPROVED';
	        update stepStatus;
	        
	        con.EvaluateCustomCode(null,lstOfSteps[0]);
	        
        Test.stopTest();  
    }
}
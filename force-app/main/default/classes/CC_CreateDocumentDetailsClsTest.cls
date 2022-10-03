@isTest
public with sharing class CC_CreateDocumentDetailsClsTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    
    private static void init(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
		newAccounts[0].Oracle_Party_Id__c = '0000001';
		insert newAccounts; 
				                  
        createdSRList = TestUtility.createSR(1,'Employment_Visa_New');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        createdSRList[0].I_Agree__c = true;
        insert createdSRList;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList;    
        
       // Document_Detail_SR_Field_Mapping__c srfm = new Document_Detail_SR_Field_Mapping__c();
       // srfm.Active__c = true;
       // srfm.Document_Detail_Field_API_Name__c = 'test';
       // srfm.SR_Field_API_Name__c = 'Initial_Approval';
        //srfm.Service_Request_Recordtype_API__c = 'CID_Approval';
       // srfm.Name = 'tester';
        //insert srfm;
        Document_Detail_SR_Field_Mapping__c srf = new Document_Detail_SR_Field_Mapping__c();
        srf.Active__c =true;
        srf.Service_Request_Recordtype_API__c = 'Employment_Visa_New';
        srf.SR_Field_API_Name__c = 'HexaBPM__Customer__c';
        srf.Document_Type__c = 'Residence Visa';
        srf.Document_Detail_Field_API_Name__c = 'Account__c';
        srf.Name = '1';
        insert srf;

    }
    public static testmethod void TestCC_CreateDocumentDetailsCls(){
       	init();
        Test.startTest();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Customer__c, HexaBPM__SR__r.HexaBPM__Record_Type_Name__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        CC_CreateDocumentDetailsCls con = new CC_CreateDocumentDetailsCls();
        con.EvaluateCustomCode(null,lstOfSteps[0]);
        Test.stopTest();
    }
    
}
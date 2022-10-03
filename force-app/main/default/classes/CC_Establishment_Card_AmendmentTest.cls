@isTest
public with sharing class CC_Establishment_Card_AmendmentTest 
{
	private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    
    private static void init(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '123456';
        insert newAccounts; 
                                  
        createdSRList = TestUtility.createSR(1,'Establishment_Card_Amendment');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        createdSRList[0].Establishment_Card_Issue_Date__c = system.today();
        createdSRList[0].Establishment_Arabic_Name__c= 'test';
        createdSRList[0].Establishment_English_Name__c = 'tester';
        insert createdSRList;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList;  
        
        Document_Details__c doc =  new Document_Details__c(Document_Status__c='Active',Account__c=newAccounts[0].id,Document_Type__c='Establishment Card');
        insert doc;   

    }
    public static testmethod void TestCC_EstablishmentApproval(){
        init();
        
        Test.startTest();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id,HexaBPM__SR__r.Establishment_English_Name__c ,HexaBPM__SR__r.Establishment_Arabic_Name__c, HexaBPM__SR__r.HexaBPM__Customer__c,HexaBPM__SR__r.Establishment_Card_Issue_Date__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        CC_Establishment_Card_Amendment con = new CC_Establishment_Card_Amendment();
        con.EvaluateCustomCode(null,lstOfSteps[0]);
        Test.stopTest();
    }
}
@isTest
public with sharing class CC_CancelledPOBoxTest {
 
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    private static List<Account> createdAccountList; 
    private static  List<PO_Box__c> createdPOBoxtList; 
    
    private static void init(){
        createdAccountList = TestClassUtility.createAccounts(1);
        createdAccountList[0].Oracle_Party_Id__c = '0000001';
        insert createdAccountList;
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, createdAccountList[0].Id);
        insert newContacts;  
        
        PO_Box__c pb = new PO_Box__c();
        pb.Type__c  = 'EziMAIL Bronze';
        pb.PO_Box_Number__c = '1234';
        createdPOBoxtList = new List<PO_Box__c>();      
        createdPOBoxtList.add(pb);
        insert createdPOBoxtList;
        
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        createdSRList[0].HexaBPM__Customer__c = createdAccountList[0].Id;
        createdSRList[0].PO_Box__c = createdPOBoxtList[0].Id;
        insert createdSRList;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList;     
        
        
        
    }
    
    public static testmethod void TestCC_CancelledPOBox(){
        init();
        CC_CancelledPOBox con = new CC_CancelledPOBox();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Customer__c,HexaBPM__SR__r.HexaBPM__Contact__c,HexaBPM__SR__r.PO_Box__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        con.EvaluateCustomCode(null,lstOfSteps[0]);
    }
    
}
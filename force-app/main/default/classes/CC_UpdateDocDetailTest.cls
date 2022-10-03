@isTest
public class CC_UpdateDocDetailTest
{
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    private static List<Account> createdAccountList; 
    
    
    private static void init(){
         createdAccountList = TestClassUtility.createAccounts(1);
         createdAccountList[0].Oracle_Party_Id__c = '0000001';
        insert createdAccountList;
       
        createdSRList = TestUtility.createSR(1,'EChannel_Cancellation');
        createdSRList[0].HexaBPM__Customer__c = createdAccountList[0].Id;
        createdSRList[0].Permit_Number__c = '1234';
        insert createdSRList;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList;     
        
       Cancellation_SRs_Document_Types__c csr = new Cancellation_SRs_Document_Types__c();
       csr.Document_Type__c = 'Alcohol Permit';
       csr.Service_Request_Recordtype_API__c = 'EChannel_Cancellation';
       csr.Name = '18';
       insert csr;
       
       Document_Details__c docs = new Document_Details__c();  
       docs.Document_Status__c='Active';
       docs.Document_Type__c= 'Alcohol Permit';
       docs.Account__c = createdAccountList[0].Id;
       docs.Document_Cancel_Date__c = system.today();
       docs.Document_Number__c = '1234';
       docs.Service_Request__c = createdSRList[0].Id;
       insert docs; 
    }
    
    public static testmethod void TestCC_UpdateDocDetail(){
        init();
        CC_UpdateDocDetail con = new CC_UpdateDocDetail();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Customer__c,HexaBPM__SR__r.HexaBPM__Record_Type_Name__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        con.EvaluateCustomCode(null,lstOfSteps[0]);
    }
    
}
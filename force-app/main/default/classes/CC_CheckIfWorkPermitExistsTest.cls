@isTest
public class CC_CheckIfWorkPermitExistsTest
{
    private static testMethod void CC_CheckIfWorkPermitExists_UT()
    {
    
         List<Account> createdAccountList = TestClassUtility.createAccounts(1);
        createdAccountList[0].Oracle_Party_Id__c = '0000001';
        insert createdAccountList;
        
        Document_Details__c objDocDetail = new Document_Details__c();
        objDocDetail.Document_Type__c = 'Alcohol Permit';
        objDocDetail.Account__c = createdAccountList[0].Id;
        objDocDetail.Document_Status__c = 'Active';
        insert objDocDetail;
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, createdAccountList[0].Id);
        insert newContacts;  
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Permit_Alcohol');
        createdSRList[0].HexaBPM__Customer__c = createdAccountList[0].Id;
        createdSRList[0].Document_Type__c = 'Alcohol Permit';
        insert createdSRList;
        
        List<HexaBPM__Step__c>  createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList; 
        
        test.startTest();
        CC_CheckIfWorkPermitExists cc = new CC_CheckIfWorkPermitExists ();
        cc.EvaluateCustomCode(createdSRList[0],createdstepList[0]);
        test.stopTest();
    }
}
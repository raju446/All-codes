@isTest
private class CC_CancelPermitDocDetailClsTest{
    static testmethod void cancelAlcoholPermitTest(){
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
            CC_CancelPermitDocDetailCls conCC = new CC_CancelPermitDocDetailCls();
            List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Customer__c, HexaBPM__SR__r.Document_Type__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
            conCC.EvaluateCustomCode(null,lstOfSteps[0]);
        test.stopTest();
    }
}
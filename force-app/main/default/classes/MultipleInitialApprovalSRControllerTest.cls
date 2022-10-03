@isTest
private class MultipleInitialApprovalSRControllerTest{
    static testMethod void initialApprovalTest(){
        HexaBPM__SR_Status__c objSRStatus = new HexaBPM__SR_Status__c();
        objSRStatus = new HexaBPM__SR_Status__c();
        objSRStatus.Name = 'Submitted';
        objSRStatus.HexaBPM__Code__c = 'SUBMITTED';
        insert objSRStatus;
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].License_Expiry_Date__c  = System.today().addYears(1);
        insert newAccounts; 

        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].HexaBPM__Internal_SR_Status__c = objSRStatus.Id; 
        createdSRList[0].HexaBPM__External_SR_Status__c = objSRStatus.Id; 
        insert createdSRList;
        
        test.startTest();
            system.currentPageReference().getParameters().put('Id', newAccounts[0].Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(newAccounts[0]);
            MultipleInitialApprovalSRController multiApp = new MultipleInitialApprovalSRController(sc);
            
        test.stopTest();

    }
    static testMethod void initialApprovalTest2(){
        HexaBPM__SR_Status__c objSRStatus = new HexaBPM__SR_Status__c();
        objSRStatus = new HexaBPM__SR_Status__c();
        objSRStatus.Name = 'Submitted';
        objSRStatus.HexaBPM__Code__c = 'SUBMITTED';
        insert objSRStatus;
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].License_Expiry_Date__c  = System.today().addYears(1);
        insert newAccounts; 

        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(3,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].HexaBPM__Internal_SR_Status__c = objSRStatus.Id; 
        createdSRList[0].HexaBPM__External_SR_Status__c = objSRStatus.Id; 
        createdSRList[1].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[1].HexaBPM__Internal_SR_Status__c = objSRStatus.Id; 
        createdSRList[1].HexaBPM__External_SR_Status__c = objSRStatus.Id; 
        createdSRList[2].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[2].HexaBPM__Internal_SR_Status__c = objSRStatus.Id; 
        createdSRList[2].HexaBPM__External_SR_Status__c = objSRStatus.Id; 
        insert createdSRList;
        
        test.startTest();
            system.currentPageReference().getParameters().put('Id', newAccounts[0].Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(newAccounts[0]);
            MultipleInitialApprovalSRController multiApp = new MultipleInitialApprovalSRController(sc);
            system.debug('@@ACCTID: '+multiApp.accountId);
        test.stopTest();

    }
}
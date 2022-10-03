@isTest
private class ServiceRequestEditOverrideControllerTest{
    static testMethod void ServiceRequestEditOverrideControllerTest1(){
        
        HexaBPM__SR_Template__c srtemp = new HexaBPM__SR_Template__c();
        srtemp.Name = 'Trainings and Seminars Permit';
        srtemp.HexaBPM__SR_RecordType_API_Name__c = 'Initial_Approval';
        srtemp.HexaBPM__Is_Through_Flow__c = true;
        insert srtemp;
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 
        
                
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        insert createdSRList;
        

        test.startTest();
            system.currentPageReference().getParameters().put('Id', createdSRList[0].Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(createdSRList[0]);
            ServiceRequestEditOverrideController srOverride = new ServiceRequestEditOverrideController(sc);
            srOverride.CheckAccess();
            srOverride.closeWindow();
        test.stopTest();

    }
}
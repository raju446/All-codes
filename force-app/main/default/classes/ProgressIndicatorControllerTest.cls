@isTest
private class ProgressIndicatorControllerTest{
    static testMethod void ProgressIndicatorControllerTest1(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 
        
        HexaBPM__SR_Template__c srtemp = new HexaBPM__SR_Template__c();
        srtemp.HexaBPM__Sub_menu_section__c = 'Permits';
        srtemp.HexaBPM__SR_RecordType_API_Name__c = 'Permit_Alcohol';
        insert srtemp;
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Permit_Alcohol');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].HexaBPM__Submitted_DateTime__c = Datetime.now().addDays(-1);
        insert createdSRList;
        
        HexaBPM__SR_Steps__c createSRstep = new  HexaBPM__SR_Steps__c();
        //createSRstep.HexaBPM__SR__c = createdSRList[0].Id;
        createSRstep.HexaBPM__SR_Template__c = srtemp.Id;
        createSRstep.HexaBPM__Active__c = true;
        createSRstep.HexaBPM__Group_Name__c = 'GRP1';
        insert createSRstep;
        
        List<HexaBPM__Step__c> createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,createSRstep.Id);
        insert createdstepList; 
            
        test.startTest();
            system.currentPageReference().getParameters().put('Id', createdSRList[0].Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(createdSRList[0]);
            ProgressIndicatorController progressIndi = new ProgressIndicatorController(sc);
        test.stopTest();

    }
}
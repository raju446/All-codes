@isTest
private class ServiceRequestTriggerHandlerTest{
    static testMethod void ServiceRequestTriggerHandlerTest1(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 

        test.startTest();
            List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Permit_Alcohol');
            createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
            insert createdSRList;
            
        test.stopTest();

    }
    static testMethod void ServiceRequestTriggerHandlerTest2(){
    
        HexaBPM__SR_Status__c objSRStatus = new HexaBPM__SR_Status__c();
        objSRStatus.Name = 'Closed';
        objSRStatus.HexaBPM__Code__c = 'CLOSED';
        objSRStatus.HexaBPM__Type__c = 'End';
        insert objSRStatus;
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Permit_Alcohol');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        insert createdSRList;

        test.startTest();
            createdSRList[0].HexaBPM__External_SR_Status__c = objSRStatus.Id;
            update createdSRList;
            
        test.stopTest();

    }
}
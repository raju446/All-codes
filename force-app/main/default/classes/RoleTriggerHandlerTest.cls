@isTest
private class RoleTriggerHandlerTest{
    static testMethod void roleTriggerhandlerTest(){
    
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].License_Expiry_Date__c  = System.today().addYears(1);
        newAccounts[0].Is_Initial_Approval__c = false;
        newAccounts[0].TotalAuthorisedSignatories__c = 1;
        insert newAccounts; 
        
        Business_Activity__c ba = new Business_Activity__c();
        ba.Activity_Code__c = '111111';
        ba.Entity__c = newAccounts[0].id;
        insert ba;
        
        Role__c objRole = new Role__c();
        objRole.Subject_Account__c = newAccounts[0].Id;
        objRole.Type__c = 'Authorised Signatory';
        

        test.startTest();
            insert objRole;
            
            objRole.Role_Name__c = 'Lawyer';
            update objRole;
        test.stopTest();

    }
}
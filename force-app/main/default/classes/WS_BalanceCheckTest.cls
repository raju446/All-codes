@isTest
private class WS_BalanceCheckTest{
    static testMethod void wsbalanceCheck1(){
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        insert newAccounts; 
            
        test.startTest();
            WS_BalanceCheck.UpdatePortalBalance(newAccounts[0].Oracle_Party_Id__c, 20000);
        test.stopTest();

    }
    static testMethod void wsbalanceCheck2(){
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        insert newAccounts; 
            
        test.startTest();
            WS_BalanceCheck.GetOracleBalance(newAccounts[0].Oracle_Party_Id__c);
        test.stopTest();

    }
    static testMethod void wsbalanceCheck3(){
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].Oracle_Site_Id__c = '101';
        insert newAccounts; 
            
        test.startTest();
           Test.setMock(HttpCalloutMock.class, new WS_BalaneCheckMock());
           WS_BalanceCheck.GetOracleBalance_New(newAccounts[0].Id);
        	WS_BalanceCheck.updateEntityBalance(newAccounts[0].Id);
        test.stopTest();

    }
}
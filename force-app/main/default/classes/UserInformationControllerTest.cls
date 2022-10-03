@isTest
private class UserInformationControllerTest{
    static testMethod void userInfotest1(){
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(2, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        insert newContacts;
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
            
        test.startTest();
            UserInformationController userInfoCtrlr = new UserInformationController();
            userInfoCtrlr.UserId = portalUser.Id;
            userInfoCtrlr.getUserName();
        test.stopTest();

    }
}
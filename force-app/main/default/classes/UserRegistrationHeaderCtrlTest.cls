@isTest
public with sharing class UserRegistrationHeaderCtrlTest {

    public static testmethod void TestUserRegistrationHeaderCtrl(){
        UserRegistrationHeaderCtrl urh = new UserRegistrationHeaderCtrl();      
        urh.SecondaryLogoURL = 'test.com';
    }
}
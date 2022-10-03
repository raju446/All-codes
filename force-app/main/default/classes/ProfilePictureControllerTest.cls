@isTest
public with sharing class ProfilePictureControllerTest {
    
    public static testmethod void TestProfilePictureController(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts; 
            
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Profile_Picture_Id__c = '12345';
        newContacts[0].Portal_User_Creation__c = true;
        
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        insert newContacts;  
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        
        
        system.runAs(portalUser){
                        
            ProfilePictureController ppc = new ProfilePictureController();
            ppc.strCroppedData = 'base64,1234';
            ppc.SaveCroppedImage();
        } 
 
    }
}
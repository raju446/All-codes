@isTest
public with sharing class DeleteProfilePicControllerTest {
  
private static  List<Attachment> createdAttachmentList; 

public static testmethod void TestDeleteProfilePicController(){
      
      List<Account> newAccounts = TestClassUtility.createAccounts(1);
    insert newAccounts; 
    
    createdAttachmentList = TestClassUtility.createAttachment(
                  new List<Attachment>{
                      new Attachment(ParentId=newAccounts[0].Id)});
          
    List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
    newContacts[0].Portal_User_Creation__c = true;
    newContacts[0].Profile_Picture_Id__c = createdAttachmentList[0].Id;
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
    insert newContacts;  
  
    User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
      
    
    
    system.runAs(portalUser){
      
        DeleteProfilePicController prc = new DeleteProfilePicController();
       prc.deleteProfilePic();
        
    } 
 
  }
    
}
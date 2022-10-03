@isTest
public with sharing class AnnouncementDetailControllerTest {
    public static testmethod void TestAnnouncementDetailController(){
        List<Account> createdAccountList = TestClassUtility.createAccounts(1);
        insert createdAccountList;
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, createdAccountList[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Community_Username__c = 'test12mg@adgm.portal';
        newContacts[0].Is_Guest_User__c = true;
        insert newContacts;  
        
        Blob b = Blob.valueOf('Test Data');
        Attachment attachment = new Attachment();
        attachment.ParentId = newContacts[0].id;
        attachment.Name = 'Test Attachment for Parent';
        attachment.Body = b;
        insert attachment;
        
        User portalUser = [SELECT Id FROM User WHERE ContactId =:newContacts[0].Id];
        system.runAs(portalUser){
            AnnouncementListController alc = new AnnouncementListController();
            alc.getAnnouncement();
            alc.refresh();
            alc.getTotalPages();
        
            String recId = Schema.Sobjecttype.Notice__c.getRecordTypeInfosByName().get('Alert').getRecordTypeId();
            Notice__c ntc = new Notice__c();
            ntc.RecordTypeId = recId;
            ntc.Entity__c = createdAccountList[0].Id;
            ntc.Start_Date__c = system.today();
            ntc.Type__c = 'Announcement';
            ntc.Alert_Text__c = 'test';
            ntc.Status__c = 'Active';
            ntc.End_Date__c = system.today();
            ntc.Severity__c = 'High';
            ntc.Available_for__c = 'Company User';
            ntc.Title__c ='Tester';
            ntc.Announcement_Content__c = 'tester1';
            ntc.Notification_Picture_Id__c = attachment.id;
            insert ntc;
            
            ApexPages.currentPage().getParameters().put('id',ntc.Id);
            AnnouncementDetailController adc = new AnnouncementDetailController();
        }   
        //adc.notice;
    }
}
@isTest
public with sharing class AnnouncementListControllerTest {
    private static  List<Account> createdAccountList; 
    private static  List<Notice__c> createdNoticeList;
    public static void init(){
        createdAccountList = TestClassUtility.createAccounts(1);
        insert createdAccountList;
        createdNoticeList = TestClassUtility.createNotice(
                                new List<Notice__c>{
                                    new Notice__c(Entity__c = createdAccountList[0].Id)});
    }   
    public static testmethod void TestAnnouncementListController(){
    init();
    AnnouncementListController alc = new AnnouncementListController();
    alc.getAnnouncement();
    alc.refresh();
    alc.getTotalPages();
    
            
    }
    public static testmethod void TestAnnouncementListController2(){
        
        init();
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, createdAccountList[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Community_Username__c = 'test1mg@adgm.portal';
        newContacts[0].Is_Guest_User__c = true;
        insert newContacts;  
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        system.runAs(portalUser){
            AnnouncementListController alc = new AnnouncementListController();
            alc.getAnnouncement();
            alc.refresh();
            alc.getTotalPages();
        }   
    }   
    public static testmethod void TestAnnouncementListController3(){
        
        init();
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, createdAccountList[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Community_Username__c = 'test11mg@adgm.portal';
        //newContacts[0].Is_Guest_User__c = true;
        insert newContacts;  
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        //system.runAs(portalUser){
            AnnouncementListController alc = new AnnouncementListController();
            alc.getAnnouncement();
            alc.refresh();
            alc.getTotalPages();
        //}   
    }   
}
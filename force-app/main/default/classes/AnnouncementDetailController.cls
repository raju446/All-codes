/*
    Author      : Durga Prasad
    Date        : 05-Dec-2017
    Description : Page Controller to display Announcements
    --------------------------------------------------------------------------------------
*/
public without sharing class AnnouncementDetailController{
    public Notice__c notice {get;set;}
    public AnnouncementDetailController(){
        string loggedInUserAccountId;
        list<User> lstUser = [Select contact.accountid from User where id =: Userinfo.getUserid() and ContactId!=null];
        if(lstUser!=null && lstUser.size()>0){
            loggedInUserAccountId = lstUser[0].contact.accountid;
            for(Notice__c nt:[select title__c, Announcement_Content__c from Notice__c where Type__c = 'Announcement' and id=:ApexPages.currentPage().getParameters().get('id')]){// and Entity__c=:loggedInUserAccountId]){
                notice = nt;
            }
        }
    }
}
/*
    Author      : Durga Prasad
    Date        : 12-Nov-2017
    Description : Page Controller to display Announcement Lists
    --------------------------------------------------------------------------------------
*/
public without sharing class AnnouncementListController{
    public Integer noOfRecords{get; set;}
    public Integer size{get;set;}
    public boolean isGuestUser {get;set;}
    public string loggedInUserAccountId;
    public AnnouncementListController() {
        
        list<User> lstUser = [Select contact.accountid,contact.Is_Guest_User__c from User where id =: Userinfo.getUserid() limit 1];
        if(!lstUser.IsEmpty()){
            loggedInUserAccountId = lstUser[0].contact.accountid;
            isGuestUser = lstUser[0].contact.Is_Guest_User__c;
        }
    }
    public ApexPages.StandardSetController setCon {
        get{
            if(setCon == null){
                set<string> uniqueAnnouncements = new set<string>();
                set<id> ntIds = new set<id>();
                size = 10;
                string queryString ; //Select Id,Name,Title__c from Notice__c where Type__c = \'Announcement\' order by Name
                date todayDate = system.today();
                if(isGuestUser)
                    queryString = 'select Id,Name,title__c, Announcement_Header_Content__c,Notification_Picture_Id__c from Notice__c where Start_Date__c<=:todayDate  and End_Date__c>=:todayDate  and Publish__c=true and (Entity__c=:loggedInUserAccountId or (Entity__c = null)) and Available_for__c INCLUDES (\'Guest User\') and Type__c = \'Announcement\' ';
                else
                    queryString = 'select Id,Name,Title__c,Announcement_Header_Content__c,Notification_Picture_Id__c from Notice__c where Start_Date__c<=:todayDate  and End_Date__c>=:todayDate and Publish__c=true and (Entity__c=:loggedInUserAccountId or (Entity__c = null)) and Available_for__c INCLUDES (\'Company User\') and Type__c = \'Announcement\'  ';
                
                /*for(Notice__c nt : Database.query(queryString))
                {
                    if(!uniqueAnnouncements.contains(nt.Title__c)){
                        uniqueAnnouncements.add(nt.Title__c);
                        ntIds.add(nt.id);
                    }
                }*/
                queryString += 'order by CreatedDate desc';
                System.debug('queryString '+queryString );
                map<string,Notice__c> ntlist = new map<string,Notice__c>();
                for(Notice__c nt : database.query(queryString)){
                	ntlist.put(nt.title__c,nt);
                }
                //setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setCon = new ApexPages.StandardSetController(ntlist.values());
                setCon.setPageSize(size);
                noOfRecords = setCon.getResultSize();
            }
            return setCon;
        }set;
    }
    public List<Notice__c> getAnnouncement(){
        List<Notice__c> announcementList = new List<Notice__c>();
        for(Notice__c a : (List<Notice__c>)setCon.getRecords())
            announcementList.add(a);
        return announcementList;
    }
     
    public pageReference refresh() {
        setCon = null;
        getAnnouncement();
        setCon.setPageNumber(1);
        return null;
    }
    public Integer getTotalPages() {
        return Integer.valueof(Math.ceil((Double) noOfRecords / size));
    }
}
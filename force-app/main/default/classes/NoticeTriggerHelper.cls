/*
    Author      : Kim Noceda
    Date        : 03-Apr-2018
    Description : Trigger handler class that is being referenced in the NoticeTriggerHandler.
                  All DML methods are being handled in this handler class.
    --------------------------------------------------------------------------------------
*/
public without sharing class NoticeTriggerHelper {

    /*
        Method Name :   CreateAnnouncementsAccounts
        Description :   Method to create Announcements to all accounts with an Oracle party Id.
    */
    public static void CreateAnnouncementsAccounts(List<Notice__c> announcementList){
        List<Recordtype> announcementRectype = new List<Recordtype>();
        if(announcementList.size() > 0){
            announcementRectype = [SELECT Id FROM Recordtype WHERE SObjectType = 'Notice__c' AND DeveloperName = 'Announcement' LIMIT 1];
        }
        
        Map<Id,Notice__c> noticeMap = new Map<Id,Notice__c>();
        for(Notice__c objNotice : announcementList){
            if(announcementRectype.size()>0){
                if(objNotice.RecordtypeId == announcementRectype[0].Id){
                    if(objNotice.Entity__c == null && objNotice.Publish__c == true){
                        noticeMap.put(objNotice.Id, objNotice);
                    }
                }
            }
        }
        
        if(noticeMap.size() > 0){
            List<Notice__c> noticeList = new List<Notice__c>();
            for(Account objAcct : [SELECT Id, Oracle_Party_Id__c FROM Account /*WHERE (Oracle_Party_Id__c <> null AND Oracle_Party_Id__c <> '')*/ ]){
                for(Id key : noticeMap.keyset()){
                    Notice__c objNotice = noticeMap.get(key).clone();
                    objNotice.Entity__c = objAcct.Id;
                    noticeList.add(objNotice);
                }
            }
            
            if(!noticeList.isEmpty()){
                try{
                    insert noticeList;
                } catch(Exception e){
                    System.debug('##ERROR: '+e.getMessage());
                }
            }
            
            /*if(noticeMap.size() > 0){
                //delete noticeMap.values();
                deleteNoticeAnnouncements(noticeMap.keyset());
            }*/
        }
    }
    
    /*
        Method Name :   deleteNoticeAnnouncements
        Description :   Method to delete the inserted notices with blank entity from CreateAnnouncementsAccounts method.
    */
    /*@future
    public static void deleteNoticeAnnouncements(Set<Id> noticeIds){
        List<Notice__c> deleteNotice = new List<Notice__c>();
        for(Notice__c objNotice : [SELECT Id FROM Notice__c WHERE Id IN :noticeIds]){
            deleteNotice.add(objNotice);
        }
        
        if(!deleteNotice.isEmpty()){
            try{
                delete deleteNotice;
            } catch(Exception e){
                System.debug('##ERROR: '+e.getMessage());
            }
        }
    }*/
}
/*
    Author      : Kim Noceda
    Date        : 03-Apr-2018
    Description : Trigger Handler for Notice__c Object
    --------------------------------------------------------------------------------------
*/
public without sharing class NoticeTriggerHandler {
    public static void Execute_BI(list<Notice__c> TriggerNew){
    	for(Notice__c nt : TriggerNew){
        	if(nt.Type__c == 'Annoucement' && nt.Publish__c == true && nt.Email_Sent__c == false && nt.Entity__c != null){
        		nt.Send_Email__c = true;
        	} 
        }
    }
    public static void Execute_AI(list<Notice__c> TriggerNew){
        //NoticeTriggerHelper.CreateAnnouncementsAccounts(TriggerNew);
    }
    public static void Execute_BU(list<Notice__c> TriggerNew,map<Id,Notice__c> TriggerOldMap)
    {
    	system.debug('====');
        for(Notice__c nt : TriggerNew){
        	system.debug('===='+nt.Type__c+'=='+nt.Publish__c);
        	if(nt.Type__c == 'Announcement' && nt.Publish__c == true && nt.Email_Sent__c == false && nt.Entity__c != null){
        		nt.Send_Email__c = true;
        	}
        }
    }
    public static void Execute_AU(list<Notice__c> TriggerNew,map<Id,Notice__c> TriggerOldMap){
    //if(Label.Allow_Announcment_Creation == 'True')
        //NoticeTriggerHelper.CreateAnnouncementsAccounts(TriggerNew);
    }
}
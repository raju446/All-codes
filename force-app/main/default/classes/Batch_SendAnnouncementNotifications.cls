/*
    Author      : Azmath
    Date        : 17-Mar-2020
    Description : Batch Class to send announcement notifications..
    -------------------------------------------------------------------------------------------
*/
global without sharing class Batch_SendAnnouncementNotifications implements Database.Batchable<sObject>, Database.Stateful
{
	public string announcementType='';
	public boolean isGenericNotification = false;
	public set<id> acclist = new set<id>();
	public Id annoucementid;
	public Batch_SendAnnouncementNotifications(string aType, boolean isGen,string aId){
		this.announcementType 		= aType;
		this.isGenericNotification 	= isGen;
		this.annoucementid = aId;
	}
    global Database.QueryLocator start(Database.BatchableContext BC)
	{
		if(isGenericNotification == true)
		{
			//acclist = new set<id>{'0012500001A8PvC','0012500001IVA3C'}; 
			set<string> recTypes = new set<string>();
			if(announcementType.contains('Guest User')){
				recTypes.add('ADGM_Guest');
			}
			if(announcementType.contains('Company User')){
				recTypes.add('ADGM_Registered_Company');
			}
			system.debug('===='+recTypes);
			if(!recTypes.isEmpty()){
				string query = 'Select id, Email from User where isActive=true and Contact.Account.Record_Type_Name__c IN:recTypes';// and contact.Accountid IN:acclist';
				system.debug('======query is ==='+query);
				return database.getQueryLocator(query);
			}
		}
		else
		{
			acclist = new set<id>();
			for(Notice__c nt : [Select Entity__c from Notice__c where Send_Email__c=true and Type__c='Announcement' and Publish__c=true]){
				acclist.add(nt.Entity__c);
			}
			if(!acclist.isEmpty()){
				string query = 'Select id, Email from User where isActive=true  and contact.Accountid IN:acclist ';
				return database.getQueryLocator(query);
			}
		}
		return null;
	}
	global void execute(Database.BatchableContext BC,list<User> UserList)
	{
		try
		{
			list<EmailTemplate> temp 	= [Select Id from EmailTemplate where DeveloperName='Notify_Client_when_an_Announcement_is_made' LIMIT 1];
			OrgWideEmailAddress[] owea	= [select Id from OrgWideEmailAddress where Address =:Label.OrgWideEmailAddress];
			list<Messaging.SingleEmailMessage> notificationsLst = new list<Messaging.SingleEmailMessage>();
			
			set<User> uniqueset = new set<user>();
			uniqueset.addAll(UserList);
			system.debug('===users size=='+UserList.size());
			for(User u : uniqueset)
			{
				system.debug('======user name'+u.email);
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				mail.setTargetObjectId(u.Id);
				system.debug('====='+u.id);
				mail.setTemplateId(temp[0].Id);
				mail.setSaveAsActivity(false);
				if(!owea.isEmpty())
					mail.setOrgWideEmailAddressId(owea.get(0).Id);
				notificationsLst.add(mail);
			}
			system.debug('======'+notificationsLst.size());
			if(!notificationsLst.isEmpty())
			{
				List<Messaging.SendEmailResult> results = Messaging.sendEmail(notificationsLst);
				if (!results.get(0).isSuccess()) {
				    System.StatusCode statusCode = results.get(0).getErrors()[0].getStatusCode();
				    String errorMessage = results.get(0).getErrors()[0].getMessage();
				    system.debug('===error==='+errorMessage);
				}
			}
		}catch(Exception e){
			
		}
	}
	
	global void finish(Database.BatchableContext BC)
	{
		if(isGenericNotification == false)
		{
			list<Notice__c> ntlist = new list<Notice__c>();
			for(Notice__c nt : [Select Entity__c from Notice__c where Entity__c = :acclist]){
				nt.Send_Email__c = false;
				nt.Email_Sent__c = true;
				ntlist.add(nt);
			}
			update ntlist;
		}
		else{
			if(annoucementid != null){
				list<Notice__c> nt = [Select Email_Sent__c from Notice__c where id=:annoucementid];
				if(!nt.isEmpty()){
					nt[0].Email_Sent__c = true;
				}
				update nt;
			}
		}
		
		system.debug('Finish method entered');
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setUseSignature(false);	
		String[] toAddresses = new String[]{UserInfo.getUserEmail()};//'azmathullah.shaik@pwc.com'};
		mail.setToAddresses(toAddresses);
		mail.setSubject('CONFIRMATION - Annoucement notification');
		mail.setPlainTextBody('New Announcement Notification emails has been successfully sent to all the recipients.');
		try{
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
        } catch(Exception ex){
            system.debug('===error==='+ex.getmessage());
        }
	}
}
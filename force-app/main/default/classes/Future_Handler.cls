global without sharing class Future_Handler
{
	@future
	public static void createInitialApprovalSuccesslog(string srid)
	{
		Log__c log = new Log__c(Message__c=' SR Created successfully with Id '+srid+'as part of Initial Approval.',
								User_Name__c=UserInfo.getUsername());
		insert log;
	}
	@future
	public static void notifyPortalUsers(set<id> accountids)
	{
		Id recordtypeid;
		list<Notice__c> alerts = new list<Notice__c>();
		
		if(Schema.SObjectType.Document_Details__c.getRecordTypeInfosByName().get('Alert')!=null && Schema.SObjectType.Document_Details__c.getRecordTypeInfosByName().get('Alert').getRecordTypeId()!=null)
        recordtypeid = Schema.SObjectType.Document_Details__c.getRecordTypeInfosByName().get('Alert').getRecordTypeId();
        
        for(Id id :accountids)
        {
        	Notice__c alert 				= new Notice__c();
        	alert.Type__c 					= 'Company Alert';
        	alert.Entity__c 				= id;
        	alert.Start_Date__c 			= system.today();
        	alert.End_Date__c 				= system.today().addDays(14);
        	alert.Status__c 				= 'Active';
        	alert.Severity__c 				= 'High';
        	alert.Sys_Alert_Unique_Key__c 	= Id+'-'+alert.Start_Date__c+'-'+alert.End_Date__c+system.now();
        	alert.Alert_Text__c 			= 'Your companies name has been changed, Please update your establishment card.';
        	alerts.add(alert);
        }
        if(!alerts.isempty())
        insert alerts;
        
		map<Id,list<User>> AccountsWithPortalUsers 			= new map<Id,list<User>>();
		list<Messaging.SingleEmailMessage> notificationsLst = new list<Messaging.SingleEmailMessage>();
		
		if(!accountids.isEmpty())
		{
			set<id> conIds = new set<Id>();
			for(Contact con : [Select Id,AccountId FROM Contact where AccountId IN:AccountIds and RecordType.Name = 'Contact - Portal User']){
				conIds.add(con.id);
			}
			
			for(User usr : [Select id,Contact.AccountId FROM User where ContactId IN:conIds and Contact.AccountId != null and isActive = true])
			{
				if(AccountsWithPortalUsers.containsKey(usr.Contact.AccountId)){
					AccountsWithPortalUsers.get(usr.Contact.AccountId).add(usr);
				}else{
					AccountsWithPortalUsers.put(usr.Contact.AccountId,new list<User>{usr});
				}
			}
			system.debug('=======portal users====='+AccountsWithPortalUsers.values());
		}
		
		//3. Construct email with Recipients..
		if(!AccountsWithPortalUsers.isEmpty())
		{
			list<EmailTemplate> temp = [Select Id from EmailTemplate where DeveloperName='Entity_Change_Notificaiton' LIMIT 1];
			OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:Label.OrgWideEmailAddress];
			if(!temp.isEmpty())
			{
				for(Id id : AccountsWithPortalUsers.keyset())
				{
					for(User u : AccountsWithPortalUsers.get(id))
					{
						system.debug('====User==='+u.id);
						Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
						mail.setTargetObjectId(u.Id);
						mail.setTemplateId(temp[0].Id);
						mail.setSaveAsActivity(false);
						if(!owea.isEmpty())
						mail.setOrgWideEmailAddressId(owea.get(0).Id);
						notificationsLst.add(mail);
					}
				}
			}
		}
		if(!notificationsLst.isEmpty()){
             Messaging.sendEmail(notificationsLst);
        }
	}
    
}
@isTest
public without sharing class Future_HandlerTest
{
	public static testMethod void Future_Handler_UT()
	{
		Future_Handler.createInitialApprovalSuccesslog('1234');
	}
	public static testMethod void notifyPortalUsers()
	{
		List<Account> createdAccountList = TestClassUtility.createAccounts(1);
		insert createdAccountList;
		
		//Create contact
		Id recid;
		if(Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact - Portal User')!=null && Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact - Portal User').getRecordTypeId()!=null)
		{
			recid = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact - Portal User').getRecordTypeId();
		}
		Contact contact1 = new Contact(
		FirstName = 'Test',
		Lastname = 'test',
		AccountId = createdAccountList[0].Id,
		Email = System.now().millisecond() + 'test@test.com',
		recordtypeid = recid
		);
		insert contact1;
		
		Profile portalProfile = [SELECT Id FROM Profile where name='OSS Community Login User - Admin'  Limit 1];
		User user1 = new User(
		Username = System.now().millisecond() + 'test12345@test.com',
		ContactId = contact1.Id,
		ProfileId = portalProfile.Id,
		Alias = 'test123',
		Email = 'test12345@test.com',
		EmailEncodingKey = 'UTF-8',
		LastName = 'McTesty',
		CommunityNickname = 'test12345',
		TimeZoneSidKey = 'America/Los_Angeles',
		LocaleSidKey = 'en_US',
		LanguageLocaleKey = 'en_US'
		);
		Database.insert(user1);
		
		set<id> accidset = new set<id>{createdAccountList[0].id};
		Future_Handler.notifyPortalUsers(accidset);
		
		User AdminUser = [Select id from User where Profile.Name = 'System Administrator' limit 1];
	}
}
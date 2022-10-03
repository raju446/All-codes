@isTest
public class CreateCRMRegEntityTest 
{
	public static testMethod void creteEntityTest()
	{
		Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM Registered Company').getRecordTypeId();
		Account acc = new Account(Name='DED Test',Account_Name_Arabic__c='DED Test',Entity_Id__c='00001',License_Expiry_Date__c=Date.today().addDays(360),
							Entity_Type__c='Private Company Limited By Shares',Entity_Status__c='Registered',Registration_Date__c=Date.today());
		insert acc;
		
		CreateCRMRegEntity.createentity(acc.id);
	}    
}
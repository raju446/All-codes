@isTest
public class DED_Schedule_Batch_issueBLFZEDTest 
{
	static testMethod void issueBLFZED()
	{
		Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM Registered Company').getRecordTypeId();
		Account acc = new Account(Name='DED Test',Account_Name_Arabic__c='DED Test',Entity_Id__c='00001',License_Expiry_Date__c=Date.today().addDays(360),
							Entity_Type__c='Private Company Limited By Shares',Entity_Status__c='Registered',Registration_Date__c=Date.today(),IssueBLFZEd__c=true);
		insert acc;
		
		Address__c addr = new Address__c(Entity__c=acc.id,State__c='Al Maryah Island',Street_Name_of_Cluster_on_the_Island__c='Test',Building_Name__c='Test',Type__c='Physical');
		insert addr;
		
		Business_Activity__c ba = new Business_Activity__c(Entity__c=acc.id,Activity_Code__c='1234',Status__c='Active',Activity_Name_Arabic__c='test',Activity_Name__c='Test');
		insert ba;
		
		Entity_Owner__c owner = new Entity_Owner__c(Entity__c=acc.id,EDOwnerID__c='1234',Owner_Full_Name_En__c='Test',Owner_Type__c='Individual',RelationShip_Start_Date__c=Date.today(),Relationship_Status__c='active',Relationship_Type__c='PARTNER_INDIVIDUAL');
		insert owner;
		
		test.startTest();
			test.setMock(HttpCalloutMock.class, new DED_issueMockHttpResponse());
            DED_Schedule_Batch_issueBLFZED Sched = new DED_Schedule_Batch_issueBLFZED ();
            String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, Sched);
        test.stopTest();
	}
	static testMethod void modifyBLFZED()
	{
		Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM Registered Company').getRecordTypeId();
		Account acc = new Account(Name='DED Test',Account_Name_Arabic__c='DED Test',Entity_Id__c='00001',License_Expiry_Date__c=Date.today().addDays(360),Data_Pushed_to_DED__c=true,
							Entity_Type__c='Private Company Limited By Shares',Entity_Status__c='Registered',Registration_Date__c=Date.today(),modifyBLFZEd__c=true);
		insert acc;
		
		Address__c addr = new Address__c(Entity__c=acc.id,State__c='Al Maryah Island',Street_Name_of_Cluster_on_the_Island__c='Test',Building_Name__c='Test',Type__c='Physical');
		insert addr;
		
		Business_Activity__c ba = new Business_Activity__c(Entity__c=acc.id,Activity_Code__c='1234',Status__c='Active',Activity_Name_Arabic__c='test',Activity_Name__c='Test');
		insert ba;
		
		Entity_Owner__c owner = new Entity_Owner__c(Entity__c=acc.id,EDOwnerID__c='1234',Owner_Full_Name_En__c='Test',Owner_Type__c='Individual',RelationShip_Start_Date__c=Date.today(),Relationship_Status__c='active',Relationship_Type__c='PARTNER_INDIVIDUAL');
		insert owner;
		
		owner.Owner_Full_Name_En__c = 'Test1';
		update owner;
		test.startTest();
			test.setMock(HttpCalloutMock.class, new DED_modifyMockHttpResponse());
            DED_Schedule_Batch_modifyBLFZED Sched = new DED_Schedule_Batch_modifyBLFZED ();
            String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, Sched);
        test.stopTest();
	}
	static testMethod void renewBLFZED()
	{
		Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM Registered Company').getRecordTypeId();
		Account acc = new Account(Name='DED Test',Account_Name_Arabic__c='DED Test',Entity_Id__c='00001',License_Expiry_Date__c=Date.today().addDays(360),
							Entity_Type__c='Private Company Limited By Shares',Entity_Status__c='Registered',Registration_Date__c=Date.today(),renewBLFZEd__c=true);
		insert acc;
		
		Address__c addr = new Address__c(Entity__c=acc.id,State__c='Al Maryah Island',Street_Name_of_Cluster_on_the_Island__c='Test',Building_Name__c='Test',Type__c='Physical');
		insert addr;
		
		Business_Activity__c ba = new Business_Activity__c(Entity__c=acc.id,Activity_Code__c='1234',Status__c='Active',Activity_Name_Arabic__c='test',Activity_Name__c='Test');
		insert ba;
		
		test.startTest();
			test.setMock(HttpCalloutMock.class, new DED_RenewMockHttpResponse());
            DED_Schedule_Batch_renewBLFZED Sched = new DED_Schedule_Batch_renewBLFZED ();
            String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, Sched);
        test.stopTest();
	}
	static testMethod void cancelBLFZED()
	{
		Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM Registered Company').getRecordTypeId();
		Account acc = new Account(Name='DED Test',Account_Name_Arabic__c='DED Test',Entity_Id__c='00001',License_Expiry_Date__c=Date.today().addDays(360),Cancellation_Date__c=Date.today(),
							Entity_Type__c='Private Company Limited By Shares',Entity_Status__c='Registered',Registration_Date__c=Date.today(),cancelBLFZEd__c=true);
		insert acc;
		
		Address__c addr = new Address__c(Entity__c=acc.id,State__c='Al Maryah Island',Street_Name_of_Cluster_on_the_Island__c='Test',Building_Name__c='Test',Type__c='Physical');
		insert addr;
		
		Business_Activity__c ba = new Business_Activity__c(Entity__c=acc.id,Activity_Code__c='1234',Status__c='Active',Activity_Name_Arabic__c='test',Activity_Name__c='Test');
		insert ba;
		
		test.startTest();
			test.setMock(HttpCalloutMock.class, new DED_CancelMockHttpResponse());
            DED_Schedule_Batch_cancelBLFZED Sched = new DED_Schedule_Batch_cancelBLFZED ();
            String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, Sched);
        test.stopTest();
	}
}
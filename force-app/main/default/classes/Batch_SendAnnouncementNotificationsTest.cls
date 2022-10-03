@isTest
public class Batch_SendAnnouncementNotificationsTest 
{
    private static testMethod void Batch_SendAnnouncementNotificationsUT()
    {
    	Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM Registered Company').getRecordTypeId(); 
    	Account acc = new Account(Name='Test',Recordtypeid=accRecordTypeId, Entity_Id__c='1111',Oracle_Party_Id__c='00001');
    	insert acc;
    	
    	List<Contact> newContacts = TestClassUtility.createContacts(1, acc.id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Community_Username__c = 'testreguser@adgm.portal';
        newContacts[0].Types_of_Services_Accessible__c = 'Company Services; Payment - Account Services; Permits Services; Visa & Letter Services';
        insert newContacts;
        
        Notice__c nt = new Notice__c(Entity__c = acc.Id, Send_Email__c=true,Type__c='Announcement',Publish__c=true);
        insert nt;
        
        SendAnnouncementEmail.invokeBatch(true,'Company User',nt.id);
        SendAnnouncementEmail.invokeBatch(false,'Company User',nt.id);
        
        Notice__c nt1 = [Select Send_Email__c from Notice__c where id=:nt.id];
        system.assertEquals(nt.Send_Email__c, true);
    }
}
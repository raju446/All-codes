public with sharing class ParticipantTriggerHandler 
{
	public static void beforeInsert(list<Amendment__c> participants)
	{
		//ParticipantTriggerHelper.mapParentSR(participants);
	}
	public static void afterInsert(list<Amendment__c> participants)
	{
		ParticipantTriggerHelper.createplaceholder(participants, null, true);
	}
	public static void afterUpdate(list<Amendment__c> participants, map<id,Amendment__c> oldmap)
	{
		ParticipantTriggerHelper.createplaceholder(participants,oldmap,false);
	}
	public static void beforeDelete(list<Amendment__c> participants)
	{
		system.debug('==before delete====');
		ParticipantTriggerHelper.deleteSRDoc(participants);
	}
}
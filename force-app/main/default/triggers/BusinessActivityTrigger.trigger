trigger BusinessActivityTrigger on Business_Activity__c (after insert) 
{
	if(trigger.isInsert && trigger.isAfter){
		BusinessActivityTriggerHandler.Trigger_AI(trigger.new);
	}
}
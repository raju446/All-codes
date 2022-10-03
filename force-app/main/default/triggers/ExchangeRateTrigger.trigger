trigger ExchangeRateTrigger on Exchange_Rate__c (After insert) {
	if(trigger.isAfter){
        if(trigger.isInsert){
            ExchangeRateTriggerHandler.Execute_AI(trigger.newmap);
        }
    }
}
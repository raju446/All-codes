trigger OpportunityTrigger on Opportunity (after insert, after update, before insert, before update) {
    if(trigger.isAfter){
        if(trigger.isInsert)
            OpportunityTriggerHandler.Execute_AI(trigger.new);
        else if(trigger.isUpdate)
            OpportunityTriggerHandler.Execute_AU(trigger.new,trigger.oldmap);
    }
}
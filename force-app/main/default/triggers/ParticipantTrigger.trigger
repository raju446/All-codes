trigger ParticipantTrigger on Amendment__c (before delete, after insert, after update, before insert) {
    
    if(trigger.isInsert && trigger.isBefore){
        ParticipantTriggerHandler.beforeInsert(trigger.new);
    }
    if(trigger.isInsert && trigger.isAfter){
        ParticipantTriggerHandler.afterInsert(trigger.new);
    }
    if(trigger.isUpdate && trigger.isAfter){
        ParticipantTriggerHandler.afterUpdate(trigger.new,trigger.oldmap);
    }
    if(trigger.isDelete && trigger.isBefore){
        ParticipantTriggerHandler.beforeDelete(trigger.old);
    }
}
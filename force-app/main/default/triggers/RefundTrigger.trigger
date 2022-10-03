trigger RefundTrigger on Refund__c (before insert, before update, after insert, after update) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            RefundTriggerHandler.handleBI(Trigger.new);
        }
        if(Trigger.isUpdate){
            RefundTriggerHandler.handleBU(Trigger.new, trigger.oldMap);
        }
    }else if(Trigger.isAfter){
        if(Trigger.isInsert){
            RefundTriggerHandler.handleAI(Trigger.new);
        }
        if(Trigger.isUpdate){
            RefundTriggerHandler.handleAU(Trigger.new, trigger.oldMap);
        }
    }
}
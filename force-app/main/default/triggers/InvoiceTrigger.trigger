trigger InvoiceTrigger on Invoice__c (before insert,after insert, before update,after update) {
    if(trigger.isBefore && trigger.isInsert){
        
        InvoiceTriggerHandler.Execute_BI(trigger.new);
    }
    if(trigger.isBefore && trigger.isUpdate){
        InvoiceTriggerHandler.Execute_BU(trigger.new,trigger.oldmap);
    }
    if(trigger.isAfter){
        if(trigger.isInsert){
            InvoiceTriggerHandler.Execute_AI(trigger.new);
        }else if(trigger.isUpdate){
            InvoiceTriggerHandler.Execute_AU(trigger.new,trigger.oldmap);
        }
    }
}
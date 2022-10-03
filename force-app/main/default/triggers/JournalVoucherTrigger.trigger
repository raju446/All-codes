trigger JournalVoucherTrigger on Journal_Header__c (after insert, after update) {
    
    if(trigger.isAfter){
        if(trigger.isInsert){
            JournalVoucherTriggerHandler.Execute_AI(trigger.new);
        }
        
        if(trigger.isUpdate){
            JournalVoucherTriggerHandler.Execute_AU(Trigger.newMap, Trigger.oldMap);
        }
    }
    
}
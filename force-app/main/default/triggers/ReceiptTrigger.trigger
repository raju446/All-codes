trigger ReceiptTrigger on Receipt__c (before insert,after insert, before update,after update) {
    if(trigger.isBefore && trigger.isInsert){
        for(Receipt__c rep:trigger.new){
            if(rep.Receipt_Date__c==null)
                rep.Receipt_Date__c = system.now();
        }
        ReceiptTriggerHandler.Execute_BI(trigger.new);
    }
    if(trigger.isBefore && trigger.isUpdate){
        ReceiptTriggerHandler.Execute_BU(trigger.new,trigger.oldmap);
    }
    if(trigger.isAfter){
        if(trigger.isInsert){
            ReceiptTriggerHandler.Execute_AI(trigger.new);
        }else if(trigger.isUpdate){
            ReceiptTriggerHandler.Execute_AU(trigger.new,trigger.oldmap);
        }
    }
}
trigger InvoiceLineItemTrigger on Invoice_Line_Item__c (before insert,after insert, before update,after update, before delete) {
    if(trigger.isBefore && trigger.isInsert){
        
        InvoiceLineItemTriggerHandler.Execute_BI(trigger.new);
    }
    if(trigger.isBefore && trigger.isUpdate){
        InvoiceLineItemTriggerHandler.Execute_BU(trigger.new,trigger.oldmap);
    }
    
    
    if(trigger.isAfter){
        if(trigger.isInsert){
            InvoiceLineItemTriggerHandler.Execute_AI(trigger.new);
        }else if(trigger.isUpdate){
            InvoiceLineItemTriggerHandler.Execute_AU(trigger.new,trigger.oldmap);
        }
        
    }
}
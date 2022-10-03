/*
    Author      : Durga Prasad
    Date        : 07-May-2020
    Description : Trigger handler for RA_Receipt_Invoice_TriggerHandler.
    ---------------------------------------------------------------------
*/
trigger RA_InvoiceLineItemTrigger on RA_Invoice_Line_Item__c (after insert, after update, before insert, before update) {
    if(trigger.IsAfter && trigger.IsInsert)
        RA_InvoiceLineItemTriggerHandler.Execute_AI(Trigger.new);
}
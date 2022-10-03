trigger CustomerInvoiceReceiptTrigger on Customer_Invoice_Receipt__c (before insert,before update) {
    if(trigger.IsInsert && Trigger.IsBefore)
        CustomerInvRtTriggerHandler.Execute_BI(Trigger.New);
    if(trigger.IsUpdate&& Trigger.IsBefore)
        CustomerInvRtTriggerHandler.Execute_BU(Trigger.New,Trigger.OldMap);
}
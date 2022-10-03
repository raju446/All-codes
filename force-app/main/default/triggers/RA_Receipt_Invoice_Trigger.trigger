/*
    Author      : Durga Prasad
    Date        : 06-May-2020
    Description : Trigger to Populate Entity on Transactional object and create them as Receipts and Invoices.
    ----------------------------------------------------------------------------------------------------------
*/
trigger RA_Receipt_Invoice_Trigger on RA_Receipt_Invoice__c (before insert,after insert,before update,after update) {
	if(trigger.IsInsert){
		if(trigger.IsBefore)
			RA_Receipt_Invoice_TriggerHandler.Execute_BI(Trigger.new);
		else
			RA_Receipt_Invoice_TriggerHandler.Execute_AI(Trigger.new);
	}
	if(trigger.IsUpdate){
		if(trigger.IsBefore)
			RA_Receipt_Invoice_TriggerHandler.Execute_BU(Trigger.new,Trigger.OldMap);
		else
			RA_Receipt_Invoice_TriggerHandler.Execute_AU(Trigger.new,Trigger.OldMap);
	}
}
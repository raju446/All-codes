/*
    Author      : Durga Prasad
    Date        : 24-June-2020
    Description : ReceiptDescription Trigger
    -------------------------------------------------------------------------------------
*/
trigger ReceiptDescriptionTrigger on Receipt_Description__c (before insert,before update) {
    if(trigger.IsBefore){
        if(trigger.IsInsert)
            ReceiptDescriptionTriggerHandler.Execute_BI(Trigger.New);
        if(trigger.IsUpdate)
            ReceiptDescriptionTriggerHandler.Execute_BU(Trigger.New,Trigger.OldMap);
    }
}
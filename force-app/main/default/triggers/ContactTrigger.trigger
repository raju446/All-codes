trigger ContactTrigger on Contact (after insert, before update, before insert, after update) {
    if(trigger.isAfter){
        if(trigger.isInsert){
            ContactTriggerHandler.Execute_AI();
            ContactTriggerHandler.createPortalUser(trigger.New); //reference the creation of portal user
        }
        if(trigger.isUpdate){
            ContactTriggerHandler.Execute_AU(Trigger.New,trigger.oldmap);
        }
    }
    if(trigger.isBefore){
        if(trigger.isUpdate){
            ContactTriggerHandler.Execute_BU();
            ContactTriggerHandler.populatePreviousCompanyName(trigger.New, trigger.oldmap); //populates the Previous Company Name of contact is reparented
        }
        if(trigger.isInsert){
            Trigger_Settings__c TS = Trigger_Settings__c.getValues('ContactTrgr_PopulateAccountForContact');
            ContactTriggerHandler.Execute_BI();
            if(TS != null && TS.is_Active__c == TRUE){
                ContactTriggerHandler.populateAccountForContact(trigger.New);
            }
        }
    }
}
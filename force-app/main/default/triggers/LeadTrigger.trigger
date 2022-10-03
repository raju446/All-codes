/*********************LeadTrigger********************/
/***
***Author:  Rajil
***Date:    09-Jul-2018
***/
trigger LeadTrigger on Lead( before insert,before update, after update, after insert){
    Trigger_Settings__c TS = Trigger_Settings__c.getValues('LeadTrigger');
    if(TS != null && TS.is_Active__c == TRUE){
        if(Trigger.isBefore){
            if(Trigger.isInsert)
                LeadTriggerHandler.Execute_BI(Trigger.new);
            if(Trigger.isupdate)
                LeadTriggerHandler.Execute_BU(Trigger.new,trigger.oldmap);
        }else if(Trigger.isAfter){
            if(Trigger.isUpdate){
                LeadTriggerHandler.Execute_AU(Trigger.New,trigger.oldmap);
                //CRM Support
                //Adding chatter post when the primary contact is inserted/Updated
                LeadTriggerHandler.primaryContactUpdateNotification(Trigger.New,trigger.oldmap);
            }
            if(Trigger.isInsert){
                LeadTriggerHandler.Execute_AI(trigger.New);
                //CRM Support
                //Adding chatter post when the primary contact is inserted/Updated
                LeadTriggerHandler.primaryContactUpdateNotification(trigger.New,null);
            }
        }
    }
}
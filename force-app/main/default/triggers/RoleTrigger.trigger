/*
    Author      : Kim Noceda
    Date        : 08-Jan-2018
    Description : Trigger for Role__c
    --------------------------------------------------------------------------------------
*/
trigger RoleTrigger on Role__c (after insert, after update, before insert, before update) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            RoleTriggerHandler.Execute_BI(trigger.new);
        }else if(trigger.isUpdate){
            RoleTriggerHandler.Execute_BU(trigger.new,trigger.oldmap);
        }
    }else{
        if(trigger.isInsert){
            RoleTriggerHandler.Execute_AI(trigger.new);
        }
        if(trigger.isUpdate){
            RoleTriggerHandler.Execute_AU(trigger.new,trigger.oldmap);
        }
    }
}
/*
    Author      : Kim Noceda
    Date        : 03-Apr-2018
    Description : Trigger for Notice__c
    --------------------------------------------------------------------------------------
*/
trigger NoticeTrigger on Notice__c (after insert, after update, before insert, before update) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            NoticeTriggerHandler.Execute_BI(trigger.new);
        }else if(trigger.isUpdate){
            NoticeTriggerHandler.Execute_BU(trigger.new,trigger.oldmap);
        }
    }else{
        if(trigger.isInsert){
            NoticeTriggerHandler.Execute_AI(trigger.new);
        }
        if(trigger.isUpdate){
            NoticeTriggerHandler.Execute_AU(trigger.new,trigger.oldmap);
        }
    }
}
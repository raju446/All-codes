/*
    Author      : Durga Prasad
    Date        : 17-Sep-2017
    Description : Trigger for Account
    --------------------------------------------------------------------------------------
*/
trigger AccountTrigger on Account (after insert, after update, before insert, before update) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            AccountTriggerHandler.Execute_BI(trigger.new);
        }else if(trigger.isUpdate){
            AccountTriggerHandler.Execute_BU(trigger.new,trigger.oldmap);
        }
    }else{
        if(trigger.isInsert){
            AccountTriggerHandler.Execute_AI(trigger.new,trigger.oldmap);//
        }
        if(trigger.isUpdate){
            AccountTriggerHandler.Execute_AU(trigger.new,trigger.oldmap,trigger.newmap);
        }
        
    }
}
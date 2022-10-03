trigger TaskTrigger on Task (before insert,before update,after insert, after update,after undelete, after delete) {
    if(Trigger.isInsert && Trigger.isBefore){
        TaskTriggerHandler.doBI(Trigger.new);
    }

    if(Trigger.isInsert && Trigger.isAfter){
        //CRM Support
        //This method will also update Last_Contact_Date__c field on lead for email and Call tasks
        TaskTriggerHandler.doAI(Trigger.new);
    }

    if(Trigger.isUpdate && Trigger.isBefore){
        TaskTriggerHandler.doBU(Trigger.new);
    }

    if(Trigger.isUpdate && Trigger.isAfter){
        TaskTriggerHandler.doAU(Trigger.new,Trigger.oldMap);
    }
    if(Trigger.isAfter){
        //CRM Support
        //Update count of Email activity on Lead
        TaskTriggerHandler.updateEmailConterOnLead(trigger.New,trigger.old);
    }
}
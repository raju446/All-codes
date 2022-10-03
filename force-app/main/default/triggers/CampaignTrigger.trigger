trigger CampaignTrigger on Campaign (after insert, before update, after update, before insert) {
    if(Trigger.isInsert && Trigger.isAfter)
        CampaignTriggerHandler.Execute_AI(Trigger.new);
    if(Trigger.isUpdate && Trigger.isBefore)
        CampaignTriggerHandler.Execute_BU(Trigger.new,Trigger.oldMap);
    if(Trigger.isBefore && Trigger.isInsert){
        CampaignTriggerHandler.Execute_BI(Trigger.new);
    }
    
    if(Trigger.isUpdate && Trigger.isAfter)
        CampaignTriggerHandler.Execute_AU();
}
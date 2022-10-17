trigger OpportunityTrigger on Opportunity (after update) {
    Opportunity oppt = new Opportunity();
for(Opportunity oppt:Trigger.New){
    oppt.Primary__c=true;
Account acc =New Account();{
acc.id=oppt.Accountid;
acc.Opportunity__c=oppt.id; 
update acc;
}
}
}
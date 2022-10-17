public with sharing class Contactrole 
{
    @AuraEnabled
    public static list<OpportunityContactRole> getRelatedList(id recordId)
    {
        List<OpportunityContactRole> Conlist = [SELECT Contact__c,Role,Title__c,Opportunity.Id FROM OpportunityContactRole where OpportunityId=: recordId ];
        return Conlist;
    }
}
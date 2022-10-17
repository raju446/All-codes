public with sharing class Contactapex
{
    @AuraEnabled( cacheable = true )
    public static list<OpportunityContactRole> getRelatedList(id recordId)
    {
        List<OpportunityContactRole> Conlist = [SELECT Contact.Name,Contact.Title,Role,Opportunity.Id From OpportunityContactRole where OpportunityId=: recordId ];
        return Conlist;
    }
}
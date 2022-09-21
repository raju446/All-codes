public with sharing class Opportunutyhelp {
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getAccountList(string accId) {
        return [SELECT Id, Name, StageName, CloseDate, AccountId      
            FROM Opportunity where StageName = 'Prospecting' And AccountId=:accId];
    }

    }
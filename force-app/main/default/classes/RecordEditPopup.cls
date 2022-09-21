public with sharing class RecordEditPopup {
    @AuraEnabled(cacheable=true)
    public static List<student2__c> getOpportunities(){
        return [SELECT id, Name, gender__c, fees__c, marks__c, results__c FROM student2__c WHERE Name = 'Closed Won' LIMIT 20];
    }
}
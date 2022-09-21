public with sharing class  editpopup {
    @AuraEnabled(cacheable=true)
    public static List<student2__c> getOpportunities(){
        return [SELECT id, Name, results__c, marks__c, gender__c, fees__c FROM student2__c];
    }
}
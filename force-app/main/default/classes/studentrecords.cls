public with sharing class studentrecords {
    @AuraEnabled(cacheable=true)
    public static List<student2__c> getstudent2List() {
        return [SELECT Id, Name, gender__c, fees__c,
                marks__c, results__c
            FROM student2__c];
    }
}
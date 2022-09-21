public with sharing class apexclass1 {
    @AuraEnabled
    public static List<student1__c> getUserList() {
        return [Select id,name,email_id__c,fees__c,gender__c FROM student1__c ];
    }
}
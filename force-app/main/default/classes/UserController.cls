public with sharing class UserController {
    @AuraEnabled
    public static List<student2__c> getUserList() {
        return [Select id,name,gender__c,fees__c,marks__c FROM student2__c ];
    }
}
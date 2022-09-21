public with sharing class result {

    @AuraEnabled(cacheable=true)
    public static List<student2__c> retrieveContactData(string keySearch){       

        List<student2__c> contactList = [Select Id,Name,gender__c,teacher2__r.Name From student2__c  Where teacher2__r.Name =:KeySearch];
        return contactList;
    }
}
public with sharing class teachersearch {

    @AuraEnabled(cacheable=true)
    public static List<student2__c> retrieveContactData(string keySearch){       
        
        List<student2__c> contactList = [Select Id,Name,gender__c,fees__c,results__c,marks__c From student2__c Where teacher2__r.Name=:keySearch];
        return contactList;
    }
}
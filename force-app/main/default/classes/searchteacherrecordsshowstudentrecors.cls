public with sharing class searchteacherrecordsshowstudentrecors {

    @AuraEnabled(cacheable=true)
    public static List<student2__c> apex1(string keySearch){       
        
        List<student2__c> contactList = [Select Id,Name,gender__c,fees__c,marks__c,results__c,teacher2__r.Name From student2__c Where teacher2__r.Name=:keySearch];
        return contactList;
    }
}
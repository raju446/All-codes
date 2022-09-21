public class apex8 {
    //public with sharing class UserController {
    @AuraEnabled
    public static List<students__c> getUserList() {
        return [Select id,name,Aadhar_number_del__c,class_no__c,fees__c,Email_id__c FROM students__c ];
    }
}
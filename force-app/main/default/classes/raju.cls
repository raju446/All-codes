public with sharing class raju {

    /*Using multiple parameter in apex  controller */
    @AuraEnabled
    public static student2__c submitScoreAction(string name,string gender,integer fees,string results){
        student2__c student = new student2__c();
        student.Name=Name;
        student.gender__c=gender;
         student.fees__c=fees;
        student.results__c=results;
        system.debug('f======'+student);

        insert student;
        return student;
    }
}
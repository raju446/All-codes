public with sharing class lwcAppExampleApex {
   

    //TEACHER REALATED STUDENTS RECORD
    @AuraEnabled(cacheable=true)
    public static List<teacher2__c> retrieveaccountRecords(){
        List<teacher2__c> accList = [Select Id,Name,fees__c From teacher2__c];
        return accList;
    }


    @AuraEnabled(cacheable=true)
    public static List<student2__c> retrievecontactRecords(string accId){
      List<student2__c> st = new  List<student2__c>();
      List<student2__c> conList = [Select Id,Name,gender__c,fees__c,marks__c,teacher2__r.id From student2__c];
      for(student2__c con:conList){
        st.add(con);
      }
      return st;
    }
}
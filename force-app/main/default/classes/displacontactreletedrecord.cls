public with sharing class displacontactreletedrecord {
   

    //Display the Contacts based on AccountId the help of event in LWc
    @AuraEnabled(cacheable=true)
    public static List<teacher2__c> retrieveAccountRecords(){
        List<teacher2__c> accList = [Select Id, Name From teacher2__c];
        return accList;
    }


    @AuraEnabled(cacheable=true)
    public static List<student2__c> retrieveContactRecords(string accId){
      List<student2__c> conObj = new  List<student2__c>();
      List<student2__c> conList = [Select Id,name,gender__c,marks__c,results__c,teacher2__r.id From student2__c Where teacher2__r.id=:accId];
      for(student2__c con:conList){
        conObj.add(con);
      }
      return conObj;
    }
}
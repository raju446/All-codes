public with sharing class searchAccountController {
 
 @AuraEnabled
 public static List < student2__c > fetchAccount(String searchKeyWord) {
  String searchKey = searchKeyWord + '%';
  List < student2__c > returnList = new List < student2__c > ();
  List < student2__c > student1 = new list<student2__c>();
  student1 = [select id, Name,fees__c,gender__c,marks__c,results__c from student2__c
                                   where gender__c ='male']; 
  for (student2__c acc:student1) {
      returnList.add(acc);
  }  
     return returnList;
 }
}
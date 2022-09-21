@isTest
public class student_count {
    static testmethod void genderchange(){
       student2__c ui = new student2__c();{
          ui.marks__c=50;
        ui.fees__c=100000;
        ui.gender__c='Male';
       ui.results__c='pass';
           
        insert ui;
       } 
  }
}
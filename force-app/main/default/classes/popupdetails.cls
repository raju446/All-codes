public with sharing class popupdetails {

  
    // Create a lightning-datatable and display modal on rowaction
    @AuraEnabled(cacheable=true)
    public static List<student2__c> getDataFromContact(){
      List<student2__c> conList = [Select Id,Name,gender__c,fees__c,marks__c,results__c,teacher2__r.Name From student2__c];
      try{
         return conList;
      }
      catch(Exception e){
         throw new AuraHandledException(e.getMessage());
      }
    }

}
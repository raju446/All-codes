global class samplestudent implements Database.Batchable <sObject>,Database.Stateful,Schedulable {  
    global samplestudent(){
    }
    Set<id> successRecord = new Set<id>();
    Set<id> failRecord = new Set<id>();
   
 global Database.QueryLocator start(Database.BatchableContext info){
        String SOQL='Select id,name,marks__c, fees__c,(select id, name from student2__r) from teacher2__c';
       return Database.getQueryLocator(SOQL);
   }    
   global void execute(Database.BatchableContext info, List<teacher2__c> scope){
       List<teacher2__c> accsToUpdate = new List<teacher2__c>();
       List<student2__c> cUpdate = new List<student2__c>();
       for(teacher2__c a : scope)
          {
           a.marks__c=2021;
           a.fees__c= 7000;
           accsToUpdate.add(a);
           for (student2__c c:a.student2__r){
               c.name = 'REDDY';
               c.chekbox__c=true;
               c.marks__c=99;
               cUpdate.add(c);
           }
       }      
       Database.SaveResult[] srList = Database.update(accsToUpdate, false);
       Database.SaveResult[] srList1 = Database.update(cUpdate, false);


       for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                successRecord.add(sr.getId());
            }
           
    else {
        for(Database.Error err : sr.getErrors()) {
        }
            failRecord.add(sr.getId());
    }
  }
       
        for (Database.SaveResult sr : srList1) {
            if (sr.isSuccess()) {
                successRecord.add(sr.getId());
            }
    else {
        for(Database.Error err : sr.getErrors()) {
        }
        
          failRecord.add(sr.getId());
    }
  }


   }    
   global void finish(Database.BatchableContext info){
   // Get the ID of the AsyncApexJob representing this batch job
   // from Database.BatchableContext.
   // Query the AsyncApexJob object to retrieve the current job's information.
   AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
      TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :info.getJobId()];
     
   // Send an email to the Apex job's submitter notifying of job completion.
   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       
   String[] toAddresses = new String[] {a.CreatedBy.Email};
   mail.setToAddresses(toAddresses);
   mail.setSubject('Teacher and student update' + a.Status);
   mail.setPlainTextBody
       
   ('The batch Apex job processed ' + a.TotalJobItems +
   ' batches with '+ a.NumberOfErrors + ' failures.'+successRecord+'successRecordids: '+ 'failRecordids: '+ failRecord);
   Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   }
 
   
    global void execute(SchedulableContext SC){
        database.executeBatch(new samplestudent(),100);
       //for cron expression
        // String cronexpression = ‘0 0 0 ? * * *’
       // System.schedule(‘Testing’, cronexpression, testobj);        
    }
}
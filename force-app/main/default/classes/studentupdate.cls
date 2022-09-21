global class studentupdate implements Database.Batchable <SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc){
        String Query='Select id,gender__c from student2__c';
        return Database.getQueryLocator(Query);
            }
            
    global void execute(Database.BatchableContext bc, List<student2__c> qlist){
        for(student2__c q:qlist){
            q.gender__c ='female';
            
        }
        update qlist;
    }

    global void finish(Database.BatchableContext bc){
         
    }
}
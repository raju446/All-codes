global without sharing class Schedule_DeleteInitialApprovals implements Schedulable{

    global void execute (SchedulableContext SC){
        database.executeBatch(new Batch_DeleteInactiveInitialApprovals(),10);
    }
}
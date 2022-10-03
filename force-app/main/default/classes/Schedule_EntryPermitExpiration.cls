global without sharing class Schedule_EntryPermitExpiration implements Schedulable{

    global void execute (SchedulableContext SC){
        database.executeBatch(new Batch_EntryPermitExpirationAlerts(),50);
    }
}
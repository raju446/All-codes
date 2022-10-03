/*
    Author      : Kim Noceda
    Date        : 22-Nov-2017
    Description : Scheduled job that references SetPOBoxtoCancelledBatch.
    --------------------------------------------------------------------------------------
*/
global without sharing class SetPOBoxtoCancelledSchedule implements Schedulable {
  global void execute(SchedulableContext SC){
        SetPOBoxtoCancelledBatch poBoxBatch = new SetPOBoxtoCancelledBatch();
        database.executeBatch(poBoxBatch,200);
    }
}
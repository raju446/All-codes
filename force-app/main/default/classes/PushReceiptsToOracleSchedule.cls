/*
    Author      : Kim Noceda
    Date        : 30-Jan-2017
    Description : Schedule class to reference Batch_PushReceiptsToOracle batch class
    --------------------------------------------------------------------------------------
*/
global without sharing class PushReceiptsToOracleSchedule implements Schedulable {
  global void execute(SchedulableContext SC){
        Batch_PushReceiptsToOracle btch = new Batch_PushReceiptsToOracle();
        database.executeBatch(btch,10);
    }
}
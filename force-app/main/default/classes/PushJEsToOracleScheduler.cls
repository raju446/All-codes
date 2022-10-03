/*
    Author      : Anu Saxena
    Date        : 29-Nov-2021
    Description : Schedule class to reference Batch_PushJEsToOracle batch class
    --------------------------------------------------------------------------------------
*/
global without sharing class PushJEsToOracleScheduler implements Schedulable {
  global void execute(SchedulableContext SC){
        //Batch_PushJEsToOracle btch = new Batch_PushJEsToOracle();
        Batch_PushJEsToOracle_New btch = new Batch_PushJEsToOracle_New();
        database.executeBatch(btch,100);
    }
}
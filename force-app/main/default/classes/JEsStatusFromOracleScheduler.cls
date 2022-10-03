/*
    Author      : Anu Saxena
    Date        : 29-Nov-2021
    Description : Schedule class to reference Batch_JEsStatusFromOracle batch class
    --------------------------------------------------------------------------------------
*/
global without sharing class JEsStatusFromOracleScheduler implements Schedulable {
  global void execute(SchedulableContext SC){
        Batch_JEsStatusFromOracle btch = new Batch_JEsStatusFromOracle();
        database.executeBatch(btch,1);
    }
}
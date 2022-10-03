/*
    Author      : Kim Noceda
    Date        : 29-Apr-2018
    Description : Schedule class to reference Batch_PushInvoicesToOracle batch class
    --------------------------------------------------------------------------------------
*/
global without sharing class PushInvoicesToOracleSchedule implements Schedulable {
  global void execute(SchedulableContext SC){
        Batch_PushInvoicesToOracle btch = new Batch_PushInvoicesToOracle();
        database.executeBatch(btch,10);
    }
}
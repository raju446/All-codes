/*
    Author      : Azmath
    Date        : 09-Jul-2020
    Description : Schedule class to reference DED_Batch_issueBLFZED class
    --------------------------------------------------------------------------------------
*/
global without sharing class DED_Schedule_Batch_issueBLFZED  implements Schedulable
{
  global void execute(SchedulableContext SC){
        DED_Batch_issueBLFZED  btch = new DED_Batch_issueBLFZED();
        database.executeBatch(btch,1); 
    }
}
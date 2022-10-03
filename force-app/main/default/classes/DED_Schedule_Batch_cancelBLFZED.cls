/*
    Author      : Azmath
    Date        : 09-Jul-2020
    Description : Schedule class to reference DED_Batch_cancelBLFZED class
    --------------------------------------------------------------------------------------
*/
global without sharing class DED_Schedule_Batch_cancelBLFZED implements Schedulable
{
    global void execute(SchedulableContext SC){
        DED_Batch_cancelBLFZED  btch = new DED_Batch_cancelBLFZED();
        database.executeBatch(btch,1);
    }
}
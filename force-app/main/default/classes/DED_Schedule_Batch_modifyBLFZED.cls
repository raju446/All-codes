/*
    Author      : Azmath
    Date        : 09-Jul-2020
    Description : Schedule class to reference DED_Batch_modifyBLFZED class
    --------------------------------------------------------------------------------------
*/
global without sharing class DED_Schedule_Batch_modifyBLFZED implements Schedulable
{
    global void execute(SchedulableContext SC){
        DED_Batch_modifyBLFZED  btch = new DED_Batch_modifyBLFZED();
        database.executeBatch(btch,1);
    }
}
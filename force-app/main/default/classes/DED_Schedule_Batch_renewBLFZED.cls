/*
    Author      : Azmath
    Date        : 09-Jul-2020
    Description : Schedule class to reference DED_Batch_renewBLFZED class
    --------------------------------------------------------------------------------------
*/
global without sharing class DED_Schedule_Batch_renewBLFZED implements Schedulable
{
    global void execute(SchedulableContext SC){
        DED_Batch_renewBLFZED  btch = new DED_Batch_renewBLFZED();
        database.executeBatch(btch,1);
    }
}
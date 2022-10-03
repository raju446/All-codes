/*
    Author      : Durga Prasad
    Date        : 02-Jan-2018
    Description : Schedule Class to create the Company Alerts
    -------------------------------------------------------------------------------------------
*/
global without sharing class Schedule_CreateCompanyAlerts implements Schedulable{
    global void execute (SchedulableContext SC){
        database.executeBatch(new Batch_CreateCompanyAlerts());
    }
}
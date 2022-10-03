/*
    Author      : Kim Noceda
    Date        : 04-Jan-2018
    Description : Trigger for Appointment__c
    --------------------------------------------------------------------------------------
*/
trigger AppointmentTrigger on Appointment__c (before update,before insert){
    if(trigger.isBefore){
        if(trigger.isUpdate){
            AppointmentTriggerHandler.populateRescheduleCtr(trigger.new, trigger.oldMap);
        }
        if(trigger.isInsert && trigger.isBefore){
            AppointmentTriggerHandler.checkDuplicateAppointment(trigger.new);
        }
    }
}
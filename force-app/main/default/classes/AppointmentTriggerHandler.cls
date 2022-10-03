/*
    Author      : Kim Noceda
    Date        : 04-Jan-2018
    Description : Trigger handler class that is being referenced in the AppointmentTrigger.
                  All DML methods are being handled in this handler class.
    ***************************************************************************
    Version    :v0.1
    Author     : Azmath
    Change     : created a method "checkDuplicateAppointment" to check the duplicate appointments.
    --------------------------------------------------------------------------------------
*/
public without sharing class AppointmentTriggerHandler{

    //method to count the number of reschedules of an appointment
    public static void populateRescheduleCtr(List<Appointment__c> newAppointments, Map<Id, Appointment__c> oldAppointmentsMap){
        for(Appointment__c objApp : newAppointments){
            if(objApp.Appointment_Master__c != oldAppointmentsMap.get(objApp.Id).Appointment_Master__c){
                if(objApp.Count_of_Re_Schedule__c == null){
                    objApp.Count_of_Re_Schedule__c = 1;
                } else{
                    objApp.Count_of_Re_Schedule__c = objApp.Count_of_Re_Schedule__c + 1;
                }
            }
        }
    }
    public static void checkDuplicateAppointment(List<Appointment__c> appts){        
        set<id> SRIDs = new set<id>();
        set<id> existingSRIDs = new set<id>();
        for(Appointment__c app : appts){
            SRIDs.add(app.Service_Request__c);
        }
        for(Appointment__c app : [Select id,Service_Request__c from Appointment__c where Service_Request__c IN:SRIDs]){
            existingSRIDs.add(app.Service_Request__c);
        }
        for(Appointment__c app : appts){
            if(existingSRIDs.contains(app.Service_Request__c)){
                app.addError('Appointment already created');
            }
        }
        
        
    }
}
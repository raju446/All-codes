/*  
    Author      : Durga Prasad
    Date        : 15-Nov-2018
    Name        : Batch_GenericExpiryNotificationsSchedule
    Description : Schedule class that will be scheduled on daily basis to notify customer on card / license expiry.
    ----------------------------------------------------------------------------------------------------------------
*/
global class Batch_GenericExpiryNotificationsSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        Batch_GenericExpiryNotifications b = new Batch_GenericExpiryNotifications();
        database.executebatch(b,200); 
    }
}
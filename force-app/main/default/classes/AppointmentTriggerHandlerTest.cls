@isTest
public with sharing class AppointmentTriggerHandlerTest {
    public static  List<Appointment_Master__c> createdAppointmentList; 
    private static  Appointment__c createdAppointment; 
    private static List<Appointment__c> ls;
    
    public static void init(){
	    
	    createdAppointmentList = TestUtility.createAppointmentMasters(system.today(),system.today().addDays(7),'9:00 am',5);
	    insert createdAppointmentList;
	    
	    createdAppointment = new Appointment__c();
	    createdAppointment.Appointment_Master__c = createdAppointmentList[0].Id;
	    
	    insert createdAppointment;
	   
	    
	    createdAppointmentList = TestUtility.createAppointmentMasters(system.today(),system.today().addDays(7),'9:00 pm',5);
	    insert createdAppointmentList;	
	    
	    createdAppointment.Appointment_Master__c = createdAppointmentList[0].Id;
	   
	    update createdAppointment;
    }
    
    
    
    public static testmethod void TestAppointmentTriggerHandler(){
    	init();
		    	
    } 
    
    
}
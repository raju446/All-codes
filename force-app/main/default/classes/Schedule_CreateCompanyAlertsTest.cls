@isTest
public with sharing class Schedule_CreateCompanyAlertsTest {
 
    public static testMethod void testschedule() {

	    Test.StartTest();
		Schedule_CreateCompanyAlerts sh1 = new Schedule_CreateCompanyAlerts();
		String sch = '0 0 23 * * ?'; 
		system.schedule('Test Territory Check', sch, sh1); 
		Test.stopTest(); 
    }
}
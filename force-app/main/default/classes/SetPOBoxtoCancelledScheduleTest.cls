@isTest
public with sharing class SetPOBoxtoCancelledScheduleTest {
    
    public static testmethod void testcase(){
		Test.startTest();
    	SetPOBoxtoCancelledSchedule con = new SetPOBoxtoCancelledSchedule();
    	String sch = '0 0 23 * * ?';
		system.schedule('Test Territory Check', sch, con); 
        Test.stopTest();
    }
}
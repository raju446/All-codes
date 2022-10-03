/*
*Author : Azmath
*Description :Test class for participant trigger and its handler,helper classes.
*/
@isTest
public class ParticpantTriggerTest 
{
    private static testMethod void ParticpantTriggerUT() 
    {
        list<HexaBPM__Service_Request__c> sr = ADPTestDataFactory.createcustomerandSR('Temporary_Fit_Out_Security_Clearance',1);
        Amendment__c am = ADPTestDataFactory.createParticipant( 'Test',  'TestAr',  '1234',sr[0].id, 'India');
        am.Contractor_Name__c ='ABC';
        update am; 
        delete am;
    }
}
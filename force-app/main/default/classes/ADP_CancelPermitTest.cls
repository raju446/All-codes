/*
*Author : Azmath
Description : Test class for ADP_CancelPermit.
*/
@istest
public with sharing class ADP_CancelPermitTest 
{
    private static testMethod void ADP_CancelPermitUT() 
    {
        HexaBPM__SR_Template__c temp = new HexaBPM__SR_Template__c();
        temp.HexaBPM__Active__c = true;
        temp.Name='Extended Operating Hours';
        temp.HexaBPM__SR_RecordType_API_Name__c = 'Extended_Operating_Hours';
        insert temp;

        list<HexaBPM__Service_Request__c> srlist = ADPTestDataFactory.createcustomerandSR('Extended_Operating_Hours',1);
        srlist[0].HexaBPM__SR_Template__c = temp.id;
        update srlist;
        system.assertEquals(srlist.isEmpty(),false);
        
        HexaBPM__Step_Template__c stepTemplate = new HexaBPM__Step_Template__c(Name='Cancel Permit',HexaBPM__Code__c='Cancel_Permit',HexaBPM__Step_RecordType_API_Name__c='General',HexaBPM__Summary__c='Cancel Permit');
        insert stepTemplate;

        HexaBPM__Status__c stepStatus = new HexaBPM__Status__c(Name='Awaiting Approval',HexaBPM__Type__c='Start',HexaBPM__Code__c='AWAITING_APPROVAL');
        insert stepStatus;

        HexaBPM__SR_Steps__c srSteps = new HexaBPM__SR_Steps__c(HexaBPM__SR_Template__c=temp.id,HexaBPM__Step_Template__c=stepTemplate.id,
            HexaBPM__Start_Status__c=stepStatus.id,HexaBPM__Active__c=true,HexaBPM__Summary__c='Cancel Permit',
            HexaBPM__Step_RecordType_API_Name__c='General',HexaBPM__Step_Type__c='Quick Action',HexaBPM__Group_Name__c='Cancellation/Fines');
        insert srSteps;
        
        test.startTest();
            Apexpages.StandardController sc = new Apexpages.StandardController(srlist[0]);
            ADP_CancelPermit acp = new ADP_CancelPermit(sc);
            acp.confirmCancel();
        test.stopTest();
    }
}
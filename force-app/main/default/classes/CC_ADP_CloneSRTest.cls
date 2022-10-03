/*
*Author : Azmath
Description : Test class for CC_ADP_CloneSR
*/
@isTest
public class CC_ADP_CloneSRTest 
{
    private static testMethod void  CC_ADP_CloneSR_UT() 
    {
        list<HexaBPM__Service_Request__c> srlist = ADPTestDataFactory.createcustomerandSR('Extended_Operating_Hours',1);
        system.assertEquals(srlist.isEmpty(),false);
        HexaBPM__Step_Template__c stemplate = ADPTestDataFactory.createstepTemplate('TYPING', 'Test');
        HexaBPM__Status__c status           = ADPTestDataFactory.createStatus('APPLICATION_SUBMITTED', 'APPLICATION_SUBMITTED');
        HexaBPM__SR_Status__c srstatus      = ADPTestDataFactory.createSRstatus('INVOICE_GENERATED','INVOICE GENERATED','End');
        srlist[0].HexaBPM__Internal_SR_Status__c = srstatus.id;
        update srlist[0];

        HexaBPM__Service_Request__c am      = ADPTestDataFactory.createamendment(srlist[0].HexaBPM__Customer__c,srlist[0].id);
        am.Reason_of_Cancellation__c = null;
        am.Start_Date__c = Date.today();
        am.End_Date__c = Date.today().addDays(1);
        am.Location__c = 'ADGM';
        update am;
        SRDocTriggerHandlerTest.createMasterData();

        test.startTest();
        HexaBPM__SR_Doc__c srdoc = ADPTestDataFactory.createSRDoc(srlist[0].id,'Extended Business Hours Permit');//Id srid,string docname)
        Amendment__c pa = ADPTestDataFactory.createParticipant('Test','Testar','1233',srlist[0].id,'India');
        HexaBPM__Step__c actionitem         = ADPTestDataFactory.createactionitem('Typing', stemplate.id, am.id, status.id);
        CC_ADP_CloneSR cc = new CC_ADP_CloneSR();
        cc.EvaluateCustomCode(am, actionitem);

        CC_ADP_CancelPermit cc1 = new CC_ADP_CancelPermit();
        cc1.EvaluateCustomCode(am, actionitem);
        test.stopTest();
    }
}
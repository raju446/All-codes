/*
*Author : Azmath
Description : Test class for CC_PushtoADP and ADPJson
*/
@isTest
public class CC_PushtoADPTest
{
    private static testMethod void CC_PushtoADPUT()
    {
        List<sObject> ls = Test.loadData(ADP_AttributesMapping__c.sObjectType, 'ADPTestData');
        system.assertEquals(ls.isEmpty(),false);
        list<HexaBPM__Service_Request__c> srlist = ADPTestDataFactory.createcustomerandSR('Temporary_Fit_Out_Security_Clearance',1);
        HexaBPM__Step_Template__c stemplate = ADPTestDataFactory.createstepTemplate('TYPING', 'Test');
        HexaBPM__Status__c status           = ADPTestDataFactory.createStatus('APPLICATION_SUBMITTED', 'APPLICATION_SUBMITTED');
        HexaBPM__Step__c actionitem         = ADPTestDataFactory.createactionitem('Typing', stemplate.id, srlist[0].id, status.id);
        Amendment__c part                   = ADPTestDataFactory.createParticipant('Test','Test','1234',srlist[0].id,'India');
        Business_Activity__c ba             = ADPTestDataFactory.createBusinessActivity('Test','TestAr','1234',srlist[0].HexaBPM__Customer__c);
        Trade_Name__c tr                    = ADPTestDataFactory.createdTradename(srlist[0].HexaBPM__Customer__c,'Test','Test');
        SRDocTriggerHandlerTest.createMasterData();
        HexaBPM__SR_Doc__c srdoc            = ADPTestDataFactory.createSRDoc(srlist[0].id,'Test');
        Address__c a                        = ADPTestDataFactory.createAddress(srlist[0].HexaBPM__Customer__c);
        test.setMock(HttpCalloutMock.class, new ADP_MockHttpRespSubmitRequest());
        
        test.startTest();
            CC_PushtoADP cc = new CC_PushtoADP();
            cc.EvaluateCustomCode(srlist[0],actionitem);
        test.stopTest();
    }
    private static testMethod void CC_PushtoADPUT1()  
    {
        list<HexaBPM__Service_Request__c> srlist = ADPTestDataFactory.createcustomerandSR('Extended_Operating_Hours',1);
        system.assertEquals(srlist.isEmpty(),false);
        HexaBPM__Step_Template__c stemplate = ADPTestDataFactory.createstepTemplate('TYPING', 'Test');
        HexaBPM__Status__c status           = ADPTestDataFactory.createStatus('APPLICATION_SUBMITTED', 'APPLICATION_SUBMITTED');
        HexaBPM__SR_Status__c srstatus      = ADPTestDataFactory.createSRstatus('INVOICE_GENERATED','INVOICE GENERATED','End');
        srlist[0].HexaBPM__Internal_SR_Status__c = srstatus.id;
        update srlist[0];
        HexaBPM__Service_Request__c am      = ADPTestDataFactory.createamendment(srlist[0].HexaBPM__Customer__c,srlist[0].id);
        HexaBPM__Step__c actionitem         = ADPTestDataFactory.createactionitem('Typing', stemplate.id, am.id, status.id);
        
        
        
        
        test.startTest();
            CC_PushtoADP cc = new CC_PushtoADP();
            cc.EvaluateCustomCode(am,actionitem);
        test.stopTest();
        
    }
}
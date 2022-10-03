@isTest
public class CC_ADP_CreateCommercialLicenseDocTest
{
    private static testMethod void CC_ADP_CreateCommercialLicenseDocUT()
    {
        list<HexaBPM__Service_Request__c> srlist = ADPTestDataFactory.createcustomerandSR('Temporary_Fit_Out_Security_Clearance',1);
        system.assertEquals(srlist.isEmpty(),false);
        
        HexaBPM__Step_Template__c stemplate = ADPTestDataFactory.createstepTemplate('TYPING', 'Test');
        HexaBPM__Status__c status           = ADPTestDataFactory.createStatus('APPLICATION_SUBMITTED', 'APPLICATION_SUBMITTED');
        HexaBPM__Step__c actionitem         = ADPTestDataFactory.createactionitem('Typing', stemplate.id, srlist[0].id, status.id);
        Attachment att = ADPTestDataFactory.createAttachment(srlist[0].HexaBPM__Customer__c);
        actionitem = [Select id, HexaBPM__SR__c, HexaBPM__SR__r.HexaBPM__Customer__c from HexaBPM__Step__c where id=:actionitem.id];
        test.startTest();
            CC_ADP_CreateCommercialLicenseDoc cc = new CC_ADP_CreateCommercialLicenseDoc();
            cc.EvaluateCustomCode(srlist[0],actionitem);
        test.stopTest();
    }
}
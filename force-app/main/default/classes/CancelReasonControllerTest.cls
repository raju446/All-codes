@isTest
public class CancelReasonControllerTest
{
    public static testMethod void CancelReasonController_UT()
    {
        List<HexaBPM__Service_Request__c> createdSRList; 
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        insert createdSRList;
        ApexPages.StandardController SC = new ApexPages.StandardController(createdSRList[0]);
        CancelReasonController cr = new CancelReasonController(SC);
        cr.confirmCancel();
        cr.sr.Reason_of_Cancellation__c = 'Test';
        cr.confirmCancel();
    }
}
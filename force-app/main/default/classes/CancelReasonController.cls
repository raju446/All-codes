/*****************************************
Author : Azmath
Description : This class will be invoked when user Clicks on Cancel Request
              from SR detail page for the internal users to capture the 
              cancellation reason.
******************************************/
public without sharing class CancelReasonController
{
    public HexaBPM__Service_Request__c sr {get;set;}
    public CancelReasonController(ApexPages.StandardController controller)
    {
        sr = new HexaBPM__Service_Request__c();
        if(controller.getId() != null)
        {
            sr = [SELECT id,Name,Reason_of_Cancellation__c  FROM HexaBPM__Service_Request__c WHERE ID=:controller.getId()];
        }
    }
    public pageReference confirmCancel()
    {
        try{
        if(sr.Reason_of_Cancellation__c == null || sr.Reason_of_Cancellation__c  == '')
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Please enter cancellation reason.'));
            return null;
        }
        update sr;
        CancelServiceRequest.createCancelStep(sr.id);
        }catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,ex.getMessage()));
            return null;
        }
        return new pageReference('/'+sr.id).setRedirect(true);
    }
}
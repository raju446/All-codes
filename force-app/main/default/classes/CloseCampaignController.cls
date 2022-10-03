/*
    Author      :   Yogesh Mahajan 
    Class Name  :   CloseCampaignController
    Description :   It is used as a controller for close an campaign Lightning Component 
    Date        :   02/27/2019
*/
public without sharing class CloseCampaignController {
    // Constants
    private static final String ERROR_MSG = 'Please add documents before closing the campaign.';
    private static final String SUCESS_MSG = 'Campaign has been closed successfully';
    private static final String ALREADY_CLOSED = 'Campaign is already been closed';
    private static final String NOT_APPROVED_CLOSED = 'Campaign is not Approved by HOD';
    private static final String COMPLETED_STATUS = 'Completed'; 
    private static final String REVIEW_STATUS = 'Under Review'; 
    private static final String APPROVED_HOD_STATUS = 'Approved by HOD'; 
    private static final String APPROVED_MAR_STATUS = 'Approved by Marketing'; 
    private static final String IN_PROGRESS_STATUS = 'In Progress';
    /*
    Name : validationBeforecloseCampaign
    Description : check camapign status & attachment
    */
    @AuraEnabled  
    public static String validationBeforecloseCampaign(Id campaignId) {
        List<Campaign> listCampaign = new List<Campaign>([SELECT ID, Status, RecordType.Name, CRM_Approval_Status__c, CRM_Approval_Required__c,Main_Category__c FROM Campaign WHERE ID =: campaignId ]);
        
        // If status is already closed
        if(listCampaign == null || listCampaign[0].Status == COMPLETED_STATUS) {
            return ALREADY_CLOSED;
        }
        
        // If status is already closed
        if((listCampaign == null || listCampaign[0].Status <> IN_PROGRESS_STATUS) && listCampaign[0].Main_Category__c <> 'Event Nomination / Joint Committee Meeting') {
            return 'Close campaign is allowed on event In Progress status.';
        }
        
        // If status is already closed
        if(listCampaign == null || listCampaign[0].CRM_Approval_Status__c <> APPROVED_HOD_STATUS && listCampaign[0].CRM_Approval_Required__c) {
            return NOT_APPROVED_CLOSED;
        }     
        
        return SUCESS_MSG;
    }//end validationBeforecloseCampaign()
    
    /*
    Name : closeCampaign
    Description : make camapign status 'Completed'
    */
    @AuraEnabled  
    public static String closeCampaign(Id campaignId) {
        
        Campaign objCampaign = new Campaign();
        objCampaign.id = campaignId;
        objCampaign.Status = COMPLETED_STATUS;
        objCampaign.CRM_Start_Feedback_Process__c = true;		// Added by prateek.b.bansal@pwc.com on 18 Jan.
        objCampaign.CRM_Close_Date__c = system.now();
        try {
            update objCampaign;
            
        } catch(Exception ex){
            return ex.getMessage();
        }
        return SUCESS_MSG;
        
    }
}//end class
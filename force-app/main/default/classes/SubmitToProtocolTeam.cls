/*
    Author      :   Yogesh Mahajan 
    Class Name  :   SubmitToProtocolTeam
    Description :   It is used as a controller for Lightning Component (LEX_SubmitToProtocolTeam)
    Date        :   02/20/2019      
*/
public without sharing class SubmitToProtocolTeam {
    private static final String SUCESS_MSG = 'Campaign has been submitted successfully.';
    /*
        Method Name : submitCampaign
        Description : Used to assign the campaign to Protocol team member
    */
     @AuraEnabled  
    public static String submitCampaign(String campaignId) {
        List<Campaign> listCamp = new List<Campaign>([SELECT id, CRM_Submit_to_Protocol_Team__c	 FROM Campaign WHERE ID =:campaignId]);
        if(listCamp <> null && listCamp.size() > 0 && listCamp[0].CRM_Submit_to_Protocol_Team__c	 ) {
            return 'The record is already been submitted.';
        } else  if(listCamp <> null && listCamp.size() > 0 && !listCamp[0].CRM_Submit_to_Protocol_Team__c	){
            listCamp[0].CRM_Submit_to_Protocol_Team__c	 = true;
            try {
                update listCamp;
            } catch ( exception ex) {
                return ex.getMessage();
            }//end try- catch
        }//end if
        
        return SUCESS_MSG;
    }//end 
}
/*
    Author      :   Yogesh Mahajan 
    Class Name  :   SendEmailController
    Description :   It is used as a controller for the send Invite Lightning Component 
    Date        :   02/20/2019
*/
public without sharing  class SendEmailController {
    
    // Constants
    Private static final string SUCCESS_MSG = 'Success';
    Private static final string DUPLICATE_GROUP = 'Please add other group. Current group is already exit.';
    Private static final string TEMPLATE_ERROR = 'Please select email template';
    private static final String ALREADY_CLOSED = 'Campaign is already been closed';
    private static final String COMPLETED_STATUS = 'Completed'; 
    private static final String IN_PROGRESS_STATUS = 'In Progress';
    private static final String PENDING_STATUS = 'Pending';
    private static final String EMAIL_LIMIT_MSG = 'Send email limit exceeded. Please try to send email tomorrow';
    /*
    Name : getRecipientsData
    Description : all CampaignMember related to Campaign
    */
    @AuraEnabled  
    public static List<CampaignMemberWrapper> getRecipientsData(String campaignId, Boolean isExternal) {
        String eventName;
        
        // Fetch campaign data        
        List<Campaign> listCampaign = new List<Campaign>([SELECT id, Main_Category__c, CRM_Feedback_Required__c FROM Campaign WHERE id=:campaignId ]);
        
        if(listCampaign <> null && listCampaign.size() > 0) {
            List<CampaignMemberWrapper> listCampaignMemberWrapper = new List<CampaignMemberWrapper>();
            CampaignMemberWrapper objCampaignMemberWrapper;
            //call dynamic SOQL
            String soqlQuery = '';
            // Add all the query fields
            List<String> listFieldAPINames = new List<String>();
            // fields to query 
            listFieldAPINames.add('Id');
            listFieldAPINames.add('Name');
            listFieldAPINames.add('Email');
            listFieldAPINames.add('ContactId');
            listFieldAPINames.add('CRM_Internal_Invitee__c');
            listFieldAPINames.add('CRM_Email_Sent__c');
            listFieldAPINames.add('CRM_Group__c');
            listFieldAPINames.add('CampaignID');
            listFieldAPINames.add('Campaign.Name');
            listFieldAPINames.add('CRM_Send_Feedback_Email__c');
            listFieldAPINames.add('CRM_Attachment_Ids__c');
            listFieldAPINames.add('CRM_Email_Template_Id__c');
            
            DynamicSOQLUtility dynamicSOQLUtility = new DynamicSOQLUtility();
            // Call select function
            soqlQuery = dynamicSOQLUtility.createSelect(listFieldAPINames , 'CampaignMember');
            if(campaignId <> null && campaignId <> '' && isExternal) {
                //add where clause
                soqlQuery = dynamicSOQLUtility.addWhereCondition(soqlQuery, 'CampaignID', campaignId, '=');
                soqlQuery = dynamicSOQLUtility.addWhereCondition(soqlQuery, 'CRM_Internal_Invitee__c', false, '=', 'AND');
            }
            
            if(campaignId <> null && campaignId <> '' && !isExternal) {
                //add where clause
                soqlQuery = dynamicSOQLUtility.addWhereCondition(soqlQuery, 'CampaignID', campaignId, '=');
                soqlQuery = dynamicSOQLUtility.addWhereCondition(soqlQuery, 'CRM_Internal_Invitee__c', true, '=', 'AND');
            }
            soqlQuery = dynamicSOQLUtility.addWhereCondition(soqlQuery, 'CRM_Email_Sent__c', false, '=','AND');
            
            if(campaignId <> null && campaignId <> '') {
                for(CampaignMember objCampaignMember : database.query(soqlQuery)) {                             
                    objCampaignMemberWrapper = new CampaignMemberWrapper();
                    if(!isExternal)
                        objCampaignMember.CRM_Send_Feedback_Email__c = listCampaign[0].CRM_Feedback_Required__c;
                    objCampaignMemberWrapper.campaignMemberRec = objCampaignMember; 
                    objCampaignMemberWrapper.isFeedbackRequired = listCampaign[0].CRM_Feedback_Required__c;
                    objCampaignMemberWrapper.isSelected = false;
                    listCampaignMemberWrapper.add(objCampaignMemberWrapper);
                    
                }//end for
                if(listCampaignMemberWrapper <> null && listCampaignMemberWrapper.size() > 0) {
                    return listCampaignMemberWrapper;
                }//end if
            }//end if
        }//end if
        
        return null;
    }//end fetchRecipientData()
    
    /*
    Name : getEmailTempletesData
    Description : get email template data
    */
    @AuraEnabled  
    public static List<EmailTemplate> getEmailTempletesData() {
        List<EmailTemplate> listEmailTempletes = new List<EmailTemplate>();
        
        listEmailTempletes = [SELECT id
                                    , Name
                                    , DeveloperName 
                                    , TemplateType 
                                    , Description
                              FROM EmailTemplate 
                              WHERE Folder.Name =: Label.Protocol_Email_Template_Folder_Name AND
                                IsActive = true];
        if(listEmailTempletes <> null && listEmailTempletes.size() > 0) {
            return listEmailTempletes;
        }//end if
        return null;        
    }//end getEmailTempletesData()
    
    /*
    Name : sendEmailToAllCampaignMembers
    Description : Send an email to all the selected invitee
    */
    @AuraEnabled  
    public static String sendEmailToAllCampaignMembers(List<CampaignMemberWrapper> listInternalCampaignMember, List<CampaignMemberWrapper> listExternalCampaignMember, EmailTemplate objEmailTemplate, Boolean isBCC, String orgWideId, List<String> listAttIds, String delegatedBy) {
        
        List<CampaignMemberWrapper> listCampaignMemberWrapper = new List<CampaignMemberWrapper>();
        
        if(listInternalCampaignMember <> null) {
            listCampaignMemberWrapper.addAll(listInternalCampaignMember);
        }
        if(listExternalCampaignMember <> null) {
            listCampaignMemberWrapper.addAll(listExternalCampaignMember);
        }
        
        if(objEmailTemplate <> null && listCampaignMemberWrapper <> null) {
            try {
                Messaging.reserveSingleEmailCapacity(listCampaignMemberWrapper.size());
                // instantiate a new instance of the Queueable class
                SendEventEmail updateJob = new SendEventEmail(listCampaignMemberWrapper, objEmailTemplate, orgWideId, listAttIds, delegatedBy);
                // enqueue the job for processing
                ID jobID = System.enqueueJob(updateJob);
            } catch (exception ex) {
                return EMAIL_LIMIT_MSG;
            }
             
        } else {
            return TEMPLATE_ERROR;
        }//end else - if
            
        
        return SUCCESS_MSG;
    }
    
    /*
    Name : getCampaignAttachment
    Description : get all current campaign attachment
    */
    @AuraEnabled  
    public static List<ContentVersion> getCampaignAttachment(String campaignId) {
        Set<Id> setContentDocumentId = new Set<Id>();
        for(ContentDocumentLink objContentDocumentLink : [SELECT ContentDocumentId 
                 FROM ContentDocumentLink 
                 WHERE LinkedEntityId  =: campaignId ]) {
            setContentDocumentId.add(objContentDocumentLink.ContentDocumentId);    
        }//end for
        return  [SELECT id,FileType, Title, ContentSize 
                 FROM ContentVersion 
                 WHERE islatest = true 
                    AND ContentDocumentId IN: setContentDocumentId ];
    }
    
    
    /*
    Name : createEmailTemplate
    Description : clone email template
    */
    @AuraEnabled
    public static List<EmailTemplate> createEmailTemplate (String templateID) {
        EmailTemplate currentTemplate = [SELECT DeveloperName,Body,BrandTemplateId,Encoding,FolderId,HtmlValue,IsActive, Markup, Name, RelatedEntityType, Subject, TemplateType, UIType FROM emailtemplate WHERE id =: templateID];
        EmailTemplate objNewTemplate = currentTemplate.clone(false, false, false, false);
        String todayDateTime = (String.valueOf(system.now())).replace(' ', '_');
        todayDateTime = todayDateTime.replace('-', '_');
        todayDateTime = todayDateTime.replace(':', '_');
        objNewTemplate.DeveloperName = objNewTemplate.DeveloperName + '_'+todayDateTime;
        objNewTemplate.Name = objNewTemplate.Name + ' Clone';
        try {
            if(objNewTemplate <> null)
                insert objNewTemplate; 
        } catch(Exception ex) {
            system.debug('Exception------>'+ex.getMessage());
        }
        return getEmailTempletesData();
    }
    
    /*
    Name : getApprovedStatus
    Description : check current capmpaign status
    */
    @AuraEnabled  
    public static String getApprovedStatus(String campaignId) { 
        List<Campaign> listCamp = new List<Campaign>();
        Set<String> listCampStatus = new Set<String>();
        listCampStatus.add('Approved by HOD');
        listCampStatus.add('Approved by Marketing');
        listCamp = [SELECT id, status,RecordType.DeveloperName, CRM_Approval_Status__c, CRM_Approval_Required__c, CRM_Meeting_Date_Time__c  FROM Campaign WHERE id =: campaignId];
        if(listCamp <>  null && listCamp.size() > 0) {
            if(listCamp[0].status == COMPLETED_STATUS) {
                return ALREADY_CLOSED;
            }//end if
            
            if(listCamp[0].status <> IN_PROGRESS_STATUS && listCamp[0].RecordType.DeveloperName <> 'CRM_Government_Event' && listCamp[0].RecordType.DeveloperName <> 'CRM_MBZ_Majlis_Lecture' && listCamp[0].RecordType.DeveloperName <> 'CRM_Event_Nomination_Joint_Committee_Meeting') {
                return 'Send email is allowed on event In Progress status.';
            }//end if
            
            Date campDate = date.newinstance(listCamp[0].CRM_Meeting_Date_Time__c.year(), listCamp[0].CRM_Meeting_Date_Time__c.month(), listCamp[0].CRM_Meeting_Date_Time__c.day());
            
            if(campDate <= system.now()) {
                return 'Event start date should be greater than today. Please change event start date.';
            }//end if
            
            if((listCampStatus.contains(listCamp[0].CRM_Approval_Status__c) && listCamp[0].CRM_Approval_Required__c )
               || !listCamp[0].CRM_Approval_Required__c){
                   return SUCCESS_MSG;
               } else {
                   return 'Campaign is not Approved by HOD';
               }//end if       
            
            
        }//end if
                
        return null;
    }//end getApprovedStatus()
    
    /*
    Name : getGroups
    Description : get campaign member group picklist values
    */
    @AuraEnabled  
    public static List<LEX_Helper.PicklistValueWrapper> getGroups(String fieldAPIname, Boolean nullRequired) {
        return LEX_Helper.getPicklistValues('CampaignMember', fieldAPIname, nullRequired);
    }//end  getGroups()
    
    /*
    Name : getAllOrgWideEmail
    Description : get all Org Wide Email
    */
    @AuraEnabled  
    public static List<OrgWideEmailAddress> getAllOrgWideEmail() {
        Set<String> listEmailAdd = new Set<String>(); 
        List<CRM_Send_Email_Configuration__mdt> listSendEmailConfiguration = new List<CRM_Send_Email_Configuration__mdt>();
        for(CRM_Send_Email_Configuration__mdt objSendEmail :  [SELECT id, MasterLabel, CRM_Email__c FROM CRM_Send_Email_Configuration__mdt]) {
            listEmailAdd.add(objSendEmail.CRM_Email__c);
        }
        List<OrgWideEmailAddress> listOrgwide = new List<OrgWideEmailAddress>();
        If(listEmailAdd <> null) {
            listOrgwide = [SELECT ID, Address, DisplayName FROM OrgWideEmailAddress WHERE Address IN:listEmailAdd];
        }
        
        return listOrgwide;
    }// end getAllOrgWideEmail()
    
   
    public class CampaignMemberWrapper {
        @AuraEnabled public CampaignMember campaignMemberRec {get;set;}
        @AuraEnabled public Boolean isSelected {get;set;}
        @AuraEnabled public Boolean isFeedbackRequired {get;set;}
    }//end ReceiptsWrapper
}//end class
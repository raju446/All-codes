/*
Author      :   Yogesh Mahajan 
Class Name  :   SendEventEmail
Description :   It is used send bulk email to campaign member
Date        :   02/20/2019
*/
public without sharing class SendEventEmail implements Queueable {
    
    private List<SendEmailController.CampaignMemberWrapper> listCampaignMemberWrapper;
    private EmailTemplate objEmailTemplate;
    private String orgWideId;
    private List<String> listAttIds;
    private String delegatedBy;
    
    
    
    public SendEventEmail (List<SendEmailController.CampaignMemberWrapper> listCampaignMemberWrapper, EmailTemplate objEmailTemplate, String orgWideId, List<String> listAttIds, String delegatedBy) {
        this.listCampaignMemberWrapper = listCampaignMemberWrapper;
        this.objEmailTemplate = objEmailTemplate;
        this.orgWideId = orgWideId;
        this.listAttIds = listAttIds;
        this.delegatedBy = delegatedBy;
    }
    
    
    public void execute(QueueableContext context) {
        
        List<Messaging.Emailfileattachment> listFileAttachments = new List<Messaging.Emailfileattachment>();
        // List Selected CampaignMember contact
        List<string> lstContactId = new List<string>();
        // List Selected CampaignMember contact update
        List<Contact> lstContactToUpdate = new List<Contact>();
        Contact objContact;
        // List Selected CampaignMember
        List<string> lstCampaignMemberId = new List<string>();
        // List Selected CampaignMember to update
        Map<Id, CampaignMember> mapCampaignMemberToUpdate = new Map<Id, CampaignMember>();
        CampaignMember objCampaignMember ;
        // List single email to send.
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        if(objEmailTemplate <> null && listCampaignMemberWrapper <> null) {
            // get email attachment
            IF(listAttIds <> NULL) {               
                for(ContentVersion objContentVersion : [SELECT pathOnClient, VersionData, FileType FROM ContentVersion WHERE Id IN:listAttIds]) {
                    Messaging.Emailfileattachment emailfileattachment = new Messaging.Emailfileattachment();
                    emailfileattachment.setFileName(objContentVersion.pathOnClient);
                    emailfileattachment.setBody(objContentVersion.VersionData);
                    listFileAttachments.add(emailfileattachment);
                }//end for
            }//END IF
            
            
            Map<String, String> mapContactWithCampaignId = new Map<String, String>();
            set<Id> campaignIdSet = new set<Id>();        //added by prateek.b.bansal
            for(SendEmailController.CampaignMemberWrapper objCampaignMemberWrapper : listCampaignMemberWrapper) {
                // get all selected records
                if(objCampaignMemberWrapper.isSelected) {
                    
                    // Make Email_Sent_to_Member true for CampaignMember
                    objCampaignMember = new CampaignMember();
                    objCampaignMember = objCampaignMemberWrapper.campaignMemberRec;
                    objCampaignMember.CRM_Email_Sent__c = true;
                    objCampaignMemberWrapper.campaignMemberRec.CRM_Attachment_Ids__c = String.join(listAttIds,',');
                    objCampaignMemberWrapper.campaignMemberRec.CRM_Email_Template_Id__c = String.valueOf(objEmailTemplate.id);
                    if(String.valueOf(objCampaignMemberWrapper.campaignMemberRec.CRM_Group__c) == 'None') {
                        objCampaignMemberWrapper.campaignMemberRec.CRM_Group__c = null;
                    }
                    
                    mapCampaignMemberToUpdate.put(objCampaignMember.Id, objCampaignMember);
                    // update Campaign Id in contact
                    mapContactWithCampaignId.put(objCampaignMember.ContactId, objCampaignMember.CampaignId);
                    campaignIdSet.add(objCampaignMember.CampaignId);            //added by prateek.b.bansal
                    // Create Send Email list
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    
                    mail.setTemplateId(objEmailTemplate.id);                        
                    mail.setTargetObjectId(objCampaignMember.ContactId);
                    system.debug('orgWideId==>>' + orgWideId);
                    if(orgWideId <> null && orgWideId <> '' && orgWideId  <> 'None') {
                        mail.setOrgWideEmailAddressId(orgWideId);
                    }
                    
                    
                    
                    if(listFileAttachments <> null && listFileAttachments.size() > 0) 
                    mail.setFileAttachments(listFileAttachments);
                    mail.setSaveAsActivity(false);
                    mail.setUseSignature(false);
                    mails.add(mail);
                }//end if
                system.debug('mails==>>' + mails);
                system.debug('mails==>>' + mails.size());
                // Update Group Value in CampaignMember
                if(String.valueOf(objCampaignMemberWrapper.campaignMemberRec.CRM_Group__c) <> 'None' 
                   && String.valueOf(objCampaignMemberWrapper.campaignMemberRec.CRM_Group__c) <> ''
                   && String.valueOf(objCampaignMemberWrapper.campaignMemberRec.CRM_Group__c) <> null) {
                       if(mapCampaignMemberToUpdate.get(objCampaignMemberWrapper.campaignMemberRec.Id) <> null) {
                           mapCampaignMemberToUpdate.get(objCampaignMemberWrapper.campaignMemberRec.Id).CRM_Email_Sent__c = true;
                       } else {
                           mapCampaignMemberToUpdate.put(objCampaignMemberWrapper.campaignMemberRec.Id, objCampaignMemberWrapper.campaignMemberRec);
                       }//end else - if 
                   }//end if
            } //end for
            //added by prateek.b.bansal  
            Map<Id, String> campaignVirtualVenueMap = new Map<Id, String>();
            if(campaignIdSet != null && campaignIdSet.Size() > 0){
                for(Campaign campaignObj : [SELECT Id, Virtual_Venue__c FROM Campaign WHERE Id IN : campaignIdSet]){
                    if(String.isNotBlank(campaignObj.Virtual_Venue__c)){
                        campaignVirtualVenueMap.put(campaignObj.Id, campaignObj.Virtual_Venue__c);    
                    }
                }
            }//end of changes
            if(mapContactWithCampaignId <> null && mapContactWithCampaignId.values().size() > 0) {
                for(Contact objCon : [SELECT id,CRM_Current_Campaign__c, CRM_Encrypted_ID__c, CRM_Delegated_By__c  FROM Contact WHERE id IN: mapContactWithCampaignId.keyset() FOR UPDATE ]) {
                    objCon.CRM_Current_Campaign__c = mapContactWithCampaignId.get(objCon.id);
                    //added by prateek.b.bansal
                    if(campaignVirtualVenueMap.containsKey(mapContactWithCampaignId.get(objCon.id))){
                        objCon.CRM_Current_Campaign_Virtual_Venue__c = campaignVirtualVenueMap.get(mapContactWithCampaignId.get(objCon.id));
                    }
                    objCon.CRM_Encrypted_ID__c = ApexCodeUtility.getEncryptedValueURL(objCon.id);
                    objCon.CRM_Delegated_By__c = delegatedBy; 
                    lstContactToUpdate.add(objCon);
                }
            }
            // Save point to rollback if exception comes
            Savepoint sp = Database.setSavepoint();
            try {
                // Update contact
                if(lstContactToUpdate <> null && lstContactToUpdate.size() > 0) {
                    update lstContactToUpdate;
                }
                // send emails
                if(mails <> null && mails.size() > 0) {
                    Messaging.sendEmail(mails);
                    system.debug('message sent');
                }
                // update campaign
                if(mapCampaignMemberToUpdate <> null && mapCampaignMemberToUpdate.values().size() > 0) {
                    update mapCampaignMemberToUpdate.values();
                }
            } catch (exception ex) {
                Database.rollback( sp );
                String sMessage = ex.getMessage();
                Log__c objLog = new Log__c();
                if(sMessage .length() > 240) {
                    objLog.Message__c = sMessage.subString(0,240);
                } else {
                    objLog.Message__c = sMessage;
                }//end if
                
                objLog.Line_Number__c = ex.getLineNumber();
                objLog.Stack_Trace__c =  ex.getStackTraceString();
                objLog.Type_Name__c = ex.getTypeName();
                objLog.User_Email__c = UserInfo.getUserEmail();
                insert objLog;
            }//end try - catch
        }
        
        
    }//end execute
    
}
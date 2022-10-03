/*
    Author      : Durga Prasad
    Date        : 04-Jan-2018
    Description : Custom code to send email to RI when Initial Approval happen
    --------------------------------------------------------------------------------------
*/
global without sharing class CC_CID_EmailNotifications implements HexaBPM.iCustomCodeExecutable {
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c stp) {
        string strResult = 'Success';
        if(stp!=null && stp.HexaBPM__SR__c!=null && label.R_I_Email_Address!=null){
            Contact objCon = new Contact();
            objCon.LastName = 'ADGM';
            objCon.Email = label.Initial_Approval_Contact_Email;
            insert objCon;
            
            list<Messaging.SingleEmailMessage> lstInitialApprovalEmails = new list<Messaging.SingleEmailMessage>();
            String[] ToAddresses = new String[]{label.R_I_Email_Address};
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(ToAddresses);
            if(stp.Is_Rejected__c){
                for(EmailTemplate temp:[Select Id from EmailTemplate where DeveloperName='Initial_Rejection_Email']){
                    mail.setTemplateId(temp.Id);
                }
            }else{
                for(EmailTemplate temp:[Select Id from EmailTemplate where DeveloperName='Initial_Approval_Email']){
                    mail.setTemplateId(temp.Id);
                }
            }
            mail.setSaveAsActivity(false);
            mail.setWhatId(stp.HexaBPM__SR__c);
            mail.setTargetObjectId(objCon.Id);
            
            list<Messaging.EmailFileAttachment> lstEmailAttachments = new list<Messaging.EmailFileAttachment>();
            string AttachmentId;
            for(HexaBPM__SR_Doc__c SRDoc:[Select Id,HexaBPM__Doc_ID__c from HexaBPM__SR_Doc__c where HexaBPM__Service_Request__c=:stp.HexaBPM__SR__c and HexaBPM__Document_Master__r.HexaBPM__Code__c='INITIAL_APPROVAL_REJECTION_LETTER' and HexaBPM__Doc_ID__c!=null]){
                AttachmentId = SRDoc.HexaBPM__Doc_ID__c;
            }
            if(AttachmentId!=null){
                for(Attachment attach : [Select Id,Name,Body,ContentType from Attachment where Id=:AttachmentId]){
                    Messaging.EmailFileAttachment MailAtt = new Messaging.EmailFileAttachment();
                    MailAtt.setFileName(attach.Name);
                    MailAtt.setBody(attach.Body);
                    MailAtt.setContentType(attach.contentType);
                    lstEmailAttachments.add(MailAtt);
                }
                if(lstEmailAttachments.size()>0)
                    mail.setFileAttachments(lstEmailAttachments);
            }
            lstInitialApprovalEmails.add(mail);
            system.debug('lstInitialApprovalEmails==>'+lstInitialApprovalEmails);
            try{
                Messaging.sendEmail(lstInitialApprovalEmails);
                delete objCon;
            }catch(Exception e){
                strResult = e.getMessage()+'';
            }
        }
        return strResult;
    }
}
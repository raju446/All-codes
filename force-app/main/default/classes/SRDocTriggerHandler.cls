public class SRDocTriggerHandler {
    
    //method to generate the Running number for the SR docs
    public static void generateRunningNumber(List<HexaBPM__SR_Doc__c> newSRDocList){
        //initialize Integer variables
        Integer adgmCRNOC;
        Integer adgmCRGOV;
        Integer adgmCRLTR;
        Integer adgmCRPR;
        Integer adgmCRIMM;
        
        //get Max SR Doc number for NOC Document type
        SR_Doc_Running_Number__c srDocNOC = SR_Doc_Running_Number__c.getInstance('SR_Doc_NOC');
        SR_Doc_Running_Number__c srDocGOV = SR_Doc_Running_Number__c.getInstance('SR_Doc_GOV');
        SR_Doc_Running_Number__c srDocLTR = SR_Doc_Running_Number__c.getInstance('SR_Doc_LTR');
        SR_Doc_Running_Number__c srDocPR = SR_Doc_Running_Number__c.getInstance('SR_Doc_PR');
        SR_Doc_Running_Number__c srDocCRIMM = SR_Doc_Running_Number__c.getInstance('SR_Doc_CRIMM');
                                                    
        //Assign the values to the integer variables
        adgmCRNOC = Integer.valueOf(srDocNOC.SR_Doc_Running_Number__c);
        adgmCRGOV = Integer.valueOf(srDocGOV.SR_Doc_Running_Number__c);
        adgmCRLTR = Integer.valueOf(srDocLTR.SR_Doc_Running_Number__c);
        adgmCRPR = Integer.valueOf(srDocPR.SR_Doc_Running_Number__c);
        adgmCRIMM = Integer.valueOf(srDocCRIMM.SR_Doc_Running_Number__c);
        
        //ISSUE-000643  
        map<id,string> permitNumbers = new map<id,string>();
        for(HexaBPM__SR_Doc__c srDoc : newSRDocList){
            if(srDoc.Service_Request_Name__c == 'Renew_Alcohol_Permit'){
                permitNumbers.put(srDoc.HexaBPM__Service_Request__c,srDoc.Permit_Number__c);
            }
        }
        //
        
        system.debug('====rec type name====='+newSRDocList[0].Service_Request_Name__c);
        //iterates on the sr docs to be inserted and populates the document number based on the running number per letter type
        List<SR_Doc_Running_Number__c> srDocNumList = new List<SR_Doc_Running_Number__c>();
        for(HexaBPM__SR_Doc__c srDoc : newSRDocList){
            if(srDoc.Exclude_from_Running_Number__c == false){
                if(srDoc.Letter_Type__c != NULL && srDoc.Letter_Type__c.equals('No Objection Certificate')  ){
                    //srDoc.Document_Number__c = 'ADGM/RA/CRNOC/1701' + String.valueOf(++adgmCRNOC).leftpad(4).replace(' ', '0');
                    srDoc.Document_Number__c = srDocNOC.Document_Prefix__c + String.valueOf(++adgmCRNOC).leftpad(4).replace(' ', '0');
                    srDocNOC.SR_Doc_Running_Number__c = adgmCRNOC;
                    srDocNumList.add(srDocNOC);
                }
                if(srDoc.Letter_Type__c != NULL && srDoc.Letter_Type__c.equals('Government Correspondence')  ){
                    //srDoc.Document_Number__c = 'ADGM/RA/CRGOV/1701' + String.valueOf(++adgmCRGOV).leftpad(4).replace(' ', '0');
                    srDoc.Document_Number__c = srDocGOV.Document_Prefix__c + String.valueOf(++adgmCRGOV).leftpad(4).replace(' ', '0');
                    srDocGOV.SR_Doc_Running_Number__c = adgmCRGOV;   
                    srDocNumList.add(srDocGOV);  
                }
                if(srDoc.Letter_Type__c != NULL && srDoc.Letter_Type__c.equals('Letter')  ){
                    //srDoc.Document_Number__c = 'ADGM/RA/CRLTR/1701' + String.valueOf(++adgmCRLTR).leftpad(4).replace(' ', '0'); 
                    srDoc.Document_Number__c = srDocLTR.Document_Prefix__c + String.valueOf(++adgmCRLTR).leftpad(4).replace(' ', '0'); 
                    srDocLTR.SR_Doc_Running_Number__c = adgmCRLTR;
                    srDocNumList.add(srDocLTR);   
                }
                if(srDoc.Letter_Type__c != NULL && srDoc.Letter_Type__c.equals('Permit')  ){
                    //srDoc.Document_Number__c = 'ADGM/RA/CRPR/1701' + String.valueOf(++adgmCRPR).leftpad(4).replace(' ', '0');
                    if(srDoc.Service_Request_Name__c == 'Renew_Alcohol_Permit'){
                        srDoc.Document_Number__c  = permitNumbers.get(srDoc.HexaBPM__Service_Request__c);
                    }else{
                        srDoc.Document_Number__c = srDocPR.Document_Prefix__c + String.valueOf(++adgmCRPR).leftpad(4).replace(' ', '0');
                        srDocPR.SR_Doc_Running_Number__c = adgmCRPR;
                    }
                    srDocNumList.add(srDocPR);    
                }
                if(srDoc.Letter_Type__c != NULL && srDoc.Letter_Type__c.equals('CID Approval Letter')  ){
                    //srDoc.Document_Number__c = 'ADGM/RA/CRIMM/0000' + String.valueOf(++adgmCRIMM).leftpad(4).replace(' ', '0');
                    srDoc.Document_Number__c = srDocCRIMM.Document_Prefix__c + String.valueOf(++adgmCRIMM).leftpad(4).replace(' ', '0');
                    srDocCRIMM.SR_Doc_Running_Number__c = adgmCRIMM; 
                    srDocNumList.add(srDocCRIMM);    
                }
            }
        }
        
        System.debug('@@DOC_LIST: '+srDocNumList);
        //Update Running number in custom setting
        if(!srDocNumList.isEmpty()){
            try{
                update srDocNumList;
            } catch(Exception e){
                System.debug('#ERROR: '+e.getMessage());
            }
        }
    }
    
    public static void sendEmailofIAApprovalorRejection(List<HexaBPM__SR_Doc__c> newSRDocList,map<id,HexaBPM__SR_Doc__c> oldmap)
    {
        map<id,id> srdocWithAttids = new map<id,id>();
        for(HexaBPM__SR_Doc__c srDoc : newSRDocList)
        {
            if(srDoc.Service_Request_Name__c == 'Initial_Approval' && srDoc.Name == 'Initial Approval/Rejection Letter' && 
                    srDoc.HexaBPM__Doc_ID__c != null && srDoc.HexaBPM__Doc_ID__c != oldmap.get(srDoc.id).HexaBPM__Doc_ID__c)
            {
                srdocWithAttids.put(srDoc.id,srDoc.HexaBPM__Doc_ID__c);
            }
        }
        if(!srdocWithAttids.isEmpty())
        {
            map<id,Attachment> Attachments = new map<id,Attachment>();
            list<Messaging.SingleEmailMessage> lstInitialApprovalEmails = new list<Messaging.SingleEmailMessage>();
            Id templateId = [Select Id from EmailTemplate where DeveloperName='Initial_Approval_Email'].id;
            
            for(Attachment att : [Select Id,Name,Body,Parentid,ContentType from Attachment where Id=:srdocWithAttids.values()])
            {
                Attachments.put(att.Parentid,att);
            }
            if(!Attachments.isEmpty())
            {
                String[] ToAddresses = new String[]{label.R_I_Email_Address};
                Contact objCon = new Contact();
                objCon.LastName = 'ADGM';
                objCon.Email = label.Initial_Approval_Contact_Email;
                insert objCon;
                for(HexaBPM__SR_Doc__c srDoc : [Select id, HexaBPM__Service_Request__c, Name from HexaBPM__SR_Doc__c where ID IN:srdocWithAttids.keyset()])
                {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(ToAddresses);
                    mail.setTemplateId(templateId);
                    mail.setSaveAsActivity(false);
                    mail.setWhatId(srDoc.HexaBPM__Service_Request__c);
                    mail.setTargetObjectId(objCon.Id);
                    
                    Attachment att = Attachments.get(srDoc.id);
                    if(att != null)
                    {
                        list<Messaging.EmailFileAttachment> lstEmailAttachments = new list<Messaging.EmailFileAttachment>();
                        Messaging.EmailFileAttachment MailAtt = new Messaging.EmailFileAttachment();
                        MailAtt.setFileName(att.Name);
                        MailAtt.setBody(att.Body);
                        MailAtt.setContentType(att.contentType);
                        lstEmailAttachments.add(MailAtt);
                        mail.setFileAttachments(lstEmailAttachments);
                        lstInitialApprovalEmails.add(mail);
                    }
                }
                if(!lstInitialApprovalEmails.isEmpty()){
                    Messaging.sendEmail(lstInitialApprovalEmails);
                }
                delete objCon;
            }
        }
    }
}
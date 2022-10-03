@RestResource(urlMapping='/AuthorisedSignatories/*')
global without sharing class REST_AuthorisedSignatories{
    @HttpPost
    global static ResponseDetails ProcessAuthorisedSignatories(){
        ResponseDetails objResp = new ResponseDetails();
        ResponseDetails objErrorResp = new ResponseDetails();
        
        //system.debug('Req==>'+RestContext.request.requestBody.tostring());
        AuthorisedSignatory container = new AuthorisedSignatory();
        
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM Registered Company').getRecordTypeId();
        try{
            container = (AuthorisedSignatory)System.JSON.deserialize(RestContext.request.requestBody.tostring(),AuthorisedSignatory.class);
            //system.debug('container==>'+container);
            list<Attachment> lstAttachmentsTBI = new list<Attachment>();
            if(container!=null && container.EntityId!=null && container.RoleId!=null){
                objErrorResp.RoleId = container.RoleId;
                objErrorResp.EntityId = container.EntityId;
                objErrorResp.AuthorisedSignatory_SFID = null;
                objErrorResp.StatusCode = '600';
                    
                Role__c objRole = new Role__c();
                for(Account acc:[Select Id from Account where Entity_Id__c=:container.EntityId and Recordtypeid=:accRecordTypeId]){
                    objRole.Subject_Account__c = acc.Id;
                }
                if(objRole.Subject_Account__c==null){
                    objErrorResp.Message = 'Entity not found.';
                    return objErrorResp;
                }
                if(container.PassportEvidence!=null && container.PassportEvidence.FileId!=null && container.PassportEvidence.FileId!=''){
                    objRole.Passport_Evidence_FileId__c = container.PassportEvidence.FileId;
                }else{
                    objErrorResp.Message = 'Error : Passport Evidence is missing.';
                    return objErrorResp;
                }
                
                if(container.Forenames==null || (container.Forenames!=null && container.Forenames=='')){
                    objErrorResp.Message = 'Error : Forename is missing.';
                    return objErrorResp;
                }
                if(container.CountryofResidence==null || (container.CountryofResidence!=null && container.CountryofResidence=='')){
                    objErrorResp.Message = 'Error : Country of Residence is missing.';
                    return objErrorResp;
                }
                if(container.Nationality==null || (container.Nationality!=null && container.Nationality=='')){
                    objErrorResp.Message = 'Error : Nationality is missing.';
                    return objErrorResp;
                }
                if(container.Status==null || (container.Status!=null && container.Status=='')){
                    objErrorResp.Message = 'Error : Status is missing.';
                    return objErrorResp;
                }
                
                if(container.RoleId==null || (container.RoleId!=null && container.RoleId=='')){
                    objErrorResp.Message = 'Error : RoleId is missing.';
                    return objErrorResp;
                }
                
                if(container.EvidenceOfAppointment!=null && container.EvidenceOfAppointment.FileId!=null)
                    objRole.Evidence_Of_Appointment_FileId__c = container.EvidenceOfAppointment.FileId;
                if(container.UAE_Visa_or_Entry_Stamp!=null && container.UAE_Visa_or_Entry_Stamp.FileId!=null)
                    objRole.Visa_Entry_Stamp_FileId__c = container.UAE_Visa_or_Entry_Stamp.FileId;
                if(container.UAE_NationalID!=null && container.UAE_NationalID.FileId!=null)
                    objRole.UAE_NationalId_FileId__c = container.UAE_NationalID.FileId;
                    
                objRole.Role_Id__c = container.EntityId+'-'+container.RoleId;
                objRole.Type__c = 'Authorised Signatory';
                if(container.Forenames!=null)
                    objRole.Forenames__c = container.Forenames;
                if(container.Title!=null)
                    objRole.Title__c = container.Title;
                if(container.ForenamesArabic!=null)
                    objRole.Forenames_in_Arabic__c = container.ForenamesArabic;
                if(container.Surname!=null)
                    objRole.Surname__c = container.Surname;
                if(container.SurnameArabic!=null)
                    objRole.Surname_in_Arabic__c = container.SurnameArabic;
                if(container.CountryofResidence!=null)
                    objRole.Country_of_Residence__c = container.CountryofResidence;
                if(container.Nationality!=null)
                    objRole.Nationality__c = container.Nationality;
                if(container.Status!=null)
                    objRole.Status__c = container.Status;
                
                if(container.Role!=null)
                    objRole.Role_Name__c = container.Role;
                if(container.Capacity!=null)
                    objRole.Capacity__c = container.Capacity;
                
                /*if(container.IsCIDApproval!=null && container.IsCIDApproval==true)
                    objRole.Is_CID_Approval_Pending__c = true;
                else
                    objRole.Is_CID_Approval_Pending__c = false;*/
                
                upsert objRole Role_Id__c;
                
                if(container.PassportEvidence!=null && container.PassportEvidence.FileBody!=null && container.PassportEvidence.FileBody!='' && container.PassportEvidence.FileBody!='null'){
                    Attachment objAttachment = new Attachment();
                    objAttachment.ParentId = objRole.Id;
                    objAttachment.Name = container.PassportEvidence.FileName;
                    objAttachment.ContentType = container.PassportEvidence.ContentType;
                    objAttachment.Body = EncodingUtil.base64Decode(container.PassportEvidence.FileBody);
                    objAttachment.Description = container.PassportEvidence.FileId;
                    lstAttachmentsTBI.add(objAttachment);
                }
                if(container.EvidenceOfAppointment!=null && container.EvidenceOfAppointment.FileBody!=null && container.EvidenceOfAppointment.FileBody!='' && container.EvidenceOfAppointment.FileBody!='null'){
                    Attachment objAttachment = new Attachment();
                    objAttachment.ParentId = objRole.Id;
                    objAttachment.Name = container.EvidenceOfAppointment.FileName;
                    objAttachment.ContentType = container.EvidenceOfAppointment.ContentType;
                    objAttachment.Body = EncodingUtil.base64Decode(container.EvidenceOfAppointment.FileBody);
                    objAttachment.Description = container.EvidenceOfAppointment.FileId;
                    lstAttachmentsTBI.add(objAttachment);
                }
                if(container.UAE_Visa_or_Entry_Stamp!=null && container.UAE_Visa_or_Entry_Stamp.FileBody!=null && container.UAE_Visa_or_Entry_Stamp.FileBody!='' && container.UAE_Visa_or_Entry_Stamp.FileBody!='null'){
                    Attachment objAttachment = new Attachment();
                    objAttachment.ParentId = objRole.Id;
                    objAttachment.Name = container.UAE_Visa_or_Entry_Stamp.FileName;
                    objAttachment.ContentType = container.UAE_Visa_or_Entry_Stamp.ContentType;
                    objAttachment.Body = EncodingUtil.base64Decode(container.UAE_Visa_or_Entry_Stamp.FileBody);
                    objAttachment.Description = container.UAE_Visa_or_Entry_Stamp.FileId;
                    lstAttachmentsTBI.add(objAttachment);
                }
                if(container.UAE_NationalID!=null && container.UAE_NationalID.FileBody!=null && container.UAE_NationalID.FileBody!='' && container.UAE_NationalID.FileBody!='null'){
                    Attachment objAttachment = new Attachment();
                    objAttachment.ParentId = objRole.Id;
                    objAttachment.Name = container.UAE_NationalID.FileName;
                    objAttachment.ContentType = container.UAE_NationalID.ContentType;
                    objAttachment.Body = EncodingUtil.base64Decode(container.UAE_NationalID.FileBody);
                    objAttachment.Description = container.UAE_NationalID.FileId;
                    lstAttachmentsTBI.add(objAttachment);
                }
                
                if(lstAttachmentsTBI.size()>0){
                    insert lstAttachmentsTBI;
                    list<id> attids = new list<id>();
                    for(Attachment att : lstAttachmentsTBI){
                        attids.add(att.id);
                    }
                    Update_Role_AttachmentIds.updateAttachmentIds_Future(objRole.id,attids);
                }
                
                //Create Initial Approval SR if the CIDApproval flag is true..
                if(objRole.id != null){
                    createInitialApprovalSR(objRole);
                }
                objResp.RoleId = container.RoleId;
                objResp.EntityId = container.EntityId;
                objResp.AuthorisedSignatory_SFID = objRole.Id;
                objResp.StatusCode = '200';
                objResp.Message = 'Role processed successfully.';
            }
        }catch(Exception e){
            system.debug('Exception==>'+e.getMessage());
            objResp.RoleId = container.RoleId;
            objResp.EntityId = container.EntityId;
            objResp.AuthorisedSignatory_SFID = null;
            objResp.StatusCode = '600';
            string MessageVal = e.getMessage()+'';
            if(MessageVal.indexOf('String length exceeds maximum: 6000000')>-1)
                MessageVal = 'String length exceeds maximum: 6000000';
            objResp.Message = MessageVal;
        }
        return objResp;
    }
    global class AuthorisedSignatory{
        global string RoleId;
        global string Role;
        global string Title;
        global string Forenames;
        global string Surname;
        global string ForenamesArabic;
        global string SurnameArabic;
        global string CountryofResidence;
        global string Nationality;
        global string Status;
        global Document EvidenceOfAppointment;
        global Document PassportEvidence;
        global Document UAE_Visa_or_Entry_Stamp;
        global Document UAE_NationalID;
        global string EntityId;
        global boolean isUpdate;
        global string Capacity;
        
        /* CR051 DROP 2...*/
        global boolean IsCIDApproval;
        global Integer TotalAuthorisedSignatories;
        /* CR051 END ...*/
    }
    global class Document{
        global string FileName;
        global string ContentType;
        global string FileBody;
        global string FileId;
    }
    global class ResponseDetails{
        global string AuthorisedSignatory_SFID;
        global string RoleId;
        global string EntityId;
        global string StatusCode;
        global string Message;
    }
    
    public static void createInitialApprovalSR(Role__c role){
        List<HexaBPM__Service_Request__c> objSRList = new List<HexaBPM__Service_Request__c>();
        Id cidRectypeId;
        Integer lastmns = Integer.valueof(label.Initial_Approval_Time_Range);
        Datetime dt = system.now().addMinutes(lastmns);
        for(RecordType rectype : [SELECT Id from RecordType WHERE sObjectType='HexaBPM__Service_Request__c' AND DeveloperName=:Label.Initial_Approval_Recordtype_API AND IsActive=true LIMIT 1]){
                   cidRectypeId = rectype.Id;
        }
        for(Account objAcct :[Select id,Is_Initial_Approval__c,TotalAuthorisedSignatories__c,Entity_Id__c,
                        (SELECT Id FROM Relationships__r WHERE  
                                    Type__c = 'Authorised Signatory'
                                    AND LastModifiedDate > :dt),
                         (SELECT Id from Business_Activities__r LIMIT 1)  
                         FROM Account WHERE Id =:role.Subject_Account__c  AND Is_Initial_Approval__c=true])
        {
            //system.debug('======'+objAcct.Is_Initial_Approval__c+'----'+objAcct.Relationships__r.size()+'==='+objAcct.TotalAuthorisedSignatories__c+'====='+objAcct.Business_Activities__r.size());
            if(objAcct.Is_Initial_Approval__c == true && objAcct.Relationships__r.size() == objAcct.TotalAuthorisedSignatories__c && objAcct.Business_Activities__r.size() > 0){
                HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
                objSR.License_Number__c = objAcct.Entity_Id__c;
                objSR.RecordtypeId = cidRectypeId;
                objSR.HexaBPM__Customer__c = objAcct.Id;
                objSR.HexaBPM__Email__c = UserInfo.getUserEmail();
                objSR.HexaBPM__Auto_Submit__c = true;
                objSR.IA_Reason__c = 'Request From Catalyst';
                objSRList.add(objSR);
            }
        }
        if(!objSRList.isEmpty()){
            insert objSRList;
            if(objSRList[0].id != null)
                Future_Handler.createInitialApprovalSuccesslog(objSRList[0].id);
        }
    }
}
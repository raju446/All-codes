/*
    Author      : Durga Prasad
    Date        : 17-Sep-2017
    Description : Page controller of User Access Registration form for Registered Company
    --------------------------------------------------------------------------------------
*/
public without sharing class UserRegistrationController {
    
    public HexaBPM__Service_Request__c objSR {get;set;}
    public String srTemplateCode = Label.SR_Company_User_Access_Request;
    public Boolean hasError;
    
    public String infoMessage{get;set;}
    public Boolean isUserNameAvailable {get;set;}
    public String iconURL {get;set;}
    public String guestUsername {get;set;}
    public Boolean hasErrorUsername {get;set;}
    public Boolean hasErrorformatUsername {get;set;}
    
    public Attachment objDocument{get;set;}
    public list<DocumentDetailsCls> lstDocuments{get;set;}
    public Boolean allDocsUploaded {get;set;}
    public String missedDocuments {get;set;}
    
    public Boolean hasExistingUserSR {get;set;}
    public String accountExpiryDateStr {get;set;}
    public String disclaimerText{get;set;}
    
    //public Boolean hasInvalidCIDApprovalDate {get;set;}
    public Boolean showTaxRegNum {get;set;}
    public string invalidFileMsg {get;set;}
    public UserRegistrationController(){
        objSR = new HexaBPM__Service_Request__c();
        /*for(RecordType rectyp:[Select Id from RecordType where sObjectType='HexaBPM__Service_Request__c' and DeveloperName=:srTemplateCode and IsActive=true]){
           objSR.RecordTypeId = rectyp.Id;
        }*/
        
        list<Recordtype> recType = [Select Id from RecordType where sObjectType='HexaBPM__Service_Request__c' and DeveloperName=:srTemplateCode and IsActive=true LIMIT 1];
        if(recType!=null && recType.size() > 0){
            objSR.RecordTypeId = recType[0].Id;
        }
        
        disclaimerText = '';
        list<HexaBPM__SR_Template__c> objSRTemplate = [Select Id, Disclaimer_Text__c from HexaBPM__SR_Template__c where HexaBPM__SR_RecordType_API_Name__c=:srTemplateCode LIMIT 1];
        if(objSRTemplate!=null && objSRTemplate.size()>0){
            disclaimerText = objSRTemplate[0].Disclaimer_Text__c;
        }
        
        String licenseNumParam = apexpages.currentpage().getparameters().get('licenseNumber');
        if(licenseNumParam != null && licenseNumParam != ''){
            objSR.License_Number__c = licenseNumParam;
        }
        
        hasError = false;
        hasExistingUserSR = false;
        showTaxRegNum  = false;
        //hasInvalidCIDApprovalDate = false;
        
        lstDocuments = new list<DocumentDetailsCls>();
        PrepareDocumentList();
        allDocsUploaded = true;
        missedDocuments = '';
    }
    
    public void toggletaxregNum(){
        if(objSR.Registered_for_Tax__c == 'Yes'){
            showTaxRegNum = true;
        } else{
            showTaxRegNum = false;
        }
    }
    
    public pageReference checkUName(){
        objSR.Guest_Username__c = guestUsername + '@adgm.portal';
        System.debug('@@USERNAME: '+objSR.Guest_Username__c);
        infoMessage = '';
        iconURL = '';
        isUserNameAvailable = false;
        hasErrorUsername = false;
        hasErrorformatUsername = false;
        //if(objSR.Guest_Username__c == null){
        if(guestUsername == null || guestUsername == ''){
            infoMessage = 'You can\'t have an empty username';
            iconURL = '/img/msg_icons/error16.png';
        } else{
            if(guestUsername.contains(' ') || 
                guestUsername.contains('\'') || 
                guestUsername.contains('\"') || 
                guestUsername.contains(',') ||
                guestUsername.contains(':') || 
                guestUsername.contains(';') ||
                guestUsername.contains('/')){
                 hasErrorformatUsername = true;
            } else{
                String existingUserName = ApexCodeUtility.isExistingUsername(objSR.Guest_Username__c);
                System.debug('@@EXISTUSERNAME: '+existingUserName);
                if(existingUserName != ''){
                    infoMessage = 'The username "' +existingUserName+ '" is taken or cannot be used. Try another value.';
                    iconURL = '/img/msg_icons/error16.png';
                } else{
                    String existingUserNameSR = ApexCodeUtility.isExistingUsernameSR(objSR.Guest_Username__c);
                    if(existingUserNameSR != ''){
                        infoMessage = 'The username "' +existingUserNameSR+ '" is taken or cannot be used. Try another value.';
                        iconURL = '/img/msg_icons/error16.png';
                    } else{
                        infoMessage = 'Available.';
                        isUserNameAvailable = true;
                        iconURL = '/img/msg_icons/confirm16.png';
                    }
                }
            }
        }
        /*if(objSR.Company_Name__c != null){
            if(checkExistingCompanyName(objSR.Company_Name__c) == true){
                objSR.Company_Name__c.addError('Company Name is already used.');
                hasError = true;
            }
        }*/
        if(objSR.HexaBPM__Email__c != null){
            if(checkEmail(objSR.HexaBPM__Email__c,objSR.License_Number__c) == true){
                objSR.HexaBPM__Email__c.addError('Email is already used by an existing user.'); 
                hasError = true;
            }
        }
        return null;
    }
    
    public pageReference cancelReg(){
        PageReference pageRef = new PageReference(Label.ADGM_Login_Homepage);
        pageRef.setRedirect(false);
        return pageRef;
    }
    
    public pageReference SubmitSR(){
        //System.debug('@@DOCUMENT: '+objDocument);
        objSR.Guest_Username__c = guestUsername + '@adgm.portal';
        objSR.Role__c = 'Lead Admin';
        infoMessage = '';
        iconURL = '';
        isUserNameAvailable = false;
        fieldValidation();
        
        if(objSR.Guest_Username__c != null){
            String existingUserName = ApexCodeUtility.isExistingUsername(objSR.Guest_Username__c);
            if(existingUserName != ''){
                infoMessage = 'The username "' +existingUserName+ '" is taken or cannot be used. Try another value.';
                iconURL = '/img/msg_icons/error16.png';
                hasError = true;
            } else{
                String existingUserNameSR = ApexCodeUtility.isExistingUsernameSR(objSR.Guest_Username__c);
                if(existingUserNameSR != ''){
                    infoMessage = 'The username "' +existingUserNameSR+ '" is taken or cannot be used. Try another value.';
                    iconURL = '/img/msg_icons/error16.png';
                    hasError = true;
                } 
            }
        }
        
        checkDocuments();
        validateDocuments();
        if(string.isNotEmpty(invalidFileMsg)){ //Checks for valid file type and size
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,invalidFileMsg);
            ApexPages.addMessage(myMsg);
            lstDocuments = new list<DocumentDetailsCls>();
            PrepareDocumentList();
            return null;
        }
        else{
            System.debug('##HASERROR1:' +hasError);
            if(hasError == false ){
                Savepoint sp = Database.setSavepoint();
                try{
                    insert objSR;
                    
                    createSRDoc();
                    //lstDocuments = new list<DocumentDetailsCls>();
                    
                    list<HexaBPM__SR_Status__c> srStatusSubmittedId = [SELECT Id, HexaBPM__Code__c FROM HexaBPM__SR_Status__c WHERE HexaBPM__Code__c = 'SUBMITTED'];
                    
                    if(srStatusSubmittedId!=null && srStatusSubmittedId.size()>0){
                        objSR.HexaBPM__Internal_SR_Status__c = srStatusSubmittedId[0].Id;
                        objSR.HexaBPM__External_SR_Status__c = srStatusSubmittedId[0].Id;
                        objSR.HexaBPM__Submitted_Date__c = system.today();
                        objSR.HexaBPM__Submitted_DateTime__c = system.now();
                        update objSR;
                    }
                    
                    objSR = [SELECT Id, Name FROM HexaBPM__Service_Request__c WHERE Id=:objSR.Id];
                    
                    PageReference pageRef = new PageReference('/apex/CompanyUserRegistrationThankyou?srNumber='+objSR.Name);
                    pageRef.setRedirect(true);
                    return pageRef;
                    
                } catch(Exception e){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
                    Database.rollback(sp);
                    return null;
                }finally{
                    lstDocuments = new list<DocumentDetailsCls>();
                    PrepareDocumentList();
                }
            } else{
                lstDocuments = new list<DocumentDetailsCls>();
                PrepareDocumentList();
                return null;
            }
        }
        
    }
    
    public void checkDocuments(){
        allDocsUploaded = true;
        missedDocuments = '';
        list<String> documentName = new list<String>();
        for(DocumentDetailsCls doc : lstDocuments){
            if(doc.objAttachment.Body == null && doc.isOptional == false){
                documentName.add(doc.SRDocName);
                allDocsUploaded = false;
                hasError = true;
            }
        }
        
        System.debug('@@DOCUMENTNAMES: '+documentName);
        
        if(!documentName.isEmpty()){
            for(integer i=0;i<documentName.size();i++){
                missedDocuments = missedDocuments + documentName[i];
                if(i!=documentName.size()-1){
                    missedDocuments = missedDocuments + ', ';
                }
            }
        }
    }
    public void validateDocuments(){
        //Checks File validation for the format types -- v1.1
        invalidFileMsg = '';
        for(DocumentDetailsCls doc : lstDocuments){
            if(doc.objAttachment.Name != null){
                boolean validFileType = false;
                string selectedContenttype = doc.objAttachment.ContentType;
                if(string.isNotEmpty(selectedContenttype)){
                    System.debug('selectedContenttype'+selectedContenttype);
                    String[] validContentTypes =new String[]{'jpg', 'jpeg', 'bmp', 'png', 'pdf'};
                    for(string strContentType : validContentTypes ){
                        if(selectedContenttype.indexOf(strContentType) > -1){ 
                            validFileType = true;
                            break;
                        }
                    }
                }
                if(validFileType == false){
                    invalidFileMsg = 'Please select a valid file format';
                    lstDocuments = new list<DocumentDetailsCls>();
                    PrepareDocumentList(); 
                }
                // 1MB validation
                else if(validFileType == true){
                    if(doc.objAttachment.BodyLength > 5242880) {
                        invalidFileMsg = 'Please upload a file with a maximum of 5 MB size';
                        lstDocuments = new list<DocumentDetailsCls>();
                        PrepareDocumentList();
                    }
                }
            }
        }
    }
    public void createSRDoc(){
        
        List<HexaBPM__SR_Doc__c> insertSRDoc = new List<HexaBPM__SR_Doc__c>();
        Map<String, Attachment> srDocsAttMap = new Map<String, Attachment>();
        List<Attachment> insertSRAttachments = new List<Attachment>();
        
        for(DocumentDetailsCls doc : lstDocuments){
            if(doc.objAttachment.Body != null){
                HexaBPM__SR_Doc__c srDoc = new HexaBPM__SR_Doc__c();
                srDoc.HexaBPM__From_Finalize__c = true;
                srDoc.Name = doc.SRDocName;
                srDoc.HexaBPM__Document_Master__c = doc.DocumentMasterId;
                srDoc.HexaBPM__Service_Request__c = objSR.Id;
                srDoc.HexaBPM__SR_Template_Doc__c = doc.STRTemplateDocumentId;
                srDoc.HexaBPM__Status__c = 'Pending Upload';
                srDoc.HexaBPM__Document_Description_External__c = doc.DocumentDescription;
                
                srDocsAttMap.put(srDoc.Name, doc.objAttachment);
                
                insertSRDoc.add(srDoc);
            }
        }
        try{
            if(!insertSRDoc.isEmpty()){
                insert insertSRDoc;
            }
            
            for(HexaBPM__SR_Doc__c srDoc : insertSRDoc){
                if(srDocsAttMap.containskey(srDoc.Name)){
                    Attachment att = srDocsAttMap.get(srDoc.Name);
                    att.ParentId = srDoc.Id;
                    insertSRAttachments.add(att);
                    srDoc.HexaBPM__Status__c = 'Uploaded';
                }
            }
            if(!insertSRAttachments.isEmpty()){
                insert insertSRAttachments;
            }
            update insertSRDoc;
        }catch(Exception e){
             ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
        }
    }
    
    public void fieldValidation(){
        //title is required.
        hasError = false;
        hasErrorUsername = false;
        hasErrorformatUsername = false;
        hasExistingUserSR = false;
        //hasInvalidCIDApprovalDate = false;
        System.debug('@@TITLE: '+objSR.Title__c);
        accountExpiryDateStr = '';
        // if(objSR.I_Agree__c == false){
        //     objSR.I_Agree__c.addError('Please read the terms and conditions and click on I Agree before proceeding to save the service request.');
        //     hasError = true;
        // }
        if(objSR.Title__c == null){
            objSR.Title__c.addError('Title is required.');
            hasError = true;
        }
        //first name is required.
        if(objSR.First_Name__c == null){
            objSR.First_Name__c.addError('First Name is required.');
            hasError = true;
        }
        //first name should not contain special characters
        if(objSR.First_Name__c != null){
            if(hasSpecialChars(objSR.First_Name__c) == false){
                objSR.First_Name__c.addError('Special charaters are not allowed.');
                hasError = true;
            }
        }
        //last name is required.
        if(objSR.Last_Name__c == null){
            objSR.Last_Name__c.addError('Last Name is required.');
            hasError = true;
        }
        //last name should not contain special characters
        if(objSR.Last_Name__c != null){
            if(hasSpecialChars(objSR.Last_Name__c) == false){
                objSR.Last_Name__c.addError('Special charaters are not allowed.');
                hasError = true;
            }
        }
        //date of birth - Age should be above 18.
        if(objSR.Date_of_Birth__c != null){
            Integer totalDays = objSR.Date_of_Birth__c.daysBetween(System.Today());
            Integer applicantAge = (integer)(math.Floor(totalDays/365.2425));
            if(applicantAge < 18){
                objSR.Date_of_Birth__c.addError('Applicant should be above 18 years old.');
                hasError = true;
            }
        }
        //date of birth is required.
        if(objSR.Date_of_Birth__c == null){
            objSR.Date_of_Birth__c.addError('Date of Birth is required.');
            hasError = true;
        }
        //email is required.
        if(objSR.HexaBPM__Email__c == null){
            objSR.HexaBPM__Email__c.addError('Email is required.'); 
            hasError = true;
        }
        //email is already existing.
        if(objSR.HexaBPM__Email__c != null){
            if(checkEmail(objSR.HexaBPM__Email__c,objSR.License_Number__c) == true){
                objSR.HexaBPM__Email__c.addError('Email is already used by an existing user.'); 
                hasError = true;
            }
        }
        //mobile is required.
        if(objSR.HexaBPM__Send_SMS_to_Mobile__c == null){
            objSR.HexaBPM__Send_SMS_to_Mobile__c.addError('Contact Number is required.');
            hasError = true;
        }
        //company name is required.
        /*if(objSR.Company_Name__c == null){
            objSR.Company_Name__c.addError('Company Name is required.');
            hasError = true;
        }*/
        //company name arabic is required.
        /*if(objSR.Company_Name_Arabic__c == null){
            objSR.Company_Name_Arabic__c.addError('Company Name (Arabic) is required.');
            hasError = true;
        }*/
        //License Number is required.
        if(objSR.License_Number__c== null){
            objSR.License_Number__c.addError('License Number is required.');
            hasError = true;
        }
        //License Number is valid.
        if(objSR.License_Number__c != null){
            Id acctId = checkExistingLicenseNumber(objSR.License_Number__c);
            System.debug('##ACCTID: '+acctId);
            if(acctId == null){
                objSR.License_Number__c.addError('License Number is invalid.');
                hasError = true;
            } else{
                //check if there is already an SR submitted on the Entity.
                if(checkValidLicense(acctId) == false){
                    hasError = true;
                    objSR.License_Number__c.addError('License has not been issued.');
                } else{
                    if(label.Portal_CheckLicenseExpiry == 'True' && checkExistingLicenseExpiry(acctId) == true){
                        hasError = true;
                        objSR.License_Number__c.addError('License Number is already expired on '+accountExpiryDateStr);
                    } else{
                        objSR.HexaBPM__Customer__c = acctId;
                    }
                }
            
                //check if there is already an SR submitted on the Entity. -- CR-5062018: Remove the validation if there is already a portal admin on the entity
                /*if(checkExistingCompanyUserSR(acctId, objSR.HexaBPM__Email__c) == true){
                    hasError = true;
                    hasExistingUserSR = true;
                } else{
                    if(checkValidLicense(acctId) == false){
                        hasError = true;
                        objSR.License_Number__c.addError('License has not been issued.');
                    } else{
                        if(checkExistingLicenseExpiry(acctId) == true){
                            hasError = true;
                            objSR.License_Number__c.addError('License Number is already expired on '+accountExpiryDateStr);
                        } else{
                            objSR.HexaBPM__Customer__c = acctId;
                        }
                    }
                }*/
                /*if(checkCIDApprovalDate(acctId) == true){
                    hasError = true;
                    hasInvalidCIDApprovalDate = true;
                }*/
            }
        }
        //username is required.
        if(guestUsername == null || guestUsername == ''){
            //objSR.Guest_Username__c.addError('Username is required.');
            hasErrorUsername = true;
            hasError = true;
        }
        
        //username should not include spaces.
        if(guestUsername != null){
            if(guestUsername.contains(' ') || 
                guestUsername.contains('\'') || 
                guestUsername.contains('\"') || 
                guestUsername.contains(',') ||
                guestUsername.contains(':') || 
                guestUsername.contains(';') ||
                guestUsername.contains('/')){
                hasErrorformatUsername = true;
                hasError = true;
            }
        }
        
        //tax registration number required
        if(objSR.Registered_for_Tax__c == 'Yes'){
            if(objSR.Tax_Registration_Number__c == null || objSR.Tax_Registration_Number__c == ''){
                objSR.Tax_Registration_Number__c.addError('Tax Registration Number is required.');
                hasError = true;
            }
        }
        if(objSR.Types_of_Services_Accessible__c == null){
            objSR.Types_of_Services_Accessible__c.addError('Types of Services is required.');
            hasError = true;
        }
    }
    public Boolean hasSpecialChars(String strName){
        Pattern p = Pattern.compile('[a-zA-Z0-9 ]*$');
        Matcher pm = p.matcher(strName);
        Boolean result = pm.matches();
        return result;
    }
    
    public Boolean checkPhone(String strPhone){
        Pattern p = Pattern.compile('\\D*?(\\d\\D*?){10}');
        Matcher pm = p.matcher(strPhone);
        Boolean result = pm.matches();
        return result;
    }
    
    public Boolean checkEmail(String email,string license){
        Boolean hasExistingEmail = false;
        List<User> existUser = [Select Id FROM User WHERE Email = :email AND ContactId <> null AND contact.Account.Entity_Id__c=:license];
        if(!existUser.isEmpty()){
            hasExistingEmail = true;
        }
        return hasExistingEmail;
    }
    
    public Boolean checkExistingCompanyName(String companyName){
        Boolean hasExistingEntityName = false;
        List<Account> existAcctName = [Select Id, Name FROM Account WHERE Name = :companyName];
        if(!existAcctName.isEmpty()){
            hasExistingEntityName = true;
        }
        return hasExistingEntityName;
    }
    
    public Id checkExistingLicenseNumber(String srLicenseNumber){
        Id accountId = null;
        List<Account> validAccount = [Select Id, Name FROM Account WHERE Entity_Id__c = :srLicenseNumber LIMIT 1];
        if(!validAccount.isEmpty()){
            accountId = validAccount[0].Id;
        }
        return accountId;
    }
    
    public Boolean checkValidLicense(Id accountId){
        Boolean isIssued = false;
        List<Account> validAccount = [Select Id, Name, Establishment_Card__r.Document_Expiry_Date__c, License_Expiry_Date__c FROM Account WHERE Id = :accountId LIMIT 1];
        system.debug('##VALIDACCT: '+validAccount);
        if(!validAccount.isEmpty()){
            if(validAccount[0].License_Expiry_Date__c != null){
                isIssued = true;
            }
        }
        system.debug('@@ISSUED: '+isIssued);
        return isIssued;
    }
    
    public Boolean checkExistingLicenseExpiry(Id accountId){
        Boolean isExpired = false;
        List<Account> validAccount = [Select Id, Name, Establishment_Card__r.Document_Expiry_Date__c, License_Expiry_Date__c FROM Account WHERE Id = :accountId LIMIT 1];
        system.debug('##VALIDACCT: '+validAccount);
        if(!validAccount.isEmpty()){
            //if(validAccount[0].Establishment_Card__r.Document_Expiry_Date__c <= System.today()){
            if(validAccount[0].License_Expiry_Date__c <= System.today()){
                //accountExpiryDateStr = String.valueOf(validAccount[0].Establishment_Card__r.Document_Expiry_Date__c);
                accountExpiryDateStr = validAccount[0].License_Expiry_Date__c.format();
                isExpired = true;
            }
        }
        return isExpired;
    }
    /*public Boolean checkCIDApprovalDate(Id accountId){
        Boolean isInvalid = false;
        List<Account> validAccount = [Select Id, Name, Initial_Approval_Issue_Date__c FROM Account WHERE Id = :accountId LIMIT 1];
        if(!validAccount.isEmpty()){
            if(validAccount[0].Initial_Approval_Issue_Date__c == null){
                isInvalid = true;
            }
        }
        return isInvalid;
    }*/
    
    /*public Boolean checkExistingCompanyUserSR(Id accountId, String emailStr){
        List<HexaBPM__Service_Request__c> existingSR = [SELECT Id 
                                                        FROM HexaBPM__Service_Request__c 
                                                        WHERE HexaBPM__Customer__c = :accountId 
                                                        AND HexaBPM__Email__c = :emailStr  //added criteria to check email per accountId
                                                        AND Recordtype.DeveloperName = :Label.SR_Company_User_Access_Request 
                                                        AND (HexaBPM__External_Status_Code__c = 'SUBMITTED' 
                                                        OR HexaBPM__External_Status_Code__c = 'APPROVED')];
        system.debug('@@EXISTSR: '+existingSR);
        if(!existingSR.isEmpty()){
            return true;
        } else{
            return false;
        }       
    }*/
    
    public void PrepareDocumentList(){
        lstDocuments = new list<DocumentDetailsCls>();
        for(HexaBPM__SR_Template_Docs__c TD:[Select Id,HexaBPM__Added_through_Code__c,HexaBPM__Document_Master__c,HexaBPM__Document_Master__r.Name,
                                            HexaBPM__Document_Master_Code__c,HexaBPM__SR_Template__c, HexaBPM__Document_Description_External__c, HexaBPM__Optional__c,Template_URL__c
                                            from HexaBPM__SR_Template_Docs__c 
                                            WHERE HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c=:srTemplateCode 
                                            AND HexaBPM__SR_Template__r.HexaBPM__Active__c = true 
                                            AND HexaBPM__On_Submit__c = true and HexaBPM__Added_through_Code__c=true 
                                            ORDER BY HexaBPM__Optional__c ASC]){
            //objSR.HexaBPM__SR_Template__c = TD.HexaBPM__SR_Template__c;
            DocumentDetailsCls objDoc = new DocumentDetailsCls();
            objDoc.SRDocName = TD.HexaBPM__Document_Master__r.Name;
            if(TD.Template_URL__c!=null)
                objDoc.DocumentName = TD.HexaBPM__Document_Master__r.Name+' <b>(Click <a href="'+TD.Template_URL__c+'" target="_blank" style="text-decoration:underline;">here</a> to access template)</b>';
            else
                objDoc.DocumentName = TD.HexaBPM__Document_Master__r.Name;
            objDoc.DocumentCode = TD.HexaBPM__Document_Master_Code__c;
            objDoc.DocumentMasterId = TD.HexaBPM__Document_Master__c;
            objDoc.STRTemplateDocumentId = TD.Id;
            objDoc.DocumentDescription = TD.HexaBPM__Document_Description_External__c;
            objDoc.isOptional = TD.HexaBPM__Optional__c;
            lstDocuments.add(objDoc);
        }
    }
    
    public class DocumentDetailsCls{
        public Boolean isOptional {get;set;}
        public string DocumentName{get;set;}
        public string SRDocName{get;set;}
        public string DocumentCode{get;set;}
        public string DocumentMasterId{get;set;}
        public string STRTemplateDocumentId{get;set;}
        public string FileType{get;set;}
        public string FileName{get;set;}
        public  Attachment objAttachment{get;set;}
        public String DocumentDescription{get;set;}
        public DocumentDetailsCls(){
            objAttachment = new Attachment();
        }
    }
}
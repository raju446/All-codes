/*
    Author      : Kim Noceda
    Date        : 17-Sep-2017
    Description : Page Controller createand submit SR for Guest user.
    --------------------------------------------------------------------------------------
*/
public without sharing class GuestUserRegistrationController {
    
    public HexaBPM__Service_Request__c objSR {get;set;}
    public String srTemplateCode = Label.SR_Guest_User_Access_Request;
    public Boolean hasError;
    
    public String infoMessage{get;set;}
    public Boolean isUserNameAvailable {get;set;}
    public String iconURL {get;set;}
    public String guestUsername {get;set;}
    public Boolean hasErrorUsername {get;set;}
    public Boolean hasErrorformatUsername {get;set;}
    
    public String existingAcctId {get;set;}
    public string jsonTranslateFields {get;set;}
    
    public Boolean showTaxRegNum {get;set;}
    public String disclaimerText{get;set;}
    
    public GuestUserRegistrationController(){
        objSR = new HexaBPM__Service_Request__c();
        /*for(RecordType rectyp:[Select Id from RecordType where sObjectType='HexaBPM__Service_Request__c' and DeveloperName=:srTemplateCode and IsActive=true]){
           objSR.RecordTypeId = rectyp.Id;
        }*/
        List<Recordtype> recType = [Select Id from RecordType where sObjectType='HexaBPM__Service_Request__c' and DeveloperName=:srTemplateCode and IsActive=true LIMIT 1];
        objSR.RecordTypeId = recType[0].Id;
        hasError = false;
        showTaxRegNum  = false;
        
        disclaimerText = '';
        List<HexaBPM__SR_Template__c> objSRTemplate = [Select Id, Disclaimer_Text__c from HexaBPM__SR_Template__c where HexaBPM__SR_RecordType_API_Name__c=:srTemplateCode LIMIT 1];
        if(objSRTemplate.size() > 0){
            disclaimerText = objSRTemplate[0].Disclaimer_Text__c;
        }
        
        //Gets the field ids -> Source and Destination for Arabic translation from custom setting.
        List<TranslateFields__c> lstTranslateFields = new List<TranslateFields__c>();
        lstTranslateFields  = TranslateFields__c.getAll().values();
        if(lstTranslateFields.size() > 0){
            jsonTranslateFields = JSON.serialize(lstTranslateFields);
        }
    }
    
    public void toggletaxregNum(){
        if(objSR.Registered_for_Tax__c == 'Yes'){
            showTaxRegNum = true;
        } else{
            showTaxRegNum = false;
        }
    }
    
    public void checkUName(){
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
            if(checkEmail(objSR.HexaBPM__Email__c) == true){
                objSR.HexaBPM__Email__c.addError('Email is already used by an existing user.'); 
                hasError = true;
            }
        }
    }
    
    public pageReference cancelReg(){
        PageReference pageRef = new PageReference(Label.ADGM_Login_Homepage);
        pageRef.setRedirect(false);
        return pageRef;
    }
    
    public pageReference SubmitSR(){
        //System.debug('@@DOCUMENT: '+objDocument);
        objSR.Guest_Username__c = guestUsername + '@adgm.portal';
        infoMessage = '';
        iconURL = '';
        isUserNameAvailable = false;
        fieldValidation();
        existingAcctId = '';
        
        if(objSR.Guest_Username__c != null){
            String existingUserName = ApexCodeUtility.isExistingUsername(objSR.Guest_Username__c);
            if(existingUserName != ''){
                infoMessage = 'The username "' +existingUserName+ '" is taken or cannot be used. Try another value.';
                iconURL = '/img/msg_icons/error16.png';
                hasError = true;
            } 
            else
            {
                String existingUserNameSR = ApexCodeUtility.isExistingUsernameSR(objSR.Guest_Username__c);
                if(existingUserNameSR != ''){
                    infoMessage = 'The username "' +existingUserNameSR+ '" is taken or cannot be used. Try another value.';
                    iconURL = '/img/msg_icons/error16.png';
                    hasError = true;
                } 
            }
            if(objSR.License_Number__c != null) 
            {
                for(Account acc : [SELECT id FROM Account WHERE Entity_Id__c=:objSR.License_Number__c LIMIT 1]){
                    infoMessage = 'The License Number "' +objSR.License_Number__c+ '" is taken or cannot be used. Try another value.';
                    iconURL = '/img/msg_icons/error16.png';
                    hasError = true;
                }
            }
        }
        
        Boolean hasExistCompany = checkExistingCompanyName(objSR.Company_Name__c);
        objSR.Existing_Guest_User_Account_Id__c = existingAcctId;
        
        System.debug('##HASERROR1:' +hasError);
        System.debug('##MOBILE:' +objSR.HexaBPM__Send_SMS_to_Mobile__c );
        if(hasError == false){
            Savepoint sp = Database.setSavepoint();
            try{
                objSR.HexaBPM__Auto_Submit__c = true;
                insert objSR;
                
                /*List<HexaBPM__SR_Status__c> srStatusSubmittedId = [SELECT Id, HexaBPM__Code__c FROM HexaBPM__SR_Status__c WHERE HexaBPM__Code__c = 'SUBMITTED'];
                
                objSR.HexaBPM__Internal_SR_Status__c = srStatusSubmittedId[0].Id;
                objSR.HexaBPM__External_SR_Status__c = srStatusSubmittedId[0].Id;
                objSR.HexaBPM__Submitted_Date__c = system.today();
                objSR.HexaBPM__Submitted_DateTime__c = system.now();
                update objSR;*/
                
                
                /*List<HexaBPM__Step__c> actionItem = [SELECT Id, HexaBPM__Status__c FROM HexaBPM__Step__c WHERE HexaBPM__SR__c =:objSR.Id];
                System.debug('@@ACTIONITEM: '+actionItem);
                List<HexaBPM__Status__c> statusApprovedId = [SELECT Id, HexaBPM__Code__c 
                                                                    FROM HexaBPM__Status__c 
                                                                    WHERE HexaBPM__Code__c = 'APPROVED' AND HexaBPM__Type__c = 'End'];
                                                                    
                System.debug('@@SRSTATUSAPPROVED: '+statusApprovedId);
                if(actionItem!=null && actionItem.size()>0){
                    actionItem[0].HexaBPM__Status__c = statusApprovedId[0].Id;
                    update actionItem;
                    
                    List<HexaBPM__SR_Status__c> srStatusApprovedId = [SELECT Id, HexaBPM__Code__c FROM HexaBPM__SR_Status__c 
                                                                        WHERE HexaBPM__Code__c = 'APPROVED' AND HexaBPM__Type__c = 'End'];
                                                                        
                    objSR.HexaBPM__Internal_SR_Status__c = srStatusApprovedId[0].Id;
                    objSR.HexaBPM__External_SR_Status__c = srStatusApprovedId[0].Id;
                    update objSR;
                    
                    objSR = [SELECT Id, Name FROM HexaBPM__Service_Request__c WHERE Id = :objSR.Id];
                }*/
                objSR = [SELECT Id, Name FROM HexaBPM__Service_Request__c WHERE Id = :objSR.Id];
                PageReference pageRef = new PageReference('/apex/GuestUserRegistrationThankyou?srNumber='+objSR.Name);
                pageRef.setRedirect(true);
                return pageRef;
                
            } catch(Exception e){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
                System.debug('@@ERROR: '+e.getMessage());
                if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION, Invalid Contact Number.: [HexaBPM__Send_SMS_to_Mobile__c]')){
                    objSR.HexaBPM__Send_SMS_to_Mobile__c.addError('Invalid Contact Number.');
                }
                Database.rollback(sp);
                return null;
            }
        } else{
            return null;
        }
        
    }
    
    public void fieldValidation(){
        //title is required.
        hasError = false;
        hasErrorUsername = false;
        hasErrorformatUsername = false;
        System.debug('@@TITLE: '+objSR.Title__c);
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
            if(checkEmail(objSR.HexaBPM__Email__c) == true){
                objSR.HexaBPM__Email__c.addError('Email is already used by an existing user.'); 
                hasError = true;
            }
        }
        //mobile is required.
        if(objSR.HexaBPM__Send_SMS_to_Mobile__c == null){
            objSR.HexaBPM__Send_SMS_to_Mobile__c.addError('Contact Number is required.');
            hasError = true;
        }
        //mobile validation.
        /*if(objSR.HexaBPM__Send_SMS_to_Mobile__c != null){
            if(checkPhone(objSR.HexaBPM__Send_SMS_to_Mobile__c) == false){
                objSR.HexaBPM__Send_SMS_to_Mobile__c.addError('Invalid mobile number.');
                hasError = true;
            }
        }*/
        //company name is required.
        if(objSR.Company_Name__c == null){
            objSR.Company_Name__c.addError('Company Name is required.');
            hasError = true;
        }
        //company name should not allow double quotes.
        if(objSR.Company_Name__c != null){
            //if(objSR.Company_Name__c.contains('\"') || objSR.Company_Name__c.contains('\'')){
            if(objSR.Company_Name__c.contains('\"')){
                objSR.Company_Name__c.addError('Company Name should not contain double quotes.');
                hasError = true;
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
        
        //License no is required.
        
        if(objSR.License_Number__c== null || objSR.License_Number__c== ''){
            objSR.License_Number__c.addError('License Number is required.');
            hasError = true;
        }
        
    }
    public Boolean hasSpecialChars(String strName){
        Pattern p = Pattern.compile('[a-zA-Z0-9 ]*$');
        Matcher pm = p.matcher(strName);
        Boolean result = pm.matches();
        return result;
    }
    
    /*public Boolean checkPhone(String strPhone){
        Pattern p = Pattern.compile('\\D*?(\\d\\D*?){10}');
        Matcher pm = p.matcher(strPhone);
        Boolean result = pm.matches();
        return result;
    }*/
    
    public Boolean checkEmail(String email){
        Boolean hasExistingEmail = false;
        List<User> existUser = [Select Id FROM User WHERE Email = :email AND ContactId <> null];
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
            existingAcctId = existAcctName[0].Id;
        }
        return hasExistingEntityName;
    }
}
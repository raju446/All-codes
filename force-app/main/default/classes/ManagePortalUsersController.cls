/*
    Author      : Kim Noceda
    Date        : 18-Sep-2017
    Description : Page Controller to manager Portal users with the same Account.
                    Create new User, Update Existing users
    --------------------------------------------------------------------------------------
*/
public without sharing class ManagePortalUsersController {
    public Contact objCon {get;set;}
    public HexaBPM__Service_Request__c objSR {get;set;}
    public list<PortalUserWrapper> activePortalUsersByAccount {get;set;}
    public Boolean showContactDetailPanel {get;set;}
    public Boolean showSRDetailPanel {get;set;}
    public Id existContactId {get;set;}
    public String userAction {get;set;} 
    public Id selectedUserId {get;set;}
    public string accountId;
    public User conUser;
    public String srTemplateCode = 'User_Access_Request_for_Registered_Company';
    public String userAccessSRRectypeId;
    public Boolean hasError;
    public String infoMessage{get;set;}
    public Boolean isUserNameAvailable {get;set;}
    public String iconURL {get;set;}
    public String guestUsername {get;set;}
    public Boolean hasErrorUsername {get;set;}
    public Boolean hasErrorformatUsername {get;set;}
    public Attachment passportDocument {get;set;}
    public String userAdminAction {get;set;} 
    public Map<String, Id> profileMap = new Map<String, Id>();
    public Set<Id> contactIds = new Set<Id>();
    public Boolean totalAdminLimitError {get;set;}
    public Boolean hasErrorAttachment {get;set;}
    public Boolean isOnUserLimit {get;set;}
    public Boolean showUserLimitError {get;set;}
    public Decimal accountLimit {get;set;}
    public Integer accountUserActiveCount {get;set;}
    public Attachment objDocument{get;set;}
    public list<DocumentDetailsCls> lstDocuments{get;set;}
    public Boolean allDocsUploaded {get;set;}
    public String missedDocuments {get;set;}
    public string invalidFileMsg {get;set;}
    public String licenseNumberStr;
    public string userName;
    public ManagePortalUsersController(){
        objCon = new Contact();
        objSR = new HexaBPM__Service_Request__c();
        passportDocument = new Attachment();
        userName = '';
        for(RecordType rectyp:[Select Id from RecordType where sObjectType='HexaBPM__Service_Request__c' and DeveloperName=:srTemplateCode and IsActive=true LIMIT 1]){
           userAccessSRRectypeId = rectyp.Id;
        }
        
        profileMap = new Map<String, Id>();
        for(Profile p : [SELECT Id, Name FROM Profile]){
            profileMap.put(p.Name, p.Id);
        }
        
        licenseNumberStr = '';
        list<User> currentPortalUser = [SELECT Id, Contact.AccountId FROM User WHERE Id =: userInfo.getUserId() LIMIT 1];
        if(!currentPortalUser.isEmpty()){
            if(currentPortalUser[0].Contact.AccountId != null){
                list<Account> portalEntity = [SELECT Id, Entity_Id__c FROM Account WHERE Id = :currentPortalUser[0].Contact.AccountId LIMIT 1];
                if(!portalEntity.isEmpty()){
                    licenseNumberStr = portalEntity[0].Entity_Id__c;
                }
            }
        }
        showUserLimitError = false;
        createPortalUsersTable();
        showContactDetailPanel = false;
        totalAdminLimitError = false;
        hasErrorAttachment = false;
        
        lstDocuments = new list<DocumentDetailsCls>();
        PrepareDocumentList();
        allDocsUploaded = true;
        missedDocuments = '';
        //hasErrorUsername = false;
        //hasError = false;
    }
    public void createPortalUsersTable(){
        contactIds = new Set<Id>();
        activePortalUsersByAccount = new list<PortalUserWrapper>();
        list<User> currentUser = [Select Id, ContactId, Contact.AccountId FROM User WHERE Id = :Userinfo.getUserId() LIMIT 1];
        accountId = currentUser[0].Contact.AccountId;
        for(Contact con : [Select Id, AccountId, Account.Number_of_Users_Allowed__c,(Select Id from HexaBPM__Steps__r where HexaBPM__Record_Type_Name__c='User_Access_Request_for_Registered_Company' and HexaBPM__IsClosedStatus__c=false and HexaBPM__Is_Rejected__c=false and HexaBPM__IsCancelled__c=false) FROM Contact WHERE AccountId = :currentUser[0].Contact.AccountId]){
            if(con.HexaBPM__Steps__r!=null && con.HexaBPM__Steps__r.size()>0)
                system.debug('SR Already Exists');
            else
                contactIds.add(con.Id);
            accountLimit = con.Account.Number_of_Users_Allowed__c;
        }
        System.debug('@@CONTACTIDS: '+contactIds);
        accountUserActiveCount = 1;
        //System.debug('@@USERS: '+[SELECT Id, FirstName, LastName, isActive FROM User WHERE ContactId IN :contactIds AND isActive = TRUE]);
        for(User pUser : [SELECT Id, FirstName, LastName, isActive, Name, ContactId, Username, Email, Profile.Name,Types_of_Services_Accessible__c FROM User 
                        WHERE ContactId IN :contactIds AND ContactId <> :currentUser[0].ContactId]){
            activePortalUsersByAccount.add(new PortalUserWrapper(true, pUser.Id, pUser.Name, pUser.Username, pUser.isActive, pUser.ContactId, pUser.Email, pUser.Profile.Name,pUser.Types_of_Services_Accessible__c));
            if(pUser.isActive == TRUE){
                accountUserActiveCount = accountUserActiveCount +1;
            }
        }
        isOnUserLimit = false;
        if(accountUserActiveCount >=  accountLimit)
            isOnUserLimit = true;
        for(HexaBPM__Service_Request__c sr : [SELECT Id, First_Name__c, Last_Name__c, Guest_Username__c, HexaBPM__Email__c,Types_of_Services_Accessible__c 
                                                FROM HexaBPM__Service_Request__c WHERE HexaBPM__Customer__c = :accountId
                                                AND RecordtypeId = :userAccessSRRectypeId 
                                                AND HexaBPM__External_Status_Name__c = 'Submitted']){
            String nameStr = sr.First_Name__c + ' ' + sr.Last_Name__c;
            activePortalUsersByAccount.add(new PortalUserWrapper(false, null, nameStr, sr.Guest_Username__c, false, null, sr.HexaBPM__Email__c, null,sr.Types_of_Services_Accessible__c));
        }
    }
    public void createNewContact(){
        showUserLimitError = false;
        if(isOnUserLimit == false){
            showSRDetailPanel = true;
            objSR = new HexaBPM__Service_Request__c();
            guestUsername = '';
            hasErrorUsername = false;
            infoMessage = '';
            iconURL = '';
            isUserNameAvailable = false;
            lstDocuments = new list<DocumentDetailsCls>();
            PrepareDocumentList();
        }else{
            showUserLimitError = true;
        }
    }
    public void cancelDetail(){
        showContactDetailPanel = false;
        showSRDetailPanel = false;
        totalAdminLimitError = false;
    } 
    public void editContact(){
        System.debug('@@ContactId: '+existContactId);
        objCon = new Contact();
        objCon = [SELECT Id, FirstName, Middle_Name__c, LastName, Title, Birthdate, Email, MobilePhone 
                FROM Contact WHERE Id = :existContactId];
        showContactDetailPanel = true;
    }
    public pageReference userUpdate(){
        System.debug('@@USERAction: '+userAction);
        System.debug('@@USERID: '+selectedUserId);
        totalAdminLimitError = false;
        showUserLimitError = false;
        User selUser;
        for(User usr:[SELECT Id,isActive FROM User WHERE Id = :selectedUserId and Contact.AccountId=:accountId]){
            selUser = usr;
        }
        if(selUser!=null){
            if(userAction == 'Activate'){
                if(isOnUserLimit == false){
                    UpdateAccessType();
                    //selUser.isActive = true;
                }else{
                    showUserLimitError = true;
                }
            }else{
                selUser.isActive = false;
            }
            try{
                update selUser;
                createPortalUsersTable();
            }catch(Exception e){
                
            }
        }
        return null;
    }
    public pagereference UpdateAccessType(){
    	if(selectedUserId!=null){
    		existContactId = null;
    		for(User usr:[Select Id,ContactId,username from User where Id=:selectedUserId and Contact.AccountId=:accountId]){
    			existContactId = usr.ContactId;
                userName = usr.username;
    		}
    		if(existContactId!=null){
	    		objCon = new Contact();
		        for(Contact con: [SELECT Id, FirstName, Middle_Name__c, LastName, Title, Birthdate, Email, MobilePhone,Types_of_Services_Accessible__c
		                FROM Contact WHERE Id=:existContactId]){
		        	objCon  = con.clone();        
                }
		        showContactDetailPanel = true;
    		}
    	}
    	return null;
    }
    /*
    public pageReference userAdminUpdate(){
        system.debug('userAdminAction===>'+userAdminAction);
        system.debug('selectedUserId===>'+selectedUserId);
        totalAdminLimitError = false;
        
        User selUser;
        for(User usr:[SELECT Id, ContactId, ProfileId, Role__c FROM User WHERE Id = :selectedUserId and Contact.AccountId=:accountId]){
            selUser = usr;
        }
        Boolean isChangePortalLeadAdmin;
        isChangePortalLeadAdmin = false;
        if(selUser!=null){
            if(userAdminAction == 'Promote'){
                Id profileUserId = profileMap.get(Label.Community_Profile_Name);
                System.debug('####: '+profileUserId);
                list<User> accountUsers = [SELECT Id FROM User WHERE ContactId IN :contactIds AND ProfileId = :profileUserId];
                System.debug('@@ACCTUSERS: '+accountUsers);
                System.debug('@@ACCTUSERSSize: '+accountUsers.size());
                if(accountUsers.size() > 1){
                    totalAdminLimitError = true;
                }else{
                    selUser.ProfileId = profileUserId;
                    selUser.Role__c = 'Lead Admin';
                    isChangePortalLeadAdmin = true;
                }
            }else{
                Id profileUserId = profileMap.get(Label.Community_Profile_Non_Admin_Name);
                selUser.ProfileId = profileUserId;
                selUser.Role__c = 'Admin';
            }
            try{
                System.debug('@@ADMIN ERROR: '+totalAdminLimitError);
                System.debug('@@CHANGE: '+isChangePortalLeadAdmin);
                if(totalAdminLimitError == false){
                    update selUser;
                    if(isChangePortalLeadAdmin == true){
                        updateAccount(selUser.Id);
                    }
                    createPortalUsersTable();
                }
            } catch(Exception e){
                
            }
        }
        
        return null;
    }
    */
    /*
    @future
    public static void updateAccount(Id userId){
        list<User> currentUser = [Select Id, ContactId, Contact.AccountId FROM User WHERE Id=:userId];
        Account objAccount = [SELECT Id, Portal_Lead_Admin__c FROM Account WHERE Id = :currentUser[0].Contact.AccountId LIMIT 1];
        objAccount.Portal_Lead_Admin__c = currentUser[0].ContactId;
        try{
            update objAccount;
        } catch(Exception e){}
    }
    */
    public pageReference saveContact(){
        hasErrorAttachment = false;
        hasError = false;
        Savepoint sp = Database.setSavepoint();
        try{
            if(existContactId!= null){
                System.debug('objCon>>>>>>>>>>>>>');
                System.debug(objCon);
                checkDocuments();
                validateDocuments();
                System.debug('hasError>>>>>>>>>>>>>>>>>>>>>>>>>');
                System.debug(hasError);
                System.debug('invalidFileMsg>>>>>>>>>>>>>>>>>>>>');
                System.debug(invalidFileMsg);
                if(string.isNotEmpty(invalidFileMsg)){ //Checks for valid file type and size
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,invalidFileMsg);
                    ApexPages.addMessage(myMsg);
                    lstDocuments = new list<DocumentDetailsCls>();
                    PrepareDocumentList();
                    showContactDetailPanel = true;
                    return null;
                }else{
                    if(hasError == false){
                        objSR.Title__c = objCon.Title;
                        objSR.First_Name__c = objCon.FirstName;
                        objSR.Middle_Name__c = objCon.Middle_Name__c;
                        objSR.Last_Name__c = objCon.LastName;
                        objSR.Date_of_Birth__c = objCon.Birthdate;
                        objSR.HexaBPM__Email__c = objCon.Email;
                        objSR.HexaBPM__Contact__c = existContactId;
                        objSR.HexaBPM__Send_SMS_to_Mobile__c = objCon.MobilePhone;
                        objSR.Guest_Username__c = userName;
                        objSR.HexaBPM__Customer__c = accountId;
                        objSR.RecordtypeId = userAccessSRRectypeId;
                        objSR.Types_of_Services_Accessible__c = objCon.Types_of_Services_Accessible__c;
                        string accessType;
                        if(String.isNotEmpty(objCon.Types_of_Services_Accessible__c))
                            accessType = objCon.Types_of_Services_Accessible__c.toLowerCase();
                        if(accessType!=null && accessType.indexOf('company services')>-1 && accessType.indexOf('payment - account aervices')>-1 && accessType.indexOf('permits services')>-1 && accessType.indexOf('visa & letter services')>-1){
                            objSR.Role__c = 'Lead Admin';
                        }else{
                            objSR.Role__c = 'Admin';
                        }
                        upsert objSR;
                        System.debug('objSR>>>>>>>>>>>>>>>>>>>>>>>>>>');
                        System.debug(objSR);
                        createSRDoc();
                        
                        //passportDocument = new Attachment();
                        lstDocuments = new list<DocumentDetailsCls>();
                        
                        list<HexaBPM__SR_Status__c> srStatusSubmittedId = [SELECT Id, HexaBPM__Code__c FROM HexaBPM__SR_Status__c WHERE HexaBPM__Code__c = 'SUBMITTED'];
                    
                        objSR.HexaBPM__Internal_SR_Status__c = srStatusSubmittedId[0].Id;
                        objSR.HexaBPM__External_SR_Status__c = srStatusSubmittedId[0].Id;
                        objSR.HexaBPM__Submitted_Date__c = system.today();
                        objSR.HexaBPM__Submitted_DateTime__c = system.now();
                        update objSR;
                        //showSRDetailPanel = false;
                        showContactDetailPanel = false;
                    }else{
                        showContactDetailPanel = true;
                    }
                }
            }else{
               fieldValidation();
               system.debug('@@USERNAME: '+objSR.Guest_Username__c);
               objSR.Guest_Username__c = guestUsername + '@adgm.portal';
               if(objSR.Guest_Username__c != null){
                    String existingUserName = ApexCodeUtility.isExistingUsername(objSR.Guest_Username__c);
                    system.debug('@@USERNAMEEXIST: '+existingUserName);
                    if(existingUserName != ''){
                        infoMessage = 'The username "' +existingUserName+ '" is taken or cannot be used. Try another value.';
                        iconURL = '/img/msg_icons/error16.png';
                        hasError = true;
                    } else{
                        String existingUserNameSR = ApexCodeUtility.isExistingUsernameSR(objSR.Guest_Username__c);
                        system.debug('@@USERNAMEEXISTSR: '+existingUserNameSR);
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
                }else{
                    if(hasError == false){
                        //objSR.Guest_Username__c = guestUsername + '@adgm.portal';
                        objSR.HexaBPM__Customer__c = accountId;
                        objSR.RecordtypeId = userAccessSRRectypeId;
                        objSR.Role__c = 'Admin';
                        objSR.License_Number__c = licenseNumberStr;
                        upsert objSR;
                        createSRDoc();
                        
                        //passportDocument = new Attachment();
                        lstDocuments = new list<DocumentDetailsCls>();
                        
                        list<HexaBPM__SR_Status__c> srStatusSubmittedId = [SELECT Id, HexaBPM__Code__c FROM HexaBPM__SR_Status__c WHERE HexaBPM__Code__c = 'SUBMITTED'];
                    
                        objSR.HexaBPM__Internal_SR_Status__c = srStatusSubmittedId[0].Id;
                        objSR.HexaBPM__External_SR_Status__c = srStatusSubmittedId[0].Id;
                        objSR.HexaBPM__Submitted_Date__c = system.today();
                        objSR.HexaBPM__Submitted_DateTime__c = system.now();
                        update objSR;
                        showSRDetailPanel = false;
                    }
                }
            }
        }catch(Exception e){
            System.debug('Exception==>'+e.getMessage());
            Database.rollback(sp);
            return null;
        }finally{
            lstDocuments = new list<DocumentDetailsCls>();
            PrepareDocumentList();
        }
        createPortalUsersTable();
        return null;
    }
    
    public void checkDocuments(){
        allDocsUploaded = true;
        missedDocuments = '';
        list<String> documentName = new list<String>();
        for(DocumentDetailsCls doc : lstDocuments){
            if(doc.objAttachment.Body == null && doc.isOptional == false){
                documentName.add(doc.AttachmentName);
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
                    String[] validContentTypes =new String[]{'bmp', 'jpg', 'png', 'jpeg', 'pdf'};
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
                // 5MB validation
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
        /*list<HexaBPM__SR_Doc__c> insertSRDoc = new list<HexaBPM__SR_Doc__c>();
        
        insertSRDoc = [SELECT Id FROM HexaBPM__SR_Doc__c WHERE HexaBPM__Service_Request__c = :objSR.Id];
        passportDocument.ParentId = insertSRDoc[0].Id;
        insert passportDocument;
        
        insertSRDoc[0].HexaBPM__Status__c = 'Uploaded';
        update insertSRDoc;*/
        
        list<HexaBPM__SR_Doc__c> insertSRDoc = new list<HexaBPM__SR_Doc__c>();
        Map<String, Attachment> srDocsAttMap = new Map<String, Attachment>();
        list<Attachment> insertSRAttachments = new list<Attachment>();
        
        for(DocumentDetailsCls doc : lstDocuments){
            if(doc.objAttachment.Body != null){
                HexaBPM__SR_Doc__c srDoc = new HexaBPM__SR_Doc__c();
                srDoc.HexaBPM__From_Finalize__c = true;
                srDoc.Name = doc.AttachmentName;
                srDoc.HexaBPM__Document_Master__c = doc.DocumentMasterId;
                srDoc.HexaBPM__Service_Request__c = objSR.Id;
                srDoc.HexaBPM__SR_Template_Doc__c = doc.STRTemplateDocumentId;
                srDoc.HexaBPM__Status__c = 'Pending Upload';
                srDoc.HexaBPM__Document_Description_External__c = doc.DocumentDescription;
                
                srDocsAttMap.put(srDoc.Name, doc.objAttachment);
                
                insertSRDoc.add(srDoc);
            }
        }
        system.debug('@@INSERTSRDOC: '+insertSRDoc);
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
    }
    
    public pageReference checkUname(){
        objSR.Guest_Username__c = guestUsername + '@adgm.portal';
        System.debug('@@USERNAME: '+objSR.Guest_Username__c);
        infoMessage = '';
        iconURL = '';
        isUserNameAvailable = false;
        hasErrorUsername = false;
        hasErrorformatUsername = false;
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
        if(objSR.HexaBPM__Email__c != null){
            if(checkEmail(objSR.HexaBPM__Email__c, licenseNumberStr) == true){
                objSR.HexaBPM__Email__c.addError('Email is already used by an existing user.'); 
                hasError = true;
            }
        }
        return null;
    }
    
    public void fieldValidation(){
        hasError = false;
        hasErrorUsername = false;
        hasErrorformatUsername = false;
        
        //title is required.
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
            if(checkEmail(objSR.HexaBPM__Email__c, licenseNumberStr) == true){
                objSR.HexaBPM__Email__c.addError('Email is already used by an existing user.'); 
                hasError = true;
            }
        }
        //mobile is required.
        if(objSR.HexaBPM__Send_SMS_to_Mobile__c == null){
            objSR.HexaBPM__Send_SMS_to_Mobile__c.addError('Contact Number is required.');
            hasError = true;
        }
        //Role is required.
        /*if(objSR.Role__c == null){
            objSR.Role__c.addError('Role is required.');
            hasError = true;
        }*/
        //Check Lead Admin if not more than 2.
        /*if(objSR.Role__c != null){
            if(objSR.Role__c == 'Lead Admin'){
                Id profileUserId = profileMap.get(Label.Community_Profile_Name);
                list<User> accountUsers = [SELECT Id FROM User WHERE ContactId IN :contactIds AND ProfileId = :profileUserId];
                System.debug('@@ACCTUSERS: '+accountUsers);
                System.debug('@@ACCTUSERSSize: '+accountUsers.size());
                if(accountUsers.size() > 1){
                    objSR.Role__c.addError('There can only be a maximum of 2 administrators.');
                    hasError = true;
                }
            }
        }*/
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
    }
    public Boolean hasSpecialChars(String strName){
        Pattern p = Pattern.compile('[a-zA-Z0-9 ]*$');
        Matcher pm = p.matcher(strName);
        Boolean result = pm.matches();
        return result;
    }
    public Boolean checkEmail(String email, String license){
       // added extra param and condition for license: shagufta 31/03/21
        Boolean hasExistingEmail = false;
        list<User> existUser = [Select Id FROM User WHERE Email = :email AND ContactId <> null AND contact.Account.Entity_Id__c=:license];
        if(!existUser.isEmpty())
            hasExistingEmail = true;
        return hasExistingEmail;
    }
    public void PrepareDocumentList(){
        lstDocuments = new list<DocumentDetailsCls>();
        for(HexaBPM__SR_Template_Docs__c TD:[Select Id,HexaBPM__Added_through_Code__c,HexaBPM__Document_Master__c,HexaBPM__Document_Master__r.Name,Template_URL__c,
                                            HexaBPM__Document_Master_Code__c,HexaBPM__SR_Template__c,HexaBPM__Document_Description_External__c, HexaBPM__Optional__c  
                                            from HexaBPM__SR_Template_Docs__c 
                                            WHERE HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c=:srTemplateCode 
                                            AND HexaBPM__SR_Template__r.HexaBPM__Active__c = true 
                                            AND HexaBPM__On_Submit__c = true and HexaBPM__Added_through_Code__c=true 
                                            ORDER BY HexaBPM__Optional__c ASC]){
            //objSR.HexaBPM__SR_Template__c = TD.HexaBPM__SR_Template__c;
            DocumentDetailsCls objDoc = new DocumentDetailsCls();
            objDoc.AttachmentName = TD.HexaBPM__Document_Master__r.Name;
            if(TD.Template_URL__c!=null)
                objDoc.DocumentName = TD.HexaBPM__Document_Master__r.Name+' <b>(Click <a href="'+TD.Template_URL__c+'" target="_blank" style="text-decoration:underline;">here</a> to access template)</b>';
            else
                objDoc.DocumentName = TD.HexaBPM__Document_Master__r.Name;
            //objDoc.DocumentName = TD.HexaBPM__Document_Master__r.Name;
            objDoc.DocumentCode = TD.HexaBPM__Document_Master_Code__c;
            objDoc.DocumentMasterId = TD.HexaBPM__Document_Master__c;
            objDoc.STRTemplateDocumentId = TD.Id;
            objDoc.DocumentDescription = TD.HexaBPM__Document_Description_External__c;
            objDoc.isOptional = TD.HexaBPM__Optional__c;
            lstDocuments.add(objDoc);
        }
    }
    public class DocumentDetailsCls{
    	public string AttachmentName{get;set;}
        public Boolean isOptional {get;set;}
        public string DocumentName{get;set;}
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
    public class PortalUserWrapper{
        public Boolean isUser {get;set;}
        public Id userId {get;set;}
        public Id conId {get;set;}
        public String name {get;set;}
        public String userName {get;set;}
        public String uEmail {get;set;}
        public String status {get;set;}
        public Boolean isActive {get;set;}
        public String uProfileName {get;set;}
        public Boolean isAdminUser {get;set;}
        public string AccessType{get;set;}
        public PortalUserWrapper(Boolean isUser, Id userId, String name, String userName, Boolean isActive, Id conId, String uEmail, String uProfileName,string AccessType){
            this.isUser = isUser;
            this.userId = userId;
            this.conId = conId;
            this.name = name;
            this.userName = userName;
            this.uEmail = uEmail;
            this.isActive = isActive;
            this.uProfileName = uProfileName;
            this.isAdminUser = false;
            this.AccessType = AccessType;
            if(isUser == true){
                if(isActive == true){
                    status = 'Active';
                }else{
                    status = 'Inactive';
                }
            }else{
                status = 'Under Review';
            }
            if(uProfileName == Label.Community_Profile_Name)
                isAdminUser = true;
        }
    }
}
/******************************************************************************************
*  Author         :   Durga
*  Company        :   PwC
*  Date           :   11-April-2017
*  Description    :   Apex Controller for Step Transition Window
*  Version        :   1.0
********************************************************************************************/
public without sharing class QuickStepTransitionController { 
    public HexaBPM__Step__c step{get;set;} 
    public string SRID{get;set;}
    public string stepId{get;set;}
    public boolean hasAccess{get;set;}
    User objCurrentUser;
    public map<string,string> MapDelegatedUsers;
    public string userType{get;set;}
    public list<TransitionWrapper> lstTrnsWrap{get;set;}
    public Integer iListSize{get;set;}
    map<id,HexaBPM__Step_Transition__c> mapStepTransition; 
    public HexaBPM__Service_Request__c objSRTBU{get;set;}
    public boolean DocumentValidityCheck{get;set;}
    public boolean isStepOwnedByQueue{get;set;}
    string SRAccountId;
    decimal age = 0;
    string userAccountId;
    public string srRecTypeName{get;set;}
    public boolean isWorkPermitSR {get;set;}
    public boolean isPOBoxSR{get;set;}
    public boolean isPPExists {get;set;}
    public set<string> permitSRDocValid = new Set<string>{'Entertainment Permit','Events and Exhibition Permit','Photography Permit','Sales and Promotion Permit','Trainings and Seminars Permit','Extended Business Hours Permit','Temporary Fit Out Security Clearance'};
    
    map<string,string> MapDocumentsTBU;
    boolean checkConditions;
    public QuickStepTransitionController(ApexPages.StandardController controller)
    {
        lstTrnsWrap = new list<TransitionWrapper>();
        MapDocumentsTBU = new map<string,string>();
        iListSize = 0;
        DocumentValidityCheck = false;
        objSRTBU = new HexaBPM__Service_Request__c();
        isWorkPermitSR = false;
        isPOBoxSR = false;
        isPPExists = false;
        checkConditions = false;
        
        if(apexpages.currentpage().getParameters().get('Id')!=null)
            SRID = string.escapeSingleQuotes(apexpages.currentpage().getParameters().get('Id'));
        step = new HexaBPM__Step__c();
        if(apexpages.currentpage().getParameters().get('stepId')!=null){
            stepId = string.escapeSingleQuotes(apexpages.currentpage().getParameters().get('stepId'));
            string SRStepId;
            for(HexaBPM__Step__c stp:[select Id,Name,HexaBPM__Summary__c,RecordTypeId,HexaBPM__Step_Status__c,RecordType.DeveloperName,OwnerId,Owner.Name,RecordType.Name,HexaBPM__SR_Step__r.Document_Validity_Check__c,
                HexaBPM__Parent_Step__c,HexaBPM__SR__c,HexaBPM__SR__r.HexaBPM__SR_Template__c,HexaBPM__SR__r.HexaBPM__Parent_Step__c,HexaBPM__SR__r.HexaBPM__Parent_SR__c,HexaBPM__SR__r.Start_Date__c,HexaBPM__SR__r.End_Date__c,
                HexaBPM__SR__r.HexaBPM__Customer__c,HexaBPM__SR__r.HexaBPM__Customer__r.Registration_Date__c,HexaBPM__SR__r.HexaBPM__Customer__r.License_Expiry_Date__c,HexaBPM__SR__r.Service_Request_Name__c,HexaBPM__Status__c,HexaBPM__SR__r.Age_Days__c,
                HexaBPM__SR_Step__c,HexaBPM__Rejection_Reason__c,HexaBPM__Status__r.Name,HexaBPM__SR__r.Residence_Visa_Date_of_Expiry__c,HexaBPM__SR__r.Work_Permit_Validity__c,
                HexaBPM__SR__r.Passport_Number__c,HexaBPM__SR__r.Passport_Expiry_Date__c,HexaBPM__SR__r.HexaBPM__Contact__r.Work_Permit_Card_Number__c,
                HexaBPM__SR__r.HexaBPM__Contact__r.Nationality__c,HexaBPM__SR__r.Residence_Visa_Date_of_Issue__c,HexaBPM__SR__r.HexaBPM__Record_Type_Name__c,
                HexaBPM__SR__r.HexaBPM__Contact__r.Residence_Visa_Date_of_Expiry__c , HexaBPM__SR__r.Work_Permit_Type__c, HexaBPM__Step_Template__r.HexaBPM__Code__c, HexaBPM__SR__r.Visa_Period__c, HexaBPM__SR__r.Visa_Type__c , Action_Item_Status_f__c, HexaBPM__SR__r.Valid_From__c,
                HexaBPM__SR__r.Agent_Name__c, HexaBPM__SR__r.Is_Agent_EID_Notification_Sent__c, HexaBPM__Current_Status__c, HexaBPM__SR__r.Biometric__c
                from HexaBPM__Step__c where Id=:stepId and HexaBPM__SR__c!=null and HexaBPM__SR__r.HexaBPM__SR_Template__c !=null and IsDeleted=false]){
                step = stp;
                SRStepId = stp.HexaBPM__SR_Step__c;
                DocumentValidityCheck = stp.HexaBPM__SR_Step__r.Document_Validity_Check__c;
                objSRTBU.Id = stp.HexaBPM__SR__c;
                age = stp.HexaBPM__SR__r.Age_Days__c;
                string ownerId = stp.OwnerId;
                SRAccountId = stp.HexaBPM__SR__r.HexaBPM__Customer__c;
                // ISSUE-000154 : START
                srRecTypeName = step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c;
                if(((srRecTypeName == 'Employment_Visa_New' || srRecTypeName == 'Long_Term_Residence_Visa_New' || srRecTypeName == 'Dependent_Visa_New'
                    || srRecTypeName == 'Employment_Visa_Renewal' || srRecTypeName == 'Dependent_Visa_Renewal' || srRecTypeName == 'Visa_Transfer') 
                && step.Action_Item_Status_f__c == 'Open') && (step.HexaBPM__Step_Template__r.HexaBPM__Code__c == 'MEDICAL_IN_PROGRESS' 
                                        || step.HexaBPM__Step_Template__r.HexaBPM__Code__c == 'UPLOAD_HEALTH_INSURANCE_CARD' 
                                        || step.HexaBPM__Step_Template__r.HexaBPM__Code__c == 'EMIRATES_ID_APPLICATION' 
                                        || step.HexaBPM__Step_Template__r.HexaBPM__Code__c == 'UPDATE_HEALTH_INSURANCE_DETAILS'
                                         ))
                {
                    checkConditions = true;
                }
                // END..
                
                //ISSUE-000643  : Renew alcohol permit change..
                objSRTBU.Valid_From__c = stp.HexaBPM__SR__r.Valid_From__c ;
                if(objSRTBU.Valid_From__c != null && srRecTypeName == 'Renew_Alcohol_Permit')
                    objSRTBU.Valid_To__c = objSRTBU.Valid_From__c.addYears(1);
                //
                
                
                if(ownerId.subString(0,3) == '00G'){
                    isStepOwnedByQueue = true;
                }
                System.debug('@@TEMPLATENAME: '+stp.HexaBPM__SR__r.Service_Request_Name__c+'===='+stp.HexaBPM__SR__r.Valid_From__c);
                if(permitSRDocValid.contains(stp.HexaBPM__SR__r.Service_Request_Name__c)){
                    objSRTBU.Valid_From__c = stp.HexaBPM__SR__r.Start_Date__c;
                    objSRTBU.Valid_To__c = stp.HexaBPM__SR__r.End_Date__c;
                }
                if(stp.HexaBPM__SR__r.Service_Request_Name__c == 'Shisha Permit'){
                    objSRTBU.Valid_From__c = System.Today();
                    objSRTBU.Valid_To__c = System.Today().addYears(1);
                    if(stp.HexaBPM__SR__r.HexaBPM__Customer__r.License_Expiry_Date__c < objSRTBU.Valid_To__c){
                        objSRTBU.Valid_To__c = stp.HexaBPM__SR__r.HexaBPM__Customer__r.License_Expiry_Date__c;
                    }
                }
                if(stp.HexaBPM__SR__r.Service_Request_Name__c == 'Initial Approval'){
                   objSRTBU.Valid_From__c = System.Today();
                }
                
                if(stp.HexaBPM__SR__r.Service_Request_Name__c == 'Initial Approval'){
                   objSRTBU.Valid_From__c = System.Today();
                }
                    if( (stp.HexaBPM__SR__r.Service_Request_Name__c == 'P.O.Box - New Application' || 
                         stp.HexaBPM__SR__r.Service_Request_Name__c == 'P.O.Box - Renewal') && 
                       step.HexaBPM__Summary__c == 'Typing' ){
                           isPOBoxSR = true;
                           objSRTBU.Issue_Date__c = System.Today();                           
                           objSRTBU.Expiry_Date__c = System.Today().addYears(1);
                       }
                    
                if(stp.HexaBPM__SR__r.Service_Request_Name__c == 'Temporary Work Permit - New' || 
                stp.HexaBPM__SR__r.Service_Request_Name__c == 'Temporary Work Permit - Renew' ||
                (
                    (stp.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'New_Work_Permit_Full_Time_Non_Sponsored_Employee' || 
                    stp.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'Renew_Work_Permit_Full_Time_Non_Sponsored_Employee') && stp.HexaBPM__SR__r.Work_Permit_Type__c == 'Employee Sponsored by spouse/parent') )
                {
                    isWorkPermitSR = true;
                   if(stp.HexaBPM__SR__r.Service_Request_Name__c == 'Temporary Work Permit - New' || 
                      stp.HexaBPM__SR__r.Service_Request_Name__c == 'Temporary Work Permit - Renew'){
                       objSRTBU.Work_Permit_Issue_Date__c = System.Today();
                       string validity = stp.HexaBPM__SR__r.Work_Permit_Validity__c;
                       if(validity != null){
                            integer PermitDays = 0;
                            if(validity == '3') 
                                PermitDays=90;
                            else if(validity == '6') 
                                PermitDays=180;
                            else if(validity == '12') 
                                PermitDays=365;
                            if(system.today().daysBetween(stp.HexaBPM__SR__r.Residence_Visa_Date_of_Expiry__c) < PermitDays)    
                                objSRTBU.Work_Permit_Expiry_Date__c = stp.HexaBPM__SR__r.Residence_Visa_Date_of_Expiry__c;
                            else 
                                objSRTBU.Work_Permit_Expiry_Date__c = Date.valueOf(system.today().addDays(PermitDays));
                       }
                   }else{
                       Integer permitdays = system.today().daysBetween(system.today().addYears(3));
                       objSRTBU.Work_Permit_Issue_Date__c  = system.today();
                       objSRTBU.Work_Permit_Expiry_Date__c = system.today().addYears(3);
                    
                        if(system.today().daysBetween(stp.HexaBPM__SR__r.Residence_Visa_Date_of_Expiry__c) < PermitDays) 
                            objSRTBU.Work_Permit_Expiry_Date__c = stp.HexaBPM__SR__r.Residence_Visa_Date_of_Expiry__c;    
                   }
                   
                   
                        
                   if(stp.HexaBPM__SR__r.Service_Request_Name__c == 'Temporary Work Permit - Renew')
                    objSRTBU.Work_Permit_Card_Number__c = stp.HexaBPM__SR__r.HexaBPM__Contact__r.Work_Permit_Card_Number__c;
                }
                if(stp.HexaBPM__SR__r.Service_Request_Name__c == 'Employee Work Permit (UAE/GCC National) - New' || 
                stp.HexaBPM__SR__r.Service_Request_Name__c == 'Employee Work Permit (UAE/GCC National) - Renew' || 
                (
                    (stp.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'New_Work_Permit_Full_Time_Non_Sponsored_Employee' ||
                    stp.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'Renew_Work_Permit_Full_Time_Non_Sponsored_Employee')&& (stp.HexaBPM__SR__r.Work_Permit_Type__c == 'UAE/GCC National'
                    || stp.HexaBPM__SR__r.Work_Permit_Type__c == 'Golden Visa Holder'))
                
                )
                {
                    isWorkPermitSR = true;
                    Integer permitdays = system.today().daysBetween(system.today().addYears(3));
                    objSRTBU.Work_Permit_Issue_Date__c  = system.today();
                    objSRTBU.Work_Permit_Expiry_Date__c = system.today().addYears(3);
                    
                    if(system.today().daysBetween(stp.HexaBPM__SR__r.Passport_Expiry_Date__c) < PermitDays) 
                        objSRTBU.Work_Permit_Expiry_Date__c = stp.HexaBPM__SR__r.Passport_Expiry_Date__c;
                        
                    if(stp.HexaBPM__SR__r.Work_Permit_Type__c == 'UAE/GCC National')
                      objSRTBU.Residence_Visa_Number__c = stp.HexaBPM__SR__r.Passport_Number__c;
                    
                    if(stp.HexaBPM__SR__r.Work_Permit_Type__c == 'Golden Visa Holder' && system.today().daysBetween(stp.HexaBPM__SR__r.Residence_Visa_Date_of_Expiry__c) < PermitDays){
                        objSRTBU.Work_Permit_Expiry_Date__c = stp.HexaBPM__SR__r.Residence_Visa_Date_of_Expiry__c;
                    }
                    
                    else if(stp.HexaBPM__SR__r.Work_Permit_Type__c == 'Golden Visa Holder' && system.today().daysBetween(stp.HexaBPM__SR__r.Residence_Visa_Date_of_Expiry__c) > PermitDays){
                      objSRTBU.Work_Permit_Expiry_Date__c = system.today().addYears(3);
                    }
                    
                    if(
                        (stp.HexaBPM__SR__r.Service_Request_Name__c == 'Employee Work Permit (UAE/GCC National) - Renew' || 
                        stp.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'Renew_Work_Permit_Full_Time_Non_Sponsored_Employee') && stp.HexaBPM__SR__r.HexaBPM__Contact__r != null){
                        objSRTBU.Work_Permit_Card_Number__c = stp.HexaBPM__SR__r.HexaBPM__Contact__r.Work_Permit_Card_Number__c;
                        objSRTBU.Nationality__c = stp.HexaBPM__SR__r.HexaBPM__Contact__r.Nationality__c;
                    }
                }
                
                if(stp.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'New_Work_Permit_For_ADGM_Sponsored_Employees'){
                    isWorkPermitSR                      = true;
                    objSRTBU.Nationality__c             = stp.HexaBPM__SR__r.HexaBPM__Contact__r.Nationality__c;
                    objSRTBU.Work_Permit_Issue_Date__c  = system.today();
                    objSRTBU.Work_Permit_Expiry_Date__c = stp.HexaBPM__SR__r.HexaBPM__Contact__r.Residence_Visa_Date_of_Expiry__c;
                }
                
                if(stp.HexaBPM__SR__r.Service_Request_Name__c == 'Employment Residence Visa - Renewal'){
                    //isWorkPermitSR = true;
                    objSRTBU.Work_Permit_Card_Number__c = stp.HexaBPM__SR__r.HexaBPM__Contact__r.Work_Permit_Card_Number__c;
                    //objSRTBU.Work_Permit_Issue_Date__c  = stp.HexaBPM__SR__r.Residence_Visa_Date_of_Issue__c;
                    //objSRTBU.Work_Permit_Expiry_Date__c = stp.HexaBPM__SR__r.Residence_Visa_Date_of_Expiry__c;
                }
                
                if(stp.HexaBPM__Step_Template__r.HexaBPM__Code__c == 'RESIDENCE_VISA_STAMPING_PROCESS'){
                    objSRTBU.Valid_From__c= Date.today();
                    if(stp.HexaBPM__SR__r.Visa_Period__c != '1' && (stp.HexaBPM__SR__r.Visa_Type__c == null || stp.HexaBPM__SR__r.Visa_Type__c== ''))
                        objSRTBU.Valid_To__c= system.today().addYears(3);
                    else if(stp.HexaBPM__SR__r.Visa_Period__c == '1')
                        objSRTBU.Valid_To__c= system.today().addYears(1);
                    else if(stp.HexaBPM__SR__r.Visa_Type__c == 'Investor in Public Investments (10 years)')
                        objSRTBU.Valid_To__c= system.today().addYears(10);
                    else if(stp.HexaBPM__SR__r.Visa_Type__c == 'Investor in real-estate (5 years)')
                        objSRTBU.Valid_To__c= system.today().addYears(5);
                }
               
                
                string Step15DigitId = SRStepId;
                if(Step15DigitId!=null && Step15DigitId.length()==18)
                    Step15DigitId = Step15DigitId.substring(0,15);
                    system.debug('Step15DigitId='+Step15DigitId+ ' ');
                if(Step15DigitId!=null){
                    
                    for(HexaBPM__SR_Doc__c doc:[Select Id,Name,Name__c  from HexaBPM__SR_Doc__c where HexaBPM__Service_Request__c=:stp.HexaBPM__SR__c and Required_at_Step__c=:Step15DigitId and HexaBPM__Status__c!='Uploaded' and HexaBPM__Doc_ID__c=null]){
                        system.debug('in side doc for ');
                        MapDocumentsTBU.put(stepId,doc.Name__c);
                    }
                }
           }
        }
        hasAccess = false;
        objCurrentUser = new User();
        for(User curUser:[select Id,ContactId,Contact.AccountId,ProfileId,Profile.UserLicenseId,Profile.UserLicense.Name,Profile.UserLicense.LicenseDefinitionKey,Profile.Name from User where Id=:userInfo.getUserId() and IsActive=true]){
            objCurrentUser = curUser;
            if(curUser.ContactId==null){
                userType = 'salesforce';
            }else{
                userAccountId = curUser.Contact.AccountId;
                userType = 'Community';
            }
        }
        
        if(step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'Temporary_Work_Permit_New' && step.HexaBPM__Summary__c == 'Verification of Application')
        {
            ValidatePassport(step.HexaBPM__SR__r.Passport_Number__c,step.HexaBPM__SR__c);
        }
    }
   /*
        Method Name :   CheckAccess
        Description :   Code to check the Service Request belongs to the logged In user's account or not
    */
    public pagereference CheckAccess(){
        Pagereference pg = new Pagereference('/apex/Noaccess');
        pg.setRedirect(true);
        boolean hasAccess = true;
        if(userAccountId!=null && SRAccountId!=null){
            if(SRAccountId!=userAccountId)
                return pg;
        }
        Check_Permissions();
        return null;
    }
    
    /**
     * Method Name : Check_Permissions
     * Desription : Checks if the current user has access to make the required transition selection or not.
     **/
    public void Check_Permissions(){
        MapDelegatedUsers = new map<string,string>();
        MapDelegatedUsers = SetupObjectDataHelper.GetDelegatedUsers(objCurrentUser.Id);
        if(step.OwnerId==userinfo.getUserId() || (MapDelegatedUsers!=null && MapDelegatedUsers.get(step.OwnerId)!=null) || (objCurrentUser!=null && string.valueof(objCurrentUser.Profile.Name).indexof('System Administrator')>-1)){
            hasAccess = true;
        }else if(userType!=null && userType=='Community'){
            hasAccess = true;
        }else{
            if(step.OwnerId!=null){
                if(string.valueOf(step.OwnerId).substring(0,3)=='00G'){
                    for(SetupObjectDataHelper.GroupDetails GD:SetupObjectDataHelper.getGroupData(step.OwnerId)){
                        if(GD.GroupOrUserId==userinfo.getUserId()){
                            hasAccess = true;
                            break;
                        }
                    }
                }
            }
        }
        Prepare_Transitions();
    }
    /**
     * Method Name : Prepare_Transitions
     * Description : Queries all transitions from the current step and sets the valid possible transitions and maps it to a map value
     **/
    public void Prepare_Transitions(){
        
        set<id> setValidSteps = new set<id>();
        mapStepTransition = new map<id,HexaBPM__Step_Transition__c>();
        if(userType=='salesforce'){
            for(HexaBPM__Step_Transition__c trans:[select HexaBPM__Evaluate_Refund__c,HexaBPM__From__c,HexaBPM__Transition__r.HexaBPM__To__r.HexaBPM__Rejection__c,HexaBPM__Transition__r.HexaBPM__To__r.HexaBPM__Reupload_Document__c,HexaBPM__Parent_SR_Status__c,HexaBPM__To__c,HexaBPM__Parent_Step_Status__c,HexaBPM__Transition__c,HexaBPM__Transition__r.HexaBPM__To__c,HexaBPM__SR_Step__c,HexaBPM__SR_Status_External__c,HexaBPM__SR_Status_Internal__c,HexaBPM__Transition__r.HexaBPM__To__r.Name from HexaBPM__Step_Transition__c where HexaBPM__Transition__c!=null and HexaBPM__From__c=:step.HexaBPM__Status__r.Name and HexaBPM__SR_Step__c=:step.HexaBPM__SR_Step__c and IsDeleted=false]){
                setValidSteps.add(trans.HexaBPM__Transition__r.HexaBPM__To__c);
                mapStepTransition.put(trans.HexaBPM__Transition__r.HexaBPM__To__c,trans);
            }
        }else{
            for(HexaBPM__Step_Transition__c trans:[select HexaBPM__Evaluate_Refund__c,HexaBPM__From__c,HexaBPM__Transition__r.HexaBPM__To__r.HexaBPM__Rejection__c,HexaBPM__Transition__r.HexaBPM__To__r.HexaBPM__Reupload_Document__c,HexaBPM__Parent_SR_Status__c,HexaBPM__To__c,HexaBPM__Parent_Step_Status__c,HexaBPM__Transition__c,HexaBPM__Transition__r.HexaBPM__To__c,HexaBPM__SR_Step__c,HexaBPM__SR_Status_External__c,HexaBPM__SR_Status_Internal__c,HexaBPM__Transition__r.HexaBPM__To__r.Name from HexaBPM__Step_Transition__c where HexaBPM__Transition__c!=null and HexaBPM__From__c=:step.HexaBPM__Status__r.Name and HexaBPM__SR_Step__c=:step.HexaBPM__SR_Step__c and HexaBPM__Display_on_Portal__c=true and IsDeleted=false]){
                setValidSteps.add(trans.HexaBPM__Transition__r.HexaBPM__To__c);
                
                mapStepTransition.put(trans.HexaBPM__Transition__r.HexaBPM__To__c,trans);
            }
        }
        if(setValidSteps!=null && setValidSteps.size()>0){
            TransitionWrapper objWrap;
            for(HexaBPM__Status__c objstat:[Select Id,Name,HexaBPM__Type__c,HexaBPM__Rejection__c,Reason_Required__c,HexaBPM__SR_Closed_Status__c,HexaBPM__Code__c from HexaBPM__Status__c where ID IN:setValidSteps and IsDeleted=false]){
                objWrap = new TransitionWrapper();
                objWrap.objStatus = objstat;
                if(objstat.HexaBPM__Rejection__c || objstat.Reason_Required__c)
                    objWrap.ReasonRequired = true;
                objWrap.objSRStepTrans = new HexaBPM__Step_Transition__c();
                if(mapStepTransition.get(objstat.id)!=null)
                    objWrap.objSRStepTrans = mapStepTransition.get(objstat.id);
                lstTrnsWrap.add(objWrap);
            }
            iListSize = lstTrnsWrap.size();
        }
    }
    public string selTransition{get;set;}
    public string RejReason{get;set;}
    public string StepNotes{get;set;}
    /**
     * Method Name : SaveChanges
     * Description : Method invoked on click of proceed button. Updates the status of the step to the selected step transition value.
     **/
    public pagereference SaveChanges(){
        pagereference pg;
        if(selTransition!=null && mapStepTransition.get(selTransition)!=null){
            Savepoint Stat_svpoint = Database.setSavepoint();
            list<HexaBPM__Step__c> lstStepsTBU = new list<HexaBPM__Step__c>();
            list<HexaBPM__Service_Request__c> lstSRsTBU = new list<HexaBPM__Service_Request__c>();
            try{
                pg = new PageReference('/'+SRID);
                pg.setRedirect(true);
                if(isStepOwnedByQueue == true && userType=='salesforce'){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Please accept the Action item first before proceeding.'));
                    return null;
                }
                if(SRID!=null && mapStepTransition.get(selTransition)!=null && mapStepTransition.get(selTransition).HexaBPM__Transition__r.HexaBPM__To__r.HexaBPM__Reupload_Document__c){
                    boolean ReUploadDocFound = false;
                    if(userType=='salesforce'){
                        //Validation to check the backofficer has marked atleast one document as Re-upload before changing the status to Document Re-upload.
                        for(HexaBPM__SR_Doc__c doc:[Select Id,HexaBPM__Status__c from HexaBPM__SR_Doc__c where HexaBPM__Service_Request__c=:SRID and HexaBPM__Status__c='Re-upload' limit 1]){
                            ReUploadDocFound = true;
                        }
                        if(ReUploadDocFound==false){
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,label.Re_Upload_Document_Error_Message));
                            return null;
                        }
                    }else{
                        //Validation to check Customer has Re-uploaded the document which has be marked as Re-uplod
                        for(HexaBPM__SR_Doc__c doc:[Select Id,HexaBPM__Status__c from HexaBPM__SR_Doc__c where HexaBPM__Service_Request__c=:SRID and HexaBPM__Status__c='Re-upload' limit 1]){
                            ReUploadDocFound = true;
                        }
                        if(ReUploadDocFound==true){
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Please Re-upload all the documents to proceed.'));
                            return null;
                        }
                    }
                }
                if(SRID!=null){
                    string openPaymentValidation = ApexCodeUtility.CheckOpenFinePaymentStep(SRID);
                    if(openPaymentValidation!='Success'){
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,openPaymentValidation));
                        return null;
                    }
                }
                    if(mapStepTransition.get(selTransition).HexaBPM__Transition__c!=null && mapStepTransition.get(selTransition).HexaBPM__Transition__r.HexaBPM__To__c!=null && mapStepTransition.get(selTransition).HexaBPM__Transition__r.HexaBPM__To__r.HexaBPM__Rejection__c==false && MapDocumentsTBU.get(stepId)!=null){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Please upload '+MapDocumentsTBU.get(stepId)+' to proceed.'));
                    return null;
                }
                
                //Create Refund Line on Rejection
                if(mapStepTransition.get(selTransition).HexaBPM__Evaluate_Refund__c)
                    EvaluateRefundPriceItem.CreateRefundLine(step);
                if(mapStepTransition.get(selTransition).HexaBPM__SR_Status_Internal__c==null || mapStepTransition.get(selTransition).HexaBPM__SR_Status_External__c==null){
                    HexaBPM__Service_Request__c objSR = objSRTBU;
                    if(mapStepTransition.get(selTransition).HexaBPM__From__c== 'Awaiting Verification' && mapStepTransition.get(selTransition).HexaBPM__To__c == 'Application Verified'){
                        if(step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'P_O_Box_New' || 
                            step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'P_O_Box_Renewal')
                        {       
                            if(RejReason!=null && RejReason!='')
                                objSR.HexaBPM__Rejection_Reason__c = RejReason;
                            
                            if(step.HexaBPM__SR__r.Agent_Name__c!=null){
                                HexaBPM__SR_Status__c Status = [Select id from HexaBPM__SR_Status__c Where name ='Awaiting Emirates Id Submission'];
                                objSR.HexaBPM__External_SR_Status__c = status.Id;
                                objSR.HexaBPM__Internal_SR_Status__c = status.Id;
                            } else {
                                objSR.HexaBPM__External_SR_Status__c = [Select id from HexaBPM__SR_Status__c Where name ='Application in Progress'].Id;
                                objSR.HexaBPM__Internal_SR_Status__c = [Select id from HexaBPM__SR_Status__c Where name ='Awaiting Typing'].Id;
                            }
                            lstSRsTBU.add(objSR);
                        }
                    }
                    // Added to change the SR status conditionally- biometric is required then Medical test result step will be created
                    /*if(step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'Employment_Visa_New' && step.HexaBPM__Summary__c =='Medical In Progress' ) {
                        String SRStatusName ='';
                        if(step.HexaBPM__SR__r.Biometric__c== 'Yes' )  {
                            SRStatusName = 'Awaiting Medical Test Result';                            
                        } else {
                             SRStatusName = 'Awaiting Residence Visa Approval';
                        }   
                        Id statusId = [Select id from HexaBPM__SR_Status__c Where name =:SRStatusName].Id;
                        objSR.HexaBPM__External_SR_Status__c = statusId;
                        objSR.HexaBPM__Internal_SR_Status__c = statusId;
                    }*/
                }
                
                if(mapStepTransition.get(selTransition).HexaBPM__SR_Status_Internal__c!=null && mapStepTransition.get(selTransition).HexaBPM__SR_Status_External__c!=null)
                {
                    HexaBPM__Service_Request__c objSR = objSRTBU;
                    objSR.HexaBPM__Internal_SR_Status__c = mapStepTransition.get(selTransition).HexaBPM__SR_Status_Internal__c;
                    objSR.HexaBPM__External_SR_Status__c = mapStepTransition.get(selTransition).HexaBPM__SR_Status_External__c;
                    if(RejReason!=null && RejReason!='')
                        objSR.HexaBPM__Rejection_Reason__c = RejReason;
                    
                    //Assign Doc Valid from and Valid TO
                    
                    if(step.HexaBPM__Step_Template__r.HexaBPM__Code__c == 'RESIDENCE_VISA_STAMPING_PROCESS' && mapStepTransition.get(selTransition).HexaBPM__Transition__r.HexaBPM__To__r.Name == 'Residence Visa Stamped')
                    {
                        objSR.Residence_Visa_Date_of_Issue__c = objSR.Valid_From__c;
                        objSR.Residence_Visa_Date_of_Expiry__c = objSR.Valid_To__c;
                    }
                    if((srRecTypeName == 'Dependent_Visa_New'|| srRecTypeName == 'Dependent_Visa_Renewal') && age <=14 && step.HexaBPM__Step_Template__r.HexaBPM__Code__c == 'EMIRATES_ID_APPLICATION'){
                        objSR.HexaBPM__External_SR_Status__c = label.Awaiting_upload_of_HIC;
                    }
                    if((srRecTypeName == 'Dependent_Visa_New'|| srRecTypeName == 'Dependent_Visa_Renewal') && age <=14 && step.HexaBPM__Step_Template__r.HexaBPM__Code__c == 'UPDATE_HEALTH_INSURANCE_DETAILS'){
                        objSR.HexaBPM__External_SR_Status__c = label.VISA_STAMPING_IN_PROGRESS;
                        objSR.HexaBPM__Internal_SR_Status__c = label.AWAITING_RESIDENCE_VISA_STAMPING;
                    }
                    lstSRsTBU.add(objSR);
                }
                
                if(mapStepTransition.get(selTransition).HexaBPM__Parent_SR_Status__c!=null && step.HexaBPM__SR__r.HexaBPM__Parent_SR__c!=null){
                  
                    HexaBPM__Service_Request__c objParentSR = new HexaBPM__Service_Request__c(Id=step.HexaBPM__SR__r.HexaBPM__Parent_SR__c);
                    objParentSR.HexaBPM__Internal_SR_Status__c = mapStepTransition.get(selTransition).HexaBPM__Parent_SR_Status__c;
                    objParentSR.HexaBPM__External_SR_Status__c = mapStepTransition.get(selTransition).HexaBPM__Parent_SR_Status__c;
                    if(RejReason!=null && RejReason!='')
                        objParentSR.HexaBPM__Rejection_Reason__c = RejReason;
                    lstSRsTBU.add(objParentSR);
                }
                update lstSRsTBU;
                
                step.HexaBPM__Status__c = mapStepTransition.get(selTransition).HexaBPM__Transition__r.HexaBPM__To__c;
                step.HexaBPM__Step_Notes__c = StepNotes;
                step.HexaBPM__Rejection_Reason__c = RejReason;
                if(StepNotes==null || (StepNotes!=null && StepNotes==''))
                    step.HexaBPM__Step_Notes__c = RejReason;
                system.debug('RejReason=>'+RejReason);
                
                System.debug('@@STEP1--: '+step);
                lstStepsTBU.add(step);
                if(mapStepTransition.get(selTransition).HexaBPM__Parent_Step_Status__c!=null && step.HexaBPM__SR__r.HexaBPM__Parent_Step__c!=null){
                    
                    HexaBPM__Step__c ParentStep = new HexaBPM__Step__c(Id=step.HexaBPM__SR__r.HexaBPM__Parent_Step__c);
                    ParentStep.HexaBPM__Status__c = mapStepTransition.get(selTransition).HexaBPM__Parent_Step_Status__c;
                    lstStepsTBU.add(ParentStep);
                }
                update lstStepsTBU;
                
                
                //ISSUE-000154 - START
                if(checkConditions == true)
                {
                
                    boolean isMedicalClosed         = false;
                    boolean isHealthCardStepClosed  = false;
                    //boolean isSubmitPPtoADGMClosed  = false;
                    boolean isUpdateHIcardClosed    = false;
                    boolean isEIDClosed             = false;
                    HexaBPM__Service_Request__c SRtoupdate = new HexaBPM__Service_Request__c();
                    
                    
                    for(HexaBPM__Step__c step : [SELECT HexaBPM__Status__r.HexaBPM__Code__c,HexaBPM__Step_Template__r.HexaBPM__Code__c from HexaBPM__Step__c where (HexaBPM__Step_Template__r.HexaBPM__Code__c = 'UPLOAD_HEALTH_INSURANCE_CARD'
                        OR HexaBPM__Step_Template__r.HexaBPM__Code__c = 'MEDICAL_IN_PROGRESS' 
                        Or HexaBPM__Step_Template__r.HexaBPM__Code__c = 'UPDATE_HEALTH_INSURANCE_DETAILS'
                        Or HexaBPM__Step_Template__r.HexaBPM__Code__c = 'EMIRATES_ID_APPLICATION') 
                     and HexaBPM__SR__c =:SRID])
                    {
                        if(step.HexaBPM__Step_Template__r.HexaBPM__Code__c == 'UPLOAD_HEALTH_INSURANCE_CARD' && step.HexaBPM__Status__r.HexaBPM__Code__c == 'DOCUMENT_UPLOADED'){
                            isHealthCardStepClosed = true;
                        }
                        //if(step.HexaBPM__Step_Template__r.HexaBPM__Code__c == 'SUBMIT_PASSPORT_VISA_STAMPING' && (step.HexaBPM__Status__r.HexaBPM__Code__c == 'DELIVERED_TO_ADGM' || step.HexaBPM__Status__r.HexaBPM__Code__c == 'COURIER_COLLECTION')){
                          //  isSubmitPPtoADGMClosed = true;
                        //}
                        if(step.HexaBPM__Step_Template__r.HexaBPM__Code__c == 'MEDICAL_IN_PROGRESS' && step.HexaBPM__Status__r.HexaBPM__Code__c == 'MEDICAL_APPLICATION_COMPLETED'){
                            isMedicalClosed   = true;
                        }
                        if(step.HexaBPM__Step_Template__r.HexaBPM__Code__c == 'UPDATE_HEALTH_INSURANCE_DETAILS' && step.HexaBPM__Status__r.HexaBPM__Code__c == 'INSURANCE_DTLS_UPDATED'){
                            isUpdateHIcardClosed   = true;
                        }
                        if(step.HexaBPM__Step_Template__r.HexaBPM__Code__c == 'EMIRATES_ID_APPLICATION' && step.HexaBPM__Status__r.HexaBPM__Code__c == 'TYPING_COMPLETED'){
                            isEIDClosed   = true;
                        }
                    }
                    
                    //system.debug('===isUpdateHIcardClosed==='+isUpdateHIcardClosed+'=isHealthCardStepClosed =='+isHealthCardStepClosed+'==isSubmitPPtoADGMClosed =='+isSubmitPPtoADGMClosed ) ;
                    SRtoupdate.id = SRID;
                    system.debug('==isUpdateHIcardClosed===='+isUpdateHIcardClosed+'==isMedicalClosed===='+isMedicalClosed);
                    if(isUpdateHIcardClosed == true && isMedicalClosed == true){
                        SRtoupdate.HexaBPM__External_SR_Status__c  = label.AWAITING_VISA_APPROVAL;
                        SRtoupdate.HexaBPM__Internal_SR_Status__c  = label.AWAITING_VISA_APPROVAL;
                    }
                    /*
                    //The below condition will execute  when the medical step closed.
                    if(isHealthCardStepClosed == false && isSubmitPPtoADGMClosed == false){
                        SRtoupdate.HexaBPM__External_SR_Status__c  = label.Awaiting_Upload_of_HIC_and_Submit_PP_to_ADGM;
                    }
                    else if(isUpdateHIcardClosed == true && isSubmitPPtoADGMClosed == false){
                        SRtoupdate.HexaBPM__Internal_SR_Status__c  = label.AWAITING_RESIDENCE_VISA_STAMPING;
                        SRtoupdate.HexaBPM__External_SR_Status__c  = label.Awaiting_PP_submission_for_visa_stamping;
                    }
                    else if(isHealthCardStepClosed == false && isSubmitPPtoADGMClosed == true){
                        SRtoupdate.HexaBPM__External_SR_Status__c  = label.Awaiting_upload_of_HIC;
                        SRtoupdate.HexaBPM__Internal_SR_Status__c  = label.AWAITING_INSURANCE_DETAILS;
                    }
                    else if(isSubmitPPtoADGMClosed == true && isUpdateHIcardClosed == true){
                        SRtoupdate.HexaBPM__Internal_SR_Status__c  = label.AWAITING_RESIDENCE_VISA_STAMPING;
                    }
                    else if(isHealthCardStepClosed == true && isSubmitPPtoADGMClosed == true && isUpdateHIcardClosed == false){
                        SRtoupdate.HexaBPM__Internal_SR_Status__c  = label.AWAITING_INSURANCE_DETAILS;
                    }*/
                    
                    /*if(isEIDClosed == true){
                            SRtoupdate.HexaBPM__External_SR_Status__c  = label.AWAITING_MED_INS_DETAILS;
                            SRtoupdate.HexaBPM__Internal_SR_Status__c  = label.AWAITING_MED_INS_DETAILS;
                    }*/
                    if(srRecTypeName == 'Dependent_Visa_New' || srRecTypeName == 'Dependent_Visa_Renewal')
                    {
                        system.debug('====='+age);
                        /*if(isHealthCardStepClosed == true && age < 15)
                        {
                            SRtoupdate.HexaBPM__Internal_SR_Status__c  = label.AWAITING_INSURANCE_DETAILS;
                            SRtoupdate.HexaBPM__External_SR_Status__c  = label.VISA_STAMPING_IN_PROGRESS;
                        }*/
                        if(isUpdateHIcardClosed == true && age < 18){
                            SRtoupdate.HexaBPM__Internal_SR_Status__c  = label.AWAITING_VISA_APPROVAL;
                            SRtoupdate.HexaBPM__External_SR_Status__c  = label.AWAITING_VISA_APPROVAL;
                        }
                        
                        if(isUpdateHIcardClosed == true && isMedicalClosed == false && age >=18){
                            SRtoupdate.HexaBPM__External_SR_Status__c  = label.AWAITING_VISA_APPROVAL;
                            SRtoupdate.HexaBPM__Internal_SR_Status__c  = label.AWAITING_MED_INS_DETAILS;
                        }
                        if(isEIDClosed == true && age <=17 && isHealthCardStepClosed == false){
                            SRtoupdate.HexaBPM__External_SR_Status__c  = label.Awaiting_upload_of_HIC;
                            SRtoupdate.HexaBPM__Internal_SR_Status__c  = label.Awaiting_upload_of_HIC;
                        }
                    }
                    
                    system.debug('====='+SRtoupdate.HexaBPM__External_SR_Status__c+'===='+SRtoupdate.HexaBPM__Internal_SR_Status__c );
                    if(SRtoupdate.id != null)
                        update SRtoupdate;  
                    
                }//END
                
                
                System.debug('@@STEP2--: ');
            }catch(DMLException e){
                string DMLError = e.getdmlMessage(0)+'';
                system.debug('Full DMLError==>'+e.getdmlMessage(0));
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    System.debug(i+'Exception===>'+e.getDmlMessage(i));
                }
                if(DMLError==null){
                    DMLError = e.getMessage()+'';
                }
                selTransition = null;
                Database.rollback(Stat_svpoint);
                system.debug('DMLError==>'+DMLError);
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,DMLError));
                return null;
            }
        }else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Please select the status to proceed.'));
            return null;
        }
        return pg;
    }
    
    /*
        Description : This method will check if Passport Number exists in any of the active contacts (or) any of the open SRs.
    */
    public void ValidatePassport(string pp,Id SRID)
    {
        set<id> contactRecTypes = new set<id>();
        
        for(RecordType rectype : [SELECT Id from RecordType WHERE sObjectType='Contact' AND 
                                    (DeveloperName='Contact_Employee' OR DeveloperName='Contact_Dependent') AND IsActive=true]){
               contactRecTypes.add(rectype.id);
        }
        string status = 'Active';
        
        Search.SearchResults searchList = Search.find('FIND :pp IN ALL FIELDS RETURNING Contact(Id,Passport_No__c where Recordtypeid IN:contactRecTypes and (Dependent_Status__c = :status OR Employment_Status__c =:status) LIMIT 1), HexaBPM__Service_Request__c(Passport_Number__c where HexaBPM__IsCancelled__c=false and HexaBPM__Is_Rejected__c = false AND HexaBPM__IsClosedStatus__c = false and ID !=:SRID LIMIT 1)');
        
        List<Search.SearchResult> contactlist = searchList.get('Contact');
        for(Search.SearchResult searchResult : contactlist)
        { 
            Contact objCon = (Contact)searchResult.getSObject(); 
            if(objCon.Passport_No__c == pp){
                isPPExists = true;
            } 
        }
        
        if(isPPExists == false)
        {
            List<Search.SearchResult> srlist = searchList.get('HexaBPM__Service_Request__c');
            for(Search.SearchResult searchResult : srlist){ 
                HexaBPM__Service_Request__c objCon = (HexaBPM__Service_Request__c) searchResult.getSObject(); 
                if(objCon.Passport_Number__c == pp){
                    isPPExists = true;
                }
            }
        }
    }
    
    
    /**
     * Method Name : ViewStep
     * Description : Method invoked on click of the View Step button. Redirects the page to the Step Detail page
     **/    
    public pagereference ViewStep(){
        Pagereference pg = new Pagereference('/'+stepId);
        pg.setredirect(true);
        return pg;
    }
    /**
     * Method Name : CancelAction
     * Description : Method invoked on click of the cancel button. Redirects the page back to the SR Detail page
     **/
    public pagereference CancelAction(){
        Pagereference pg = new Pagereference('/'+SRID);
        pg.setredirect(true);
        return pg;
    }
    /**
     * Method Name : CheckAction
     * Description : Method invoked on click of the Accept/Release button.
     **/  
    public void CheckAction(){
        if(isStepOwnedByQueue == true){
            AcceptAction();
        } else{
            ReleaseAction();
        }
    }
    /**
     * Method Name : AcceptAction
     * Description : Method invoked on click of the Accept button. Action Owner is set to current user.
     **/    
    public void AcceptAction(){
        System.debug('@@STEPOWNER: '+step.OwnerId);
        step.OwnerId = Userinfo.getUserId();
        try{
            update step;
            isStepOwnedByQueue = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Action Item Assigned Successfully.'));
        }catch(Exception e){
        }
    }
    /**
    /**
     * Method Name : ReleaseAction
     * Description : Method invoked on click of the Release button. Action Owner is set to queue.
     **/    
    public void ReleaseAction(){
        System.debug('@@STEPOWNER: '+step.OwnerId);
        List<HexaBPM__Step__c> stepSelected = [SELECT Id, HexaBPM__SR_Step__r.OwnerId FROM HexaBPM__Step__c WHERE Id = :step.Id];
        step.OwnerId = stepSelected[0].HexaBPM__SR_Step__r.OwnerId;
        try{
            update step;
            isStepOwnedByQueue = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Action Item Released Successfully.'));
        }catch(Exception e){
        }
    }
    /**
     * Wrapper Class
     **/
    public class TransitionWrapper{
        public HexaBPM__Status__c objStatus{get;set;}
        public boolean ReasonRequired{get;set;}
        public HexaBPM__Step_Transition__c objSRStepTrans{get;set;}
        public TransitionWrapper(){
            ReasonRequired = false;
        }
    }
}
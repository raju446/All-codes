/**********************************************************
    Author      :   Durga Prasad
    Company     :   PwC
    Description :   Document Upload Page for the PageFlow processes
*************************************************************/
public without sharing class UploadDocumentsController{
    
        /*Global Declaration*/            
        public Attachment document{get;set;}
        public boolean isPortalUser{get;set;}
        public list<HexaBPM__SR_Doc__c> ltGeneratedDocs{get;set;}
        public list<HexaBPM__SR_Doc__c> lstUploadableDocuments{get;set;}
        public string strObjectId{get; set;}
        public string FileName{get;set;}
        public string strSRDocId{get;set;}
        public string userType{get;set;}
        public string strError{get;set;}
        public string strComments{get;set;}
        public string strExternalComments{get;set;}
        public string strAttachmentName{get;set;}
        public set<id> setsrids{get;set;}
        map<string,string> mapParameters;
        public string strCommunityName{get;set;}
        public string strDocument_Code {get;set;}
        string AccountId;
        string strTemplate_Submenu;
        public string strSelectedFileType {get;set;}
        public string srRecordtype;
        public integer iFileSize {get;set;}
        /* End of Global Declarations*/
        
        
       /*
            Construtor Definition:- UploadDocumentsController()
            This constructor is used to gets the Id of the Object from the current page reference and assigns it to the local variable        
       */
       public UploadDocumentsController(){
           /* Start of Properties Initialization for Dynamic Flow */
           setsrids = new set<id>();
           document = new Attachment();
           ltGeneratedDocs = new list<HexaBPM__SR_Doc__c>();
           lstUploadableDocuments = new list<HexaBPM__SR_Doc__c>();
           isPortalUser = true;
           strComments = '';
           strExternalComments = '';
           userType = 'salesforce';
           for(User usr:[Select Id,ContactId,Contact.AccountId from User where Id=:userinfo.getUserId()]){
                if(usr.ContactId!=null){
                    userType = 'Community';
                    AccountId = usr.Contact.AccountId;
                }else{
                    isPortalUser = false;
                }
           }
           
           if(userType!='salesforce' && label.HexaBPM.Community_Domain!=null)
                strCommunityName = label.HexaBPM.Community_Domain;
           else
                strCommunityName = 'N/A';
           if(apexpages.currentpage().getParameters().get('Id')!=null)
                strObjectId = string.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('Id'));
           if(strObjectId!=null)
                setsrids.add(strObjectId);
           for(HexaBPM__Service_Request__c srObj : [select HexaBPM__SR_Template__r.HexaBPM__Sub_menu__c,HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c from HexaBPM__Service_Request__c where Id=:strObjectId]){
               strTemplate_Submenu  = srObj.HexaBPM__SR_Template__r.HexaBPM__Sub_menu__c;
               srRecordtype         = srObj.HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c;
           }
           PrepareGenDocs();
           retriveDocument();//calling the Retrieve document method to retrieve the documents of the object if exist on page load
           
           /* Start of Properties Initialization for Dynamic Flow */
            mapParameters = new map<string,string>();
            if(apexpages.currentPage().getParameters()!=null)
                mapParameters = apexpages.currentPage().getParameters();
        }
        /*
            Method Name :   CheckAccess
            Description :   Code to check the Service Request belongs to the logged In user's account or not
        */
        public pagereference CheckAccess(){
            Pagereference pg = new Pagereference('/apex/Noaccess');
            pg.setRedirect(true);
            boolean hasAccess = true;
            if(userType=='Community' && strObjectId!=null && AccountId!=null){
                for(HexaBPM__Service_Request__c SR:[Select Id,HexaBPM__Customer__c from HexaBPM__Service_Request__c where Id=:strObjectId]){
                   if(SR.HexaBPM__Customer__c!=AccountId)
                        hasAccess = false;
                }
                if(!hasAccess)
                    return pg;
            }
            return null;
        }
        /*
            Method Name :   PrepareGenDocs
            Description :   Code to query the documents to be generated
        */
        public void PrepareGenDocs(){
            ltGeneratedDocs = new list<HexaBPM__SR_Doc__c>();
            if(setsrids!=null && setsrids.size()>0){
                if(isPortalUser == true){
                    ltGeneratedDocs = [select id,Re_upload__c,HexaBPM__SR_Template_Doc__r.HexaBPM__On_Submit__c,HexaBPM__Service_Request__r.Letter_Available_for_Download__c,createddate,Preview_Download_Document__c,lastmodifieddate,HexaBPM__Document_Type__c,HexaBPM__Is_Not_Required__c,HexaBPM__Document_Description_External__c,HexaBPM__Preview_Download_Document__c,HexaBPM__Service_Request__c,HexaBPM__Service_Request__r.HexaBPM__Internal_Status_Name__c,name,HexaBPM__Doc_ID__c,HexaBPM__Customer_Comments__c,HexaBPM__Comments__c,HexaBPM__Rejection_Reason__c,HexaBPM__Status__c from HexaBPM__SR_Doc__c where HexaBPM__Service_Request__c IN:setsrids and HexaBPM__Sys_IsGenerated_Doc__c=true and IsDeleted=false and (Available_to_Community__c=true or HexaBPM__Service_Request__r.Show_Work_Permit__c = true) order by CreatedDate asc];
                } else{
                    ltGeneratedDocs = [select id,Re_upload__c,HexaBPM__SR_Template_Doc__r.HexaBPM__On_Submit__c,HexaBPM__Service_Request__r.Letter_Available_for_Download__c,createddate,Preview_Download_Document__c,lastmodifieddate,HexaBPM__Document_Type__c,HexaBPM__Is_Not_Required__c,HexaBPM__Document_Description_External__c,HexaBPM__Preview_Download_Document__c,HexaBPM__Service_Request__c,HexaBPM__Service_Request__r.HexaBPM__Internal_Status_Name__c,name,HexaBPM__Doc_ID__c,HexaBPM__Customer_Comments__c,HexaBPM__Comments__c,HexaBPM__Rejection_Reason__c,HexaBPM__Status__c from HexaBPM__SR_Doc__c where HexaBPM__Service_Request__c IN:setsrids and HexaBPM__Sys_IsGenerated_Doc__c=true and IsDeleted=false order by CreatedDate asc];
                }
            } 
        }
        
       /*
         Method Definition:- cancel()
         This is used to cancel the operation          
       */ 
       public void Cancel() {
            document = new Attachment();
       }
       /*
         * Method Definition:- upload()
         * This is used to Upload the document into the document object and related documents custom object.
         *      
       */ 
        public void Upload() {
            string defaultContentTypeForPassport ='tiff';
            Savepoint sp = Database.setSavepoint();
            if(strAttachmentName != null)
                FileName = strAttachmentName;
            if(strObjectId!=null && strObjectId!=''){
                HexaBPM__SR_Doc__c objRA = new HexaBPM__SR_Doc__c();    
            
                try{
                    document.Name = FileName + '.' + strSelectedFileType;
                    if(test.isRunningTest()){
                        strDocument_Code = 'passport_copy';
                    }
                    if(string.isNotEmpty(strTemplate_Submenu) && string.isNotEmpty(strDocument_Code)){
                        if(strTemplate_Submenu.toLowerCase() == 'permits' && strDocument_Code.toLowerCase() == 'passport_copy')
                        {
                            if(srRecordtype == 'Permit_Training_and_Seminar' || srRecordtype == 'Permit_Events_and_Exhibition' || srRecordtype == 'Permit_Photography'){
                                document.Name = FileName +'.pdf';
                            }else
                                document.Name = FileName +'.'+ defaultContentTypeForPassport ;
                        }
                    }
                    if(document!=null && document.body!=null){
                        //Checks File validation for the format types -- v1.1
                        boolean validFile = false;
                        boolean validFileType = false;
                        string selectedContenttype = document.ContentType;
                        if(string.isNotEmpty(selectedContenttype)){
                            System.debug('selectedContenttype'+selectedContenttype);
                            String[] validContentTypes =new String[]{'jpg', 'jpeg', 'bmp', 'gif', 'png', 'pdf', 'doc', 'docx', 'tiff'};
                            for(string strContentType : validContentTypes ){
                                if(selectedContenttype.indexOf(strContentType) > -1){ 
                                    validFileType = true;
                                    break;
                                }
                            }
                        }
                        if(validFileType == false){
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a valid file format');
                            ApexPages.addMessage(myMsg);
                            document = new Attachment(); 
                        }
                        // 1MB validation
                        else if(validFileType == true){
                            //if(iFileSize > 1048576) { 
                            if(iFileSize > 5242880) { 
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please upload a file with a maximum of 5MB size');
                                ApexPages.addMessage(myMsg);
                                document = new Attachment();
                            }
                            else
                                validFile = true;
                        }
                        if(validFile == true){
                            document.parentId = strSRDocId;
                            upsert document;
                            objRA.Id = strSRDocId;
                            if(document.Id!=null){
                            objRA.HexaBPM__Doc_ID__c = string.valueOf(document.Id);
                            objRA.HexaBPM__Status__c = 'Uploaded';
                            objRA.Re_upload__c = false;
                            objRA.HexaBPM__Document_Type__c = document.ContentType;
                            }
                            if(strComments!=null && strComments!='' && strComments.trim()!='')
                                objRA.HexaBPM__Comments__c = strComments;
                            if(strExternalComments!=null && strExternalComments!='' && strExternalComments.trim()!='')
                                objRA.HexaBPM__Customer_Comments__c = strExternalComments;
                            if(strObjectId!=null && strObjectId!=''){
                                objRA.HexaBPM__Service_Request__c = strObjectId;
                                objRA.HexaBPM__Document_Type__c = document.ContentType;
                                //try{
                                    update objRA;
                                //}catch(Exception e){
                                    //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
                                //}
                                String openPaymentValidation = ApexCodeUtility.CheckOpenFinePaymentStep(strObjectId);
                            if(openPaymentValidation!='Success'){
                                Database.rollback(sp);
                                retriveDocument();
                                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,openPaymentValidation));
                            }else{
                                CloseCustomerReupoladStep();
                            }
                            }
                        }
                    }else{
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Please specify a file to upload.'));
                    }
                }catch(DMLException e) {//To catch the DML exception while uploading the file
                  Database.rollback(sp);
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getdmlMessage(0)));
                    document = new Attachment();
                }finally {
                   document = new Attachment();
                   retriveDocument();
                }
            }else{
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'There is no Object Id'));   
            }
        }
    
    /*
         * Method Definition:- retriveDocument()
         * This is used to Retrieve the document related to the object and displays it on page load as well as on insertion of the document.
         *      
    */      
    public void retriveDocument(){
        lstUploadableDocuments = new list<HexaBPM__SR_Doc__c>();
        if(setsrids != null && setsrids.size()>0){
            if(isPortalUser == true){
                //lstUploadableDocuments = [select id,Re_upload__c,HexaBPM__SR_Template_Doc__r.Community_User_Upload_Not_Available__c,Participant_Name__c,HexaBPM__Service_Request__r.Letter_Available_for_Download__c,createddate,Preview_Download_Document__c,HexaBPM__Document_Type__c,lastmodifieddate,HexaBPM__Is_Not_Required__c,HexaBPM__Document_Description_External__c,HexaBPM__Document_Master__r.Name,HexaBPM__Service_Request__c,HexaBPM__Service_Request__r.HexaBPM__Internal_Status_Name__c,HexaBPM__Service_Request__r.HexaBPM__External_Status_Name__c,name,HexaBPM__Doc_ID__c,HexaBPM__Customer_Comments__c,HexaBPM__Comments__c,HexaBPM__Rejection_Reason__c,HexaBPM__Status__c,HexaBPM__Document_Master__r.HexaBPM__Code__c from HexaBPM__SR_Doc__c where HexaBPM__Service_Request__c IN:setsrids and HexaBPM__Sys_IsGenerated_Doc__c=false and IsDeleted=false and  Available_to_Community__c=true order by CreatedDate asc];
                list<HexaBPM__SR_Doc__c> lstDocs = [select id,Available_to_Community_on_Step__c,Re_upload__c,HexaBPM__SR_Template_Doc__r.Community_User_Upload_Not_Available__c,Participant_Name__c,HexaBPM__Service_Request__r.Letter_Available_for_Download__c,createddate,Preview_Download_Document__c,HexaBPM__Document_Type__c,lastmodifieddate,HexaBPM__Is_Not_Required__c,HexaBPM__Document_Description_External__c,HexaBPM__Document_Master__r.Name,HexaBPM__Service_Request__c,HexaBPM__Service_Request__r.HexaBPM__Internal_Status_Name__c,HexaBPM__Service_Request__r.HexaBPM__External_Status_Name__c,name,HexaBPM__Doc_ID__c,HexaBPM__Customer_Comments__c,HexaBPM__Comments__c,HexaBPM__Rejection_Reason__c,HexaBPM__Status__c,HexaBPM__Document_Master__r.HexaBPM__Code__c from HexaBPM__SR_Doc__c where HexaBPM__Service_Request__c IN:setsrids and HexaBPM__Sys_IsGenerated_Doc__c=false and IsDeleted=false and  Available_to_Community__c=true order by CreatedDate asc];
                Set<Id> srStepsCreated = new Set<Id>();
                for(HexaBPM__Step__c step : [select id, HexaBPM__SR_Step__c FROM HexaBPM__Step__c WHERE HexaBPM__SR__c IN: setsrids]){
                    srStepsCreated.add(step.HexaBPM__SR_Step__c);
                }
                for(HexaBPM__SR_Doc__c srdoc : lstDocs){
                    if(srdoc.Available_to_Community_on_Step__c == null || srdoc.Available_to_Community_on_Step__c == ''){
                        lstUploadableDocuments.add(srdoc);
                    } else{
                        if(srStepsCreated.contains(srdoc.Available_to_Community_on_Step__c)){
                            lstUploadableDocuments.add(srdoc);
                        }
                    }
                }
            }else{
                lstUploadableDocuments = [select id,Re_upload__c,HexaBPM__SR_Template_Doc__r.Community_User_Upload_Not_Available__c,Participant_Name__c,HexaBPM__Service_Request__r.Letter_Available_for_Download__c,createddate,Preview_Download_Document__c,HexaBPM__Document_Type__c,lastmodifieddate,HexaBPM__Is_Not_Required__c,HexaBPM__Document_Description_External__c,HexaBPM__Document_Master__r.Name,HexaBPM__Service_Request__c,HexaBPM__Service_Request__r.HexaBPM__Internal_Status_Name__c,HexaBPM__Service_Request__r.HexaBPM__External_Status_Name__c,name,HexaBPM__Doc_ID__c,HexaBPM__Customer_Comments__c,HexaBPM__Comments__c,HexaBPM__Rejection_Reason__c,HexaBPM__Status__c,HexaBPM__Document_Master__r.HexaBPM__Code__c from HexaBPM__SR_Doc__c where HexaBPM__Service_Request__c IN:setsrids and HexaBPM__Sys_IsGenerated_Doc__c=false and IsDeleted=false order by CreatedDate asc];
            }
        }
    }
    /*
         * Method Definition:- Back_To_SR
         * This is used to navigate user back to the service request detail page on button click
         *      
    */
    public pagereference Back_To_SR(){
        pagereference pg = new pagereference('/'+strObjectId);
        pg.setRedirect(true);
        return pg;
    }
    /*
         * Method Definition:- SaveChanges
         * This is used to save the changes made on the page and navigates back to Service Request Detail Page
         *      
    */
    public pagereference SaveChanges(){
            try{
            if(lstUploadableDocuments!=null && lstUploadableDocuments.size()>0){
                for(HexaBPM__SR_Doc__c doc:lstUploadableDocuments){
                    if(doc.Re_upload__c==true)
                        doc.HexaBPM__Status__c='Re-upload';
                }
                
                update lstUploadableDocuments;
                boolean ReUploadDoc = false;
                integer ApprovedCount = 0;
                for(HexaBPM__SR_Doc__c doc:lstUploadableDocuments){
                    if(doc.HexaBPM__Status__c=='Re-upload' || doc.Re_upload__c==true)
                        ReUploadDoc = true;
                    else if(doc.HexaBPM__Status__c=='Approved')
                        ApprovedCount = ApprovedCount + 1;
                }
                if(strObjectId!=null && strObjectId!='' && (ReUploadDoc || (lstUploadableDocuments!=null && ApprovedCount==lstUploadableDocuments.size()))){
                    if(ReUploadDoc==true)
                        AutoCloseStep(true);
                    else
                        AutoCloseStep(false);
                }
            }
        }catch(DMLException e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
            return null;
        }
        pagereference pg = new pagereference('/'+strObjectId);
        pg.setRedirect(true);
        return pg;
    }
    /*
         * Method Definition:- AutoCloseStep
         * This is used to close the open document upload/reupload step when user clicks on Save
         *      
    */
    public void AutoCloseStep(boolean Reupload){
        /*
        HexaBPM__Step__c objStp = new HexaBPM__Step__c();
        for(HexaBPM__Step__c stp:[Select Id,HexaBPM__Status__c,HexaBPM__SR_Step__c,HexaBPM__SR_Step__r.HexaBPM__Start_Status__c from HexaBPM__Step__c where HexaBPM__SR__c=:strObjectId and HexaBPM__Status__r.HexaBPM__Reupload_Document__c=true and HexaBPM__SR_Step__c!=null]){
            if(stp.HexaBPM__SR_Step__c!=null && stp.HexaBPM__Status__c==stp.HexaBPM__SR_Step__r.HexaBPM__Start_Status__c)
                objStp = stp;
        }
        if(objStp.Id!=null){
            HexaBPM__Step_Transition__c StpTrans = new HexaBPM__Step_Transition__c();
            for(HexaBPM__Step_Transition__c trans:[Select Id,HexaBPM__Transition__c,HexaBPM__Transition__r.HexaBPM__To__c,HexaBPM__SR_Status_Internal__c,HexaBPM__SR_Status_External__c from HexaBPM__Step_Transition__c where HexaBPM__SR_Step__c=:objStp.HexaBPM__SR_Step__c and HexaBPM__Transition__r.HexaBPM__To__r.HexaBPM__Reupload_Document__c=:Reupload limit 1]){
                StpTrans = trans;
            }
            if(StpTrans!=null && StpTrans.Id!=null){
                objStp.HexaBPM__Status__c = StpTrans.HexaBPM__Transition__r.HexaBPM__To__c;
                update objStp;
                if(StpTrans.HexaBPM__SR_Status_Internal__c!=null || StpTrans.HexaBPM__SR_Status_External__c!=null){
                    HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c(Id=strObjectId);
                    if(StpTrans.HexaBPM__SR_Status_Internal__c!=null)
                        objSR.HexaBPM__Internal_SR_Status__c = StpTrans.HexaBPM__SR_Status_Internal__c;
                    if(StpTrans.HexaBPM__SR_Status_External__c!=null)
                        objSR.HexaBPM__External_SR_Status__c = StpTrans.HexaBPM__SR_Status_External__c;
                        update objSR;
                }
            }
        }
        */
    }
    /*
         * Method Definition:- CloseCustomerReupoladStep
         * This is used to close the open document reupload step assigned to portal user
         *      
    */
    public void CloseCustomerReupoladStep(){
        HexaBPM__Step__c Reuplodstp = new HexaBPM__Step__c();
        HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
        boolean hasReuploadDocs = false;
        objSR.Id = strObjectId;
        decimal age = 0;
        for(HexaBPM__Step__c stp:[select Id,HexaBPM__SR_Step__c,HexaBPM__Status__c,HexaBPM__SR__c,HexaBPM__SR__r.HexaBPM__Record_Type_Name__c,HexaBPM__SR__r.Age_Days__c from HexaBPM__Step__c where (HexaBPM__Status__r.HexaBPM__Code__c='AWAITING_RE_UPLOAD' or HexaBPM__Status__r.AutoClose_Step__c=true) and HexaBPM__Status__r.HexaBPM__Type__c!='End' and (HexaBPM__SR__c=:strObjectId or HexaBPM__SR__r.HexaBPM__Parent_SR__c=:strObjectId)]){
            Reuplodstp = stp;
            age = stp.HexaBPM__SR__r.Age_Days__c;
        }
        if(Reuplodstp!=null && Reuplodstp.Id!=null)
        {
            objSR.Id = Reuplodstp.HexaBPM__SR__c;
            boolean TransitionFound = false;
            for(HexaBPM__Step_Transition__c stptran : [select HexaBPM__SR_Status_Internal__c,HexaBPM__SR_Status_External__c,HexaBPM__Transition__r.HexaBPM__To__c,HexaBPM__Transition__r.HexaBPM__From__c from HexaBPM__Step_Transition__c where HexaBPM__Transition__c!=null and HexaBPM__SR_Step__c=:Reuplodstp.HexaBPM__SR_Step__c and HexaBPM__Transition__r.HexaBPM__From__c=:Reuplodstp.HexaBPM__Status__c and  HexaBPM__Transition__r.HexaBPM__To__r.HexaBPM__Type__c = 'End' limit 1]){
                Reuplodstp.HexaBPM__Status__c = stptran.HexaBPM__Transition__r.HexaBPM__To__c;
                if(stptran.HexaBPM__SR_Status_Internal__c!=null)
                    objSR.HexaBPM__Internal_SR_Status__c = stptran.HexaBPM__SR_Status_Internal__c;
                if(stptran.HexaBPM__SR_Status_External__c!=null)
                    objSR.HexaBPM__External_SR_Status__c = stptran.HexaBPM__SR_Status_External__c;
                TransitionFound = true;
                break;
            }
            if(TransitionFound){
                for(HexaBPM__SR_Doc__c srDoc:[select Id from HexaBPM__SR_Doc__c where HexaBPM__Service_Request__c=:strObjectId and (HexaBPM__Status__c='Re-upload' or (HexaBPM__Status__c='Pending Upload' and HexaBPM__Is_Not_Required__c=false))]){
                    hasReuploadDocs = true;
                    break;
                }
                if(hasReuploadDocs==false){
                    //try{
                        if(objSR.HexaBPM__Internal_SR_Status__c!=null || objSR.HexaBPM__Internal_SR_Status__c!=null)
                            update objSR;
                        update Reuplodstp;
                    //}catch(DMLException e){
                        //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
                    //}
                }
            }
            //ISSUE-000154 - START
            //Query submit PP to adgm step and check if it is open.
           /* if(Reuplodstp.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'Employment_Visa_New' 
                || Reuplodstp.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'Long_Term_Residence_Visa_New'
                || Reuplodstp.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'Dependent_Visa_New'
                || Reuplodstp.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'Employment_Visa_Renewal'
                || Reuplodstp.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'Dependent_Visa_Renewal'
                || Reuplodstp.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'Visa_Transfer')
            {
                for(HexaBPM__Step__c step : [SELECT HexaBPM__Status__r.HexaBPM__Code__c,HexaBPM__Step_Template__r.HexaBPM__Code__c from HexaBPM__Step__c where 
                    HexaBPM__Step_Template__r.HexaBPM__Code__c = 'SUBMIT_PASSPORT_VISA_STAMPING'  and HexaBPM__SR__c =:objSR.Id])
                {
                    if(step.HexaBPM__Step_Template__r.HexaBPM__Code__c == 'SUBMIT_PASSPORT_VISA_STAMPING' && (step.HexaBPM__Status__r.HexaBPM__Code__c == 'DELIVERED_TO_ADGM' ||    step.HexaBPM__Status__r.HexaBPM__Code__c == 'COURIER_COLLECTION'))
                    {
                        objSR.HexaBPM__Internal_SR_Status__c  = label.AWAITING_INSURANCE_DETAILS;
                    }
                    else{
                        objSR.HexaBPM__Internal_SR_Status__c  = label.AWAITING_INSURANCE_DETAILS;
                        objSR.HexaBPM__External_SR_Status__c  = label.Awaiting_PP_submission_for_visa_stamping;
                    }
                }
                update objSR;
            }
            //END */
            
            //If dependent age is less than 15 , upon closure of upload H.I.C step open Visa stamping step.
            if(Reuplodstp.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'Dependent_Visa_New' || Reuplodstp.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'Dependent_Visa_Renewal')
            {
                for(HexaBPM__Step__c step : [SELECT HexaBPM__Status__r.HexaBPM__Code__c,HexaBPM__Step_Template__r.HexaBPM__Code__c from HexaBPM__Step__c where 
                    HexaBPM__Step_Template__r.HexaBPM__Code__c = 'UPLOAD_HEALTH_INSURANCE_CARD'  and HexaBPM__SR__c =:objSR.Id])
                {
                    if(age <=14 && step.HexaBPM__Status__r.HexaBPM__Code__c == 'DOCUMENT_UPLOADED'){
                        objSR.HexaBPM__Internal_SR_Status__c = label.AWAITING_INSURANCE_DETAILS;
                        objSR.HexaBPM__External_SR_Status__c = label.VISA_STAMPING_IN_PROGRESS;
                        update objSR;
                    }
                }
            }
        }   
        else
        {
            update objSR;
        }
    }
    public string RemoveDocumentId{get;set;}
    public pagereference RemoveDocument(){
        if(RemoveDocumentId!=null){
            HexaBPM__SR_Doc__c objSRDoc = new HexaBPM__SR_Doc__c(Id=RemoveDocumentId);
            objSRDoc.HexaBPM__Doc_ID__c = null;
            objSRDoc.HexaBPM__Status__c = 'Pending Upload';
            try{
                update objSRDoc;
                retriveDocument();
            }catch(DMLEXception e){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
            }
        }
        return null;
    }
}
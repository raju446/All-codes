/*
    Author      : Kim Noceda
    Date        : 17-Oct-2017
    Description : Page Controller to Introductory Statement page
    --------------------------------------------------------------------------------------
*/
public without sharing class IntroductoryStatementController {
    
    public final HexaBPM__Service_Request__c selectedSR {get;set;}
    public Amendment__c newPersonnel {get;set;}
    
    public List<PersonnelWrapper> personnelWrapList {get;set;}
    
    
    public transient Attachment objDocument{get;set;}
    public list<DocumentDetailsCls> lstDocuments{get;set;}
    
    public String srTemplateCode;
    public String testStr{get;set;}
    public String srNumberStr{get;set;}
    
    public Id existPersonnelId {get;set;}
    
    public Map<String,Id> amendmentRTypeMap;
    
    //public static Set<String> communityUserProfiles = new Set<String>{Label.Community_Profile_Name, Label.Guest_User_Profile_Name, 'System Admin'};
    public static Set<String> communityUserProfiles = new Set<String>{Label.Community_Profile_Name, Label.Guest_User_Profile_Name, 'System Admin'};
    public Boolean showDetail {get;set;}
    public Boolean isPortalUser {get;set;}
    public Boolean showExport {get;set;}
    public Boolean isEdit {get;set;}
    public String DMLError {get;set;}
    public string rtype {get;set;}
    public boolean isADPPermit {get;set;}
        
    public List<Attachment> personnelAttachments {get;set;}
    
    public IntroductoryStatementController(ApexPages.StandardController stdController){
        createAmendmentMap();
        newPersonnel = new Amendment__c();
        newPersonnel.recordtypeId = amendmentRTypeMap.get('Speaker_Performer');
        this.selectedSR = (HexaBPM__Service_Request__c)stdController.getRecord();
        
        HexaBPM__Service_Request__c srNumber = [SELECT Id, Name, HexaBPM__Record_Type_Name__c, HexaBPM__FinalizeAmendmentFlg__c FROM HexaBPM__Service_Request__c WHERE Id = :selectedSR.Id];
        srNumberStr = srNumber.Name;
        showExport = true;
        isEdit = false;
        DMLError = '';
        rtype = srNumber.HexaBPM__Record_Type_Name__c;
        
        Profile userProf = [SELECT Id, Name FROM Profile WHERE Id = :Userinfo.getProfileId()];
        if(communityUserProfiles.contains(userProf.Name)){
            isPortalUser = true;
            showExport = false;
            if(srNumber.HexaBPM__FinalizeAmendmentFlg__c == true){
                isPortalUser = false;
            }
        }
        
        createPersonnelList();
        
        srTemplateCode = srNumber.HexaBPM__Record_Type_Name__c;
        system.debug('####'+srTemplateCode);
        
        objDocument = new Attachment();
        lstDocuments = new list<DocumentDetailsCls>();
        PrepareDocumentList();
        
        if(srNumber.HexaBPM__Record_Type_Name__c == 'Permit_Entertainment' || srNumber.HexaBPM__Record_Type_Name__c == 'Extended_Operating_Hours' 
            || srNumber.HexaBPM__Record_Type_Name__c == 'Temporary_Fit_Out_Security_Clearance' || srNumber.HexaBPM__Record_Type_Name__c == 'ADGM_Permit_Amendment_Service_Request')
            {
                isADPPermit = true;
            }
    }
    
    public void createAmendmentMap(){
        amendmentRTypeMap = new Map<String,Id>();
        for(Recordtype rt : [Select Id, DeveloperName FROM Recordtype WHERE SObjecttype = 'Amendment__c']){
            amendmentRTypeMap.put(rt.DeveloperName, rt.Id);
        }
    }
    
    public void createPersonnelList(){ 
        personnelWrapList = new List<PersonnelWrapper>();
        for(Amendment__c amm : [SELECT Id, Full_Name__c, Passport_No__c, Gender__c, Nationality_New__c, Emirates_ID_Number__c FROM Amendment__c WHERE Service_Request__c = :selectedSR.Id AND RecordtypeId = :amendmentRTypeMap.get('Speaker_Performer')]){
            personnelWrapList.add(new PersonnelWrapper(amm));
        }
    }
    
    public void editExisting(){
        showDetail = true;
        isEdit = true;
        newPersonnel = new Amendment__c();
        String amQueryStr = queryAmendment(existPersonnelId);
        newPersonnel = Database.query(amQueryStr);
        System.debug('@@@@#'+newPersonnel );
    }
    
    public void deletePartcipant(){
        List<HexaBPM__SR_Doc__c> deleteParticipantSRDoc = [SELECT Id FROM HexaBPM__SR_Doc__c WHERE Introductory_Statement__c = :existPersonnelId];
        List<Amendment__c> deleteParticipant = [SELECT Id FROM Amendment__c WHERE Id = :existPersonnelId];
        if(!deleteParticipantSRDoc.isEmpty()){
            delete deleteParticipantSRDoc;
        }
        if(!deleteParticipant.isEmpty()){
            try{
                delete deleteParticipant;
                createPersonnelList();
            } catch(DMLException e){
                DMLError = e.getdmlMessage(0)+'';
                if(DMLError==null){
                    DMLError = e.getMessage()+'';
                }
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,DMLError);
                ApexPages.addMessage(myMsg);
            }
        }
    }
    
    public PageReference saveRecord(){
        //checkDocuments();
        DMLError = '';
        System.debug('@@SR: '+selectedSR.Id);
        if(newPersonnel.Id == null){
            newPersonnel.Service_Request__c = selectedSR.Id;
        }
        try{
            populateNationalityLookup();
            upsert newPersonnel;
            //if(isEdit == false){
                saveAttachments();
            //}
            lstDocuments = new list<DocumentDetailsCls>();
            newPersonnel = new Amendment__c();
            PrepareDocumentList();
            createPersonnelList();
            isEdit = false;
        } catch(DMLException e){
            //return null;
            System.debug('@@ERROR: '+e.getMessage());
            DMLError = e.getdmlMessage(0)+'';
            if(DMLError==null){
                DMLError = e.getMessage()+'';
            }
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,DMLError);
            ApexPages.addMessage(myMsg);
        }
        return null;
    }
    
    public PageReference saveRedirect(){
        //checkDocuments();
        DMLError = '';
        System.debug('@@SR: '+selectedSR.Id);
        if(newPersonnel.Id == null){
            newPersonnel.Service_Request__c = selectedSR.Id;
        }
        
        try{
            /*if(selectedSR != null){
                HexaBPM__Service_Request__c objSR = [SELECT Id, Name,HexaBPM__Submitted_Date__c,Added_New_Participant__c FROM HexaBPM__Service_Request__c WHERE Id = :selectedSR.Id];
                if(objSR != null && objSR.HexaBPM__Submitted_Date__c != null){
                    objSR.Added_New_Participant__c = true;
                    update objSR;
                }
            }*/
            populateNationalityLookup();
            upsert newPersonnel;
            //if(isEdit == false){
                saveAttachments();
            //}
            lstDocuments = new list<DocumentDetailsCls>();
            newPersonnel = new Amendment__c();
            PrepareDocumentList();
            createPersonnelList();
            isEdit = false;
            PageReference pageRef = new PageReference('/'+selectedSR.Id);
            pageRef.setRedirect(true);
            return pageRef;
        } catch(DMLException e){
            System.debug('@@ERROR: '+e.getMessage());
            DMLError = e.getdmlMessage(0)+'';
            if(DMLError==null){
                DMLError = e.getMessage()+'';
            }
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,DMLError);
            ApexPages.addMessage(myMsg);
            return null;
        }
    }
    
    public void populateNationalityLookup(){
        Map<String,Id> nationalityLookupMap = new Map<String,Id>();
        for(Lookup__c lkup : [SELECT Id, Name FROM Lookup__c WHERE Type__c = 'Nationality']){
            nationalityLookupMap.put(lkup.Name.toUpperCase(),lkup.Id);
        }
        
        if(nationalityLookupMap.containskey(newPersonnel.Nationality_New__c)){
            newPersonnel.Nationality_Lookup__c = nationalityLookupMap.get(newPersonnel.Nationality_New__c);
        }
    }
    
    //save document attachments
    public void saveAttachments()
    {
        //Delete existing SR docs and create the new SR documents on modification of participant info..
        set<string> existingdocsofUser = new set<string>();
        list<HexaBPM__SR_Doc__c> lstDocsTobeDeleted = new list<HexaBPM__SR_Doc__c>();
        for(HexaBPM__SR_Doc__c sr :[Select id,Name,HexaBPM__Doc_ID__c FROM HexaBPM__SR_Doc__c WHERE Introductory_Statement__c =:newPersonnel.Id])
        {
            if(sr.HexaBPM__Doc_ID__c == null || sr.HexaBPM__Doc_ID__c == '')
            {
                lstDocsTobeDeleted.add(sr);
            }
            else{
                existingdocsofUser.add(sr.Name);
            }
    
        }
        if(!lstDocsTobeDeleted.isEmpty())
            delete lstDocsTobeDeleted;
        //
        List<HexaBPM__SR_Doc__c> insertSRDoc = new List<HexaBPM__SR_Doc__c>();
        system.debug('##UAE_RESIDENT: '+newPersonnel.UAE_Resident__c);
        for(DocumentDetailsCls doc : lstDocuments)
        {
            system.debug('##DOC_CODE: '+doc.DocumentCode);
            if(doc.DocumentCode == 'VALID_VISA_COPY' || doc.DocumentCode == 'EMIRATES_ID')
            {
                if(newPersonnel.UAE_Resident__c == TRUE && !existingdocsofUser.contains(doc.DocumentName)){
                    HexaBPM__SR_Doc__c srDoc = new HexaBPM__SR_Doc__c();
                    srDoc.HexaBPM__From_Finalize__c = true;
                    srDoc.Introductory_Statement__c = newPersonnel.Id;
                    srDoc.Name = doc.DocumentName;
                    srDoc.HexaBPM__Document_Master__c = doc.DocumentMasterId;
                    srDoc.HexaBPM__Service_Request__c = selectedSR.Id;
                    srDoc.HexaBPM__SR_Template_Doc__c = doc.STRTemplateDocumentId;
                    srDoc.HexaBPM__Status__c = 'Pending Upload';
                    srDoc.HexaBPM__Document_Description_External__c = doc.DocumentDescription;
                    
                    
                    insertSRDoc.add(srDoc);
                }
            } else if(!existingdocsofUser.contains(doc.DocumentName)){
                
                HexaBPM__SR_Doc__c srDoc = new HexaBPM__SR_Doc__c();
                srDoc.HexaBPM__From_Finalize__c = true;
                srDoc.Introductory_Statement__c = newPersonnel.Id;
                srDoc.Name = doc.DocumentName;
                srDoc.HexaBPM__Document_Master__c = doc.DocumentMasterId;
                srDoc.HexaBPM__Service_Request__c = selectedSR.Id;
                srDoc.HexaBPM__SR_Template_Doc__c = doc.STRTemplateDocumentId;
                srDoc.HexaBPM__Status__c = 'Pending Upload';
                srDoc.HexaBPM__Document_Description_External__c = doc.DocumentDescription;
                
                
                insertSRDoc.add(srDoc);
            }
        }
        
        if(!insertSRDoc.isEmpty()){
            insert insertSRDoc;
        }
    }
    
    public string queryAmendment(Id amendmentId){
      String queryStr = 'SELECT ';
      Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Amendment__c').getDescribe().fields.getMap();
      for(String s : objectFields.keySet()) {
         queryStr += ' ' + s + ', ';
      }
       queryStr = queryStr.subString(0,queryStr.Length()-2);
       queryStr += ' FROM Amendment__c';
       queryStr += ' WHERE Id = \''+amendmentId+'\'';
       
       return queryStr;
    }
    
    public class PersonnelWrapper{
        public Amendment__c personnel {get;set;}
        
        public PersonnelWrapper(Amendment__c personnel){
            this.personnel = personnel;
        }
    }
    
    public void PrepareDocumentList(){
        lstDocuments = new list<DocumentDetailsCls>();
        for(HexaBPM__SR_Template_Docs__c TD:[Select Id,HexaBPM__Added_through_Code__c,HexaBPM__Document_Master__c,HexaBPM__Document_Master__r.Name,
                                            HexaBPM__Document_Master_Code__c,HexaBPM__SR_Template__c, HexaBPM__Document_Description_External__c 
                                            from HexaBPM__SR_Template_Docs__c 
                                            WHERE HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c=:srTemplateCode 
                                            AND HexaBPM__SR_Template__r.HexaBPM__Active__c = true 
                                            AND HexaBPM__On_Submit__c = true and For_Introductory_Statement__c=true and HexaBPM__Added_through_Code__c=true]){
            //objSR.HexaBPM__SR_Template__c = TD.HexaBPM__SR_Template__c;
            DocumentDetailsCls objDoc = new DocumentDetailsCls();
            objDoc.DocumentName = TD.HexaBPM__Document_Master__r.Name;
            objDoc.DocumentCode = TD.HexaBPM__Document_Master_Code__c;
            objDoc.DocumentMasterId = TD.HexaBPM__Document_Master__c;
            objDoc.STRTemplateDocumentId = TD.Id;
            objDoc.DocumentDescription = TD.HexaBPM__Document_Description_External__c;
            lstDocuments.add(objDoc);
        }
    }
    
    public class DocumentDetailsCls{
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
}
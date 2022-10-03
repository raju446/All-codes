@isTest
private class UploadDocumentsControllerTest{
    
    public static List<SR_Doc_Running_Number__c> srDocList = new List<SR_Doc_Running_Number__c>();

    public static void createMasterData(){
        srDocList = new List<SR_Doc_Running_Number__c>();
        SR_Doc_Running_Number__c srDocNOC = new SR_Doc_Running_Number__c();
        srDocNOC.Name = 'SR_Doc_NOC';
        srDocNOC.Document_Prefix__c = 'ADGM/RA/CRNOC/1701';
        srDocNOC.SR_Doc_Running_Number__c = 0;
        srDocList.add(srDocNOC);
        
        SR_Doc_Running_Number__c srDocGOV = new SR_Doc_Running_Number__c();
        srDocGOV.Name = 'SR_Doc_GOV';
        srDocGOV.Document_Prefix__c = 'ADGM/RA/CRGOV/1701';
        srDocGOV.SR_Doc_Running_Number__c = 0;
        srDocList.add(srDocGOV);
        
        SR_Doc_Running_Number__c srDocLTR = new SR_Doc_Running_Number__c();
        srDocLTR.Name = 'SR_Doc_LTR';
        srDocLTR.Document_Prefix__c = 'ADGM/RA/CRLTR/1701';
        srDocLTR.SR_Doc_Running_Number__c = 0;
        srDocList.add(srDocLTR);
        
        SR_Doc_Running_Number__c srDocPR = new SR_Doc_Running_Number__c();
        srDocPR.Name = 'SR_Doc_PR';
        srDocPR.Document_Prefix__c = 'ADGM/RA/CRPR/1701';
        srDocPR.SR_Doc_Running_Number__c = 0;
        srDocList.add(srDocPR);
        
        SR_Doc_Running_Number__c srDocCRIMM = new SR_Doc_Running_Number__c();
        srDocCRIMM.Name = 'SR_Doc_CRIMM';
        srDocCRIMM.Document_Prefix__c = 'ADGM/RA/CRIMM/0000';
        srDocCRIMM.SR_Doc_Running_Number__c = 0;
        srDocList.add(srDocCRIMM);
        
        insert srDocList;
    }
    static testMethod void uploadDocumentTest(){
        createMasterData();
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        insert newAccounts; 
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        insert createdSRList;
        
        HexaBPM__SR_Doc__c objSRDoc = new HexaBPM__SR_Doc__c();
        objSRDoc.HexaBPM__Service_Request__c = createdSRList[0].Id;
        insert objSRDoc;
        
        Attachment objAttachment = new Attachment();
        objAttachment.Name = 'Test Document';
        objAttachment.Body = blob.valueOf('test');
        objAttachment.ParentId = newAccounts[0].Id;
        
        Attachment objAttachment1 = new Attachment();
        objAttachment1.Name = 'Test Document';
        objAttachment1.Body = blob.valueOf('test');
        objAttachment1.ParentId = objSRDoc.Id;
        insert objAttachment1;
        
        test.startTest();
            Apexpages.currentPage().getParameters().put('id',createdSRList[0].Id);
            UploadDocumentsController uploadDocCtrlr = new UploadDocumentsController();
            uploadDocCtrlr.strError = 'test';
            uploadDocCtrlr.strDocument_Code = 'test';
            uploadDocCtrlr.CheckAccess();
            uploadDocCtrlr.strObjectId = createdSRList[0].Id;
            uploadDocCtrlr.FileName = 'Test Doc.pdf';
            uploadDocCtrlr.document = objAttachment;
            uploadDocCtrlr.Cancel();
            uploadDocCtrlr.strSRDocId = createdSRList[0].Id;
            uploadDocCtrlr.document = objAttachment;
            uploadDocCtrlr.strComments = 'Test Comments';
            uploadDocCtrlr.strExternalComments = 'Test Comments';
            uploadDocCtrlr.Upload();
        test.stopTest();
    }
    static testMethod void uploadDocumentTestPDF(){
        createMasterData();
        
        //
        HexaBPM__SR_Template__c hst = new HexaBPM__SR_Template__c();
        hst.HexaBPM__Active__c = true;
        hst.Name='Employment_Visa_New';
        hst.HexaBPM__SR_RecordType_API_Name__c = 'Employment_Visa_New';
        hst.HexaBPM__Sub_menu__c = 'permits';
        insert hst;
        
       HexaBPM__Status__c stepStatus = new HexaBPM__Status__c(Name='Awaiting Verification',HexaBPM__Type__c='Start',HexaBPM__Code__c='AWAITING_RE_UPLOAD',AutoClose_Step__c=true);
        insert stepStatus;
        
        HexaBPM__Step_Template__c stepTemplate = new HexaBPM__Step_Template__c(Name='Verification of Application',HexaBPM__Code__c='VERIFICATION_OF_APPLICATION',HexaBPM__Step_RecordType_API_Name__c='General',HexaBPM__Summary__c='Verification of Application');
        insert stepTemplate;
        
        HexaBPM__SR_Steps__c srSteps = new HexaBPM__SR_Steps__c(HexaBPM__SR_Template__c=hst.id,HexaBPM__Step_Template__c=stepTemplate.id,
        HexaBPM__Start_Status__c=stepStatus.id,HexaBPM__Active__c=true,HexaBPM__Summary__c='Verification of Application',
        HexaBPM__Step_RecordType_API_Name__c='General',HexaBPM__Step_Type__c='Quick Action',HexaBPM__Group_Name__c='Verification of Application');
        insert srSteps;
        
        
        //HexaBPM__Status__c status = new HexaBPM__Status__c(Name='Awaiting Verification',HexaBPM__Code__c='AWAITING_VERIFICATION',HexaBPM__Type__c='Start');
        
        
        HexaBPM__Status__c status1 = new HexaBPM__Status__c
        (Name='Re-Upload Document',HexaBPM__Code__c='REUPLOAD_DOCUMENT',HexaBPM__Type__c='End');
        insert status1;
        
        HexaBPM__Transition__c transition = new HexaBPM__Transition__c(HexaBPM__From__c=stepStatus.id,HexaBPM__To__c=status1.id);
        insert transition;
        
        HexaBPM__SR_Status__c srStatus = new HexaBPM__SR_Status__c(Name='Awaiting Re-Upload',HexaBPM__Code__c='AWAITING_RE-UPLOAD');
        insert srStatus;
        
        HexaBPM__Step_Transition__c stepTransition = new HexaBPM__Step_Transition__c
        (HexaBPM__SR_Step__c=srSteps.id,HexaBPM__Transition__c=transition.id,HexaBPM__SR_Status_Internal__c=srStatus.id,HexaBPM__SR_Status_External__c=srStatus.id);
        insert stepTransition;
        //
        
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        insert newAccounts; 
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Employment_Visa_New');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        insert createdSRList;
        
        
        
        HexaBPM__Step__c step = new HexaBPM__Step__c();
        step.HexaBPM__SR__c = createdSRList[0].id;
        step.HexaBPM__Status__c = stepStatus.id;
        insert step;
        
        HexaBPM__Step_Template__c st = new HexaBPM__Step_Template__c(HexaBPM__Code__c='SUBMIT_PASSPORT_VISA_STAMPING',HexaBPM__Step_RecordType_API_Name__c='General');
        insert st;
        
        HexaBPM__Step__c step1 = new HexaBPM__Step__c();
        step1.HexaBPM__SR__c = createdSRList[0].id;
        step1.HexaBPM__Status__c = stepStatus.id;
        step1.HexaBPM__Step_Template__c = st.id;
        insert step1;
        
        HexaBPM__SR_Doc__c objSRDoc = new HexaBPM__SR_Doc__c();
        objSRDoc.HexaBPM__Service_Request__c = createdSRList[0].Id;
        insert objSRDoc;
        
        Attachment objAttachment = new Attachment();
        objAttachment.Name = 'Test Document';
        objAttachment.ContentType = 'application/pdf';
        objAttachment.Body = blob.valueOf('test');
        objAttachment.ParentId = newAccounts[0].Id;
        
        Attachment objAttachment1 = new Attachment();
        objAttachment1.Name = 'Test Document';
        objAttachment1.Body = blob.valueOf('test');
        objAttachment1.ParentId = objSRDoc.Id;
        insert objAttachment1;
        
        test.startTest();
            Apexpages.currentPage().getParameters().put('id',createdSRList[0].Id);
            UploadDocumentsController uploadDocCtrlr = new UploadDocumentsController();
            uploadDocCtrlr.CheckAccess();
            uploadDocCtrlr.strSRDocId = objSRDoc.Id;
            uploadDocCtrlr.strObjectId = createdSRList[0].Id;
            uploadDocCtrlr.FileName = 'Test Doc';
            uploadDocCtrlr.document = objAttachment;
            uploadDocCtrlr.strComments = 'Test Comments';
            uploadDocCtrlr.strExternalComments = 'Test Comments';
            uploadDocCtrlr.Upload();
            uploadDocCtrlr.Back_To_SR();
        test.stopTest();
    }
    
    static testMethod void uploadDocumentTestPortal(){
        createMasterData();
        
        HexaBPM__Status__c stepStatus = new HexaBPM__Status__c();
        stepStatus.AutoClose_Step__c = true;
        stepStatus.HexaBPM__Code__c = 'CLOSED';
        insert stepStatus;
        
        HexaBPM__SR_Status__c srStatus = new HexaBPM__SR_Status__c();
        srStatus.HexaBPM__Type__c = 'End';
        srStatus.HexaBPM__Code__c = 'CLOSED';
        insert srStatus;
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Community_Username__c = 'test1++@adgm.portal';
        insert newContacts;  
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        insert createdSRList;
        
        List<HexaBPM__Document_Master__c> docmas = TestUtility.createDocMasters(1);
        docmas[0].HexaBPM__Available_to_client__c = true;
        insert docmas;
        
        HexaBPM__SR_Doc__c objSRDoc = new HexaBPM__SR_Doc__c();
        objSRDoc.HexaBPM__Service_Request__c = createdSRList[0].Id;
        objSRDoc.HexaBPM__Document_Master__c = docmas[0].Id;
        insert objSRDoc;
        
        HexaBPM__Step__c objStep = new HexaBPM__Step__c();
        objStep.HexaBPM__Status__c = stepStatus.Id;
        objStep.HexaBPM__SR__c = createdSRList[0].Id;
        insert objStep;
        
        Attachment objAttachment = new Attachment();
        objAttachment.Name = 'Test Document';
        objAttachment.ContentType = 'application/json';
        objAttachment.Body = blob.valueOf('test');
        objAttachment.ParentId = newAccounts[0].Id;
        
        Attachment objAttachment1 = new Attachment();
        objAttachment1.Name = 'Test Document';
        objAttachment1.Body = blob.valueOf('test');
        objAttachment1.ParentId = objSRDoc.Id;
        insert objAttachment1;
        
        test.startTest();
            system.runAs(portalUser){
                Apexpages.currentPage().getParameters().put('id',createdSRList[0].Id);
                UploadDocumentsController uploadDocCtrlr = new UploadDocumentsController();
                uploadDocCtrlr.strSRDocId = objSRDoc.Id;
                uploadDocCtrlr.CheckAccess();
                uploadDocCtrlr.strObjectId = createdSRList[0].Id;
                uploadDocCtrlr.FileName = 'Test Doc';
                uploadDocCtrlr.document = objAttachment;
                uploadDocCtrlr.strComments = 'Test Comments';
                uploadDocCtrlr.strExternalComments = 'Test Comments';
                uploadDocCtrlr.Upload();
                uploadDocCtrlr.SaveChanges();
                
                uploadDocCtrlr.RemoveDocumentId = objSRDoc.Id;
                uploadDocCtrlr.RemoveDocument();
                uploadDocCtrlr.AutoCloseStep(true);
            }
        test.stopTest();
    }

}
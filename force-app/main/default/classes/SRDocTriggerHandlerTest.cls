@isTest
public class SRDocTriggerHandlerTest {
    private static  List<Account> createdAccountList; 
    public static void init(){
        createdAccountList = TestClassUtility.createAccounts(1);
        createdAccountList[0].Oracle_Party_Id__c = '1234';
        insert createdAccountList;
    }
    
    public static void createMasterData(){
        List<SR_Doc_Running_Number__c> srDocList = new List<SR_Doc_Running_Number__c>();
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

    static testMethod void generateRunningNumberNOCTest() {
        createMasterData();
        init();
        List<HexaBPM__Service_Request__c> newSRs = TestUtility.createSR(1,'Permit_Photography');
        newSRs[0].HexaBPM__Customer__c = createdAccountList[0].Id;
        insert newSRs;
        
        Loop__DDP__c docPackage = new Loop__DDP__c();
        docPackage.Name = 'Test NOC';
        docPackage.Type_of_Document__c = 'No Objection Certificate';
        insert docPackage;
        
        Loop__DDP_Integration_Option__c deliveryOption = new Loop__DDP_Integration_Option__c();
        deliveryOption.Name = 'Test NOC';
        deliveryOption.Loop__DDP__c = docPackage.Id;
        insert deliveryOption;
        
        List<HexaBPM__Document_Master__c> newDocMasters = TestUtility.createDocMasters(1);
        newDocMasters[0].DDP_Letter_Template__c = deliveryOption.Id;
        insert newDocMasters;
        
        Test.startTest();
        List<HexaBPM__SR_Doc__c> newSRDocs = TestUtility.createDocMasters(1,newDocMasters[0].Id,newSRs[0].Id);
        insert newSRDocs;
        
        List<HexaBPM__SR_Doc__c> insertedSRDoc = [SELECT Id, Document_Number__c FROM HexaBPM__SR_Doc__c WHERE Id = :newSRDocs[0].Id];
       // System.assertEquals('ADGM/RA/CRNOC/17010001',insertedSRDoc[0].Document_Number__c);
        Test.stopTest();
    }
    
    static testMethod void generateRunningNumberGOVTest() {
        createMasterData();
        init();
        List<HexaBPM__Service_Request__c> newSRs = TestUtility.createSR(1,'Permit_Photography');
        newSRs[0].HexaBPM__Customer__c = createdAccountList[0].Id;
        insert newSRs;
        
        Loop__DDP__c docPackage = new Loop__DDP__c();
        docPackage.Name = 'Test GOV';
        docPackage.Type_of_Document__c = 'Government Correspondence';
        insert docPackage;
        
        Loop__DDP_Integration_Option__c deliveryOption = new Loop__DDP_Integration_Option__c();
        deliveryOption.Name = 'Test GOV';
        deliveryOption.Loop__DDP__c = docPackage.Id;
        insert deliveryOption;
        
        List<HexaBPM__Document_Master__c> newDocMasters = TestUtility.createDocMasters(1);
        newDocMasters[0].DDP_Letter_Template__c = deliveryOption.Id;
        insert newDocMasters;
        
        Test.startTest();
        List<HexaBPM__SR_Doc__c> newSRDocs = TestUtility.createDocMasters(1,newDocMasters[0].Id,newSRs[0].Id);
        insert newSRDocs;
        
        List<HexaBPM__SR_Doc__c> insertedSRDoc = [SELECT Id, Document_Number__c FROM HexaBPM__SR_Doc__c WHERE Id = :newSRDocs[0].Id];
       // System.assertEquals('ADGM/RA/CRGOV/17010001',insertedSRDoc[0].Document_Number__c);
        Test.stopTest();
    }
    
    static testMethod void generateRunningNumberLTRTest() {
        createMasterData();
         init();
        List<HexaBPM__Service_Request__c> newSRs = TestUtility.createSR(1,'Permit_Photography');
        newSRs[0].HexaBPM__Customer__c = createdAccountList[0].Id;
        insert newSRs;
        
        Loop__DDP__c docPackage = new Loop__DDP__c();
        docPackage.Name = 'Test Letter';
        docPackage.Type_of_Document__c = 'Letter';
        insert docPackage;
        
        Loop__DDP_Integration_Option__c deliveryOption = new Loop__DDP_Integration_Option__c();
        deliveryOption.Name = 'Test Letter';
        deliveryOption.Loop__DDP__c = docPackage.Id;
        insert deliveryOption;
        
        List<HexaBPM__Document_Master__c> newDocMasters = TestUtility.createDocMasters(1);
        newDocMasters[0].DDP_Letter_Template__c = deliveryOption.Id;
        insert newDocMasters;
        
        Test.startTest();
        List<HexaBPM__SR_Doc__c> newSRDocs = TestUtility.createDocMasters(1,newDocMasters[0].Id,newSRs[0].Id);
        insert newSRDocs;
        
        List<HexaBPM__SR_Doc__c> insertedSRDoc = [SELECT Id, Document_Number__c FROM HexaBPM__SR_Doc__c WHERE Id = :newSRDocs[0].Id];
        //System.assertEquals('ADGM/RA/CRLTR/17010001',insertedSRDoc[0].Document_Number__c);
        Test.stopTest();
    }
    
    static testMethod void generateRunningNumberPRTest() {
        createMasterData();
        init();
        List<HexaBPM__Service_Request__c> newSRs = TestUtility.createSR(1,'Permit_Photography');
        newSRs[0].HexaBPM__Customer__c = createdAccountList[0].Id;
        insert newSRs;
        
        Loop__DDP__c docPackage = new Loop__DDP__c();
        docPackage.Name = 'Test Permit';
        docPackage.Type_of_Document__c = 'Permit';
        insert docPackage;
        
        Loop__DDP_Integration_Option__c deliveryOption = new Loop__DDP_Integration_Option__c();
        deliveryOption.Name = 'Test Permit';
        deliveryOption.Loop__DDP__c = docPackage.Id;
        insert deliveryOption;
        
        List<HexaBPM__Document_Master__c> newDocMasters = TestUtility.createDocMasters(1);
        newDocMasters[0].DDP_Letter_Template__c = deliveryOption.Id;
        insert newDocMasters;
        
        Test.startTest();
        List<HexaBPM__SR_Doc__c> newSRDocs = TestUtility.createDocMasters(1,newDocMasters[0].Id,newSRs[0].Id);
        insert newSRDocs;
        
        List<HexaBPM__SR_Doc__c> insertedSRDoc = [SELECT Id, Document_Number__c FROM HexaBPM__SR_Doc__c WHERE Id = :newSRDocs[0].Id];
        //System.assertEquals('ADGM/RA/CRPR/17010001',insertedSRDoc[0].Document_Number__c);
        Test.stopTest();
    }
    
    static testMethod void generateRunningNumberCRIMMTest() {
        createMasterData();
        init();
        List<HexaBPM__Service_Request__c> newSRs = TestUtility.createSR(1,'Permit_Photography');
        newSRs[0].HexaBPM__Customer__c = createdAccountList[0].Id;
        insert newSRs;
        
        Loop__DDP__c docPackage = new Loop__DDP__c();
        docPackage.Name = 'Test CID Approval Letter';
        docPackage.Type_of_Document__c = 'CID Approval Letter';
        insert docPackage;
        
        Loop__DDP_Integration_Option__c deliveryOption = new Loop__DDP_Integration_Option__c();
        deliveryOption.Name = 'Test CID Approval Letter';
        deliveryOption.Loop__DDP__c = docPackage.Id;
        insert deliveryOption;
        
        List<HexaBPM__Document_Master__c> newDocMasters = TestUtility.createDocMasters(1);
        newDocMasters[0].DDP_Letter_Template__c = deliveryOption.Id;
        insert newDocMasters;
        
        Test.startTest();
        List<HexaBPM__SR_Doc__c> newSRDocs = TestUtility.createDocMasters(1,newDocMasters[0].Id,newSRs[0].Id);
        insert newSRDocs;
        
        List<HexaBPM__SR_Doc__c> insertedSRDoc = [SELECT Id, Document_Number__c FROM HexaBPM__SR_Doc__c WHERE Id = :newSRDocs[0].Id];
       // System.assertEquals('ADGM/RA/CRIMM/00000001',insertedSRDoc[0].Document_Number__c);
        Test.stopTest();
    }
    static testMethod void emailUT() {
         createMasterData();
        init();
        List<HexaBPM__Service_Request__c> newSRs = TestUtility.createSR(1,'Initial_Approval');
        newSRs[0].HexaBPM__Customer__c = createdAccountList[0].Id;
        insert newSRs;
        
        Test.startTest();
        HexaBPM__SR_Doc__c srdoc = new HexaBPM__SR_Doc__c(HexaBPM__Service_Request__c=newSrs[0].id,Name='Initial Approval/Rejection Letter');
        insert srdoc;
        
        Attachment attach=new Attachment();     
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=srdoc.id;
        insert attach;
        
        srdoc.HexaBPM__Doc_ID__c = attach.id;
        update srdoc;
        
        Test.stopTest();
    }
}
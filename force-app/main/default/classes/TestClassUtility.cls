/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class TestClassUtility {

    //create Account
    public static List<Account> createAccounts(Integer ctr){
        List<Account> insertNewAccounts = new List<Account>();
        for(Integer i=1;i<=ctr;i++){
            Account newAccount = new Account();
            newAccount.Name = 'TestAccount'+i;
            newAccount.Email__c = 'testemail'+i+'@test.com';
            
            insertNewAccounts.add(newAccount);
        }
        
        return insertNewAccounts;
    }
    
    //create Contact
    public static List<Contact> createContacts(Integer ctr, Id accountId){
        List<Contact> insertNewContacts = new List<Contact>();
        for(Integer i=1;i<=ctr;i++){
            Contact newContact = new Contact();
            newContact.AccountId = accountId;
            newContact.FirstName = 'FirstName'+i;
            newContact.LastName = 'LastName'+i;
            newContact.Email = 'testemail'+i+'@test.com';
            
            insertNewContacts.add(newContact);
        }
        
        return insertNewContacts;
    }
    
    //create notice
    public static List<Notice__c> createNotice(List<Notice__c> NoticeList){
        List<Notice__c> createNoticeList = new List<Notice__c>();
        String recId = Schema.Sobjecttype.Notice__c.getRecordTypeInfosByName().get('Alert').getRecordTypeId();
        for(Notice__c thisRecord : NoticeList){
            //TODO: populate required fields values
            Notice__c noticeDetailRecord = new Notice__c();
            noticeDetailRecord.RecordTypeId = recId; 
            noticeDetailRecord.Entity__c = thisRecord.Entity__c;
            noticeDetailRecord.Start_Date__c = (thisRecord.Start_Date__c != null) ? thisRecord.Start_Date__c : system.today();
            noticeDetailRecord.Type__c = String.isNotBlank(thisRecord.Type__c) ? thisRecord.Type__c : 'Announcement';
            noticeDetailRecord.Alert_Text__c = String.isNotBlank(thisRecord.Alert_Text__c) ? thisRecord.Alert_Text__c : 'test';
            noticeDetailRecord.Status__c = String.isNotBlank(thisRecord.Status__c) ? thisRecord.Status__c : 'Active';
            noticeDetailRecord.Severity__c = String.isNotBlank(thisRecord.Severity__c) ? thisRecord.Severity__c : 'High';
            noticeDetailRecord.End_Date__c = (thisRecord.End_Date__c != null) ? thisRecord.End_Date__c : system.today();
            noticeDetailRecord.Available_for__c = String.isNotBlank(thisRecord.Available_for__c) ? thisRecord.Available_for__c : 'Company User';
            noticeDetailRecord.Title__c = String.isNotBlank(thisRecord.Title__c) ? thisRecord.Title__c : 'Tester';
            noticeDetailRecord.Announcement_Content__c = String.isNotBlank(thisRecord.Announcement_Content__c) ? thisRecord.Announcement_Content__c : 'tester1';
            noticeDetailRecord.Announcement_Header_Content__c = String.isNotBlank(thisRecord.Announcement_Header_Content__c) ? thisRecord.Announcement_Header_Content__c : '<img src="smiley.gif" alt="Smiley face" height="42" width="42">';
            //noticeDetailRecord.Announcement_Header_Content__c = String.isNotBlank(thisRecord.Announcement_Header_Content__c) ? thisRecord.Announcement_Header_Content__c : '<img src="data:image/png;base64, iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg==" alt="Red dot" />';
            noticeDetailRecord.Publish__c = true;
            noticeDetailRecord.Available_for__c = 'Company User';
            //noticeDetailRecord.Announcement_Header_Content__c = String.isNotBlank(thisRecord.Announcement_Header_Content__c) ? thisRecord.Announcement_Header_Content__c : 'Test123';
            noticeDetailRecord.Notification_Picture_Id__c = String.isNotBlank(thisRecord.Notification_Picture_Id__c) ? thisRecord.Notification_Picture_Id__c : '123456';
            createNoticeList.add(noticeDetailRecord);
        }
        if(!createNoticeList.isEmpty()){
            Database.insert(createNoticeList);
        }
        system.debug('#### Notice Record Created = '+createNoticeList);
        return createNoticeList;   
    }
    
    //create case
    public static List<Case> createCase(List<Case> CaseList){
        List<Case> createCaseList = new List<Case>();
        for(Case thisRecord : CaseList){
            //TODO: populate required fields values
            Case caseDetailRecord = new Case();
            caseDetailRecord.Type = 'General Queries';
            caseDetailRecord.Sub_Type__c = (thisRecord.Sub_Type__c != null) ? thisRecord.Sub_Type__c : 'Submitted Requests';
            caseDetailRecord.Status = String.isNotBlank(thisRecord.Status) ? thisRecord.Status : 'New';
            caseDetailRecord.Origin = String.isNotBlank(thisRecord.Origin) ? thisRecord.Origin : 'Email';
            caseDetailRecord.Subject = String.isNotBlank(thisRecord.Subject) ? thisRecord.Subject : 'test';
            caseDetailRecord.Description = String.isNotBlank(thisRecord.Description) ? thisRecord.Description : 'tester';
            //caseDetailRecord.Queue_Name__c = (thisRecord.Queue_Name__c != null) ? thisRecord.Queue_Name__c : 'Business Admin Team';
            createCaseList.add(caseDetailRecord);
        }
        if(!createCaseList.isEmpty()){
            Database.insert(createCaseList);
        }
        system.debug('#### Case Record Created = '+createCaseList);
        return createCaseList;   
    }
    
    //create POBox records
    public static List<PO_Box__c> createPOBox(Integer ctr){
        List<PO_Box__c> insertNewPOBoxes = new List<PO_Box__c>();
        for(Integer i=0;i<ctr;i++){
            PO_Box__c newPOBox = new PO_Box__c();
            newPOBox.Type__c = 'EziMAIL Bronze';
            newPOBox.PO_Box_Number__c = '0000001';
            
            insertNewPOBoxes.add(newPOBox);
        }
        
        return insertNewPOBoxes;
    }
     
     //create Srtemplate
    public static List<HexaBPM__SR_Template__c> createSRTemplate(List<HexaBPM__SR_Template__c> SRTemplateList){
        List<HexaBPM__SR_Template__c> createSRTemplateList = new List<HexaBPM__SR_Template__c>();
        for(HexaBPM__SR_Template__c thisRecord : SRTemplateList){
            //TODO: populate required fields values
            HexaBPM__SR_Template__c SRTemplateDetailRecord = new HexaBPM__SR_Template__c();
            SRTemplateDetailRecord.HexaBPM__Active__c = true;
            SRTemplateDetailRecord.HexaBPM__SR_RecordType_API_Name__c = String.isNotBlank(thisRecord.HexaBPM__SR_RecordType_API_Name__c) ? thisRecord.HexaBPM__SR_RecordType_API_Name__c : 'User_Access_Request_for_Registered_Company';
            createSRTemplateList.add(SRTemplateDetailRecord);
        }
        if(!createSRTemplateList.isEmpty()){
            Database.insert(createSRTemplateList);
        }
        system.debug('#### SrTemplate Record Created = '+createSRTemplateList);
        return createSRTemplateList;   
    }
    
    public static List<HexaBPM__SR_Template__c> createSRTemplate(Integer ctr, Boolean isActive){
        List<HexaBPM__SR_Template__c> srTemplates = new List<HexaBPM__SR_Template__c>();
        for(Integer i=1;i<=ctr;i++){
            HexaBPM__SR_Template__c srTemplate = new HexaBPM__SR_Template__c();
            srTemplate.HexaBPM__Active__c = isActive;
            
            srTemplates.add(srTemplate);
        }
        
        return srTemplates;
    }
    
     //create Srtemplate Doc
    public static List<HexaBPM__SR_Template_Docs__c> createSRTemplateDoc(List<HexaBPM__SR_Template_Docs__c> SRTemplateDocList){
        List<HexaBPM__SR_Template_Docs__c> createSRTemplateDocList = new List<HexaBPM__SR_Template_Docs__c>();
        for(HexaBPM__SR_Template_Docs__c thisRecord : SRTemplateDocList){
            //TODO: populate required fields values
            HexaBPM__SR_Template_Docs__c SRTemplateDocDetailRecord = new HexaBPM__SR_Template_Docs__c();
            SRTemplateDocDetailRecord.HexaBPM__Added_through_Code__c = true;
            SRTemplateDocDetailRecord.HexaBPM__Document_Description_External__c = String.isNotBlank(thisRecord.HexaBPM__Document_Description_External__c) ? thisRecord.HexaBPM__Document_Description_External__c : 'test';
            SRTemplateDocDetailRecord.HexaBPM__Document_Master__c = thisRecord.HexaBPM__Document_Master__c;
            SRTemplateDocDetailRecord.HexaBPM__SR_Template__c = thisRecord.HexaBPM__SR_Template__c;
            SRTemplateDocDetailRecord.HexaBPM__Optional__c = true;
            SRTemplateDocDetailRecord.HexaBPM__On_Submit__c = true;
            createSRTemplateDocList.add(SRTemplateDocDetailRecord);
        }
        if(!createSRTemplateDocList.isEmpty()){
            Database.insert(createSRTemplateDocList);
        }
        system.debug('#### SrTemplate Doc Record Created = '+createSRTemplateDocList);
        return createSRTemplateDocList;   
    }
    
    
    //create SR_DOC_RUNNING_NUMBER
    public static List<SR_Doc_Running_Number__c> createSRDocRunningNumber(){
        List<SR_Doc_Running_Number__c> runningNumList = new List<SR_Doc_Running_Number__c>();
        for(integer i=0;i<5;i++){
            SR_Doc_Running_Number__c objSRrn = new SR_Doc_Running_Number__c();
            objSRrn.SR_Doc_Running_Number__c = 1;
            runningNumList.add(objSRrn);
        }
        runningNumList[0].Name = 'SR_Doc_NOC';
        runningNumList[1].Name = 'SR_Doc_GOV';
        runningNumList[2].Name = 'SR_Doc_LTR';
        runningNumList[3].Name = 'SR_Doc_PR';
        runningNumList[4].Name = 'SR_Doc_CRIMM';
        
        return runningNumList;
    }
    
    public static List<Attachment> createAttachment(List<Attachment> AttachmentList){
        List<Attachment> createAttachmentList = new List<Attachment>();
        for(Attachment thisRecord : AttachmentList){
            //TODO: populate required fields values
            Attachment AttachmentDetailRecord = new Attachment();
            AttachmentDetailRecord.Name = String.isNotBlank(thisRecord.Name) ? thisRecord.Name : 'Test'; 
            AttachmentDetailRecord.Body = (thisRecord.Body != null) ? thisRecord.Body : Blob.valueof('Tester');
            AttachmentDetailRecord.ContentType = String.isNotBlank(thisRecord.ContentType) ? thisRecord.ContentType : 'Test1';
            AttachmentDetailRecord.ParentId = thisRecord.ParentId;
           createAttachmentList.add(AttachmentDetailRecord);
        } 
        if(!createAttachmentList.isEmpty()){
            Database.insert(createAttachmentList);
        }
        system.debug('#### Attachment Record Created = '+createAttachmentList);
        return createAttachmentList;  
    }
    
    // create campaign
    public static List<Campaign> createCampaigns(Integer noOfRecords) {
        List<Campaign> listCampaigns = new List<Campaign>();
        Campaign objCampaign;
        for(Integer counter = 0; counter < noOfRecords;  counter++) {
            objCampaign = new Campaign();
            objCampaign.Name = 'Test ' + noOfRecords;
            listCampaigns.add(objCampaign);
        }//end for
        return listCampaigns;
    }
    
    // create campaign member
    public static List<CampaignMember> createCampaignMember(Integer noOfRecords, List<Campaign> listCampaigns, List<Contact> listContact) {
        List<CampaignMember> listCampaignMember = new List<CampaignMember>();
        CampaignMember objCampaignMember;
        for(Integer counter = 0; counter < noOfRecords;  counter++) {
            objCampaignMember = new CampaignMember();
            //objCampaignMember.Name = 'Test ' + noOfRecords;
            objCampaignMember.ContactId = listContact.size() - 1 >= counter ? listContact[counter].id : listContact[0].id  ;
            objCampaignMember.CampaignId = listCampaigns.size() - 1 >= counter ? listCampaigns[counter].id : listCampaigns[0].id  ;
            listCampaignMember.add(objCampaignMember);
        }//end for
        return listCampaignMember;
    }
    
    // create campaign member
    public static List<CRM_Survey_Question__c> createSurveyQuestion(Integer noOfRecords, List<String> listQuestiontype) {
        List<CRM_Survey_Question__c> listSurveyQuestion = new List<CRM_Survey_Question__c>();
        CRM_Survey_Question__c objSurveyQuestion;
        for(Integer counter = 0; counter < noOfRecords;  counter++) {
            objSurveyQuestion = new CRM_Survey_Question__c();
            //objCampaignMember.Name = 'Test ' + noOfRecords;
            objSurveyQuestion.CRM_Question_Type__c = listQuestiontype.size() - 1 >= counter ? listQuestiontype[counter] : listQuestiontype[0]  ;
            objSurveyQuestion.CRM_Question__c = 'Question '+counter;
            objSurveyQuestion.CRM_Survey_Category__c = 'MOU Signing Ceremony; Corporate Event; Official Delegation Meeting; Delegation Visit; Head Of State Visit; Government Official Meeting; MBZ Majlis Lecture; Corporate Meetings; Event Nomination / Joint Committee Meetings; Government Event; General Awareness; Authority Related; Event';
            listSurveyQuestion.add(objSurveyQuestion);
        }//end for
        return listSurveyQuestion;
    }
    
    // create Transferred_Employees__c
    public static List<Transferred_Employees__c> createTransferredEmployees (Integer noOfRecords, List<Account> listAccounts) {
        List<Transferred_Employees__c> listTransferredEmployees = new List<Transferred_Employees__c>();
        Transferred_Employees__c objTransferredEmployees;
        for(Integer counter = 0; counter < noOfRecords;  counter++){
            objTransferredEmployees = new Transferred_Employees__c();
            objTransferredEmployees.name = 'Test'+ counter;
            objTransferredEmployees.Account__c = listAccounts.size() - 1 >= counter ? listAccounts[counter].id : listAccounts[0].id  ;
            listTransferredEmployees.add(objTransferredEmployees);
        }
        return listTransferredEmployees;
    }
    
    // create Invoice
    public static List<Invoice__c> createInvoice (Integer noOfRecords, List<Account> listAccounts) {
        List<Invoice__c> listInvoice = new List<Invoice__c>();
        Invoice__c objInvoice;
        for(Integer counter = 0; counter < noOfRecords;  counter++){
            objInvoice = new Invoice__c();
            objInvoice.Status__c = 'Draft';
            objInvoice.Entity__c = listAccounts.size() - 1 >= counter ? listAccounts[counter].id : listAccounts[0].id  ;
            listInvoice.add(objInvoice);
        }
        return listInvoice;
    }
    
    // create Invoice line item
    public static List<Invoice_Line_Item__c> createInvoiceLineItem (Integer noOfRecords, List<Invoice__c> listInvoice) {
        List<Invoice_Line_Item__c> listInvoiceLineItem = new List<Invoice_Line_Item__c>();
        Invoice_Line_Item__c objInvoiceLineItem;
        for(Integer counter = 0; counter < noOfRecords;  counter++){
            objInvoiceLineItem = new Invoice_Line_Item__c();
            objInvoiceLineItem.Status__c = 'Draft';
            objInvoiceLineItem.Invoice__c = listInvoice.size() - 1 >= counter ? listInvoice[counter].id : listInvoice[0].id  ;
            listInvoiceLineItem.add(objInvoiceLineItem);
        }
        return listInvoiceLineItem;
    }
    
    // create Receipt
    public static List<Receipt__c> createReceipt (Integer noOfRecords, List<Account> listAccounts) {
        List<Receipt__c> listReceipt = new List<Receipt__c>();
        Receipt__c objReceipt;
        for(Integer counter = 0; counter < noOfRecords;  counter++){
            objReceipt = new Receipt__c();
            objReceipt.Status__c = 'Draft';
            objReceipt.Amount__c = 100;
            objReceipt.Entity__c = listAccounts.size() - 1 >= counter ? listAccounts[counter].id : listAccounts[0].id  ;
            objReceipt.Payment_Currency__c = 'AED';
            listReceipt.add(objReceipt);
        }
        return listReceipt;
    }
    
    // create Related_Invoice_Receipt__c
    public static List<Related_Invoice_Receipt__c> createRelatedInvoiceReceipt (Integer noOfRecords, List<Invoice__c> listInvoice, List<Receipt__c> listReceipt) {
        List<Related_Invoice_Receipt__c> listReceiptInvoice = new List<Related_Invoice_Receipt__c>();
        Related_Invoice_Receipt__c objReceipt;
        for(Integer counter = 0; counter < noOfRecords;  counter++){
            objReceipt = new Related_Invoice_Receipt__c();
            objReceipt.Invoice__c = listInvoice.size() - 1 >= counter ? listInvoice[counter].id : listInvoice[0].id  ;
            objReceipt.Receipt__c = listReceipt.size() - 1 >= counter ? listReceipt[counter].id : listReceipt[0].id  ;
            listReceiptInvoice.add(objReceipt);
        }
        return listReceiptInvoice;
    }
    
    // create Address 
    public static List<Address__c> createAddress (Integer noOfRecords, List<Account> listAccounts) {
        List<Address__c> listAddress = new List<Address__c>();
        Address__c objAddress;
        for(Integer counter = 0; counter < noOfRecords;  counter++){
            objAddress = new Address__c();
            objAddress.Country__c = 'UAE';
            objAddress.Entity__c = listAccounts.size() - 1 >= counter ? listAccounts[counter].id : listAccounts[0].id  ;
            objAddress.Street_Name_of_Cluster_on_the_Island__c = 'Test';
            objAddress.Floor__c = '2';
            objAddress.Building_Name__c = 'test';
            listAddress.add(objAddress);
        }
        return listAddress;
    }
    
    // create Refund
    public static List<Refund__c> createRefund (Integer noOfRecords, List<Account> listAccounts, List<Receipt__c> listReceipt) {
        List<Refund__c> listRefund = new List<Refund__c>();
        Refund__c objRefund;
        for(Integer counter = 0; counter < noOfRecords;  counter++){
            objRefund = new Refund__c();
            objRefund.Currency__c = 'AED';
            objRefund.Entity__c = listAccounts.size() - 1 >= counter ? listAccounts[counter].id : listAccounts[0].id  ;
            objRefund.Receipt__c = listReceipt.size() - 1 >= counter ? listReceipt[counter].id : listReceipt[0].id  ;
            listRefund.add(objRefund);
        }
        return listRefund;
    }
    
    // create Fund_Transfer__c
    public static List<Fund_Transfer__c> createFundTransfer (Integer noOfRecords, List<Account> listFromAccounts, List<Account> listToAccounts) {
        List<Fund_Transfer__c> listFund_Transfer = new List<Fund_Transfer__c>();
        Fund_Transfer__c objFund_Transfer;
        for(Integer counter = 0; counter < noOfRecords;  counter++){
            objFund_Transfer = new Fund_Transfer__c();
            objFund_Transfer.From_Currency__c = 'AED';
            objFund_Transfer.To_Currency__c = 'AED';
            objFund_Transfer.From_Entity__c = listFromAccounts.size() - 1 >= counter ? listFromAccounts[counter].id : listFromAccounts[0].id  ;
            objFund_Transfer.To_Entity__c = listToAccounts.size() - 1 >= counter ? listToAccounts[counter].id : listToAccounts[0].id  ;
            objFund_Transfer.Amount__c = 100;
            listFund_Transfer.add(objFund_Transfer);
        }
        return listFund_Transfer;
    }
}
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
public class CampaignTriggerTest { 
    
    public static testmethod void doTest(){
        
        List<Account> accLst = TestClassUtility.createAccounts(1);
        accLst[0].Is_ADGM_Company__c = true;
        insert accLst;
        
        List<Contact> conLst = TestClassUtility.createContacts(1,accLst[0].id);
        
        for(RecordType rectype:[Select Id from RecordType where DeveloperName='Contact_ADGM_BR_P' and sObjectType='Contact']){
            conLst[0].RecordTypeId = recType.Id;
        }
        conLst[0].CRM_Campaign_Category__c= 'MOU Signing Ceremony; Corporate Event; Official Delegation Meeting; Delegation Visit; Head Of State Visit; Government Official Meeting; MBZ Majlis Lecture; Corporate Meeting; Event Nomination / Joint Committee Meeting; Government Event';
        insert conLst;
        
        
        Test.startTest();
        List<Campaign> campgnLst = TestClassUtility.createCampaigns(1);
        campgnLst[0].RecordTypeId = CampaignTriggerHandler.getCampaignRecTypeId('MOU Signing Ceremony');
        campgnLst[0].CRM_Meeting_Date_Time__c = DateTime.now().addDays(4);
        campgnLst[0].CRM_End_Date__c = DateTime.now().addDays(6);
        campgnLst[0].CRM_Meeting_Location__c = 'Test Location';
        campgnLst[0].Status = 'Planned';
        campgnLst[0].CRM_Start_Feedback_Process__c = true;
        campgnLst[0].Main_Category__c = 'MOU Signing Ceremony';
        campgnLst[0].CRM_Arrange_Setup__c = 'Finalize Program; Book Meeting Room; Send Calendar invite to Management; Arrange for Pens & MOU Folders; Arrange for Gifts; Book Photographer; Plan Meet & Greet; Accommodation & Transportation; Flags; Catering; MOU Signing Table; Guest Signing Book Stand; Plaza Access; Notify the reception / Serco; Arrange Backdrop Banners; Plan Press Release and Media; Arrange Welcome Ticker';
        insert campgnLst;
        CampaignMember CM = [Select Id,ContactId,CampaignId,CRM_RSVP__c from CampaignMember where CampaignId =:campgnLst[0].id limit 1];
        cm.CRM_RSVP__c = 'Yes';
        cm.CRM_Send_Feedback_Email__c = true;
        update cm;
        List<Task> listTask = new List<Task>();
        for(Task objTask : [SELECT id, status FROM Task WHERE WhatId =: campgnLst[0].id]) {
            objTask.status = 'Completed';
            listTask.add(objTask);
        }//end for
        
        update listTask;
        campgnLst[0].Status ='In Progress';
        update campgnLst;
        
        
            
        
        
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='MOU_closure', 
            PathOnClient ='/MOU_closure.jpg',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = campgnLst[0].id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink;
        
        CRM_Survey_Question__c sq = new CRM_Survey_Question__c(CRM_Question__c = 'Question 2', CRM_Question_Type__c = 'Text');
        sq.CRM_Survey_Category__c = 'MOU Signing Ceremony; Corporate Event; Official Delegation Meeting; Delegation Visit; Head Of State Visit; Government Official Meeting; MBZ Majlis Lecture; Corporate Meetings; Event Nomination / Joint Committee Meetings; Government Event; General Awareness; Authority Related; Event';
        insert sq;
        
        
        campgnLst[0].CRM_Submit_to_Protocol_Team__c =true;
        campgnLst[0].Status ='Completed';
        
        update campgnLst;

        Test.stopTest(); 
    }
    
    public static testmethod void doTestWithUser(){
        // Setup test data
        // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='CRM Protocol'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        
        
        List<Account> accLst = TestClassUtility.createAccounts(1);
        accLst[0].Is_ADGM_Company__c = true;
        insert accLst;
        
        List<Contact> conLst = TestClassUtility.createContacts(1,accLst[0].id);
        
        for(RecordType rectype:[Select Id from RecordType where DeveloperName='Contact_ADGM_BR_P' and sObjectType='Contact']){
            conLst[0].RecordTypeId = recType.Id;
        }
        conLst[0].CRM_Campaign_Category__c= 'MOU Signing Ceremony; Corporate Event; Official Delegation Meeting; Delegation Visit; Head Of State Visit; Government Official Meeting; MBZ Majlis Lecture; Corporate Meeting; Event Nomination / Joint Committee Meeting; Government Event';
        insert conLst;
        
        System.runAs(u) {
            
            List<Campaign> campgnLst = TestClassUtility.createCampaigns(1);
            campgnLst[0].RecordTypeId = CampaignTriggerHandler.getCampaignRecTypeId('MOU Signing Ceremony');
            campgnLst[0].CRM_Meeting_Date_Time__c = DateTime.now().addDays(4);
            campgnLst[0].CRM_End_Date__c = DateTime.now().addDays(6);
            campgnLst[0].CRM_Meeting_Location__c = 'Test Location';
            campgnLst[0].Status = 'Planned';
            campgnLst[0].CRM_Share_With__c = 'ADGM';
            campgnLst[0].Main_Category__c = 'MOU Signing Ceremony';
            campgnLst[0].CRM_Arrange_Setup__c = 'Finalize Program; Book Meeting Room; Send Calendar invite to Management; Arrange for Pens & MOU Folders; Arrange for Gifts; Book Photographer; Plan Meet & Greet; Accommodation & Transportation; Flags; Catering; MOU Signing Table; Guest Signing Book Stand; Plaza Access; Notify the reception / Serco; Arrange Backdrop Banners; Plan Press Release and Media; Arrange Welcome Ticker';
            insert campgnLst;
            
            
        }
    }
}
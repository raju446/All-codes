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
public class SendEmailControllerTest {
    static testMethod void sendEmailTest() {
        List<Account> newAccounts = TestClassUtility.createAccounts(2);
        newAccounts[1].Is_ADGM_Company__c = true;
        insert newAccounts;
        List<Contact> newContacts = TestClassUtility.createContacts(2, newAccounts[0].Id);
        newContacts[1].AccountId = newAccounts[1].id;
        insert newContacts; 
        List<Campaign> listCampaigns = TestClassUtility.createCampaigns(1);
        listCampaigns[0].CRM_Meeting_Date_Time__c = DateTime.now().addDays(4);
        listCampaigns[0].CRM_End_Date__c = DateTime.now().addDays(6);
        insert listCampaigns;
        List<CampaignMember> listCampaignMember = TestClassUtility.createCampaignMember(2, listCampaigns, newContacts);
        insert listCampaignMember;
        
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        insert contentVersionInsert;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = listCampaigns[0].id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        Test.startTest();
        List<SendEmailController.CampaignMemberWrapper> listExternalCampaignMember = SendEmailController.getRecipientsData(listCampaigns[0].id, true);
        List<SendEmailController.CampaignMemberWrapper> listInternalCampaignMember = SendEmailController.getRecipientsData(listCampaigns[0].id, false);
        list<EmailTemplate> listEmailTemplate = SendEmailController.getEmailTempletesData();
        listEmailTemplate = SendEmailController.createEmailTemplate(listEmailTemplate[0].id);
        List<OrgWideEmailAddress> listOrgWideEmailAddress = SendEmailController.getAllOrgWideEmail();
        SendEmailController.getGroups('CRM_Group__c', true);
        SendEmailController.getApprovedStatus(listCampaigns[0].id);
        listExternalCampaignMember[0].isSelected = true;
        listExternalCampaignMember[0].campaignMemberRec.CRM_Group__c = 'Test';
        SendEmailController.getCampaignAttachment(listCampaigns[0].id);        
        SendEmailController.sendEmailToAllCampaignMembers(listInternalCampaignMember, listExternalCampaignMember, listEmailTemplate[0], true, null, new List<Id>{contentVersionInsert.id}, '');
        
        Test.stopTest();
    }
}
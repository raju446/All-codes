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
public class CloseCampaignControllerTest {
    static testMethod void closeCampaignTest() {
        Id campRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('MOU Signing Ceremony').getRecordTypeId();
        Campaign objCampaign = new Campaign();
        objCampaign.Name = 'Test Campaign';
        objCampaign.CRM_Meeting_Date_Time__c = DateTime.now().addDays(4);
        objCampaign.CRM_End_Date__c = DateTime.now().addDays(6);
        objCampaign.recordtypeId = campRecordTypeId;
        insert objCampaign;
        Test.startTest();
        String result = CloseCampaignController.validationBeforecloseCampaign(objCampaign.id);
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
        cdl.LinkedEntityId = objCampaign.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        result = CloseCampaignController.validationBeforecloseCampaign(objCampaign.id);
        objCampaign.status = 'In Progress';
        objCampaign.CRM_Approval_Required__c = true;
        update objCampaign;
        result = CloseCampaignController.validationBeforecloseCampaign(objCampaign.id);
        
        objCampaign.CRM_Approval_Status__c = 'Approved by HOD';
		update objCampaign;        
        result = CloseCampaignController.validationBeforecloseCampaign(objCampaign.id);
        
        result = CloseCampaignController.closeCampaign(objCampaign.id);
        objCampaign.status = 'Completed';
        update objCampaign;
        result = CloseCampaignController.validationBeforecloseCampaign(objCampaign.id);
		Test.stopTest();        
    }//end closeCampaignTest()
}//end CloseCampaignControllerTest
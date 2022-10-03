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
public class TaskTriggerHandlerTest {
    static testMethod void doTest() {
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
            campgnLst[0].Main_Category__c = 'MOU Signing Ceremony';
            campgnLst[0].CRM_Arrange_Setup__c = 'Finalize Program; Book Meeting Room; Send Calendar invite to Management; Arrange for Pens & MOU Folders; Arrange for Gifts; Book Photographer; Plan Meet & Greet; Accommodation & Transportation; Flags; Catering; MOU Signing Table; Guest Signing Book Stand; Plaza Access; Notify the reception / Serco; Arrange Backdrop Banners; Plan Press Release and Media; Arrange Welcome Ticker';
            insert campgnLst;
            List<Task> listTask = new List<Task>();
            listTask = [SELECT ID, STATUS FROM Task];
            update listTask;
            
        }
    }
    
    static testMethod void CloseTask() {
        List<Case> caseList = TestClassUtility.createCase(new List<Case>{new Case(Email_Address__c='test@test.com')}); 
        
        List<Task> insertTask = new List<Task>();
        Task objTask = new Task(whatid=caseList[0].Id,CRM_Internal_Task__c=true);
        insertTask.add(objTask);
        objTask = new Task(whatid=caseList[0].Id,CRM_Internal_Task__c=true);
        insertTask.add(objTask);
        
        insert insertTask;
        
        test.startTest();
            insertTask[0].Status = 'Completed';
            update insertTask[0];
        test.stoptest();
    }
}
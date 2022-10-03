@isTest
public class RSVPControllerTest{
    public static testmethod void doTest(){
        List<Account> accLst = TestClassUtility.createAccounts(1);
        insert accLst;
        
        List<Contact> conLst = TestClassUtility.createContacts(1,accLst[0].id);
        insert conLst;
        
        List<Campaign> campgnLst = TestClassUtility.createCampaigns(1);
        campgnLst[0].CRM_Meeting_Date_Time__c = DateTime.now().addDays(1);
        campgnLst[0].CRM_End_Date__c = DateTime.now().addDays(2);
        campgnLst[0].CRM_Meeting_Location__c = 'Test Location';
        campgnLst[0].Main_Category__c = 'MBZ Majlis Lecture';
        campgnLst[0].recordtypeid = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('MBZ Majlis Lecture').getRecordTypeId();
        insert campgnLst;
        
        List<CampaignMember> cmpMemLst = TestClassUtility.createCampaignMember(1,campgnLst,conLst);
        insert cmpMemLst;
        
        Test.startTest();
            PageReference aPage = Page.RSVP;
        	String conide = ApexCodeUtility.getEncryptedValue(conLst[0].id);
       		String cmpide = ApexCodeUtility.getEncryptedValue(campgnLst[0].id);
            aPage.getParameters().put('contactId', conide);
            aPage.getParameters().put('campaignId', cmpide);
            aPage.getParameters().put('reply', 'Yes');
            test.setCurrentPage(aPage);
            
            RSVPController obj = new RSVPController();
        	obj.objContactDetails.sEmirates_ID = 'xyz';
            obj.comments = 'Test Class';
            obj.setRSVP();
        	obj.updateContact();
        	obj.isIAgree = true;
        	obj.updateContact();
        	obj.updateComment();
        Test.stopTest(); 
    }
    
    public static testmethod void doTest1(){
        List<Account> accLst = TestClassUtility.createAccounts(1);
        insert accLst;
        
        List<Contact> conLst = TestClassUtility.createContacts(1,accLst[0].id);
        insert conLst;
        
        List<Campaign> campgnLst = TestClassUtility.createCampaigns(1);
        campgnLst[0].CRM_Meeting_Date_Time__c = DateTime.now().addDays(1);
        campgnLst[0].CRM_End_Date__c = DateTime.now().addDays(2);
        campgnLst[0].CRM_Meeting_Location__c = 'Test Location';
        campgnLst[0].status = 'Aborted';
        //campgnLst[0].recordtypeid = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('MBZ Majlis Lecture').getRecordTypeId();
        insert campgnLst;
        
        List<CampaignMember> cmpMemLst = TestClassUtility.createCampaignMember(1,campgnLst,conLst);
        cmpMemLst[0].CRM_RSVP__c = 'Yes';
        cmpMemLst[0].Comments__c = 'ddd';
        insert cmpMemLst;
        
        Test.startTest();
            PageReference aPage = Page.RSVP;
        	String conide = ApexCodeUtility.getEncryptedValue(conLst[0].id);
       		String cmpide = ApexCodeUtility.getEncryptedValue(campgnLst[0].id);
            aPage.getParameters().put('contactId', conide);
            aPage.getParameters().put('campaignId', cmpide);
            aPage.getParameters().put('reply', 'No');
            test.setCurrentPage(aPage);
            
            RSVPController obj = new RSVPController();
            obj.comments = 'Test Class';
            obj.setRSVP();
        Test.stopTest(); 
    }
    
   /* public static testmethod void doTest2(){
        List<Account> accLst = TestClassUtility.createAccounts(1);
        insert accLst;
        
        List<Contact> conLst = TestClassUtility.createContacts(1,accLst[0].id);
        insert conLst;
        
        List<Campaign> campgnLst = TestClassUtility.createCampaigns(1);
        campgnLst[0].CRM_Meeting_Date_Time__c = DateTime.now().addDays(1);
        campgnLst[0].CRM_End_Date__c = DateTime.now().addDays(2);
        campgnLst[0].CRM_Meeting_Location__c = 'Test Location';
        //campgnLst[0].Main_Category__c = 'MBZ Majlis Lecture';
        //campgnLst[0].recordtypeid = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('MBZ Majlis Lecture').getRecordTypeId();
        insert campgnLst;
        
        List<CampaignMember> cmpMemLst = TestClassUtility.createCampaignMember(1,campgnLst,conLst);
        insert cmpMemLst;
        
        Test.startTest();
            PageReference aPage = Page.RSVP;
        	String conide = ApexCodeUtility.getEncryptedValue(conLst[0].id);
       		String cmpide = ApexCodeUtility.getEncryptedValue(campgnLst[0].id);
            aPage.getParameters().put('contactId', conide);
            aPage.getParameters().put('campaignId', cmpide);
            aPage.getParameters().put('reply', 'Yes');
            test.setCurrentPage(aPage);
            
            RSVPController obj = new RSVPController();
            obj.comments = 'Test Class';
            obj.setRSVP();
        Test.stopTest(); 
    }*/
}
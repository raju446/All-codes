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
public class DelegateInviteControllerTest{
    public static testmethod void doTest(){
        List<Account> accLst = TestClassUtility.createAccounts(1);
        accLst[0].Is_ADGM_Company__c = true;
        insert accLst;
        
        List<Contact> conLst = TestClassUtility.createContacts(2,accLst[0].id);
        insert conLst;
        
        List<Contact> conLst1 = TestClassUtility.createContacts(1,accLst[0].id);
        conLst1[0].firstname = 'fname';
        conLst1[0].LastName = 'lName';
        conLst1[0].email = 'teset@t.com';
        insert conLst1;
        
        List<Campaign> campgnLst = TestClassUtility.createCampaigns(1);
        campgnLst[0].CRM_Meeting_Date_Time__c = DateTime.now().addDays(4);
        campgnLst[0].CRM_End_Date__c = DateTime.now().addDays(6);
        insert campgnLst;
        
        
        EmailTemplate objEmailTemplate = [SELECT id FROM EmailTemplate limit 1] ;
        CampaignMember objCampaignMember = new CampaignMember(ContactId=conLst[0].id,CampaignId=campgnLst[0].id);
        objCampaignMember.CRM_Email_Template_Id__c = objEmailTemplate.id;
        insert objCampaignMember;
        
        
        test.startTest();
            delete ([select id from campaignmember where contactid =: conLst1[0].id]);
            PageReference aPage = Page.DelegateInvite;
            String conide = ApexCodeUtility.getEncryptedValue(conLst[0].id);
            String cmpide = ApexCodeUtility.getEncryptedValue(campgnLst[0].id);
            aPage.getParameters().put('contactId', conide);
            aPage.getParameters().put('campaignId', cmpide);
            test.setCurrentPage(aPage);
            DelegateInviteController obj = new DelegateInviteController();
            
            obj.contactMobile = '1223456789';
            obj.isIAgree = false;
            
            //List<Contact> conList = [select name from contact where id = '' limit 1];
            obj.searchKey = 'fname';//conList[0].Name;
            obj.doSearch();
            obj.doSelectExternal();
            
            obj.isIAgree = true;
            obj.doSelectExternal();
            
            obj.getCountryPicklist();
            
            obj.doSelect(); 
            for(DelegateInviteController.ContactWrapper wrapObj : obj.contactWrapperLst){
                if(wrapObj.conName.contains('fname')){
                    wrapObj.isSelected = true;
                }
            }
            
            
            obj.doSelect();
        test.stopTest();
    }
}
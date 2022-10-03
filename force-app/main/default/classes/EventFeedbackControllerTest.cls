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
public class EventFeedbackControllerTest{
    public static testmethod void doTest(){
        List<Account> accLst = TestClassUtility.createAccounts(1);
        insert accLst;
        
        List<Contact> conLst = TestClassUtility.createContacts(1,accLst[0].id);
        insert conLst;
        
        List<Campaign> campgnLst = TestClassUtility.createCampaigns(1);
        campgnLst[0].CRM_Meeting_Date_Time__c = DateTime.now().addDays(4);
        campgnLst[0].CRM_End_Date__c = DateTime.now().addDays(6);
        campgnLst[0].CRM_Meeting_Location__c = 'Test Location';
        campgnLst[0].Status = 'Planned';
        insert campgnLst;

        List<CRM_Survey_Question__c> questions = new List<CRM_Survey_Question__c>();
        CRM_Survey_Question__c q1 = new CRM_Survey_Question__c(CRM_Question__c = 'Question 1', CRM_Question_Type__c = 'Dichotomous');
        questions.add(q1);
        CRM_Survey_Question__c q2 = new CRM_Survey_Question__c(CRM_Question__c = 'Question 2', CRM_Question_Type__c = 'Text');
        questions.add(q2);
        CRM_Survey_Question__c q3 = new CRM_Survey_Question__c(CRM_Question__c = 'Question 3', CRM_Question_Type__c = 'Rating',CRM_Max_Rating__c=5);
        questions.add(q3);

        insert questions;

        List<CRM_Survey_Response__c> responses = new List<CRM_Survey_Response__c>();
        for(CRM_Survey_Question__c q : questions){
            CRM_Survey_Response__c res = new CRM_Survey_Response__c(CRM_Campaign__c = campgnLst[0].id,CRM_Contact__c = conLst[0].id,CRM_Survey_Question__c=q.id);
            responses.add(res);
        }
        insert responses;

        Test.startTest();
            PageReference aPage = Page.EventFeedback;
        	String conide = ApexCodeUtility.getEncryptedValue(conLst[0].id);
       		String cmpide = ApexCodeUtility.getEncryptedValue(campgnLst[0].id);
            aPage.getParameters().put('contactId', conide);
            aPage.getParameters().put('campaignId', cmpide);
            test.setCurrentPage(aPage);
    
            EventFeedbackController obj = new EventFeedbackController();
        	obj.doSubmit();
        	
        	for(EventFeedbackController.SurveyResponseWrapper  w : obj.surveyResponseWrapperLst){
                if(w.questionType == 'Dichotomous'){
                    w.forDichotomous = 'Yes';
                } 
            }
        	obj.doSubmit();
        	
        	for(EventFeedbackController.SurveyResponseWrapper  w : obj.surveyResponseWrapperLst){
                if(w.questionType == 'Dichotomous'){
                    w.forDichotomous = 'Yes';
                } else if(w.questionType == 'Text'){
                    w.forText = 'Test';
                } 
            }
            obj.doSubmit();
        
            for(EventFeedbackController.SurveyResponseWrapper  w : obj.surveyResponseWrapperLst){
                if(w.questionType == 'Dichotomous'){
                    w.forDichotomous = 'Yes';
                } else if(w.questionType == 'Text'){
                    w.forText = 'Test';
                } else if(w.questionType == 'Rating'){
                    w.getItems();
                    w.rating = '1';
                }
            }
    
            obj.doSubmit();
        Test.stopTest(); 
        
    }
}
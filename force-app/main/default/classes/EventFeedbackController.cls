/*
    Author      :   Durga Prasad
    Class Name  :   EventSurveyController
    Description :   Page Controller to capture the Internal Invitee's Feedback on Events
    
    Modified By : Jayanta Karmakar
    Date        : 6th March,2019
    Description : Added the logic for submit button.
*/
public without sharing class EventFeedbackController {
    public List<SurveyResponseWrapper> surveyResponseWrapperLst{get;set;}
    public boolean isSubmitted {get;set;}
    public boolean isThank {get;set;}
    public EventFeedbackController(){
        try{
            string contactId = ApexPages.currentPage().getParameters().get('contactId');
            string campaignId= ApexPages.currentPage().getParameters().get('campaignId');
            String contactIdDecrypted = '', campaignIdDecrypted = '';
            
            if(contactId <> null) {
                contactId = ApexCodeUtility.getDecryptedValue(contactId);
            }
            
            if( campaignId <> null) {
                campaignId = ApexCodeUtility.getDecryptedValue(campaignId);
            }
            
            isSubmitted = true;
            isThank = false;
            surveyResponseWrapperLst = new List<surveyResponseWrapper>();
            isSubmitted = false;
            for(CRM_Survey_Response__c resp : [select id,CRM_Response__c,CRM_Survey_Question__c,CRM_Survey_Question__r.CRM_Max_Rating__c,CRM_Survey_Question__r.CRM_Question__c,
                                               CRM_Survey_Question__r.CRM_Question_Type__c,CRM_Survey_Question__r.CRM_Survey_Category__c
                                               from CRM_Survey_Response__c where CRM_Contact__c =: contactId AND CRM_Campaign__c =: campaignId order by CRM_Survey_Question__r.CRM_Serial_Number__c]){
                                                   surveyResponseWrapper wrapObj = new surveyResponseWrapper(resp.id,resp.CRM_Survey_Question__c,resp.CRM_Survey_Question__r.CRM_Question__c,resp.CRM_Survey_Question__r.CRM_Question_Type__c,resp.CRM_Survey_Question__r.CRM_Max_Rating__c);
                                                   surveyResponseWrapperLst.add(wrapObj);
                                                   if(resp.CRM_Response__c == null){
                                                       isSubmitted = false;
                                                   }
                                               }
        } catch(Exception ex){
            system.debug('---->'+ex.getMessage());
        }
    }
    
    /*
     	Name : doSubmit
        Description : Method to be called on form submittion.
    */
    
    public pageReference doSubmit(){
        List<CRM_Survey_Response__c> listToUpdate = new List<CRM_Survey_Response__c>();
        for(surveyResponseWrapper w : surveyResponseWrapperLst){
            if(w.questionType == 'Dichotomous'){
                if(w.forDichotomous == null || w.forDichotomous == ''){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please answer the following question - '+w.question));
                    return null;
                } else {
                    CRM_Survey_Response__c resp = new CRM_Survey_Response__c(id=w.respId,CRM_Response__c=w.forDichotomous);
                    listToUpdate.add(resp);
                }
            } else if(w.questionType == 'Text'){
                if(w.forText == null || w.forText.Trim() == '' ){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please answer the following question - '+w.question));
                    return null;
                } else {
                    CRM_Survey_Response__c resp = new CRM_Survey_Response__c(id=w.respId,CRM_Response__c=w.forText);
                    listToUpdate.add(resp);
                }
            } else if(w.questionType == 'Rating'){
                if(w.rating == null || w.rating == ''){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please answer the following question - '+w.question));
                    return null;
                } else {
                    CRM_Survey_Response__c resp = new CRM_Survey_Response__c(id=w.respId,CRM_Response__c=w.rating);
                    listToUpdate.add(resp);
                }
            }
        }

        try{
            update listToUpdate;
            isThank = true;
            return null;
        } catch(Exception e){
            system.debug('---->'+e.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
            return null;
        }
    }
    
     /*
        Class Name : Wrapper
        Description : It is used to display the data to user and to hold user input.
    */

    public class SurveyResponseWrapper{
        public string respId;
        public string questionId;
        public string question {get;set;}
        public string questionType {get;set;}
        public Decimal ratingSize {get;set;}
        public string forDichotomous {get;set;}
        public string forText{get;set;}
        public String rating{get;set;}
        
        public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>(); 
            options.add(new SelectOption('N/A','N/A')); 
            for(Integer i =1 ; i<=ratingSize ; i++){
                options.add(new SelectOption(String.valueof(i),String.valueof(i))); 
            }
            return options;
        }
        
        public SurveyResponseWrapper(Id recId,id qId, String qtn, String qType, Decimal rteSize){
            respId = recId;
            questionId = qid;
            question = qtn;
            questionType = qType;
            ratingSize = rteSize;   
        }
    }
}
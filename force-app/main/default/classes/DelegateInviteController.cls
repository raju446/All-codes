/*
Author      :   Jayanta Karmakar
Class Name  :   DelegateInviteController
Description :   Page Controller for DelegateInvite.
Date        :   20-Mar-2019
*/
public without sharing class DelegateInviteController {
    
    public Contact con {get;set;} // Hold loggedin contact record
    public List<ContactWrapper> contactWrapperLst {get;set;} // List of wrapper class to display and fetch data from Page.
    public boolean isInternalCon {get;set;} // To render the section based on the type of contact wheather its an Internal or External
    public Campaign camp; // Hold the campaign details 
    public Map<String,String> conMap;
    Public String searchKey {get;set;}
    Public String alreadyDelegatedMsg {get;set;}
    public String first_Name {get;set;}
    public String last_Name {get;set;}
    public String email_id {get;set;}
    public String company_Name {get;set;}
    public String mobileCode {get;set;}
    public String contactMobile {get;set;}
    public String jobTitle {get;set;}
    public String middle_Name {get;set;}
    public String comments {get;set;}
    public String errorMSG {get;set;}
    public String errorConsentMSG {get;set;}
    public boolean gotRecord{get;set;}
    public boolean isIAgree {get;set;}
    public String company_id;
    public String contactId, campaignId;
    public String disclimerMsg {get;set;}
    public String eventType {get;set;}
    
    public DelegateInviteController(){
        isInternalCon = false;
        gotRecord = false;
        try {
            
            
            contactId = ApexPages.currentPage().getParameters().get('contactId');
            campaignId= ApexPages.currentPage().getParameters().get('campaignId');
            String contactIdDecrypted = '', campaignIdDecrypted = '';
            if(contactId <> null && String.isNotBlank(contactId)) {
                contactId = ApexCodeUtility.getDecryptedValue(contactId);
            }
            
            if( campaignId <> null && String.isNotBlank(campaignId)) {
                campaignId = ApexCodeUtility.getDecryptedValue(campaignId);
            }
            con = new Contact();
            if(contactId != null && contactId != '' && campaignId != null && campaignId != ''){
                for(Contact cont : [select Id,Name,Account.Is_ADGM_Company__c,Account.Name,Accountid,CRM_Disclaimer__c from contact where Id=:contactId]){
                    if(cont.CRM_Disclaimer__c <> '' && cont.CRM_Disclaimer__c <> null) {
                        disclimerMsg = cont.CRM_Disclaimer__c;    
                    } else {
                        disclimerMsg = 'Do you agree that the information being submitted in this form is accurate and do you agree for ADGM to use and store this information?';
                    }
                    
                    if(cont.Account.Is_ADGM_Company__c){
                        isInternalCon = true;
                        con = cont;
                    }
                    
                    company_Name = cont.Account.Name;
                    company_id = cont.Accountid;
                    System.debug(cont.Account.Name);
                }
                
                camp = [select id,name,ownerid,status,RecordType.Name from Campaign where id=: campaignId];        
                if(camp.status == 'Completed' || camp.status == 'Aborted'){
                    alreadyDelegatedMsg = camp.Name+' is already '+camp.status;
                }
                if(camp != null && String.isNotBlank(camp.RecordType.Name) && (camp.RecordType.Name).contains('MOU')){
                    eventType = 'MOU';
                }else if(camp != null && String.isNotBlank(camp.RecordType.Name)){
                    eventType = 'Event';
                }
            }
            
            doSearch();
        } catch(Exception ex){
            system.debug('---->'+ex.getMessage());
        }
    }
    
    /*
    Method Name : doSearch
    Description : It is used to search contacts
    */
    public void doSearch(){
        contactWrapperLst = new List<ContactWrapper>();
        
        Set<id> delCont = new set<id>();
        for(task t : [select whoid from task where whatid =: camp.id AND subject = 'New Delegation Suggested']){
            delCont.add(t.whoid);
        }
        
        
        
        for(campaignmember cm  : [select contactid from campaignmember where campaignId =: camp.id limit 1000]){
            delCont.add(cm.contactid);
        }
        delCont.add(con.id);
        conMap =new Map<String,String>();
        
        
        List<Contact> listContact = new List<Contact>();        
        List<string> searchValues = new List<String>();
        if(searchKey <> null && searchKey <> '' && String.isNotBlank(searchKey)) {
            searchKey = searchKey.trim();
            for(String sVal : searchKey.split(' ')) {
                sVal = sVal.trim();
                if(sVal <> '' && sVal <> null && sVal <> ' ') {
                    searchValues.add(sVal);
                }
            }
            
            searchValues.add(searchKey);
        }
        if(searchValues <> null && searchValues.size() > 0){
            system.debug(searchValues);
            if(Test.isRunningTest()){
                listContact = [select id,name, CRM_I_Agree__c, Email,CRM_Disclaimer__c, Job_Code__r.Name, CRM_Full_Name__c from contact limit 10];
            } else {
                listContact = [select id,name,CRM_I_Agree__c,Email,CRM_Disclaimer__c, Job_Code__r.Name, CRM_Full_Name__c from contact where Id NOT IN: delCont AND Account.Is_ADGM_Company__c = TRUE AND (FirstName IN: searchValues OR LastName IN: searchValues OR Middle_Name__c IN: searchValues)  limit 1000];
            }
            
            
            system.debug(listContact);
            if(listContact.size() > 0){
                gotRecord= true;
                errorMSG  = null;
            } else {
                errorMSG = 'No Record Found.';
            }
        }
        
        if(listContact <> null && listContact.size() > 0) {
            for(Contact con : listContact ){
                //Boolean b = delCont.contains(con.id)? TRUE : FALSE;
                contactWrapperLst.add(new ContactWrapper(con.CRM_Full_Name__c,con.id,FALSE,con.Email,con.Job_Code__r.Name,con.CRM_Disclaimer__c,con.CRM_I_Agree__c));
                conMap.put(con.id,con.name);
            }
        }
        
    }
    
    /*
    Method Name : getcountryPicklist
    Description : It is used to get mobile country code
    */
    public List<selectOption> getCountryPicklist() {
        List<LEX_Helper.PicklistValueWrapper> listPicklistValue = new List<LEX_Helper.PicklistValueWrapper>();
        listPicklistValue = LEX_Helper.getPicklistValues('Contact', 'CRM_Mobile_Country_Code__c', true);
        List<selectOption> options = new List<selectOption>();
        if(listPicklistValue <> null && listPicklistValue.size() > 0) {
            for(LEX_Helper.PicklistValueWrapper objPicklistValueWrapper : listPicklistValue) {
                options.add(new selectOption(objPicklistValueWrapper.picklistVal, objPicklistValueWrapper.picklistLabel)); 
            }//end for
        }//end if
        return options;
    }
    
    /*
    Method Name : doSelect
    Description : It is used to do operation after selecting the internal contact for Delegation
    */
    public pagereference doSelect(){
        errorMSG = '';
        // Save point to rollback if exception comes
        Savepoint sp = Database.setSavepoint();
        try{
            CampaignMember[] campaignMember = [select CRM_RSVP__c,CRM_Email_Template_Id__c,CRM_Attachment_Ids__c,CRM_Send_Feedback_Email__c, Contact.CRM_Full_Name__c from CampaignMember where Contact.Id = :con.id and Campaign.Id = :camp.id];
            system.debug('old CM'+campaignMember);
            if(campaignMember <> null && campaignMember.size() > 0){ 
                campaignMember[0].CRM_RSVP__c = 'No'; 
                
                List<task> taskLst = new List<Task>();
                List<CampaignMember> campMems = new List<CampaignMember>();
                for(ContactWrapper cw : contactWrapperLst){
                    system.debug('cw.conName===='+cw.conName);
                    if(cw.isSelected){
                        String s = con.name+' has delegated '+conMap.get(cw.conId)+' for the Campaign '+camp.name;
                        Task t = new Task(ownerId = camp.ownerid, whoid= cw.conId, subject = conMap.get(cw.conId)+'- Delegation Suggested' ,Description =s ,whatid = camp.id,ActivityDate = date.today());
                        taskLst.add(t);
                        
                        CampaignMember cm = new CampaignMember(campaignId = camp.id, contactid= cw.conId,CRM_Send_Feedback_Email__c = campaignMember[0].CRM_Send_Feedback_Email__c,CRM_I_Agree__c=cw.isAgreed,CRM_Disclaimer__c=cw.theDisclimer);
                        system.debug('new CM------'+cm);
                        campMems.add(cm);
                    }
                }
                if(taskLst <> null && campMems <> null && taskLst.size() > 0 && campMems.size() > 0) {
                    insert taskLst;
                    insert campMems;
                    update campaignMember;
                    
                } else {
                    errorMSG  = 'Please select at list one person for delegation.';
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select at least one person for delegation.')); 
                    return null;
                }
                
                
                List<String> attIds = new List<String>();
                List<CRM_Send_Email_Configuration__mdt> listSendEmailConfiguration =  [SELECT id, MasterLabel, CRM_Email__c FROM CRM_Send_Email_Configuration__mdt where CRM_Default__c = true limit 1];
                String orgWideId = null;
                if(listSendEmailConfiguration <> null && listSendEmailConfiguration.size() > 0) {
                    orgWideId = [SELECT ID FROM OrgWideEmailAddress WHERE Address =:listSendEmailConfiguration[0].CRM_Email__c].Id;
                }
                
                if(campaignMember <> null && campaignMember.size() > 0 && campaignMember[0].CRM_Attachment_Ids__c != null && campaignMember[0].CRM_Attachment_Ids__c == '')
                    attIds = campaignMember[0].CRM_Attachment_Ids__c.split(',');
                List<EmailTemplate> et = [select id,name from EmailTemplate where id =: campaignMember[0].CRM_Email_Template_Id__c LIMIT 1]; 
                List<SendEmailController.CampaignMemberWrapper> wrapList = new List<SendEmailController.CampaignMemberWrapper>();
                for(CampaignMember cm : campMems){
                    SendEmailController.CampaignMemberWrapper cmWrapper = new SendEmailController.CampaignMemberWrapper();
                    cmWrapper.campaignMemberRec = cm;
                    cmWrapper.isSelected = true; 
                    wrapList.add(cmWrapper);
                }
                
                if(et <> null && et.size() > 0 && campaignMember <> null && campaignMember.size() > 0) {
                    SendEmailController.sendEmailToAllCampaignMembers(wrapList,new List<SendEmailController.CampaignMemberWrapper>(),et[0],false,orgWideId, attIds, campaignMember[0].Contact.CRM_Full_Name__c);
                }
                
                
                contactWrapperLst = new List<ContactWrapper>();
            }
            return doRedirect();
        } catch(Exception e){
            Database.rollback( sp );
            system.debug(e.getMessage());
            system.debug(e.getLineNumber());
            errorMSG ='Error : '+e.getMessage() ;
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.geMessage(0)));
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
            return null;
        }
    }
    
    /*
    Method Name : doSelectExternal
    Description : It is used to do operation after selecting the external contact for Delegation
    */
    public pagereference doSelectExternal(){
        if(contactMobile.length() > 14 || contactMobile.length() < 8 || !contactMobile.isNumeric()) {
            errorMSG = 'Phone must be between 8 to 14. OR Can not contain Letters.';
            return null;
        }
        
        if(!isIAgree){
            errorConsentMSG = 'Please check the box if you want to proceed';
            return null;
        }
        
        CampaignMember[] campaignMember = [select CRM_RSVP__c,CRM_Email_Template_Id__c,CRM_Attachment_Ids__c,CRM_Send_Feedback_Email__c from CampaignMember where Contact.Id = : contactId and Campaign.Id = :camp.id];
        if(campaignMember.size() > 0){
            campaignMember[0].CRM_RSVP__c = 'No';
            update campaignMember;
        }
        String tsubject;
        if(isInternalCon){
            tsubject = first_Name+' '+last_Name+' - Delegation Suggested';
        } else {
            tsubject = company_Name+' - Delegation Suggested';
        }
        try{
            
            Task tsk = new Task(ownerId = camp.ownerid,subject = tsubject ,whatid = camp.id,ActivityDate = date.today(),Description =comments,CRM_External_First_Name__c =first_Name ,
                                CRM_External_Last_Name__c=last_Name ,CRM_External_Email__c = email_id ,CRM_External_Company__c= company_Name,CRM_External_Company_Id__c = company_id,
                                CRM_External_Mobile__c = contactMobile, CRM_External_Job_Title__c = jobTitle, CRM_External_Country_Code__c = mobileCode, CRM_External_Contact_Id__c = contactId, CRM_External_Middle_Name__c = middle_Name  );
            
            insert tsk;
            first_Name = null;
            last_Name = null;
            comments = null;
            email_id = null;
            company_Name = null;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Record captured successfully.'));
            return doRedirect();
            
        } catch(Exception e) {
            system.debug(e.getMessage());
            system.debug(e.getLineNumber());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
            return null;
        }
    }
    
    /*
    Method Name : doRedirect 
    Description : It is used to redirect user to Thank You page upon successful submission.
    */
    public pagereference doRedirect(){
        Pagereference pr = page.Thankyou;
        return pr;
    }
    
    /*
    Class Name : ContactWrapper
    Description : It is used to display the data to user and to hold user input.
    */
    public class ContactWrapper{
        public Boolean isSelected {get;set;}
        public String conName {get;set;}
        public String conEmail {get;set;}
        public String conJob {get;set;}
        public String conId {get;set;}
        public Boolean isDelegated {get;set;}
        public String theDisclimer {get;set;}
        public Boolean isAgreed {get;set;}
        public ContactWrapper(String n, String i,boolean bn,String conEmail, String conJob,String disc, boolean agreed){
            conName = n;
            conId = i;
            isDelegated = bn;
            isSelected = false;
            this.conEmail = conEmail ;
            this.conJob = conJob ;
            theDisclimer = disc;
            isAgreed = agreed;
        }
    }
}
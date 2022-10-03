/*
    Author      :   Yogesh Mahajan 
    Class Name  :   ShowAttendeeListController
    Description :   It is used as a controller for the EventDetails public page
    Date        :   03/03/2019       
*/
public without sharing class ShowAttendeeListController {
    public EventDetails objEvent{get;set;}
    public Boolean isInternal {get;set;}
    /*
	Name : ShowAttendeeListController
	Description : get date rage from url and show all the event details
	*/
    public ShowAttendeeListController(){
        isInternal = false;
        objEvent = new EventDetails();
        try{
            string contactId = ApexPages.currentPage().getParameters().get('contactId');
            string sCampaignId= ApexPages.currentPage().getParameters().get('Id');
            
            if(contactId <> null) {
                contactId = ApexCodeUtility.getDecryptedValue(contactId);
            }
            if( sCampaignId <> null) {
                sCampaignId = ApexCodeUtility.getDecryptedValue(sCampaignId);
            }
            if(contactId <> null) {
                List<Contact> listContact = [SELECT Account.Is_ADGM_Company__c FROM Contact WHERE id =: contactId ];
                if(listContact <> null && listContact.size() > 0 && listContact[0].Account.Is_ADGM_Company__c == true) {
                    isInternal = true;
                }
                
            }
            
            
            if(sCampaignId !=null){
                
                list<EventMembers> lstMembers = new list<EventMembers>();
                for(CampaignMember CM:[Select Name,Email,Phone,CompanyOrAccount,CRM_RSVP__c,
                                       Campaign.Name,Campaign.Status,Campaign.Category__c,Campaign.Main_Category__c,Campaign.CRM_Agenda__c,Campaign.CRM_End_Date__c,Campaign.CRM_Meeting_Location__c,Campaign.CRM_Meeting_Date_Time__c 
                                       FROM CampaignMember WHERE campaignId=:sCampaignId AND CRM_Email_Sent__c = true  ORDER BY CRM_Internal_Invitee__c DESC]){
                                           EventMembers obj = new EventMembers();
                                           obj.Name = CM.Name;
                                           obj.Email = CM.Email;
                                           obj.Phone = CM.Phone;
                                           obj.accName = CM.CompanyOrAccount;
                                           obj.RSVP = CM.CRM_RSVP__c;
                                           lstMembers.add(obj);
                                           if(objEvent.Name==null){
                                               objEvent.Name = CM.Campaign.Name;
                                               objEvent.status = CM.Campaign.status;
                                               objEvent.Category = CM.Campaign.Main_Category__c;
                                               objEvent.CRMAgenda = CM.Campaign.CRM_Agenda__c;
                                               objEvent.MeetingDateTime = CM.Campaign.CRM_Meeting_Date_Time__c;
                                               objEvent.EndDateTime = CM.Campaign.CRM_End_Date__c;
                                               if(objEvent.MeetingDateTime!=null)
                                                   objEvent.MeetingDateTime = objEvent.MeetingDateTime.addHours(4);
                                               if(objEvent.EndDateTime!=null)
                                                   objEvent.EndDateTime = objEvent.EndDateTime.addHours(4);
                                               objEvent.Location = CM.Campaign.CRM_Meeting_Location__c;
                                           }
                                       }
                objEvent.lstMembers = lstMembers;
            } 
            
        } catch(Exception ex){
            system.debug('---->'+ex.getMessage());
        }
    }
    public Double offset{
        get{
            TimeZone tz = UserInfo.getTimeZone();
            //Milliseconds to Day
            return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
        }
    }
    public class EventDetails{
        public string Name{get;set;}
        public string status {get;set;}
        public string Category{get;set;}
        public string CRMAgenda{get;set;}
        public DateTime MeetingDateTime{get;set;}
        public DateTime EndDateTime{get;set;}
        public string Location{get;set;}
        public list<EventMembers> lstMembers{get;set;}
        public EventDetails(){
            lstMembers = new list<EventMembers>();
        }
    }
    public class EventMembers{
        public string Name{get;set;}
        public String accName{get;set;}
        public string Email{get;set;}
        public string Phone{get;set;}
        public string RSVP{get;set;}
    }
}
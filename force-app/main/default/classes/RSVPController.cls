/*
    Author      :   Jayanta Karmakar
    Class Name  :   RSVPController
    Description :   Page Controller to store RSVP response and send calender invite
    

*/
public without sharing class RSVPController{
    public string comments {get;set;} //Comments for CampaignMember
    public Contact con;
    public boolean isSubmitted {get;set;} //Boolean variable to set whether the comment is captured from the user.
    public string contactId; //Contact Id parameter passed in the page.
    public string campaignId; //Campaign Id parameter passed in the page.
    public CampaignMember[] campaignMember;
    public boolean isCompleted {get;set;}
    public string pgMsg {get;set;}
    public ContactDetails objContactDetails {get;set;}
    public boolean isEmiratesIDNeeded {get;set;}
    public boolean isIAgree {get;set;}
    public String errorMSG {get;set;}
    public string reply {get;set;}
    public boolean isYes {get;set;}
    public String disclimerMsg {get;set;}
    
    public RSVPController(){
        isSubmitted = false;
        isCompleted = false;
        isIAgree = false;
        isEmiratesIDNeeded = false;
        objContactDetails = new ContactDetails();
        try{
            contactId = ApexPages.currentPage().getParameters().get('contactId');
            campaignId= ApexPages.currentPage().getParameters().get('campaignId');
            if(contactId <> null && String.isNotBlank(contactId)) {
                contactId = ApexCodeUtility.getDecryptedValue(contactId);
            }
            
            if( campaignId <> null && String.isNotBlank(campaignId)) {
                campaignId = ApexCodeUtility.getDecryptedValue(campaignId);
            }
            
            reply = ApexPages.currentPage().getParameters().get('reply');
            if(reply == 'yes'){
                isYes = true;
            }else{
                isYes = false;
            }
            
            campaignMember = [select CRM_RSVP__c,Comments__c,campaign.Main_Category__c, campaign.status,campaign.name,contact.CRM_Disclaimer__c from CampaignMember where Contact.Id = :contactId and Campaign.Id = :campaignId ];
            
            List<Contact> listContact = new List<Contact>();
            if(campaignMember.size() > 0){
                if(campaignMember[0].contact.CRM_Disclaimer__c <> '' && campaignMember[0].contact.CRM_Disclaimer__c <> null) {
                    disclimerMsg = campaignMember[0].contact.CRM_Disclaimer__c;    
                } else {
                    disclimerMsg = 'Do you agree that the information being submitted in this form is accurate and do you agree for ADGM to use and store this information?';
                }
                
                if(contactId <> null && contactId <> '' && (campaignMember[0].campaign.Main_Category__c == 'Government Event' || campaignMember[0].campaign.Main_Category__c == 'MBZ Majlis Lecture')) {
                    isEmiratesIDNeeded = true;
                    listContact = [SELECT id, Salutation, FirstName, LastName, Email,CRM_Mobile_Country_Code__c, MobilePhone, Emirates_ID_Number__c FROM Contact WHERE id =:contactId ];
                    if(listContact <> null && listContact.size() > 0) {
                        objContactDetails.sSalutation = listContact[0].Salutation;
                        objContactDetails.sFirstName = listContact[0].FirstName;
                        objContactDetails.sLastName = listContact[0].LastName;
                        objContactDetails.sEmail = listContact[0].Email;
                        objContactDetails.sMobile = listContact[0].MobilePhone;
                        objContactDetails.sCountry_Code = listContact[0].CRM_Mobile_Country_Code__c;
                        objContactDetails.sEmirates_ID = listContact[0].Emirates_ID_Number__c;
                    }
                    
                    
                    
                    
                }
                if(campaignMember[0].campaign.status == 'Completed' || campaignMember[0].campaign.status == 'Aborted'){
                    isCompleted = true;
                    pgMsg = campaignMember[0].campaign.name +' is already '+ campaignMember[0].campaign.status;
                }
                
                if(campaignMember[0].CRM_RSVP__c != '' && campaignMember[0].CRM_RSVP__c !=  null){
                    isCompleted = true;
                    pgMsg = 'Response Already Captured.';
                }
                //If comments holds value which mean response is captured, mark "isSubmitted" to True.
                if(String.IsNotBlank(campaignMember[0].Comments__c))
                    isSubmitted = true;
            }
        } catch(Exception ex){
            system.debug('---->'+ex.getMessage());
        }
    }
    /* 
        Name : setRSVP
        Description : Sets the RSPV value to "Yes/No"; Once the RSVP value is captured, the user is not given a choice to resubmit.
    */  
    public PageReference setRSVP(){
        try{
            if(campaignMember.size() > 0){
                if(campaignMember[0].campaign.status != 'Completed' && campaignMember[0].campaign.status != 'Aborted'){
                    if(String.IsNotBlank(contactId) && String.IsNotBlank(campaignId)){
                        CampaignMember[] campaignMember = [select CRM_RSVP__c from CampaignMember where Contact.Id = :contactId and Campaign.Id = :campaignId ];
                        if(campaignMember.size() > 0){
                            if(String.IsBlank(campaignMember[0].CRM_RSVP__c)){
                                if(String.IsNotBlank(reply)){
                                    if(reply == 'yes'){ //yes
                                        campaignMember[0].CRM_RSVP__c = 'Yes';
                                        if(!isEmiratesIDNeeded) 
                                            sendInvite(campaignId,contactId);
                                    }else{
                                        campaignMember[0].CRM_RSVP__c = 'No';
                                    }
                                }
                                
                                if(!isEmiratesIDNeeded) {
                                    upsert campaignMember;
                                    if(reply == 'yes'){
                                        PageReference thankyouPage = new PageReference('/Thankyou');
                                        thankyouPage.setRedirect(true);
                                        return thankyouPage;
                                    } else {
                                        return null;
                                    }
                                } else if(reply == 'No' && isEmiratesIDNeeded){
                                    upsert campaignMember;
                                    return null;
                                }
                                
                                
                            }
                        }
                    }
                }
            }
            
        }
        catch(Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
        }
        return null;
    }
    
    /* 
        Name : sendInvite
        Description : Method to update the comments on Campaign Member.
    */  
    public PageReference updateContact(){
        if(objContactDetails <> null && objContactDetails.sEmirates_ID <> null) {
            if(!isIAgree){
                errorMSG = 'Please check the box if you want to proceed';
                return null;
            }
                
            Contact objContact = new contact(id=contactId);
           
            objContact.Emirates_ID_Number__c = objContactDetails.sEmirates_ID;
            objContact.CRM_I_Agree__c = isIAgree;
            try {
                sendInvite(campaignId,contactId);
                
                update objContact;
                if(ApexPages.currentPage().getParameters().get('reply') == 'yes'){
                    campaignMember[0].CRM_RSVP__c = 'Yes';
                }
                upsert campaignMember;
            }catch(Exception e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
                return null;
            }
            
            
        }
        //Redirect the user to ThankYou Page once the RSVP Comment is captured.
        PageReference thankyouPage = new PageReference('/Thankyou');
        thankyouPage.setRedirect(true);
        return thankyouPage;
    }
    /* 
        Name : updateComment
        Description : Method to update the comments on Campaign Member.
    */ 
    public PageReference updateComment(){
        if(String.IsNotBlank(contactId) && String.IsNotBlank(campaignId)){
            CampaignMember[] campaignMember = [select id, Comments__c from CampaignMember where Contact.Id = :contactId and Campaign.Id = :campaignId ];
            if(campaignMember.size() > 0){
                if(String.IsNotBlank(comments)){
                    campaignMember[0].Comments__c = comments;
                    try {
                        update campaignMember;    
                    }catch(Exception e){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
                        return null;
                    }
                    
                }
            }
        }
        //Redirect the user to ThankYou Page once the RSVP Comment is captured.
        PageReference thankyouPage = new PageReference('/Thankyou');
        thankyouPage.setRedirect(true);
        return thankyouPage;
    }
    /* 
        Name : sendInvite
        Description : Method to send out Invitition email.
    */
    public void sendInvite(String campId,String conId) {
        con = [Select id,email,Name from Contact where id =: conId]; 
        Campaign cmpn = [select id,Name,CRM_Meeting_Date_Time__c,CRM_End_Date__c,CRM_Meeting_Location__c,CRM_Agenda__c, Virtual_Venue__c from Campaign where id =: campId];
        //Date dt = date.newinstance(cmpn.CRM_Meeting_Date_Time__c.year(), cmpn.CRM_Meeting_Date_Time__c.month(), cmpn.CRM_Meeting_Date_Time__c.day());
        // String dte = String.valueof(dt).substring(0,10);
        String dte = cmpn.CRM_Meeting_Date_Time__c.day() +'/'+ cmpn.CRM_Meeting_Date_Time__c.month() +'/'+ cmpn.CRM_Meeting_Date_Time__c.year();
        String agenda = cmpn.CRM_Agenda__c != null ? cmpn.CRM_Agenda__c : '';
        String msgBody = '<p>Dear '+con.name+',</p> <p>You have an upcoming meeting on '+dte+'. Please find the details of the meeting below.</p>';
        msgBody += '<table> <tr><td style="width:100px"><b>Subject</b></td> <td>'+cmpn.Name+'</td></tr> ';
        msgBody += '<tr><td><b>Location</b></td> <td>'+cmpn.CRM_Meeting_Location__c+'</td></tr>';
        msgBody += '<tr><td><b>Start</b></td> <td>'+formatDateTime(cmpn.CRM_Meeting_Date_Time__c)+'</td></tr>';
        msgBody += '<tr><td><b>End</b></td> <td>'+formatDateTime(cmpn.CRM_End_Date__c)+'</td></tr>';
        msgBody += '<tr><td><b>Organizer</b></td> <td>'+Label.Organizer_Email+'</td></tr>';
        msgBody += '<tr><td><b>Agenda</b></td> <td>'+agenda+'</td></tr>';
        String virtualVenue = cmpn.Virtual_Venue__c != null ? cmpn.Virtual_Venue__c : '';
        msgBody += '<tr><td><b>Virtual Venue</b></td> <td>' + virtualVenue + '</td></tr> </table>';
    

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {con.Email};
        System.debug('toAdresses------------------->'+toAddresses);
        mail.setToAddresses(toAddresses);
        mail.setSubject('Meeting Invitation');
        mail.setHtmlBody(msgBody);
        List<CRM_Send_Email_Configuration__mdt> listSendEmailConfiguration =  [SELECT id, MasterLabel, CRM_Email__c FROM CRM_Send_Email_Configuration__mdt where CRM_Default__c = true limit 1];
        String orgWideId = null;
        if(listSendEmailConfiguration <> null && listSendEmailConfiguration.size() > 0) {
            orgWideId = [SELECT ID FROM OrgWideEmailAddress WHERE Address =:listSendEmailConfiguration[0].CRM_Email__c].Id;
        }
        if(orgWideId <> null && orgWideId <> '') {
            mail.setOrgWideEmailAddressId(orgWideId);
        }
        
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        attach.filename = 'meeting.ics';
        attach.ContentType = 'text/calendar;';
        attach.inline = true;
        
        attach.body = invite(cmpn);
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attach});
        Messaging.SendEmailResult[] er = Messaging.sendEmail(new Messaging.Email[] {mail});
    }

     /* 
        Name : invite
        Description : Method to generate and return ICS file.
    */
    public Blob invite(Campaign cmp) {
        String txtInvite = '';
        txtInvite += 'BEGIN:VCALENDAR\n';
        txtInvite += 'PRODID::-//hacksw/handcal//NONSGML v1.0//EN\n';//'PRODID:-//Microsoft Corporation//Outlook 12.0 MIMEDIR//EN\n'; 
        txtInvite += 'VERSION:2.0\n';
        txtInvite += 'BEGIN:VEVENT\n';
        txtInvite += 'UID:info@test.com\n';
        txtInvite += 'CREATED:'+convertDateTime(DateTime.now())+'\n';
        txtInvite += 'DTEND:'+convertDateTime(cmp.CRM_End_Date__c)+'\n';
        txtInvite += 'DTSTAMP:'+convertDateTime(DateTime.now())+'\n';
        txtInvite += 'DTSTART:'+convertDateTime(cmp.CRM_Meeting_Date_Time__c)+'\n';
        txtInvite += 'LAST-MODIFIED:'+convertDateTime(DateTime.now())+'\n';
        txtInvite += 'DESCRIPTION:'+cmp.CRM_Agenda__c+'\n';
        txtInvite += 'LOCATION:'+cmp.CRM_Meeting_Location__c+'\n';
        txtInvite += 'SUMMARY:'+cmp.Name+'\n';
        txtInvite += 'LANGUAGE=en-us:'+cmp.Name+'\n';
        txtInvite += 'ORGANIZER:MAILTO:'+Label.Organizer_Email+'\n';
        txtInvite += 'ATTENDEE:mailto:'+con.email+'\n';
        txtInvite += 'END:VEVENT\n';
        txtInvite += 'END:VCALENDAR';
        
        System.debug(txtInvite);
        return Blob.valueOf(txtInvite);
    }

     /* 
        Name : convertDateTime
        Description : Method to convert datetime to ICS accepted format.
    */
    public String convertDateTime(DateTime dt){
        if(dt == null){return null;}
        String dtString = String.valueof(dt)+'Z';
        dtString = dtString.replaceAll(' ','T').replaceAll('-','').replaceAll(':','');
        return dtString;
    }
    /*
    Name : formatDateTime
    Description : format Date Time in dd/mm/yyyy hh:mm
    */
    public String formatDateTime(DateTime dt){
        if(dt == null){return null;}
        dt = dt.addHours(4);
        String hr = (dt.hour()<10)?('0'+dt.hour()): String.valueof(dt.hour());
        String mn = (dt.minute()<10)?('0'+dt.minute()): String.valueof(dt.minute());
        String dtString = dt.day() +'/'+ dt.month() +'/'+ dt.year() +' '+hr+':'+mn;
        return dtString;
    }
    
    public class ContactDetails{
        public string sSalutation {get;set;}
        public string sFirstName {get;set;}
        public string sLastName {get;set;}
        public string sEmail {get;set;}
        public string sMobile {get;set;}
        public string sCountry_Code {get;set;}
        
        public String sEmirates_ID {get;set;}
    }
}
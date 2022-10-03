public without sharing class HomeController{
    public list<Alert> lstAlert {get;set;}
    public list<Appointment> lstAppointment {get;set;}
    public transient list<Announcement> lstAnnouncement {get;set;}
    public boolean isGuestUser {get;set;}
    public boolean AlertsViewAll{get;set;}
    public string companyName {get;set;}
    public Service service {get;set;}
    public boolean isEntityChanged {get;set;}
    public class Alert{
        public string alertMessage {get;set;}
    }
    public class Appointment{
        public string appointmentDate {get;set;}
        public string appointmentMessage {get;set;}
        public string titleContent {get;set;}
    }
    public class Announcement{
        public string id {get;set;}
        public transient string headerImage {get;set;}
        public string announceTitle {get;set;}
        public string HeaderImageContentType{get;set;}
        public string shortAnnouncementDtl {get;set;}
    }
    public class Service{
        public boolean isCompanyService {get;set;}
        public boolean isVisaLetterService {get;set;}
        public boolean isPermitService {get;set;}
        public Service(){
            isCompanyService = false;
            isVisaLetterService = false;
            isPermitService = false;
        }
    }
    public HomeController(){
        service = new Service();
        lstAlert = new list<Alert>();
        AlertsViewAll = false;
        lstAppointment = new list<Appointment>();
        lstAnnouncement = new list<Announcement>();
        string loggedInUserAccountId;
        isEntityChanged = false;
        list<User> lstUser = [Select Contact.Account.IsEntityChanged__c,contact.accountid,contact.Is_Guest_User__c,contact.Account.Name,contact.Types_of_Services_Accessible__c, contact.Account.Entity_Status__c from User where id =:Userinfo.getUserid() limit 1];
        
        if(!lstUser.IsEmpty()){
            loggedInUserAccountId = lstUser[0].contact.accountid;
            isGuestUser = lstUser[0].contact.Is_Guest_User__c;
            companyName = lstUser[0].contact.Account.Name;
            isEntityChanged  = lstUser[0].Contact.Account.IsEntityChanged__c;
            system.debug('===='+isEntityChanged);
            /* Alerts list **/
            list<Notice__c> lstNotice = new list<Notice__c>();
            /*
            if(isGuestUser)
                lstNotice = [select Alert_Text__c,Expiry_Date__c from Notice__c where Start_Date__c<=:system.TODAY() and End_Date__c>=:system.TODAY() and Entity__c =:loggedInUserAccountId and Type__c = 'Company Alert' and Status__c!='Inactive' and Status__c!='Expired' order by Severity__c desc limit 5];
            else
            */
            lstNotice = [select Alert_Text__c,Expiry_Date__c from Notice__c where Start_Date__c<=:system.TODAY() and End_Date__c>=:system.TODAY() and Entity__c = :loggedInUserAccountId  and Type__c = 'Company Alert' and Status__c!='Inactive' and Status__c!='Expired' order by Severity__c desc limit 5];
            if(lstNotice != null && lstNotice.size() > 0){
                integer AlertCount = 0;
                for(Notice__c nt: lstNotice){
                    Alert alert = new Alert();
                    if(nt.Expiry_Date__c!=null)
                        alert.alertMessage = nt.Alert_Text__c+' on '+nt.Expiry_Date__c.day()+'-'+datetime.newInstance(nt.Expiry_Date__c.year(), nt.Expiry_Date__c.month(),nt.Expiry_Date__c.day()).format('MMM')+'-'+nt.Expiry_Date__c.year();//notice.Expiry_Date__c.format();
                    else
                        alert.alertMessage = nt.Alert_Text__c;
                    if(AlertCount<4)
                        lstAlert.add(alert);
                    AlertCount++;
                    /*
                    if(notice.Entity__c!=null && isGuestUser==false)
                        lstAlert.add(alert);
                    
                    else if(isGuestUser && notice.Entity__c==null)
                        lstAlert.add(alert);
                    */
                }
                if(AlertCount>4)
                    AlertsViewAll = true;
            }
            /* Appointments list **/
            list<Appointment__c> listAppointment = [select Employee_Name__c, Appointment_Type__c, Appointment_Date__c from Appointment__c where Customer__c = :loggedInUserAccountId and Appointment_SR_Closed__c=false limit 4];
            if(listAppointment != null && listAppointment.size() > 0){
                for(Appointment__c app: listAppointment){
                    Appointment appointment = new Appointment();
                    appointment.appointmentMessage = app.Employee_Name__c + ' ' + app.Appointment_Type__c;
                    if(app.Appointment_Date__c != null){
                        appointment.appointmentDate = DateTime.newInstance(app.Appointment_Date__c.year(),app.Appointment_Date__c.month(),app.Appointment_Date__c.day()).format('dd MMM YYYY');
                    }
                    lstAppointment.add(appointment);
                }
            }
            list<Notice__c> lstAnnounce = new list<Notice__c>(); 
            map<string,Notice__c> uniqueAnnouncements = new map<string,Notice__c>();
            if(isGuestUser)
            {
            	for(Notice__c nt : [select Id,title__c,Notification_Picture_Id__c,Announcement_Content__c from Notice__c where Start_Date__c<=:system.today() 
            						and End_Date__c>=:system.today() and Publish__c=true and (Entity__c=:loggedInUserAccountId or (Entity__c = null)) and Available_for__c INCLUDES ('Guest User') 
            						and Type__c = 'Announcement' order by CreatedDate desc limit 4])
				{
					uniqueAnnouncements.put(nt.title__c,nt);
				}
				lstAnnounce.addAll(uniqueAnnouncements.values());
				//lstAnnounce = [select Id,title__c,Notification_Picture_Id__c,Announcement_Content__c from Notice__c where Start_Date__c<=:system.today() and End_Date__c>=:system.today() and Publish__c=true and (Entity__c=:loggedInUserAccountId ) and Available_for__c INCLUDES ('Guest User') and Type__c = 'Announcement' order by CreatedDate desc limit 4];
            }
            else
            {
            	for(Notice__c nt : [select Id,title__c, Notification_Picture_Id__c, Announcement_Content__c from Notice__c where Start_Date__c<=:system.today() and End_Date__c>=:system.today() 
            					and Publish__c=true and (Entity__c=:loggedInUserAccountId or (Entity__c = null)) and Available_for__c INCLUDES ('Company User') 
            					and Type__c = 'Announcement' order by CreatedDate desc limit 4])
				{
					uniqueAnnouncements.put(nt.title__c,nt);
				}
				lstAnnounce.addAll(uniqueAnnouncements.values());
            	//lstAnnounce = [select Id,title__c,Notification_Picture_Id__c,Announcement_Content__c from Notice__c where Start_Date__c<=:system.today() and End_Date__c>=:system.today() and Publish__c=true and (Entity__c=:loggedInUserAccountId or (Entity__c = null)) and Available_for__c INCLUDES ('Company User') and Type__c = 'Announcement' order by CreatedDate desc limit 4];
            }
            
            system.debug('lstAnnounce==>'+lstAnnounce);
            /* Announcement list **/
            if(lstAnnounce != null && lstAnnounce .size() > 0){
                map<string,Attachment> mapAnnouncementImages = new map<string,Attachment>();
                set<string> setAttachmentIds = new set<string>();
                for(Notice__c notice: lstAnnounce){
                    setAttachmentIds.add(notice.Notification_Picture_Id__c);
                }
                if(setAttachmentIds.size()>0){
                    for(Attachment atch:[Select Id,Body,ContentType from Attachment where Id IN:setAttachmentIds]){
                        mapAnnouncementImages.put(atch.Id,atch);
                    }
                }
                for(Notice__c notice: lstAnnounce){
                    Announcement announce = new Announcement();
                    if(mapAnnouncementImages.get(notice.Notification_Picture_Id__c)!=null){
                        announce.headerImage = EncodingUtil.base64Encode(mapAnnouncementImages.get(notice.Notification_Picture_Id__c).Body);//notice.Notification_Picture_Id__c;
                        announce.HeaderImageContentType = mapAnnouncementImages.get(notice.Notification_Picture_Id__c).ContentType;
                    }
                    announce.announceTitle = notice.title__c;
                    announce.id = notice.Id;
                    if(String.isNotBlank(notice.Announcement_Content__c)){
                        String announcementSummary = notice.Announcement_Content__c.abbreviate(100);
                        announce.shortAnnouncementDtl = announcementSummary;
                    }
                    lstAnnouncement.add(announce);
                }
            }
            //Check accessible services
            if(String.isNotBlank(lstUser[0].contact.Types_of_Services_Accessible__c))
            {
                if(lstUser[0].contact.Types_of_Services_Accessible__c.toLowerCase().indexOf('company services') > -1)
                {
                    system.debug('====='+lstUser[0].contact.Types_of_Services_Accessible__c);
                    service.isCompanyService = true; 
                    
                }
                if((lstUser[0].contact.Types_of_Services_Accessible__c.toLowerCase().indexOf('visa & letter services') > -1))
                    
                {
                    service.isVisaLetterService = true;
                    system.debug('===isEntityChanged ===='+isEntityChanged);
                    
                    if(isEntityChanged  == true)
                    service.isVisaLetterService = false;
                    
                }
                if(lstUser[0].contact.Types_of_Services_Accessible__c.toLowerCase().indexOf('permits services') > -1)
                    service.isPermitService = true; 
                
                list<string> activeStatuses = label.PORTAL_ACTIVE_STATUSES.split(';');
                set<string> ast = new set<string>();
                ast.addAll(activeStatuses);
                
                if(!ast.contains(lstUser[0].contact.Account.Entity_Status__c)){
                    service.isCompanyService = false;
                    service.isPermitService = false; 
                    service.isVisaLetterService = false; 
                }
            }
        }
    }
    
}
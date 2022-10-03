/*
    Author      : Durga Prasad
    Date        : 14-Dec-2017
    Description : Controller to display the list of Alerts specific to the company
    --------------------------------------------------------------------------------------
*/
public without sharing class AlertsListController {
    public Integer noOfRecords{get; set;}
    public Integer size{get;set;}
    public boolean isGuestUser{get;set;}
    public string loggedInUserAccountId;
    public AlertsListController(){
        isGuestUser = false;
        for(User usr:[Select contact.accountid,contact.Is_Guest_User__c from User where id =: Userinfo.getUserid() limit 1]){
            loggedInUserAccountId = usr.contact.accountid;
            isGuestUser = usr.contact.Is_Guest_User__c;
        }
    }
    public ApexPages.StandardSetController setCon {
        get{
            if(setCon == null){
                size = 10;
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator([select Alert_Text__c,Expiry_Date__c from Notice__c where Start_Date__c<=:system.TODAY() and End_Date__c>=:system.TODAY() and Entity__c = :loggedInUserAccountId  and Type__c = 'Company Alert' and Status__c!='Inactive' and Status__c!='Expired' order by Severity__c desc limit 10000]));
                setCon.setPageSize(size);
                noOfRecords = setCon.getResultSize();
                system.debug('----------##----' + noOfRecords);
            }
            return setCon;
        }set;
    }
    public class Alert{
        public string alertMessage {get;set;}
    }
    public list<Alert> getAlerts(){
        list<Alert> lstAlert = new list<Alert>();
        for(Notice__c nt : (list<Notice__c>)setCon.getRecords()){
            Alert alrt = new Alert();
            if(nt.Expiry_Date__c!=null)
                alrt.alertMessage = nt.Alert_Text__c+' on '+nt.Expiry_Date__c.day()+'-'+datetime.newInstance(nt.Expiry_Date__c.year(), nt.Expiry_Date__c.month(),nt.Expiry_Date__c.day()).format('MMM')+'-'+nt.Expiry_Date__c.year();//notice.Expiry_Date__c.format();
            else
                alrt.alertMessage = nt.Alert_Text__c;
            lstAlert.add(alrt);
        }
        return lstAlert;
    }
     
    public pageReference refresh() {
        setCon = null;
        getAlerts();
        setCon.setPageNumber(1);
        return null;
    }
    public Integer getTotalPages() {
        return Integer.valueof(Math.ceil((Double) noOfRecords / size));
    }
}
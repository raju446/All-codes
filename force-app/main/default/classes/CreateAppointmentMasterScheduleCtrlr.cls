/*
Author      : Rajil Ravindran
Date        : 15-Oct-2017
Description : Controller class to create appointment masters based on the date range and the selected timmings and slots.
--------------------------------------------------------------------------------------
*/
public class CreateAppointmentMasterScheduleCtrlr{
    
    public Appointment_Master__c startAMDate {get;set;}
    public Appointment_Master__c endAMDate {get;set;}
    
    public List<AvailableTimeWrapper> timeWrapList {get;set;}
    
    public Boolean hasError {get;set;}
    
    public CreateAppointmentMasterScheduleCtrlr(ApexPages.StandardController stdController){
        startAMDate = new Appointment_Master__c();
        endAMDate = new Appointment_Master__c();
        createTimeWrapper();
    }
    
    public void createTimeWrapper(){
        timeWrapList = new List<AvailableTimeWrapper>();
        List<Appointment_Timings__c> appTimes = Appointment_Timings__c.getall().values();
        for(Appointment_Timings__c appT : appTimes){
            if(appT.Active__c == TRUE){
                timeWrapList.add(new AvailableTimeWrapper(false,true, appT.Time__c, 0,false));
            }
        }
    }
    
    public PageReference saveAppointmentMaster(){       
        hasError = false;
        if(startAMDate.Date__c > endAMDate.Date__c){
            hasError = TRUE;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'From Date should be on or before To Date.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        if(hasError == false){
            List<Appointment_Master__c> newAppMasterList = new List<Appointment_Master__c>();
            System.debug('@@TIMEWRAP: '+timeWrapList);
            Date startDate = startAMDate.Date__c;
            Integer totalDays = startDate.daysBetween(endAMDate.Date__c)+1;
            System.debug('##DAYS: '+totalDays);
            Id bussHoursId = [SELECT Id FROM BusinessHours WHERE isDefault = true LIMIT 1].Id;
            System.debug('##BU_HOURS: '+bussHoursId);
            do{
                Datetime availDate = datetime.newInstance(startDate.year(), startDate.month(),startDate.day()).addHours(9);
                System.debug('@@AVAILDATE: '+availDate+ ' : '+BusinessHours.isWithin(bussHoursId,availDate));
                System.debug('##STARTDATE: '+startDate);
                if(BusinessHours.isWithin(bussHoursId,availDate) == TRUE){
                    for(AvailableTimeWrapper atw : timeWrapList){
                        if(atw.isSelected == TRUE){
                            Appointment_Master__c am = new Appointment_Master__c();
                            am.Date__c = startDate;
                            Datetime dt = datetime.newInstance(startDate.year(), startDate.month(),startDate.day());
                            String dayOfWeek = dt.format('EEEE');
                            System.debug('##dayOfWeek: '+dayOfWeek);
                            System.debug('##atw.avaliableForFriday: '+atw.avaliableForFriday);
                            am.No_of_Seats__c = atw.numOfSeats;
                            am.Time__c = atw.timeStr;
                            am.Biometrics_Required__c = atw.isBiometricsRequired;
                            am.VIP__c = atw.isVIP;
                            am.Status__c = 'Active';
                            if(dayOfWeek == 'Friday' && atw.avaliableForFriday)
                                newAppMasterList.add(am);
                            if(dayOfWeek != 'Friday')
                                newAppMasterList.add(am);
                        }
                    }
                }
                startDate = startDate.addDays(1);
            } while(startDate < = endAMDate.Date__c);
            
            if(!newAppMasterList.isEmpty()){
                System.debug('@@APP-MASTER-SIZE: '+newAppMasterList.size());
                System.debug('@@APP-MASTER: '+newAppMasterList);
                try{
                    insert newAppMasterList;
                    PageReference pageRef = new PageReference('/'+Label.Appoint_Master_Object_Prefix+'/o');
                    pageRef.setRedirect(true);
                    return pageRef;
                } catch(Exception e){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
                    ApexPages.addMessage(myMsg);
                }
            } else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'There are no Appointment Masters created.');
                ApexPages.addMessage(myMsg);
            }
            return null;
        }
        return null;
    }
    
    public class AvailableTimeWrapper{
        public Boolean isSelected {get;set;}
        public Boolean avaliableForFriday {get;set;}
        public String timeStr {get;set;}
        public Integer numOfSeats {get;set;}
        public Boolean isBiometricsRequired {get;set;}
        public Boolean isVIP {get;set;}
        
        public AvailableTimeWrapper(Boolean isSelected,Boolean avaliableForFriday, String timeStr, Integer numOfSeats, Boolean isVIP){
            this.isSelected = isSelected;
            this.avaliableForFriday = avaliableForFriday;
            this.timeStr = timeStr;
            this.numOfSeats = numOfSeats;
            if(timeStr == '10:00 AM'){
                isBiometricsRequired = true;
            }
            this.isVIP = isVIP;
        }
    }
}
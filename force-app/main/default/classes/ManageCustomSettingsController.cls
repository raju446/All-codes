/*
    Author      : Kim Noceda
    Date        : 18-Jan-2018
    Description : Page Controller to manage the custom settings
    --------------------------------------------------------------------------------------
*/
public without sharing class ManageCustomSettingsController {

    public String selectedCustomSetting{get;set;}
    public Boolean isCSSelected{get;set;}
    public String selSettingname{get;set;}
    
    public Boolean isNewRecord{get;set;}
    
    public List<Appointment_Timings__c> appointmentList {get;set;}
    public List<Case_Types__c> caseTypeList {get;set;}
    public List<Fines__c> finesList {get;set;}
    public List<SLA_Configuration__c> slaList {get;set;}
    public List<Visa_Check_Availability_API__c> visaCheckList {get;set;}
    
    public Boolean isShowAppointment{get;set;}
    public Boolean isShowCaseType{get;set;}
    public Boolean isShowFines{get;set;}
    public Boolean isShowSLA{get;set;}
    public Boolean isShowVisaCheck{get;set;}
    
    public Appointment_Timings__c newAppt{get;set;}
    public Case_Types__c newCaseType{get;set;}
    public Fines__c newFines{get;set;}
    public SLA_Configuration__c newSLA{get;set;}
    public Visa_Check_Availability_API__c newVisaCheck{get;set;}
    
    public String csRecordToBeDeleted{get;set;}
    public String csRecordToBeEdited{get;set;}
    
    public AppointmentWrapper appoinmentNewWrap {get;set;}
    public CaseWrapper   caseNewWrap {get;set;}
    public FinesWrapper fineNewWrap {get;set;}
    public SlaWrapper SlaNewWrap {get;set;}
    public VisaWrapper visaNewWrap {get;set;}

    public ManageCustomSettingsController(){
        selectedCustomSetting =  '';
        isCSSelected = false;
        initialiseList();
        isNewRecord = false;
        //initialiseNewRecords();
        csRecordToBeDeleted = '';
        csRecordToBeEdited = '';
        selSettingname='';
    }
    
    public void initialiseList(){
        appointmentList = new List<Appointment_Timings__c>();
        caseTypeList = new List<Case_Types__c>();
        finesList = new List<Fines__c>();
        slaList = new List<SLA_Configuration__c>();
        visaCheckList = new List<Visa_Check_Availability_API__c>();
        
        isShowAppointment = false;
        isShowCaseType = false;
        isShowFines = false;
        isShowSLA = false;
        isShowVisaCheck = false;

        csRecordToBeDeleted = '';
        csRecordToBeEdited = '';
        selSettingname = '';
        
        isNewRecord = false;
        isCSSelected = false;
    }
    
    public void initialiseNewRecords(){
        newAppt = new Appointment_Timings__c();
        newCaseType = new Case_Types__c();
        newFines = new Fines__c();
        newSLA = new SLA_Configuration__c();
        newVisaCheck = new Visa_Check_Availability_API__c();
        
        appoinmentNewWrap = new AppointmentWrapper();
        caseNewWrap =  new CaseWrapper();
        fineNewWrap = new FinesWrapper();
        SlaNewWrap = new SlaWrapper(); 
        visaNewWrap = new VisaWrapper();
    }
    
    public void selectedSettingName(){
        System.debug('##SETTINGNAME: '+selectedCustomSetting);
        initialiseList();
        if(selectedCustomSetting != '--None--' && selectedCustomSetting != ''){
            isCSSelected = true;
            if(selectedCustomSetting == 'Appointment_Timings__c'){
                selSettingname = 'Appointment Timings';
                appointmentList = [SELECT Id, Name, Time__c, Active__c FROM Appointment_Timings__c ORDER BY Name];
                isShowAppointment = true;
            }
            else if(selectedCustomSetting == 'Case_Types__c'){
                selSettingname = 'Case Types';
                caseTypeList = [SELECT Id, Name, Case_Description__c, Case_Title__c, Icon_Name__c, Record_Type_API_Name__c, Seq_No__c FROM Case_Types__c ORDER BY Name];
                isShowCaseType = true;
            }
            else if(selectedCustomSetting == 'Fines__c'){
                selSettingname = 'Fines';
                finesList = [SELECT Id, Name, Document_Type__c, Fine_Amount__c, Fine_Amount_Per_Month__c, First_Month_Amount__c, Grace_Period__c, Maximum_Fine_Amount__c, SR_Record_Type_Name__c FROM Fines__c ORDER BY Name];
                isShowFines = true;
            }
            else if(selectedCustomSetting == 'SLA_Configuration__c'){
                selSettingname = 'SLA Configuration';
                slaList = [SELECT Id, Name, Business_Hour_Id__c, Queue_Name__c, SLA_Hours__c, SLA_Minutes__c FROM SLA_Configuration__c ORDER BY Name];
                isShowSLA = true;
            }
            else if(selectedCustomSetting == 'Visa_Check_Availability_API__c'){
                selSettingname = 'Visa Check Availability API';
                visaCheckList = [SELECT Id, Name, API_Name__c FROM Visa_Check_Availability_API__c ORDER BY Name];
                isShowVisaCheck = true;
            }
        }
        System.debug('##SEL: '+isCSSelected);
    }
    
    public void cancelEdit(){
        isNewRecord = false;
    }
    
    public void deleteCSRecord(){
        System.debug('##DELETECS: '+csRecordToBeDeleted);
        try{
            if(selectedCustomSetting != 'None' && selectedCustomSetting != ''){
                if(selectedCustomSetting == 'Appointment_Timings__c'){
                    newAppt = Appointment_Timings__c.getValues(csRecordToBeDeleted);
                    delete newAppt;
                }
                else if(selectedCustomSetting == 'Case_Types__c'){
                    newCaseType = Case_Types__c.getValues(csRecordToBeDeleted);
                    delete newCaseType;
                }
                else if(selectedCustomSetting == 'Fines__c'){
                    newFines = Fines__c.getValues(csRecordToBeDeleted);
                    delete newFines;
                }
                else if(selectedCustomSetting == 'SLA_Configuration__c'){
                    newSLA = SLA_Configuration__c.getValues(csRecordToBeDeleted);
                    delete newSLA;
                }
                else if(selectedCustomSetting == 'Visa_Check_Availability_API__c'){
                    newVisaCheck = Visa_Check_Availability_API__c.getValues(csRecordToBeDeleted);
                    delete newVisaCheck;
                }
            }
            selectedSettingName();
        } catch(Exception e){
        }
    }
    
    public void editCSRecord(){
        isNewRecord = true;
        if(selectedCustomSetting != 'None' && selectedCustomSetting != ''){
            if(selectedCustomSetting == 'Appointment_Timings__c'){
                newAppt = Appointment_Timings__c.getValues(csRecordToBeEdited);
                appoinmentNewWrap = new AppointmentWrapper(newAppt);
            }
            else if(selectedCustomSetting == 'Case_Types__c'){
                newCaseType = Case_Types__c.getValues(csRecordToBeEdited);
                caseNewWrap =  new CaseWrapper(newCaseType);
            }
            else if(selectedCustomSetting == 'Fines__c'){
                newFines = Fines__c.getValues(csRecordToBeEdited);
                fineNewWrap = new FinesWrapper(newFines);
            }
            else if(selectedCustomSetting == 'SLA_Configuration__c'){
                newSLA = SLA_Configuration__c.getValues(csRecordToBeEdited);
                SlaNewWrap = new SlaWrapper(newSLA ); 
            }
            else if(selectedCustomSetting == 'Visa_Check_Availability_API__c'){
                newVisaCheck = Visa_Check_Availability_API__c.getValues(csRecordToBeEdited);
                visaNewWrap = new VisaWrapper(newVisaCheck);
            }
        }
        System.debug('!!ISNEW: '+isNewRecord);
        System.debug('!!SETTING: '+selectedCustomSetting);
    }
    
    public void newCSRecord(){
        isNewRecord = true;
        if(selectedCustomSetting != 'None' && selectedCustomSetting != ''){
            if(selectedCustomSetting == 'Appointment_Timings__c'){
                newAppt = new Appointment_Timings__c();
                appoinmentNewWrap = new AppointmentWrapper(newAppt);
            }
            else if(selectedCustomSetting == 'Case_Types__c'){
                newCaseType = new Case_Types__c();
                caseNewWrap =  new CaseWrapper(newCaseType);
            }
            else if(selectedCustomSetting == 'Fines__c'){
                newFines = new Fines__c();
                fineNewWrap = new FinesWrapper(newFines);
            }
            else if(selectedCustomSetting == 'SLA_Configuration__c'){
                newSLA = new SLA_Configuration__c();
                SlaNewWrap = new SlaWrapper(newSLA ); 

            }
            else if(selectedCustomSetting == 'Visa_Check_Availability_API__c'){
                newVisaCheck = new Visa_Check_Availability_API__c();
                visaNewWrap = new VisaWrapper(newVisaCheck);
            }
        }
        System.debug('!!ISNEW: '+isNewRecord);
        System.debug('!!SETTING: '+selectedCustomSetting);
    }
    
    public void saveRecord(){
        try{
            if(selectedCustomSetting != 'None' && selectedCustomSetting != ''){
                if(selectedCustomSetting == 'Appointment_Timings__c'){
                    System.debug('##APPOINTMENT');
                    /*if(newAppt.Id != null){
                        update newAppt;
                    } else{
                        insert newAppt;
                    }*/
                    if(appoinmentNewWrap.appId != null){
                        appoinmentNewWrap.updateAppointment();
                    } else{
                        appoinmentNewWrap.insertAppointment();
                    }
                }
                else if(selectedCustomSetting == 'Case_Types__c'){
                    /*if(newCaseType.Id != null){
                        update newCaseType;
                    } else{
                        insert newCaseType;
                    }*/
                    if(caseNewWrap.appId != null){
                        caseNewWrap.updateCase();
                    } else{
                        caseNewWrap.insertCase();
                    }
                }
                else if(selectedCustomSetting == 'Fines__c'){
                    /*if(newFines.Id != null){
                        update newFines;
                    } else{
                        insert newFines;
                    }*/
                    if(fineNewWrap.appId != null){
                        fineNewWrap.updateFine();
                    } else{
                        fineNewWrap.insertFine();
                    }
                }
                else if(selectedCustomSetting == 'SLA_Configuration__c'){
                    /*if(newSLA.Id != null){
                        update newSLA;
                    } else{
                        insert newSLA;
                    }*/
                    if(SlaNewWrap.appId != null){
                        SlaNewWrap.updateSla();
                    } else{
                        SlaNewWrap.insertSla();
                    }
                }
                else if(selectedCustomSetting == 'Visa_Check_Availability_API__c'){
                    /*if(newVisaCheck.Id != null){
                        update newVisaCheck;
                    } else{
                        insert newVisaCheck;
                    }*/
                    if(visaNewWrap.appId != null){
                        visaNewWrap.updateVisa();
                    } else{
                        visaNewWrap.insertVisa();
                    }
                }
            }
            selectedSettingName();
        } catch(Exception e){
            System.debug('##ERROR: '+e.getMessage());
        }
    }
    public class AppointmentWrapper {
        public Id appId {get;set;}
        public String appname {get;set;}
        public String apptime {get;set;}
        public Boolean appactive {get;set;}
        
        public AppointmentWrapper(Appointment_Timings__c apt) {
            this.appId = apt.Id;
            this.appname = apt.Name;
            this.apptime = apt.Time__c;
            this.appactive = apt.Active__c;
        }

        public AppointmentWrapper() {}

        public Appointment_Timings__c getAppointmentTimings() {
            return new Appointment_Timings__c(
                Id = this.appId,
                Name = this.appname,
                Time__c = this.apptime,
                Active__c = this.appactive
            );
        }

        public void updateAppointment() {
            Appointment_Timings__c apt = this.getAppointmentTimings();
            try{
                update apt;
               }
            catch(Exception e){}    
            this.appId = apt.Id;
        }
        public void insertAppointment() {
            Appointment_Timings__c apt = this.getAppointmentTimings();
            try{
                insert apt;
               }
            catch(Exception e){}
            this.appId = apt.Id;
        }

    }
    public class CaseWrapper{
        public Id appId {get;set;}
        public String appname {get;set;}
        public String appdesc {get;set;}
        public String apptitle {get;set;}
        public String appicon {get;set;}
        public String apprec {get;set;}
        public Decimal appSeqNum {get;set;}
        
        public CaseWrapper(Case_Types__c apt) {
            this.appId = apt.Id;
            this.appname = apt.Name;
            this.appdesc = apt.Case_Description__c;
            this.apptitle = apt.Case_Title__c;
            this.appicon = apt.Icon_Name__c;
            this.apprec = apt.Record_Type_API_Name__c;
            this.appSeqnum = apt.Seq_No__c;
        }

        public CaseWrapper() {}

        public Case_Types__c getcaseTimings() {
            return new Case_Types__c(
                Id = this.appId,
                Name = this.appname,
                Case_Description__c = this.appdesc,
                Case_Title__c = this.apptitle,
                Icon_Name__c = this.appicon,
                Record_Type_API_Name__c = this.apprec,
                Seq_No__c = this.appSeqnum
            );
        }

        public void updateCase() {
            Case_Types__c apt = this.getcaseTimings();
            try{
                update apt;
                }
            catch(Exception e){}
            this.appId = apt.Id;
        }
        public void insertCase() {
            Case_Types__c apt = this.getcaseTimings();
            try{
                insert apt;
               }
            catch(Exception e){} 
            this.appId = apt.Id;
        }

    }
    
    public class FinesWrapper{
        public Id appId {get;set;}
        public String appname {get;set;}
        public String appdoc {get;set;}
        public Decimal appfineday {get;set;}
        public Decimal appfinemonth {get;set;}
        public Decimal appfineamountmonth {get;set;}
        public Decimal appgrace {get;set;}
        public Decimal appmax {get;set;}
        public String appsr {get;set;}
        
        public FinesWrapper(Fines__c apt) {
            this.appId = apt.Id;
            this.appname = apt.Name;
            this.appdoc = apt.Document_Type__c;
            this.appfineday = apt.Fine_Amount__c;
            this.appfinemonth = apt.Fine_Amount_Per_Month__c;
            this.appfineamountmonth = apt.First_Month_Amount__c;
            this.appgrace = apt.Grace_Period__c;
            this.appmax = apt.Maximum_Fine_Amount__c;
            this.appsr = apt.SR_Record_Type_Name__c;

        }

        public FinesWrapper() {}

        public Fines__c getFineTimings() {
            return new Fines__c(
                Id = this.appId,
                Name = this.appname,
                Document_Type__c = this.appdoc,
                Fine_Amount__c = this.appfineday,
                Fine_Amount_Per_Month__c = this.appfinemonth,
                First_Month_Amount__c = this.appfineamountmonth,
                Grace_Period__c = this.appgrace,
                Maximum_Fine_Amount__c = this.appmax,
                SR_Record_Type_Name__c = this.appsr
            );
        }

        public void updateFine() {
            Fines__c apt = this.getFineTimings();
            try{
                update apt;
                }
            catch(Exception e){}
            this.appId = apt.Id;
        }
        public void insertFine() {
            Fines__c apt = this.getFineTimings();
            try{
                insert apt;
                }
            catch(Exception e){}
            this.appId = apt.Id;
        }

    }
    
    public class SlaWrapper{
        public Id appId {get;set;}
        public String appname {get;set;}
        public String appbussiness {get;set;}
        public String appqueue {get;set;}
        public Decimal appslahr {get;set;}
        public Decimal appslamin {get;set;}
        
        
        public SlaWrapper(SLA_Configuration__c apt) {
            this.appId = apt.Id;
            this.appname = apt.Name;
            this.appbussiness = apt.Business_Hour_Id__c;
            this.appqueue = apt.Queue_Name__c;
            this.appslahr = apt.SLA_Hours__c;
            this.appslamin = apt.SLA_Minutes__c;
        }

        public SlaWrapper() {}

        public SLA_Configuration__c getSlaTimings() {
            return new SLA_Configuration__c(
                Id = this.appId,
                Name = this.appname,
                Business_Hour_Id__c = this.appbussiness,
                Queue_Name__c = this.appqueue,
                SLA_Hours__c = this.appslahr,
                SLA_Minutes__c = this.appslamin
            );
        }

        public void updateSla() {
            SLA_Configuration__c apt = this.getSlaTimings();
            try{
                update apt;
                }
            catch(Exception e){}
            this.appId = apt.Id;
        }
        public void insertSla() {
            SLA_Configuration__c apt = this.getSlaTimings();
            try{
                insert apt;
                }
            catch(Exception e){}
            this.appId = apt.Id;
        }

    }
    public class VisaWrapper{
        public Id appId {get;set;}
        public String appname {get;set;}
        public String appapi {get;set;}
        
        public VisaWrapper(Visa_Check_Availability_API__c apt) {
            this.appId = apt.Id;
            this.appname = apt.Name;
            this.appapi = apt.API_Name__c;
        }

        public VisaWrapper() {}

        public Visa_Check_Availability_API__c getVisaTimings() {
            return new Visa_Check_Availability_API__c(
                Id = this.appId,
                Name = this.appname,
                API_Name__c = this.appapi
            );
        }

        public void updateVisa() {
            Visa_Check_Availability_API__c apt = this.getVisaTimings();
            try{
                update apt;
                }
            catch(Exception e){}
            this.appId = apt.Id;
        }
        public void insertVisa() {
            Visa_Check_Availability_API__c apt = this.getVisaTimings();
            try{
                insert apt;
                }
            catch(Exception e){}
            this.appId = apt.Id;
        }

    }
    
}
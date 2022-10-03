/*
    Author      : Kim Noceda
    Date        : 10-Oct-2017
    Description : Controller class to create an appointment on the portal based on the sr selected
    --------------------------------------------------------------------------------------
    v1.0    Durga    19-Aug-2019    Added Custom label to activate / deactivate the VIP Filter Logic
*/
public without sharing class CreateAppointmentController {

    public Appointment__c newAppointment {get;set;}
    public String selectedSR {get;set;}
    public String selectedDate {get;set;}
    public String selectedTimeVal {get;set;}
    public String selectedReason {get;set;}
    public Boolean selectCovidTest{get;set;}
    
    public List<SelectOption> availableSRs {get;set;}
    public List<SelectOption> availableAppDates {get;set;}
    public List<SelectOption> availableAppTimes {get;set;}
    
    public Set<Date> validDates;
    public Map<String,Id> timeUnqKeys;
    public Map<String,Appointment_Master__c> appointmentMasterMap;
    public Map<String,Boolean> biometricAppMasterMap;
    
    public Boolean hasError {get;set;}
    public Boolean hasErrorDate {get;set;}
    public Boolean hasErrorTime {get;set;}
    public Boolean hasErrorReason {get;set;}
    public Boolean hasErrorCovidTest {get;set;}
    public boolean hasErrorDateArrival{get;set;}
    public Boolean isMedClosed {get;set;}
    public Boolean hasPaymentFineError {get;set;}
    public boolean hasFutureDate {get;set;}
    public boolean hasSelectTravelOption{get;set;}
    
    public Map<Id,Id> medicalStepBySRMap;
    
    public String accId {get;set;}
    public String selectedSRName {get;set;}
    
    public List<HexaBPM__Service_Request__c> objCurrentSR {get;set;}
    public Boolean isInternalUser;
    public String internalSRId;
    public String hasPaymentFineErrorMsg {get;set;}
    public String DMLError {get;set;}
    public set<Date> RemDaysSet;

    public CreateAppointmentController(){
        isMedClosed = false;
        isInternalUser = false;
        String existAppointmentId = null;
        existAppointmentId = Apexpages.currentpage().getparameters().get('id');
        String accountStrParam = '';
        internalSRId = '';
        hasPaymentFineErrorMsg = '';
        DMLError = '';
        newAppointment = new Appointment__c();
        RemDaysSet = new set<Date>();
        list<User> lstUser = [Select contact.accountid from User where id =: Userinfo.getUserid() limit 1];
        if(!lstUser.IsEmpty()){
            if(lstUser[0].contact.accountid != null){
                accId = lstUser[0].contact.accountid;
            }else{
                isInternalUser = true;
                accountStrParam = Apexpages.currentpage().getparameters().get('accountid');
                if(accountStrParam != null && accountStrParam != '')
                    accId = accountStrParam;
                    
                string srStr = Apexpages.currentpage().getparameters().get('srid');
                if(srStr != null && srStr!='')
                    internalSRId = srStr;
            }
            System.debug('@@SR: '+internalSRId);
        }
        if(existAppointmentId != null && existAppointmentId != ''){
            newAppointment = [SELECT Id, Appointment_Time__c,Select_Travel_option__c, Recent_date_entered_in_U_A_E__c, Service_Request__c, Appointment_Master__c, Reschedule_Reason__c FROM Appointment__c WHERE Id = :existAppointmentId];
            selectedSR = newAppointment.Service_Request__c;
            //selectedSRName = newAppointment.Service_Request__r.Name;
            objCurrentSR = new List<HexaBPM__Service_Request__c>();
            objCurrentSR = [SELECT Id, Name, Title__c, First_Name__c, Last_Name__c FROM HexaBPM__Service_Request__c WHERE Id = :selectedSR LIMIT 1];
            selectedSRName = objCurrentSR[0].Name + ' - ' + objCurrentSR[0].Title__c + ' ' + objCurrentSR[0].First_Name__c + ' ' + objCurrentSR[0].Last_Name__c;
            isMedClosed = isMedAppointmentClosed(selectedSR);
        } else{
            availableSRs = getAvailableServiceRequests();
        }
        
        if(isMedClosed == false){
            availableAppDates = getAvailableDates();
            //createTimeWrapper();
            availableAppTimes = new List<SelectOption>();
            availableAppTimes.add(new SelectOption('','--None--'));
            hasErrorDate = false;
        }
    }
    
    public Boolean isMedAppointmentClosed(String srId){
        Boolean isMedApptmntClosed = false;
        for(HexaBPM__Step__c step : [SELECT Id, HexaBPM__SR__c 
                                        FROM HexaBPM__Step__c 
                                        WHERE HexaBPM__SR__c = :srId
                                        AND HexaBPM__Status__r.HexaBPM__Type__c = 'End' 
                                        AND HexaBPM__Step_Template__r.HexaBPM__Code__c = 'COLLECT_PASSPORT_FROM_ADGM']){
                                        
            isMedApptmntClosed = true;
        }
        return isMedApptmntClosed;
    }
    
    public List<SelectOption> getAvailableServiceRequests(){
        List<SelectOption> availableServiceRequests = new List<SelectOption>();
        Map<Id,HexaBPM__Service_Request__c> srMap = new Map<Id,HexaBPM__Service_Request__c>();
        Set<Id> srIds = new Set<Id>();
        availableServiceRequests.add(new SelectOption('', '--None--'));
        if(internalSRId!=null && internalSRId!=''){
            for(HexaBPM__Service_Request__c sr : [SELECT Id, Name, Biometric__c, First_Name__c, Last_Name__c 
                                                    FROM HexaBPM__Service_Request__c 
                                                    WHERE HexaBPM__SR_Template__r.HexaBPM__Sub_menu_section__c = 'Visa Services' 
                                                    AND HexaBPM__IsClosedStatus__c <> TRUE 
                                                    AND HexaBPM__External_Status_Name__c <> 'Draft' 
                                                    AND Id=:internalSRId 
                                                    AND HexaBPM__IsCancelled__c <> TRUE 
                                                    AND HexaBPM__Is_Rejected__c <> TRUE]){
                srIds.add(sr.Id);
                srMap.put(sr.Id, sr);
                //availableServiceRequests.add(new SelectOption(sr.Id, sr.Name));
            }
        }else{
            for(HexaBPM__Service_Request__c sr : [SELECT Id, Name, Biometric__c, First_Name__c, Last_Name__c 
                                                    FROM HexaBPM__Service_Request__c 
                                                    WHERE HexaBPM__SR_Template__r.HexaBPM__Sub_menu_section__c = 'Visa Services' 
                                                    AND HexaBPM__IsClosedStatus__c <> TRUE 
                                                    AND HexaBPM__External_Status_Name__c <> 'Draft' 
                                                    AND HexaBPM__Customer__c= :accId 
                                                    AND HexaBPM__IsCancelled__c <> TRUE 
                                                    AND HexaBPM__Is_Rejected__c <> TRUE]){
                srIds.add(sr.Id);
                srMap.put(sr.Id, sr);
                //availableServiceRequests.add(new SelectOption(sr.Id, sr.Name));
            }
        }
        medicalStepBySRMap = new Map<Id,Id>();
        for(HexaBPM__Step__c step : [SELECT Id, HexaBPM__SR__c, HexaBPM__SR__r.First_Name__c, HexaBPM__SR__r.Last_Name__c, HexaBPM__SR__r.Title__c
                                        FROM HexaBPM__Step__c 
                                        WHERE HexaBPM__SR__c IN :srIds 
                                        AND HexaBPM__Status__r.HexaBPM__Code__c = 'AWAITING_CONFIRMATION' 
                                        AND HexaBPM__Step_Template__r.HexaBPM__Code__c = 'BOOK_MEDICAL_APPOINTMENT']){
            String fullname = step.HexaBPM__SR__r.Title__c + ' ' +step.HexaBPM__SR__r.First_Name__c + ' ' +step.HexaBPM__SR__r.Last_Name__c;
            availableServiceRequests.add(new SelectOption(step.HexaBPM__SR__c,fullname + ' - ' + srMap.get(step.HexaBPM__SR__c).Name));
            medicalStepBySRMap.put(step.HexaBPM__SR__c, step.Id);
        }
        if(internalSRId!=null && internalSRId!='' && label.Medical_Appointment_Data_Fix=='Yes'){
            for(HexaBPM__Step__c step : [SELECT Id, HexaBPM__SR__c, HexaBPM__SR__r.First_Name__c, HexaBPM__SR__r.Last_Name__c, HexaBPM__SR__r.Title__c
                                        FROM HexaBPM__Step__c 
                                        WHERE HexaBPM__SR__c IN :srIds 
                                        AND HexaBPM__Status__r.HexaBPM__Code__c != 'AWAITING_CONFIRMATION' 
                                        AND HexaBPM__Step_Template__r.HexaBPM__Code__c = 'BOOK_MEDICAL_APPOINTMENT']){
                String fullname = step.HexaBPM__SR__r.Title__c + ' ' +step.HexaBPM__SR__r.First_Name__c + ' ' +step.HexaBPM__SR__r.Last_Name__c;
                availableServiceRequests.add(new SelectOption(step.HexaBPM__SR__c,fullname + ' - ' + srMap.get(step.HexaBPM__SR__c).Name));
                medicalStepBySRMap.put(step.HexaBPM__SR__c, step.Id);
            }
        }
        return availableServiceRequests;
    }
    
    public List<SelectOption> getAvailableDates(){
        List<SelectOption> availableDates = new List<SelectOption>();
        if(selectedSR == null){
            availableDates.add(new SelectOption('','--None--'));
            return availableDates;
        }
        //12-09-2021: Anu : Commented to remove Covid Restriction as requested
        /*if(newAppointment.Recent_date_entered_in_U_A_E__c == null){
            availableDates.add(new SelectOption('','--None--'));
            return availableDates;
        }*/
        Integer daysStart = 0;

        Integer daysDuration = Integer.ValueOf(Label.Config_Appointment_Days_Duration);
        //12-09-2021: Anu : Commented to remove Covid Restriction as requested
        //Date startDate = System.Today().addDays(daysStart);
        ///12-09-2021: Anu : Added to remove Covid Restriction as requested
        Date startDate = date.Today().addDays(Integer.valueof(label.CoronaDays));
        //12-09-2021: Anu : Commented to remove Covid Restriction as requested
        //Old Comment: Due to corona effect the below temp changes added..
        /*Date daDate = newAppointment.Recent_date_entered_in_U_A_E__c;
        Date CompDate = Date.Today().addDays(-14);
        boolean hasRecentlyEntered = false;
        if(daDate != null && daDate < CompDate){
            startDate = date.Today().addDays(daysStart);
            system.debug('=====if===='+startDate);
        }else if(daDate != null && daDate > CompDate){
            startDate = daDate.addDays(Integer.valueof(label.CoronaDays));
            hasRecentlyEntered = true;
            system.debug('=====else===='+startDate);
        }*/
        // ********** End ***********************************
        
        
        selectedDate = '';

        validDates = new Set<Date>();
        validDates = getDateSetList(startDate, daysDuration);
        system.debug('======Valida Dates are===='+validDates);
        if(validDates == null)
            validDates = new Set<Date>();
        availableDates.add(new SelectOption('','--None--'));
        
        Integer skipDays = Integer.ValueOf(Label.Config_Appointment_Days_After_Today) + 1;
       // if(hasRecentlyEntered){
        //  skipDays = 0;
        //}
        system.debug('======skip days===='+skipDays);
        Integer count = 0;
        for(Date d : validDates)
        {
            if(isInternalUser == false && skipDays > count){
                count++;
                continue;
            }
            if(!RemDaysSet.contains(d)){
                Date newDate = d;
                String newDateStr = String.valueOf(newDate.day())+'/'+String.valueOf(newDate.month())+'/'+String.valueOf(newDate.year());
                availableDates.add(new SelectOption(newDateStr,newDateStr));
            }
            //availableDates.add(new SelectOption(newDate.format(),newDate.format()));
        }
        System.debug('@@DATES: '+availableDates);
        return availableDates;
    }
    
    public Set<Date> getDateSetList(Date startDate, Integer daysDuration){
        system.debug('=======start Date is======='+startDate);
        Set<Date> vDates = new Set<Date>();
        timeUnqKeys = new Map<String,Id>();
        biometricAppMasterMap = new Map<String,Boolean>();
        List<HexaBPM__Service_Request__c> objServiceRequest = [SELECT Id, Biometric__c, VIP__c FROM HexaBPM__Service_Request__c WHERE Id = :selectedSR];
        List<Appointment_Master__c> aMaster = new List<Appointment_Master__c>();
        if(objServiceRequest.size() > 0){
            String queryStr = 'SELECT Id, Date__c, Date_Time_Unique_Key__c, Remaining_Seats_Available__c, Biometrics_Required__c';
            queryStr = queryStr + ' FROM Appointment_Master__c';
            queryStr = queryStr + ' WHERE Date__c >= :startDate AND Status__c = \'Active\'';//AND Remaining_Seats_Available__c > 0
            
            /*//Commented this bcoz all the Appointment Masters in the system are with Bio-Metric
            else{
                queryStr = queryStr + ' AND Biometrics_Required__c = false';
            }
            */
            
            if(label.VIP_Medical_Appointment!='Disabled'){//v1.0
                if(objServiceRequest[0].Biometric__c == 'Yes'){
                    queryStr = queryStr + ' AND Biometrics_Required__c = true';
                }
                if(objServiceRequest[0].VIP__c == 'Yes'){
                    queryStr = queryStr + ' AND VIP__c = true';
                }else{
                    queryStr = queryStr + ' AND VIP__c = false';
                }
            }
            
            queryStr = queryStr + 'AND Remaining_Seats_Available__c > 0 ORDER BY Date__c ASC';
            
            aMaster = Database.query(queryStr);
            
            /*if(objServiceRequest[0].Biometric__c == 'Yes'){
                aMaster = [SELECT Id, Date__c, Date_Time_Unique_Key__c, Remaining_Seats_Available__c, Biometrics_Required__c  
                           FROM Appointment_Master__c WHERE Date__c >= :startDate AND Remaining_Seats_Available__c > 0 AND Biometrics_Required__c = true 
                           ORDER BY Date__c ASC];
            } else {
                aMaster = [SELECT Id, Date__c, Date_Time_Unique_Key__c, Remaining_Seats_Available__c, Biometrics_Required__c  
                           FROM Appointment_Master__c WHERE Date__c >= :startDate AND Remaining_Seats_Available__c > 0 
                           ORDER BY Date__c ASC];
            }*/
        } else {
            aMaster = [SELECT Id, Date__c, Date_Time_Unique_Key__c, Remaining_Seats_Available__c, Biometrics_Required__c  
                       FROM Appointment_Master__c WHERE Date__c >= :startDate AND Remaining_Seats_Available__c > 0 And Status__c = 'Active'
                       ORDER BY Date__c ASC];
        }
        Integer ctr=0;
        System.debug('@@A-MASTER: '+aMaster.size());
        
        for(Appointment_Master__c appMaster : aMaster)
        {
            system.debug('====Rem count==='+appMaster.Remaining_Seats_Available__c+'====Date=='+appMaster.Date__c);
            if(appMaster.Remaining_Seats_Available__c < 1){
                RemDaysSet.add(appMaster.Date__c);
            }
            ctr++;
            if(vDates.size() < (daysDuration+1)){
                if(!vDates.contains(appMaster.Date__c)){
                    vDates.add(appMaster.Date__c);
                }
                timeUnqKeys.put(appMaster.Date_Time_Unique_Key__c,appMaster.Id);
                biometricAppMasterMap.put(appMaster.Date_Time_Unique_Key__c, appMaster.Biometrics_Required__c);
            }
            if(vDates.size() == daysDuration){
                return vDates;
            }
            if(ctr == aMaster.size()){
                system.debug('##RETURN');
                return vDates;
            }
            System.debug('@@CTR: '+ctr);
        }
        system.debug('====Rem days set==='+RemDaysSet);
        return null;
    }
    
    public void createDates(){
        availableAppDates = getAvailableDates();
        //createTimeWrapper();
        availableAppTimes = new List<SelectOption>();
        availableAppTimes.add(new SelectOption('','--None--'));
        hasErrorDate = false;
    }
    
    public void createTimeWrapper(){
        selectedTimeVal = '';
        System.debug('&&SelectedDate: '+selectedDate);
        availableAppTimes = new List<SelectOption>();
        if(selectedDate != null && selectedDate != ''){
            availableAppTimes.add(new SelectOption('','--None--'));
            for(String key : timeUnqKeys.keyset()){
                System.debug('**KEy: '+key);
                /*if(key.contains(selectedDate)){
                    System.debug('**CONTAINS: '+key);
                    String timeStr = key.subStringAfter('_');
                    availableAppTimes.add(new SelectOption(timeStr,timeStr));
                }*/
                String keyStr = key.subStringBefore('_');
                if(keyStr == selectedDate){
                    System.debug('**CONTAINS: '+key);
                    String timeStr = key.subStringAfter('_');
                    availableAppTimes.add(new SelectOption(timeStr,timeStr));
                }
            }
        }
        System.debug('&&SelectedTIME: '+selectedTimeVal);
    }
    
    public PageReference saveAppointment(){
        hasError = false;
        hasErrorDate = false;
        hasErrorTime = false;
        hasErrorReason = false;
        hasErrorCovidTest = false;
        hasPaymentFineError = false;
        hasErrorDateArrival = false;
        hasFutureDate = false;
        hasSelectTravelOption = false;
        DMLError = '';
        
        System.debug('newAppointment.Id==>'+newAppointment.Id);
        System.debug('selectedSR==>'+selectedSR);
        System.debug('selectedDate==>'+selectedDate);
        System.debug('selectedTimeVal==>'+selectedTimeVal);
        System.debug('time==>'+newAppointment.Recent_date_entered_in_U_A_E__c);
        
        if(newAppointment.Id == null){
            if(selectedSR == null || selectedSR == ''){
                hasError = true;
            }
            if(selectedDate == null || selectedDate == ''){
                hasErrorDate = true;
            }
            if(selectedTimeVal == null || selectedTimeVal == ''){
                hasErrorTime = true;
            }
            /*if(newAppointment.Recent_date_entered_in_U_A_E__c == null){
                hasErrorDateArrival = true;
            }*/
            if(newAppointment.Recent_date_entered_in_U_A_E__c != null && newAppointment.Recent_date_entered_in_U_A_E__c > Date.today()){
                hasFutureDate = true;
            }
            if(newAppointment.Select_Travel_option__c == null || newAppointment.Select_Travel_option__c == ''){
                hasSelectTravelOption = true;
            }
            
        } else{
            if(selectedDate == null || selectedDate == ''){
                hasErrorDate = true;
            }
            if(selectedTimeVal == null || selectedTimeVal == ''){
                hasErrorTime = true;
            }
            if(selectedReason == null || selectedReason == ''){
                hasErrorReason = true;
            }
            
            /*if(newAppointment.Recent_date_entered_in_U_A_E__c == null){
                hasErrorDateArrival = true;
            }*/
            if(newAppointment.Recent_date_entered_in_U_A_E__c != null && newAppointment.Recent_date_entered_in_U_A_E__c > Date.today()){
                hasFutureDate = true;
            }
            if(newAppointment.Select_Travel_option__c == null || newAppointment.Select_Travel_option__c == ''){
                hasSelectTravelOption = true;
            }
        }
        
        if(selectCovidTest == false){
            hasErrorCovidTest = true;
        }
        system.debug('@@SELECTED VALUE: '+selectedTimeVal);
        system.debug('@@selectCovidTest VALUE: '+selectCovidTest);
        System.debug('##SELDATE: '+selectedDate);
        
        if(hasError == false && hasErrorDate == false && hasErrorTime == false && hasErrorReason == false && hasErrorDateArrival == false && hasFutureDate == false && hasSelectTravelOption ==false && hasErrorCovidTest == false){
            if(selectedSR!=null){
                String openPaymentValidation = ApexCodeUtility.CheckOpenFinePaymentStep(selectedSR);
                if(openPaymentValidation!='Success'){
                    hasPaymentFineError=true;
                    hasPaymentFineErrorMsg = openPaymentValidation;
                    return null;
                }
            }
            Savepoint MedicalConfirmationSP = Database.setSavepoint();
            if(newAppointment.Id == null){
                newAppointment.Service_Request__c = selectedSR;
                List<HexaBPM__Service_Request__c> srNumber = [SELECT Id, HexaBPM__Customer__c FROM HexaBPM__Service_Request__c WHERE Id = :selectedSR];
                newAppointment.Customer__c = srNumber[0].HexaBPM__Customer__c;
                newAppointment.Appointment_Time__c = selectedTimeVal;
                String[] dateStr = selectedDate.split('/');
                Date newSelectedDate = Date.newInstance(Integer.valueOf(dateStr[2]),Integer.valueOf(dateStr[1]),Integer.valueOf(dateStr[0]));
                newAppointment.Appointment_Date__c = newSelectedDate;
                //newAppointment.Appointment_Date__c = Date.parse(selectedDate);
                String keyStr = selectedDate + '_' + selectedTimeVal;
                newAppointment.Appointment_Master__c = timeUnqKeys.get(keyStr);
                newAppointment.Step__c = medicalStepBySRMap.get(selectedSR);
                system.debug('selectCovidTest'+selectCovidTest);
                
                newAppointment.Negative_Covid_19_PRC_Test_Result__c = selectCovidTest;
                try{
                    insert newAppointment;
                    system.debug('test+++'+newAppointment.id);
                    /*
                    List<HexaBPM__Status__c> statusAppointmentConfirmedId = [SELECT Id, HexaBPM__Code__c 
                                                                    FROM HexaBPM__Status__c 
                                                                    WHERE HexaBPM__Code__c = 'APPOINTMENT_CONFIRMED' AND HexaBPM__Type__c = 'End'];
                                                                    
                    List<HexaBPM__Step__c> actionItem = [SELECT Id, HexaBPM__Status__c, Is_Medical_Appointment_Booking_Step__c FROM HexaBPM__Step__c WHERE HexaBPM__SR__c =:selectedSR AND Id = :newAppointment.Step__c];
                    actionItem[0].HexaBPM__Status__c = statusAppointmentConfirmedId[0].Id;
                    
                    System.debug('@@STATUSCONFIRMED: '+statusAppointmentConfirmedId);
                    System.debug('@@ACTIONITEM: '+actionItem);
                    actionItem[0].Is_Medical_Appointment_Booking_Step__c = TRUE;
                    update actionItem;
                    */
                    if(medicalStepBySRMap.get(selectedSR)!=null){
                        HexaBPM__Step__c MedicalStep = new HexaBPM__Step__c();
                        for(HexaBPM__Step__c stp:[Select Id,HexaBPM__SR_Step__c,HexaBPM__Status__c from HexaBPM__Step__c where Id=:medicalStepBySRMap.get(selectedSR)]){
                            MedicalStep = stp;
                        }
                        HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c(Id=selectedSR);
                        for(HexaBPM__Step_Transition__c stptran : [select HexaBPM__SR_Status_Internal__c,HexaBPM__SR_Status_External__c,HexaBPM__Transition__r.HexaBPM__To__c,HexaBPM__Transition__r.HexaBPM__From__c from HexaBPM__Step_Transition__c where HexaBPM__Transition__c!=null and HexaBPM__SR_Step__c=:MedicalStep.HexaBPM__SR_Step__c and 
                        HexaBPM__Transition__r.HexaBPM__From__c=:MedicalStep.HexaBPM__Status__c and HexaBPM__Transition__r.HexaBPM__To__r.HexaBPM__Type__c = 'End' limit 1]){
                            MedicalStep.HexaBPM__Status__c = stptran.HexaBPM__Transition__r.HexaBPM__To__c;
                            MedicalStep.Is_Medical_Appointment_Booking_Step__c = true;
                            if(stptran.HexaBPM__SR_Status_Internal__c!=null)
                                objSR.HexaBPM__Internal_SR_Status__c = stptran.HexaBPM__SR_Status_Internal__c;
                            if(stptran.HexaBPM__SR_Status_External__c!=null)
                                objSR.HexaBPM__External_SR_Status__c = stptran.HexaBPM__SR_Status_External__c;
                            break;
                        }
                        if(objSR.HexaBPM__Internal_SR_Status__c!=null || objSR.HexaBPM__External_SR_Status__c!=null)
                            update objSR;
                        
                        update MedicalStep;
                    }
                }catch(DMLException e){
                    System.debug('@@ERROR: '+e.getMessage());
                    Database.rollback(MedicalConfirmationSP);
                    DMLError = e.getdmlMessage(0)+'';
                    if(DMLError==null){
                        DMLError = e.getMessage()+'';
                    }
                }
            } else{
                newAppointment.Appointment_Time__c = selectedTimeVal;
                String[] dateStr = selectedDate.split('/');
                Date newSelectedDate = Date.newInstance(Integer.valueOf(dateStr[2]),Integer.valueOf(dateStr[1]),Integer.valueOf(dateStr[0]));
                newAppointment.Appointment_Date__c = newSelectedDate;
                //newAppointment.Appointment_Date__c = Date.parse(selectedDate);
                String keyStr = selectedDate + '_' + selectedTimeVal;
                newAppointment.Appointment_Master__c = timeUnqKeys.get(keyStr);
                newAppointment.Reschedule_Reason__c = selectedReason;
                
                try{
                    update newAppointment;
                    
                    /*List<HexaBPM__Status__c> statusAwaitingConfirmationId = [SELECT Id, HexaBPM__Code__c 
                                                                    FROM HexaBPM__Status__c 
                                                                    WHERE HexaBPM__Code__c = 'AWAITING_CONFIRMATION' AND HexaBPM__Type__c = 'Start'];
                                                                    
                    List<HexaBPM__Step__c> actionItem = [SELECT Id, HexaBPM__Status__c FROM HexaBPM__Step__c WHERE HexaBPM__SR__c =:selectedSR AND Id = :newAppointment.Step__c];
                    actionItem[0].HexaBPM__Status__c = statusAwaitingConfirmationId[0].Id;
                    
                    System.debug('@@STATUSCONFIRMED: '+statusAwaitingConfirmationId);
                    System.debug('@@ACTIONITEM: '+actionItem);
                    update actionItem;*/
                } catch(DMLException e){
                    Database.rollback(MedicalConfirmationSP);
                    DMLError = e.getdmlMessage(0)+'';
                    if(DMLError==null){
                        DMLError = e.getMessage()+'';
                    }
                }
            }
            
            if(isInternalUser == false){
                //PageReference pageRef = new PageReference('/apex/home');
                PageReference pageRef = new PageReference('/'+selectedSR);
                pageRef.setRedirect(true);
                return pageRef;
            } else{
                PageReference pageRef = new PageReference('/'+selectedSR);
                pageRef.setRedirect(true);
                return pageRef;
            }
        }
        
        return null;
    }
    
    public PageReference cancelApp(){
        if(isInternalUser == false){
            if(selectedSR!=''){
                PageReference pageRef = new PageReference('/apex/home');
                pageRef.setRedirect(true);
                return pageRef;
            }else{
                PageReference pageRef = new PageReference('/'+selectedSR);
                pageRef.setRedirect(true);
                return pageRef;
            }
            
        } else{
            PageReference pageRef = new PageReference('/'+internalSRId);
            pageRef.setRedirect(true);
            return pageRef;
        }
    }
}
@isTest
private class CreateAppointmentControllerTest{


    static testmethod void createAppointmentTestSave(){
        
        List<Appointment_Master__c> newAppointmentMasters = TestUtility.createAppointmentMasters(System.Today().addDays(7),System.Today().addDays(14),'9:00 AM',10);
        for(Appointment_Master__c appMaster : newAppointmentMasters){
            appMaster.Status__c = 'Active';
            appMaster.VIP__c = true;
        }
        insert newAppointmentMasters;
        
        for(Appointment_Master__c app : [Select Date_Time_Unique_Key__c from Appointment_Master__c ])
        {
            system.debug(app.Date_Time_Unique_Key__c);
        }
        //system.debug('====='+
        List<HexaBPM__Service_Request__c> newSRs = TestUtility.createSR(1,Label.SR_Guest_User_Access_Request);
        newSRs[0].First_Name__c = 'Test First';
        newSRs[0].HexaBPM__Email__c = 'test@test.com';
        newSRs[0].HexaBPM__Send_SMS_to_Mobile__c = '+971564744747';
        newSRs[0].Company_Name__c = 'Test Company';
        insert newSRs;
        
        Test.startTest();
            CreateAppointmentController createAppCtrlr = new CreateAppointmentController();
            createAppCtrlr.newAppointment.Service_Request__c = newSRs[0].Id;
            
            Id bussHoursId = [SELECT Id FROM BusinessHours LIMIT 1].Id;
            Datetime availDate = BusinessHours.nextStartDate(bussHoursId,System.Today().addDays(7));
            Date newDate = Date.newInstance(availDate.year(),availDate.month(),availDate.day());
            
            String dateStr = newDate.format();
            createAppCtrlr.selectedDate = dateStr;
            //createAppCtrlr.createTimeWrapper();
            
            createAppCtrlr.selectedTimeVal = '9:00 AM';
            createAppCtrlr.selectedSR = newSRs[0].id;
            createAppCtrlr.cancelApp();
            createAppCtrlr.saveAppointment();
            
            createAppCtrlr.selectedSR = '';
            createAppCtrlr.cancelApp();
            
            createAppCtrlr.createDates();
            createAppCtrlr.isMedAppointmentClosed(newSRs[0].id);
        Test.stopTest();
    }
    
    
    
    static testmethod void createAppointmentTestSave4(){
        
        List<Appointment_Master__c> newAppointmentMasters = TestUtility.createAppointmentMasters(System.Today().addDays(7),System.Today().addDays(14),'9:00 AM',10);
        for(Appointment_Master__c appMaster : newAppointmentMasters){
            appMaster.Status__c = 'Active';
        }
        insert newAppointmentMasters;
        
        HexaBPM__SR_Template__c template = new HexaBPM__SR_Template__c(Name='test',HexaBPM__SR_RecordType_API_Name__c='test',HexaBPM__Sub_menu_section__c='Visa Services');
        insert template;
        
        List<HexaBPM__Service_Request__c> newSRs = TestUtility.createSR(1,Label.SR_Guest_User_Access_Request);
        newSRs[0].First_Name__c = 'Test First';
        newSRs[0].HexaBPM__Email__c = 'test@test.com';
        newSRs[0].HexaBPM__Send_SMS_to_Mobile__c = '+971564744747';
        newSRs[0].Company_Name__c = 'Test Company';
        newSRs[0].Biometric__c = 'No';
        newSRs[0].HexaBPM__SR_Template__c = template.id;
        newSRs[0].I_Agree__c  = true;
        insert newSRs;
        
        HexaBPM__Status__c status = new HexaBPM__Status__c(HexaBPM__Code__c='AWAITING_CONFIRMATION');
        insert status;
        
        HexaBPM__Step_Template__c temp = new HexaBPM__Step_Template__c(HexaBPM__Code__c='BOOK_MEDICAL_APPOINTMENT',HexaBPM__Step_RecordType_API_Name__c='Test');
        insert temp;
        
        HexaBPM__Step__c step = new HexaBPM__Step__c(HexaBPM__SR__c=newSRs[0].id,HexaBPM__Status__c = status.id,HexaBPM__Step_Template__c=temp.id
        );
        insert step;
        
        Appointment__c apptment = new Appointment__c();
        apptment.Appointment_Master__c = newAppointmentMasters[0].Id;
        apptment.Service_Request__c = newSRs[0].Id;
        apptment.Recent_date_entered_in_U_A_E__c = Date.today();
        apptment.Select_Travel_option__c = 'Travel by self';
        insert apptment;
        
        Test.startTest();
            
            system.currentPageReference().getParameters().put('Id', apptment.Id);
            CreateAppointmentController createAppCtrlr = new CreateAppointmentController();
            createAppCtrlr.newAppointment.Recent_date_entered_in_U_A_E__c = Date.today();
            createAppCtrlr.newAppointment.Select_Travel_option__c = 'Travel by self'; 
            createAppCtrlr.newAppointment.Service_Request__c = newSRs[0].Id;
            createAppCtrlr.getAvailableServiceRequests();
            createAppCtrlr.saveAppointment();
        Test.stopTest();
    }
    
    static testmethod void createAppointmentTestSave1()
    {
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 
        
        HexaBPM__SR_Template__c template = new HexaBPM__SR_Template__c(Name='test',HexaBPM__SR_RecordType_API_Name__c='test',HexaBPM__Sub_menu_section__c='Visa Services');
        insert template;
        
        List<HexaBPM__Service_Request__c> newSRs = TestUtility.createSR(1,Label.SR_Guest_User_Access_Request);
        newSRs[0].First_Name__c = 'Test First';
        newSRs[0].HexaBPM__Email__c = 'test@test.com';
        newSRs[0].HexaBPM__Send_SMS_to_Mobile__c = '+971564744747';
        newSRs[0].Company_Name__c = 'Test Company';
        newSRs[0].Biometric__c = 'No';
        newSRs[0].HexaBPM__SR_Template__c = template.id;
        newSRs[0].I_Agree__c  = true;
        newSRs[0].VIP__c = 'Yes';
        newSRs[0].HexaBPM__Customer__c = newAccounts[0].Id;
        insert newSRs;
        
        List<Appointment_Master__c> newAppointmentMasters = TestUtility.createAppointmentMasters(System.Today().addDays(7),System.Today().addDays(14),'9:00 AM',10);
        for(Appointment_Master__c appMaster : newAppointmentMasters){
            appMaster.Status__c = 'Active';
            appMaster.VIP__c = true;
        }
        insert newAppointmentMasters;
        
        HexaBPM__Status__c status = new HexaBPM__Status__c(HexaBPM__Code__c='AWAITING_CONFIRMATION');
        insert status;
        
        HexaBPM__Step_Template__c temp = new HexaBPM__Step_Template__c(HexaBPM__Code__c='BOOK_MEDICAL_APPOINTMENT',HexaBPM__Step_RecordType_API_Name__c='Test');
        insert temp;
        
        HexaBPM__Step__c step = new HexaBPM__Step__c(HexaBPM__SR__c=newSRs[0].id,HexaBPM__Status__c = status.id,HexaBPM__Step_Template__c=temp.id
        );
        insert step;
        
        Test.startTest();
            
            system.currentPageReference().getParameters().put('accountid', newAccounts[0].Id);
            system.currentPageReference().getParameters().put('srid', newSRs[0].Id);
            CreateAppointmentController createAppCtrlr = new CreateAppointmentController();
            createAppCtrlr.newAppointment.Recent_date_entered_in_U_A_E__c = Date.today().addDays(-30);
            createAppCtrlr.newAppointment.Select_Travel_option__c = 'Travel by self';
            createAppCtrlr.newAppointment.Select_Travel_option__c= 'Travel by self';
            createAppCtrlr.selectedSR = newSRs[0].id;
            list<selectoption> options = createAppCtrlr.getAvailableDates();
            system.debug('==options =='+options );
            createAppCtrlr.selectedDate = options[1].getValue();
            createAppCtrlr.createTimeWrapper();
            createAppCtrlr.selectedTimeVal = '9:00 AM';
            createAppCtrlr.saveAppointment();
            createAppCtrlr.internalSRId = newSRs[0].Id;
            createAppCtrlr.getAvailableServiceRequests();
            
            createAppCtrlr.selectedSR = newSRs[0].Id;
            createAppCtrlr.isInternalUser = false;
            createAppCtrlr.cancelApp();
        
        
            createAppCtrlr.isInternalUser = false;
            createAppCtrlr.selectedSR = '';
            createAppCtrlr.cancelApp();
            
            Test.stopTest();
        
    }
}
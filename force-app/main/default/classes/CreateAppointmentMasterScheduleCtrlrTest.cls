@isTest
private class CreateAppointmentMasterScheduleCtrlrTest{

    static testmethod void createMasterTestError(){
    
        Appointment_Timings__c appTimings = new Appointment_Timings__c();
        appTimings.Name = '1';
        appTimings.Time__c = '9:00 AM';
        appTimings.Active__c = TRUE;
        insert appTimings;
    
        Test.startTest();
            Appointment_Master__c appMaster = new Appointment_Master__c();
            ApexPages.StandardController sc = new ApexPages.StandardController(appMaster);
            CreateAppointmentMasterScheduleCtrlr createAppMaster = new CreateAppointmentMasterScheduleCtrlr(sc);
            createAppMaster.startAMDate.Date__c = System.Today().addDays(4);
            createAppMaster.endAMDate.Date__c = System.Today();
            createAppMaster.saveAppointmentMaster();
        Test.stopTest();
    }
    
    static testmethod void createMasterTestSave(){
    
        Appointment_Timings__c appTimings = new Appointment_Timings__c();
        appTimings.Name = '1';
        appTimings.Time__c = '9:00 AM';
        appTimings.Active__c = TRUE;
        insert appTimings;
    
        Test.startTest();
            Appointment_Master__c appMaster = new Appointment_Master__c();
            ApexPages.StandardController sc = new ApexPages.StandardController(appMaster);
            CreateAppointmentMasterScheduleCtrlr createAppMaster = new CreateAppointmentMasterScheduleCtrlr(sc);
            createAppMaster.startAMDate.Date__c = System.Today();
            createAppMaster.endAMDate.Date__c = System.Today().addDays(15);
            createAppMaster.timeWrapList[0].isSelected = true;
            createAppMaster.timeWrapList[0].numOfSeats = 10;
            createAppMaster.saveAppointmentMaster();
        Test.stopTest();
    }
    /*static testmethod void createMasterTestSavenull(){
    
        Appointment_Timings__c appTimings = new Appointment_Timings__c();
        appTimings.Name = '1';
        appTimings.Time__c = '9:00 AM';
        appTimings.Active__c = TRUE;
        insert appTimings;
    
        Test.startTest();
            Appointment_Master__c appMaster = new Appointment_Master__c();
            ApexPages.StandardController sc = new ApexPages.StandardController(appMaster);
            CreateAppointmentMasterScheduleCtrlr createAppMaster = new CreateAppointmentMasterScheduleCtrlr(sc);
            createAppMaster.startAMDate.Date__c = System.Today();
            createAppMaster.endAMDate.Date__c = System.Today().addDays(-6);
            createAppMaster.timeWrapList[0].isSelected = true;
            createAppMaster.timeWrapList[0].numOfSeats = 10;
            createAppMaster.saveAppointmentMaster();
        Test.stopTest();
    }*/
}
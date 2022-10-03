@isTest
public with sharing class ManageCustomSettingsControllerTest {
    
    
    public static testmethod void testcase(){
       // init();
       Appointment_Timings__c appt = new Appointment_Timings__c();
       appt.Active__c = true;
       appt.Time__c = '10:00 AM';
       appt.Name = '1';
       insert appt;
       
       String str = appt.Name;
       
       Case_Types__c ct = new Case_Types__c();
       ct.Seq_No__c   = 1;
       ct.Case_Description__c= 'For all queries related to portal balance, service charges, fines and refunds.';
       ct.Case_Title__c= 'Payment';
       ct.Icon_Name__c= 'icon-adgm-payment';
       ct.Record_Type_API_Name__c= 'Payment';
       ct.Name = 'Type 1';
       insert ct;
       
       String str1 = ct.Name;
       
       Fines__c fine = new Fines__c();
       fine.Name = 'Dependents EID - Cancel Visa';
       fine.Document_Type__c = 'Emirates ID';
       fine.Fine_Amount__c = 20;
       fine.Fine_Amount_Per_Month__c = null;
       fine.First_Month_Amount__c = null;
       fine.Grace_Period__c=  30;
       fine.Maximum_Fine_Amount__c = 1000;
       fine.SR_Record_Type_Name__c = 'Dependent_Visa_Cancellation';
       insert fine;
       
       String str2 = fine.Name;
       
       SLA_Configuration__c sla = new SLA_Configuration__c();
       sla.Name = 'Business Admin Team';
       sla.Business_Hour_Id__c = '01m2500000002uW';
       sla.Queue_Name__c = 'Business Admin Team';
       sla.SLA_Hours__c = 16;
       sla.SLA_Minutes__c = 960;
       insert sla;
       String str3 = sla.Name;
       
       Visa_Check_Availability_API__c visa = new Visa_Check_Availability_API__c();
       visa.Name = 'Employee Work Permit (UAE/GCC)';
       visa.API_Name__c = 'Employee_Work_Permit_UAE_GCC_National_New';
       insert visa;
       String str4 = visa.Name;
       
        
            
        ManageCustomSettingsController con = new ManageCustomSettingsController();
        //List<HexaBPM__Step__c> lstOfSteps = [SELECT Id,HexaBPM__SR__r.HexaBPM__Contact__c,HexaBPM__SR__r.Job_Title__c,HexaBPM__SR__r.Gross_Monthly_Salary__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        //con.EvaluateCustomCode(null,lstOfSteps[0]);
        
        
        con.selectedCustomSetting = 'Appointment_Timings__c';
        con.initialiseNewRecords();
        con.selectedSettingName();
        con.cancelEdit();
        con.deleteCSRecord();
        con.csRecordToBeEdited = str;
        con.editCSRecord();
        con.newCSRecord();
        con.saveRecord();
        
        con.selectedCustomSetting = 'Case_Types__c';
        con.initialiseNewRecords();
        con.selectedSettingName();
        con.cancelEdit();
        con.deleteCSRecord();
        con.csRecordToBeEdited = str1;
        con.editCSRecord();
        con.newCSRecord();
        con.saveRecord();
        
        con.selectedCustomSetting = 'Fines__c';
        con.initialiseNewRecords();
        con.selectedSettingName();
        con.cancelEdit();
        con.deleteCSRecord();
        con.csRecordToBeEdited = str2;
        con.editCSRecord();
        con.newCSRecord();
        con.saveRecord();
        
        con.selectedCustomSetting = 'SLA_Configuration__c';
        con.initialiseNewRecords();
        con.selectedSettingName();
        con.cancelEdit();
        con.deleteCSRecord();
        con.csRecordToBeEdited = str3;
        con.editCSRecord();
        con.newCSRecord();
        con.saveRecord();
        
        con.selectedCustomSetting = 'Visa_Check_Availability_API__c';
        con.initialiseNewRecords();
        con.selectedSettingName();
        con.cancelEdit();
        con.deleteCSRecord();
        con.csRecordToBeEdited = str4;
        con.editCSRecord();
        con.newCSRecord();
        con.saveRecord();
        
    }
   
}
@isTest(SeeAllData=false)
public class LeadTriggerHandlerTest{
   
    static Lead testLead = new Lead();
   
    static testMethod void Execute_BI_Test(){

        Id RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead Contact').getRecordTypeId();
       
        Trigger_Settings__c ts = new Trigger_Settings__c();
        ts.Name = 'LeadTrigger';
        ts.Is_Active__c = true;
        insert ts;
       
        List<Map_PrimaryContact_Setting__c> listPrimaryContact = new List<Map_PrimaryContact_Setting__c>();
        Map_PrimaryContact_Setting__c objPrimaryContact = new Map_PrimaryContact_Setting__c();
        objPrimaryContact.Name = 'FirstName';
        objPrimaryContact.SourceFieldName__c = 'FirstName';
        objPrimaryContact.TargetObjectField__c = 'FirstName';
        listPrimaryContact.add(objPrimaryContact);
       
        objPrimaryContact = new Map_PrimaryContact_Setting__c();
        objPrimaryContact.Name = 'Lead_City__c';
        objPrimaryContact.SourceFieldName__c = 'Lead_City__c';
        objPrimaryContact.TargetObjectField__c = 'Lead_City__c';
        listPrimaryContact.add(objPrimaryContact);
        objPrimaryContact = new Map_PrimaryContact_Setting__c();
        objPrimaryContact.Name = 'Lead_Country__c';
        objPrimaryContact.SourceFieldName__c = 'Lead_Country__c';
        objPrimaryContact.TargetObjectField__c = 'Lead_Country__c';
        listPrimaryContact.add(objPrimaryContact);
        insert objPrimaryContact;
       
       test.startTest();

       
        testLead.Company = 'Test Company 501';
        testLead.License_Number__c = 'Test-501';
        testLead.FirstName = 'Primary';
        testLead.LastName = '501';
        testLead.email = 'primary@501.com';
        testLead.Received_Consent__c = 'Full Contact Business Card';
        testLead.Received_Consent_Date__c = date.today();
        testLead.Role__c ='CEO';
        testLead.LeadSource = 'BD/FCD Direct Approach';
        testLead.Status = 'New';
        testLead.Category__c = 'Financial';
        testLead.Main_Sector__c = 'Banking';
        testLead.Industry = 'Commerce';
        testLead.Country = 'Pakistan';
        testLead.City = 'Lahore';
        testLead.Lead_City__c = 'Lahore';
        testLead.Lead_Country__c = 'Pakistan';
        testLead.First_Contact_Date__c =date.today();
        testLead.Last_Contact_Date__c = date.today();
       
        // runs LeadTriggerHandler.Execute_BI
        insert testLead;
       
        Note__c n = new Note__c();
        n.title__c ='test Note title';
        n.Lead__c = testLead.Id;
        n.Notes_Rich__c ='ttt';
        insert n;
        
        testLead.PostalCode = '38000';
        testLead.Website = 'test501.com';
        testLead.status = 'Application Submitted';
       
        // runs LeadTriggerHandler.Execute_BU - incomplete
        update testLead;
       
        Account acct = new Account(Name='Test Account');
        insert acct;
        // add a new lead with the same lead entity        
        Lead newLead = new Lead();
        newLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead Entity').getRecordTypeId();
        newLead.Company = 'Test Company Inc Corp';
        newLead.FirstName = 'Secondary';
        newLead.LastName = '501';
        newLead.email = 'secondarycorp@501.com';
        newLead.Received_Consent__c = 'Full Contact Business Card';
        newLead.Received_Consent_Date__c = date.today();
        newLead.Role__c ='CEO';
        newLead.LeadSource = 'BD/FCD Direct Approach';
        newLead.Status = 'New';
        newLead.Category__c = 'Financial';
        newLead.Main_Sector__c = 'Banking';
        newLead.Industry = 'Commerce';//
        newLead.Country = 'Pakistan';
        newLead.City = 'Lahore';
        newLead.Lead_City__c = 'Lahore';
        newLead.Lead_Country__c = 'Pakistan';
        newLead.First_Contact_Date__c = date.today();
        newLead.Last_Contact_Date__c = date.today();
        newLead.Parent_Entity__c = acct.id;
        insert newLead;
       
        newLead.status = 'Application Submitted';
       
        // runs LeadTriggerHandler.Execute_BU - incomplete
        update newLead;

        //inserting lead contact
        Lead testContact = new Lead();  
        testContact.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead Contact').getRecordTypeId();
        testContact.FirstName = 'Secondary';
        testContact.LastName = '1';
        testContact.Email = 'secondary1@501.com';
        testContact.Role__c = 'Partner';
        testContact.Received_Consent__c = 'Email';
        testContact.Received_Consent_Date__c = date.today().toStartOfMonth();
        testContact.Country = 'Pakistan';
        testContact.city = 'Lahore';
        testContact.Lead_City__c = 'Lahore';
        testContact.Lead_Country__c = 'Pakistan';
        testContact.Primary_Phone_Number_1__c = '+987654321234567890';
        testContact.Related_Lead_Entity__c = newLead.Id;
        testContact.Company = newLead.Company;
        testContact.Primary__c = false;
        testContact.status = 'New';
        insert testContact;
       


        Lead lead2 = new Lead();
        lead2.Company = 'New Lead Co.';
        //lead2.License_Number__c = 'Test-5011';
        lead2.FirstName = 'Primary';
        lead2.LastName = '501';
        lead2.email = 'primary@501.com';
        lead2.Received_Consent__c = 'Business Card';
        lead2.Received_Consent_Date__c = date.today();
        lead2.Role__c ='CEO';
        lead2.LeadSource = 'BD/FCD Direct Approach';
        lead2.Status = 'New';
        lead2.Category__c = 'Financial';
        lead2.Main_Sector__c = 'Banking';
        lead2.Industry = 'Commerce';
        lead2.Country = 'Pakistan';
        lead2.City = 'Lahore';
        lead2.Lead_City__c = 'Lahore';
        lead2.Lead_Country__c = 'Pakistan';
        lead2.First_Contact_Date__c = date.today();
        testLead.Last_Contact_Date__c = date.today();
        insert lead2;

        Lead lead3 = new Lead();
       
        lead3.Company = lead2.Company;      
        lead3.RecordTypeId = RecordTypeId;
        lead3.FirstName = 'Primary';
        lead3.LastName = '501';
        lead3.email = 'primary@501.com';
        lead3.Received_Consent__c = 'Business Card';
        lead3.Received_Consent_Date__c = date.today();
        lead3.Role__c ='CEO';
        lead3.LeadSource = 'BD/FCD Direct Approach';
        lead3.Status = 'New';
        lead3.Category__c = 'Financial';
        lead3.Main_Sector__c = 'Banking';
        lead3.Industry = 'Commerce';
        lead3.Country = 'Pakistan';
        lead3.City = 'Lahore';
        lead3.Lead_City__c = 'Lahore';
        lead3.Lead_Country__c = 'Pakistan';
        lead3.First_Contact_Date__c = date.today();
        lead3.Last_Contact_Date__c = date.today();
        lead3.Related_Lead_Entity__c= lead2.id;
        insert lead3;

        LeadTriggerHandler.getLeadRecTypeId('Lead Contact');
        database.leadConvert lc = new database.leadConvert();
        lc.setLeadId(newLead.id);
        leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        //try{
            Database.LeadConvertResult lcr = Database.convertLead(lc);    
        //} catch (Exception ex) {
       
        Task testTask = new Task(
        //    WhatId = testLead.OwnerId,
            Subject = 'Test Task 1',
            Status = 'New',
            Priority = 'Normal',
            WhoId = testLead.Id
        );
       
        insert testTask;
        testTask.Status = 'In Progress';
        update testTask;
       
        lead3.Primary__c = true;
        update lead3;
        
        test.stopTest();

    }
   
    static testMethod void primaryContactTest()
    {
    Lead testLead = new Lead();
    Id RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead Entity').getRecordTypeId();
       
        Trigger_Settings__c ts = new Trigger_Settings__c();
        ts.Name = 'LeadTrigger';
        ts.Is_Active__c = true;
        insert ts;
       
        List<Map_PrimaryContact_Setting__c> listPrimaryContact = new List<Map_PrimaryContact_Setting__c>();
        Map_PrimaryContact_Setting__c objPrimaryContact = new Map_PrimaryContact_Setting__c();
        objPrimaryContact.Name = 'FirstName';
        objPrimaryContact.SourceFieldName__c = 'FirstName';
        objPrimaryContact.TargetObjectField__c = 'FirstName';
        listPrimaryContact.add(objPrimaryContact);
       
        objPrimaryContact = new Map_PrimaryContact_Setting__c();
        objPrimaryContact.Name = 'Lead_City__c';
        objPrimaryContact.SourceFieldName__c = 'Lead_City__c';
        objPrimaryContact.TargetObjectField__c = 'Lead_City__c';
        listPrimaryContact.add(objPrimaryContact);
        objPrimaryContact = new Map_PrimaryContact_Setting__c();
        objPrimaryContact.Name = 'Lead_Country__c';
        objPrimaryContact.SourceFieldName__c = 'Lead_Country__c';
        objPrimaryContact.TargetObjectField__c = 'Lead_Country__c';
        listPrimaryContact.add(objPrimaryContact);
        insert objPrimaryContact;

test.startTest();
   
        testLead.Company = 'Test Company 501';
        testLead.License_Number__c = 'Test-501';
        testLead.FirstName = 'Primary';
        testLead.LastName = '501';
        testLead.email = 'primary@501.com';
        testLead.Received_Consent__c = 'Full Contact Business Card';
        testLead.Received_Consent_Date__c = date.today();
        testLead.Role__c ='CEO';
        testLead.LeadSource = 'BD/FCD Direct Approach';
        testLead.Status = 'New';
        testLead.Category__c = 'Financial';
        testLead.Main_Sector__c = 'Banking';
        testLead.Industry = 'Commerce';
        testLead.Country = 'Pakistan';
        testLead.City = 'Lahore';
        testLead.Lead_City__c = 'Lahore';
        testLead.Lead_Country__c = 'Pakistan';
        testLead.First_Contact_Date__c = date.today();
        testLead.Last_Contact_Date__c = date.today();
        testLead.Recordtypeid = RecordTypeId;
        testLead.Data_Source__c = 'Scan';
        testLead.From_FSRA__c = true;
        insert testLead;
       
        LeadTriggerHelper.isFirstTime = true;
        Id LCRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead Contact').getRecordTypeId();
        Lead lead2 = new Lead();
        lead2.Company = 'New Lead Co.';
        lead2.FirstName = 'Primary';
        lead2.LastName = '501';
        lead2.email = 'primary@501.com';
        lead2.Received_Consent__c = 'Business Card';
        lead2.Received_Consent_Date__c = date.today();
        lead2.Role__c ='CEO';
        lead2.LeadSource = 'BD/FCD Direct Approach';
        lead2.Status = 'New';
        lead2.Category__c = 'Financial';
        lead2.Main_Sector__c = 'Banking';
        lead2.Industry = 'Commerce';
        lead2.Country = 'Pakistan';
        lead2.City = 'Lahore';
        lead2.Lead_City__c = 'Lahore';
        lead2.Lead_Country__c = 'Pakistan';
        lead2.First_Contact_Date__c = date.today();
        lead2.Last_Contact_Date__c = date.today();
        lead2.Primary__c = true;
        lead2.Related_Lead_Entity__c = testLead.id;
        lead2.Recordtypeid=LCRecordTypeId;
        insert lead2;
       
       
       
       
        LeadTriggerHelper.isFirstTime = true;
        testLead.email = 'test@test.com';
        update testLead;
       
        test.stopTest();
    }

    static testMethod void LeadEventRelationship(){
       
       Id RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead Contact').getRecordTypeId();
       
        Trigger_Settings__c ts = new Trigger_Settings__c();
        ts.Name = 'LeadTrigger';
        ts.Is_Active__c = true;
        insert ts;
       
        List<Map_PrimaryContact_Setting__c> listPrimaryContact = new List<Map_PrimaryContact_Setting__c>();
        Map_PrimaryContact_Setting__c objPrimaryContact = new Map_PrimaryContact_Setting__c();
        objPrimaryContact.Name = 'FirstName';
        objPrimaryContact.SourceFieldName__c = 'FirstName';
        objPrimaryContact.TargetObjectField__c = 'FirstName';
        listPrimaryContact.add(objPrimaryContact);
       
        objPrimaryContact = new Map_PrimaryContact_Setting__c();
        objPrimaryContact.Name = 'Lead_City__c';
        objPrimaryContact.SourceFieldName__c = 'Lead_City__c';
        objPrimaryContact.TargetObjectField__c = 'Lead_City__c';
        listPrimaryContact.add(objPrimaryContact);
        objPrimaryContact = new Map_PrimaryContact_Setting__c();
        objPrimaryContact.Name = 'Lead_Country__c';
        objPrimaryContact.SourceFieldName__c = 'Lead_Country__c';
        objPrimaryContact.TargetObjectField__c = 'Lead_Country__c';
        listPrimaryContact.add(objPrimaryContact);
        insert objPrimaryContact;
      
        test.startTest();
        
        Account acct = new Account(Name='Test Account');
        insert acct;
        
        Lead testLead = new Lead();
        Id RecordTypeId1 = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead Contact').getRecordTypeId();
        testLead.RecordTypeId = RecordTypeId1;
        testLead.Sys_Record_Type_Name__c = 'Lead Contact';
        testLead.Company = 'Test Company 501';
        testLead.License_Number__c = 'Test-501';
        testLead.FirstName = 'Primary';
        testLead.LastName = '501';
        testLead.email = 'primary@501.com';
        testLead.Received_Consent__c = 'Full Contact Business Card';
        testLead.Received_Consent_Date__c = date.today();
        testLead.Role__c ='CEO';
        testLead.LeadSource = 'BD/FCD Direct Approach';
        testLead.Status = 'New';
        testLead.Category__c = 'Financial';
        testLead.Main_Sector__c = 'Banking';
        testLead.Industry = 'Commerce';
        testLead.Country = 'Pakistan';
        testLead.City = 'Lahore';
        testLead.Lead_City__c = 'Lahore';
        testLead.Lead_Country__c = 'Pakistan';
        testLead.First_Contact_Date__c =date.today();
        testLead.Last_Contact_Date__c = date.today();
        testLead.MobilePhone = '+97145555555';
       
        insert testLead;
        
       Contact con = new Contact(
        
       LastName = 'LN',
       Email = 'test@adgm.com',
       Country__c = 'Qatar',
       City__c = 'Dubai'
    //   Account = acct.id
        );
        
        Insert con;

        Event__c Event = new Event__c(
        
       
        isActive__c = true
        );
        Insert Event;
        
      Related_Event__c RelatedEvent = new Related_Event__c(
        
        Contact__c = con.Id,
        Lead_Contact__c = testLead.id,
        Event__c = Event.id);
        
        Insert RelatedEvent;
        
       test.stopTest(); 
    } 
    }
@isTest
public class UpdateLastContactDetailsTest {
    
    static testMethod void UpdateLastContactDetailsTest(){
    
        Trigger_Settings__c ts = new Trigger_Settings__c();
        ts.Name = 'LeadTrigger';
        ts.Is_Active__c = true;
        insert ts;
       
        Lead testLead = new Lead(); 
           
        testLead.Company = 'Test Company 501';
        testLead.License_Number__c = 'Test-501';
        testLead.FirstName = 'Primary';
        testLead.LastName = '501';
        testLead.email = 'primary@501.com';
        testLead.Received_Consent__c = 'Business Card';
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
        //testLead.First_Contact_Date__c = date.today().toStartOfMonth();
        //testLead.Last_Contact_Date__c = date.today().toStartOfMonth();        
        testLead.PostalCode = '38000';
        testLead.Website = 'test501.com';

        insert testLead;
        
        Lead testContact = new Lead();
        
        Id RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead Contact').getRecordTypeId();
        testContact.RecordTypeId = RecordTypeId;
        testContact.FirstName = 'Secondary';
        testContact.LastName = '1';
        testContact.Email = 'secondary1@501.com';
        testContact.Role__c = 'Partner';
        testContact.Received_Consent__c = 'Email';
        testContact.Received_Consent_Date__c = date.today();
        testContact.Country = 'Pakistan';
        testContact.city = 'Lahore';
        testContact.Lead_City__c = 'Lahore';
        testContact.Lead_Country__c = 'Pakistan';
        testContact.Primary_Phone_Number_1__c = '+9887676';
        testContact.Related_Lead_Entity__c = testLead.Id;
        testContact.Company = testLead.Company;
        
        insert testContact;
        
        
       
        // runs UpdateParentLeadOnTaskCompletion.updateParentLeadLastContactDate
      /*  Task testTask = new Task(
            //WhatId = testLead.Id,
            Subject = 'Test Task 1',
            Status = 'New',
            Priority = 'Normal',
            WhoId = testLead.Id
        );
        
        insert testTask;
        testTask.Status = 'Completed';
        update testTask;
      */
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        sendTo.add(testContact.Id);
        mail.setToAddresses(sendTo);
        mail.setSubject('URGENT BUSINESS PROPOSAL');
        mail.setHtmlBody('test email body');
        mails.add(mail);
        try{
            Messaging.sendEmail(mails);
            list<Id> lstEmailId = new list<id>();
            for(EmailMessage emailMsg : [select id from EmailMessage limit 1])
                lstEmailId.add(emailMsg.id);
            if(lstEmailId != null && lstEmailId.size()>0){
                UpdateLastContactDetails.updateLead(lstEmailId);
                UpdateFirstContactDetails.updateLead(lstEmailId);
            }
        }
        catch(Exception ex){
            System.debug(ex);
        }
        
    }
       
    }
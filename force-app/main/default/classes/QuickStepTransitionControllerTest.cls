@isTest
public class QuickStepTransitionControllerTest
{
    
    private static testMethod void QuickStepTransitionControllerUT()
    {
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 
        
        HexaBPM__SR_Template__c hst = new HexaBPM__SR_Template__c();
        hst.HexaBPM__Active__c = true;
        hst.Name='Trainings and Seminars Permit';
        hst.HexaBPM__SR_RecordType_API_Name__c = 'Permit_Training_and_Seminar';
        insert hst;
            
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR1(1,'Permit_Alcohol','56565');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].HexaBPM__SR_Template__c = hst.id;
        insert createdSRList;
        
        HexaBPM__Step__c step = new HexaBPM__Step__c();
        step.HexaBPM__SR__c = createdSRList[0].id;
        insert step;
        
        ApexPages.standardController SC = new Apexpages.standardController(createdSRList[0]);
        ApexPages.currentpage().getParameters().put('Id',createdSRList[0].id);
        ApexPages.currentpage().getParameters().put('stepId',step.id);
        QuickStepTransitionController qst = new QuickStepTransitionController(SC);

    }
    
    private static testMethod void QuickStepTransitionControllerUT1()
    {
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        newAccounts[0].License_Expiry_Date__c = Date.today().addDays(100);
        insert newAccounts; 
        
        HexaBPM__SR_Template__c hst = new HexaBPM__SR_Template__c();
        hst.HexaBPM__Active__c = true;
        hst.Name='Shisha Permit';
        hst.HexaBPM__SR_RecordType_API_Name__c = 'Permit_Shisha';
        insert hst;
            
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR1(1,'Permit_Alcohol','000000');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].HexaBPM__SR_Template__c = hst.id;
        createdSRList[0].Valid_To__c = Date.today().addDays(200);
        insert createdSRList;
        
        HexaBPM__Step__c step = new HexaBPM__Step__c();
        step.HexaBPM__SR__c = createdSRList[0].id;
        insert step;
        
        ApexPages.standardController SC = new Apexpages.standardController(createdSRList[0]);
        ApexPages.currentpage().getParameters().put('Id',createdSRList[0].id);
        ApexPages.currentpage().getParameters().put('stepId',step.id);
        QuickStepTransitionController qst = new QuickStepTransitionController(SC);

    }
    private static testMethod void QuickStepTransitionControllerUT2()
    {
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 
        
        HexaBPM__SR_Template__c hst = new HexaBPM__SR_Template__c();
        hst.HexaBPM__Active__c = true;
        hst.Name='Temporary Work Permit - New';
        hst.HexaBPM__SR_RecordType_API_Name__c = 'Temporary_Work_Permit_New';
        insert hst;
            
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR1(1,'Temporary_Work_Permit_New','55555');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].HexaBPM__SR_Template__c = hst.id;
        createdSRList[0].Work_Permit_Validity__c='3';
        createdSRList[0].Residence_Visa_Date_of_Expiry__c=Date.today().addDays(365);
        createdSRList[0].Passport_Number__c = '12345';
        insert createdSRList;
        
        HexaBPM__Step__c step = new HexaBPM__Step__c();
        step.HexaBPM__SR__c = createdSRList[0].id;
        step.HexaBPM__Summary__c = 'Verification of Application';
        insert step;
        
        ApexPages.standardController SC = new Apexpages.standardController(createdSRList[0]);
        ApexPages.currentpage().getParameters().put('Id',createdSRList[0].id);
        ApexPages.currentpage().getParameters().put('stepId',step.id);
        QuickStepTransitionController qst = new QuickStepTransitionController(SC);

    }
    private static testMethod void QuickStepTransitionControllerUT3()
    {
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 
        
        HexaBPM__SR_Template__c hst = new HexaBPM__SR_Template__c();
        hst.HexaBPM__Active__c = true;
        hst.Name='Employee Work Permit (UAE/GCC National) - New';
        hst.HexaBPM__SR_RecordType_API_Name__c = 'Employee_Work_Permit_UAE_GCC_National_New';
        insert hst;
        
        HexaBPM__Status__c stepStatus = new HexaBPM__Status__c(Name='Awaiting Verification',HexaBPM__Type__c='Start',HexaBPM__Code__c='AWAITING_VERIFICATION');
        insert stepStatus;
        
        HexaBPM__Step_Template__c stepTemplate = new HexaBPM__Step_Template__c(Name='Verification of Application',HexaBPM__Code__c='VERIFICATION_OF_APPLICATION',HexaBPM__Step_RecordType_API_Name__c='General',HexaBPM__Summary__c='Verification of Application');
        insert stepTemplate;
        
        HexaBPM__SR_Steps__c srSteps = new HexaBPM__SR_Steps__c(HexaBPM__SR_Template__c=hst.id,HexaBPM__Step_Template__c=stepTemplate.id,
        HexaBPM__Start_Status__c=stepStatus.id,HexaBPM__Active__c=true,HexaBPM__Summary__c='Verification of Application',
        HexaBPM__Step_RecordType_API_Name__c='General',HexaBPM__Step_Type__c='Quick Action',HexaBPM__Group_Name__c='Verification of Application');
        insert srSteps;
        
        
        HexaBPM__Status__c status = new HexaBPM__Status__c(Name='Awaiting Verification',HexaBPM__Code__c='AWAITING_VERIFICATION',HexaBPM__Type__c='Start');
        
        HexaBPM__Status__c status1 = new HexaBPM__Status__c
        (Name='Re-Upload Document',HexaBPM__Code__c='REUPLOAD_DOCUMENT',HexaBPM__Type__c='End');
        insert status1;
        
        HexaBPM__Transition__c transition = new HexaBPM__Transition__c(HexaBPM__From__c=status.id,HexaBPM__To__c=status1.id);
        insert transition;
        
        HexaBPM__SR_Status__c srStatus = new HexaBPM__SR_Status__c(Name='Awaiting Re-Upload',HexaBPM__Code__c='AWAITING_RE-UPLOAD');
        insert srStatus;
        
        HexaBPM__Step_Transition__c stepTransition = new HexaBPM__Step_Transition__c
        (HexaBPM__SR_Step__c=srSteps.id,HexaBPM__Transition__c=transition.id,HexaBPM__SR_Status_Internal__c=srStatus.id,HexaBPM__SR_Status_External__c=srStatus.id);
        insert stepTransition;

            
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR1(1,'Employee_Work_Permit_UAE_GCC_National_New','65555');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].HexaBPM__SR_Template__c = hst.id;
        createdSRList[0].Work_Permit_Validity__c='6';
        createdSRList[0].Passport_Expiry_Date__c=Date.today().addDays(365);
        insert createdSRList;
        
        HexaBPM__Step__c step = new HexaBPM__Step__c();
        step.HexaBPM__SR__c = createdSRList[0].id;
        step.HexaBPM__Status__c = status.id;
        step.HexaBPM__SR_Step__c = srSteps.id;
        insert step;
        
        
        ApexPages.standardController SC = new Apexpages.standardController(createdSRList[0]);
        ApexPages.currentpage().getParameters().put('Id',createdSRList[0].id);
        ApexPages.currentpage().getParameters().put('stepId',step.id);
        QuickStepTransitionController qst = new QuickStepTransitionController(SC);
        qst.CheckAccess();
        qst.selTransition = status1.id;
        qst.SaveChanges();
        qst.AcceptAction();
        qst.CheckAction();
        qst.CancelAction();
        qst.ViewStep();
        qst.ReleaseAction();
    }
    private static testMethod void QuickStepTransitionControllerUT4()
    {
        Id contactRecordTypeid;
        Map <String,Schema.RecordTypeInfo> recordTypeMap = Contact.sObjectType.getDescribe().getRecordTypeInfosByName();
        if(recordTypeMap.containsKey('Contact - Employee')) {
         contactRecordTypeid = recordTypeMap.get('Contact - Employee').getRecordTypeId();
        }
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 
        
         List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Employment_Type__c = 'Temporary Employee Work Permit';
        newContacts[0].recordtypeid = contactRecordTypeid;
        insert newContacts;  
        
        HexaBPM__SR_Template__c hst = new HexaBPM__SR_Template__c();
        hst.HexaBPM__Active__c = true;
        hst.Name='Temporary Work Permit - Renew';
        hst.HexaBPM__SR_RecordType_API_Name__c = 'Temporary_Work_Permit_Renew';
        insert hst;
            
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR1(1,'Temporary_Work_Permit_Renew','88888');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].id;
        createdSRList[0].HexaBPM__SR_Template__c = hst.id;
        createdSRList[0].Work_Permit_Validity__c='12';
        createdSRList[0].Residence_Visa_Date_of_Expiry__c=Date.today().addDays(100);
        insert createdSRList;
        
        HexaBPM__Step__c step = new HexaBPM__Step__c();
        step.HexaBPM__SR__c = createdSRList[0].id;
        insert step;
        
        ApexPages.standardController SC = new Apexpages.standardController(createdSRList[0]);
        ApexPages.currentpage().getParameters().put('Id',createdSRList[0].id);
        ApexPages.currentpage().getParameters().put('stepId',step.id);
        QuickStepTransitionController qst = new QuickStepTransitionController(SC);

    }
    private static testMethod void QuickStepTransitionControllerUT5()
    {
        Id contactRecordTypeid;
        Map <String,Schema.RecordTypeInfo> recordTypeMap = Contact.sObjectType.getDescribe().getRecordTypeInfosByName();
        if(recordTypeMap.containsKey('Contact - Employee')) {
         contactRecordTypeid = recordTypeMap.get('Contact - Employee').getRecordTypeId();
        }
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 
        
         List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Employment_Type__c = 'Employee Work Permit(UAE/GCC National)';
        newContacts[0].recordtypeid = contactRecordTypeid;
        insert newContacts;  
        
        HexaBPM__SR_Template__c hst = new HexaBPM__SR_Template__c();
        hst.HexaBPM__Active__c = true;
        hst.Name='Employee Work Permit (UAE/GCC National) - Renew';
        hst.HexaBPM__SR_RecordType_API_Name__c = 'Employee_Work_Permit_UAE_GCC_National_Renew';
        insert hst;
            
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR1(1,'Employee_Work_Permit_UAE_GCC_National_Renew','77777');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].id;
        createdSRList[0].HexaBPM__SR_Template__c = hst.id;
        createdSRList[0].Work_Permit_Validity__c='12';
        createdSRList[0].Residence_Visa_Date_of_Expiry__c=Date.today().addDays(100);
        createdSRList[0].Passport_Expiry_Date__c = Date.today().addDays(100);
        insert createdSRList;
        
        HexaBPM__Step__c step = new HexaBPM__Step__c();
        step.HexaBPM__SR__c = createdSRList[0].id;
        insert step;
        
        ApexPages.standardController SC = new Apexpages.standardController(createdSRList[0]);
        ApexPages.currentpage().getParameters().put('Id',createdSRList[0].id);
        ApexPages.currentpage().getParameters().put('stepId',step.id);
        QuickStepTransitionController qst = new QuickStepTransitionController(SC);

    }
    private static testMethod void QuickStepTransitionControllerUT6()
    {
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 
        
        HexaBPM__SR_Template__c hst = new HexaBPM__SR_Template__c();
        hst.HexaBPM__Active__c = true;
        hst.Name='Employee Work Permit (UAE/GCC National) - New';
        hst.HexaBPM__SR_RecordType_API_Name__c = 'Employee_Work_Permit_UAE_GCC_National_New';
        insert hst;
        
        HexaBPM__Status__c stepStatus = new HexaBPM__Status__c(Name='Awaiting Verification',HexaBPM__Type__c='Start',HexaBPM__Code__c='AWAITING_VERIFICATION');
        insert stepStatus;
        
        HexaBPM__Step_Template__c stepTemplate = new HexaBPM__Step_Template__c(Name='Verification of Application',HexaBPM__Code__c='VERIFICATION_OF_APPLICATION',HexaBPM__Step_RecordType_API_Name__c='General',HexaBPM__Summary__c='Verification of Application');
        insert stepTemplate;
        
        HexaBPM__SR_Steps__c srSteps = new HexaBPM__SR_Steps__c(HexaBPM__SR_Template__c=hst.id,HexaBPM__Step_Template__c=stepTemplate.id,
        HexaBPM__Start_Status__c=stepStatus.id,HexaBPM__Active__c=true,HexaBPM__Summary__c='Verification of Application',
        HexaBPM__Step_RecordType_API_Name__c='General',HexaBPM__Step_Type__c='Quick Action',HexaBPM__Group_Name__c='Verification of Application');
        insert srSteps;
        
        
        HexaBPM__Status__c status = new HexaBPM__Status__c(Name='Awaiting Verification',HexaBPM__Code__c='AWAITING_VERIFICATION',HexaBPM__Type__c='Start');
        
        HexaBPM__Status__c status1 = new HexaBPM__Status__c
        (Name='Re-Upload Document',HexaBPM__Code__c='REUPLOAD_DOCUMENT',HexaBPM__Type__c='End',HexaBPM__Reupload_Document__c=true);
        insert status1;
        
        HexaBPM__Transition__c transition = new HexaBPM__Transition__c(HexaBPM__From__c=status.id,HexaBPM__To__c=status1.id);
        insert transition;
        
        HexaBPM__SR_Status__c srStatus = new HexaBPM__SR_Status__c(Name='Awaiting Re-Upload',HexaBPM__Code__c='AWAITING_RE-UPLOAD');
        insert srStatus;
        
        HexaBPM__Step_Transition__c stepTransition = new HexaBPM__Step_Transition__c
        (HexaBPM__SR_Step__c=srSteps.id,HexaBPM__Transition__c=transition.id,HexaBPM__SR_Status_Internal__c=srStatus.id);
        insert stepTransition;

            
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR1(1,'Employee_Work_Permit_UAE_GCC_National_New','66666');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].HexaBPM__SR_Template__c = hst.id;
        createdSRList[0].Work_Permit_Validity__c='6';
        createdSRList[0].Passport_Expiry_Date__c=Date.today().addDays(365);
        insert createdSRList;
        
        HexaBPM__Step__c step = new HexaBPM__Step__c();
        step.HexaBPM__SR__c = createdSRList[0].id;
        step.HexaBPM__Status__c = status.id;
        step.HexaBPM__SR_Step__c = srSteps.id;
        insert step;
        
        
        ApexPages.standardController SC = new Apexpages.standardController(createdSRList[0]);
        ApexPages.currentpage().getParameters().put('Id',createdSRList[0].id);
        ApexPages.currentpage().getParameters().put('stepId',step.id);
        QuickStepTransitionController qst = new QuickStepTransitionController(SC);
        
        qst.CheckAccess();
        qst.selTransition = status1.id;
        qst.SaveChanges();
        qst.AcceptAction();
        qst.CheckAction();
        qst.CancelAction();
        qst.ViewStep();
        qst.ReleaseAction();
    }
    
    private static testMethod void QuickStepTransitionControllerUT9()
    {
        Id contactRecordTypeid;
        Map <String,Schema.RecordTypeInfo> recordTypeMap = Contact.sObjectType.getDescribe().getRecordTypeInfosByName();
        if(recordTypeMap.containsKey('Contact - Employee')) {
         contactRecordTypeid = recordTypeMap.get('Contact - Employee').getRecordTypeId();
        }
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 
        
         List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Employment_Type__c = 'Employee Work Permit(UAE/GCC National)';
        newContacts[0].recordtypeid = contactRecordTypeid;
        insert newContacts;  
        
        HexaBPM__SR_Template__c hst = new HexaBPM__SR_Template__c();
        hst.HexaBPM__Active__c = true;
        hst.Name='New Work Permit for ADGM Sponsored Employees';
        hst.HexaBPM__SR_RecordType_API_Name__c = 'New_Work_Permit_For_ADGM_Sponsored_Employees';
        insert hst;
            
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR1(1,'New_Work_Permit_For_ADGM_Sponsored_Employees','47857433');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].id;
        createdSRList[0].HexaBPM__SR_Template__c = hst.id;
        createdSRList[0].Work_Permit_Validity__c='12';
        createdSRList[0].Residence_Visa_Date_of_Expiry__c=Date.today().addDays(100);
        createdSRList[0].Passport_Expiry_Date__c = Date.today().addDays(100);
        createdSRList[0].Unified_ID_No__c= '1234';
        createdSRList[0].Residence_Visa_Number__c= '1234';
        insert createdSRList;
        
        HexaBPM__Step__c step = new HexaBPM__Step__c();
        step.HexaBPM__SR__c = createdSRList[0].id;
        insert step;
        
        ApexPages.standardController SC = new Apexpages.standardController(createdSRList[0]);
        ApexPages.currentpage().getParameters().put('Id',createdSRList[0].id);
        ApexPages.currentpage().getParameters().put('stepId',step.id);
        QuickStepTransitionController qst = new QuickStepTransitionController(SC);

    }
    
    private static testMethod void QuickStepTransitionControllerUT10() {
        
        Id contactRecordTypeid;
        Map <String,Schema.RecordTypeInfo> recordTypeMap = Contact.sObjectType.getDescribe().getRecordTypeInfosByName();
        if(recordTypeMap.containsKey('Contact - Employee')) {
         contactRecordTypeid = recordTypeMap.get('Contact - Employee').getRecordTypeId();
        }
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 
        
         List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Employment_Type__c = 'Employee Work Permit(UAE/GCC National)';
        newContacts[0].recordtypeid = contactRecordTypeid;
        insert newContacts;  
        
        HexaBPM__SR_Template__c hst = new HexaBPM__SR_Template__c();
        hst.HexaBPM__Active__c = true;
        hst.Name='Employment_Visa_New';
        hst.HexaBPM__SR_RecordType_API_Name__c = 'Employment_Visa_New';
        insert hst;
            
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR1(1,'Employment_Visa_New','475937');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].id;
        createdSRList[0].HexaBPM__SR_Template__c = hst.id;
        createdSRList[0].Work_Permit_Validity__c='12';
        createdSRList[0].Residence_Visa_Date_of_Expiry__c=Date.today().addDays(100);
        createdSRList[0].Passport_Expiry_Date__c = Date.today().addDays(100);
        createdSRList[0].Unified_ID_No__c= '1234';
        createdSRList[0].Residence_Visa_Number__c= '1234';
        insert createdSRList;
        HexaBPM__Status__c status = new HexaBPM__Status__c(Name='Awaiting Verification',HexaBPM__Code__c='DOCUMENT_UPLOADED',HexaBPM__Type__c='Start');
        
        HexaBPM__Status__c stepStatus = new HexaBPM__Status__c(Name='Awaiting Verification',HexaBPM__Type__c='Intermediate',HexaBPM__Code__c='DOCUMENT_UPLOADED');
        insert stepStatus;
        
        HexaBPM__Step_Template__c stepTemplate = new HexaBPM__Step_Template__c(Name='Verification of Application',HexaBPM__Code__c='UPLOAD_HEALTH_INSURANCE_CARD',HexaBPM__Step_RecordType_API_Name__c='General',HexaBPM__Summary__c='Verification of Application');
        insert stepTemplate;
        
        HexaBPM__SR_Steps__c srSteps = new HexaBPM__SR_Steps__c(HexaBPM__SR_Template__c=hst.id,HexaBPM__Step_Template__c=stepTemplate.id,
        HexaBPM__Start_Status__c=stepStatus.id,HexaBPM__Active__c=true,HexaBPM__Summary__c='Verification of Application',
        HexaBPM__Step_RecordType_API_Name__c='General',HexaBPM__Step_Type__c='Quick Action',HexaBPM__Group_Name__c='Verification of Application');
        insert srSteps;
        
        HexaBPM__Step__c step = new HexaBPM__Step__c();
        step.HexaBPM__SR__c = createdSRList[0].id;
        step.HexaBPM__Status__c = status.id;
        step.HexaBPM__SR_Step__c = srSteps.id;
        step.HexaBPM__Step_Template__c = stepTemplate.id;
        insert step;        
        
         HexaBPM__Transition__c transition = new HexaBPM__Transition__c(HexaBPM__From__c=status.id,HexaBPM__To__c=stepStatus.id);
        insert transition;
        HexaBPM__SR_Status__c srStatus = new HexaBPM__SR_Status__c(Name='Awaiting Re-Upload',HexaBPM__Code__c='AWAITING_RE-UPLOAD');
        insert srStatus;
        
        HexaBPM__Step_Transition__c stepTransition = new HexaBPM__Step_Transition__c
        (HexaBPM__SR_Step__c=srSteps.id,HexaBPM__Transition__c=transition.id,HexaBPM__SR_Status_Internal__c=srStatus.id,HexaBPM__SR_Status_External__c=srStatus.id);
        insert stepTransition;
        
        ApexPages.standardController SC = new Apexpages.standardController(createdSRList[0]);
        ApexPages.currentpage().getParameters().put('Id',createdSRList[0].id);
        ApexPages.currentpage().getParameters().put('stepId',step.id);
        QuickStepTransitionController qst = new QuickStepTransitionController(SC);
        qst.CheckAccess();
        qst.selTransition = stepStatus.id;
        qst.SaveChanges();
        
        
        // Setup test data
        // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName=uniqueUserName);

        System.runAs(u) {
            SC = new Apexpages.standardController(createdSRList[0]);
            ApexPages.currentpage().getParameters().put('Id',createdSRList[0].id);
            ApexPages.currentpage().getParameters().put('stepId',step.id);
            qst = new QuickStepTransitionController(SC);
            qst.CheckAccess();
            qst.selTransition = stepStatus.id;
          }
    }
    
    private static testMethod void QuickStepTransitionControllerUT11()
    {
        Id contactRecordTypeid;
        Map <String,Schema.RecordTypeInfo> recordTypeMap = Contact.sObjectType.getDescribe().getRecordTypeInfosByName();
        if(recordTypeMap.containsKey('Contact - Employee')) {
            contactRecordTypeid = recordTypeMap.get('Contact - Employee').getRecordTypeId();
        }
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Employment_Type__c = 'Employee Work Permit(UAE/GCC National)';
        newContacts[0].recordtypeid = contactRecordTypeid;
        insert newContacts;  
        
        HexaBPM__SR_Template__c hst = new HexaBPM__SR_Template__c();
        hst.HexaBPM__Active__c = true;
        hst.Name='Employment_Visa_New';
        hst.HexaBPM__SR_RecordType_API_Name__c = 'Employment_Visa_New';
        insert hst;
        
        List<HexaBPM__Service_Request__c> createdSRList1 = TestUtility.createSR1(1,'Employment_Visa_New','372874');
        createdSRList1[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList1[0].HexaBPM__Contact__c = newContacts[0].id;
        createdSRList1[0].HexaBPM__SR_Template__c = hst.id;
        createdSRList1[0].Work_Permit_Validity__c='12';
        createdSRList1[0].Residence_Visa_Date_of_Expiry__c=Date.today().addDays(100);
        createdSRList1[0].Passport_Expiry_Date__c = Date.today().addDays(100);
        createdSRList1[0].Unified_ID_No__c= '1234';
        createdSRList1[0].Residence_Visa_Number__c= '1234';
        insert createdSRList1;
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR1(1,'Employment_Visa_New','000892');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].id;
        createdSRList[0].HexaBPM__SR_Template__c = hst.id;
        createdSRList[0].Work_Permit_Validity__c='12';
        createdSRList[0].Residence_Visa_Date_of_Expiry__c=Date.today().addDays(100);
        createdSRList[0].Passport_Expiry_Date__c = Date.today().addDays(100);
        createdSRList[0].Unified_ID_No__c= '1234';
        createdSRList[0].Residence_Visa_Number__c= '1234';
        createdSRList[0].HexaBPM__Parent_SR__c = createdSRList1[0].id;
        insert createdSRList;
        
        HexaBPM__Status__c status = new HexaBPM__Status__c(Name='Awaiting Verification',HexaBPM__Code__c='DOCUMENT_UPLOADED',HexaBPM__Type__c='Start');
        //insert status;
        
        HexaBPM__Status__c stepStatus = new HexaBPM__Status__c(Name='Residence Visa Stamped',HexaBPM__Type__c='Intermediate',HexaBPM__Code__c='DOCUMENT_UPLOADED');
        insert stepStatus;
        
        HexaBPM__Step_Template__c stepTemplate = new HexaBPM__Step_Template__c(Name='Verification of Application',HexaBPM__Code__c='RESIDENCE_VISA_STAMPING_PROCESS',HexaBPM__Step_RecordType_API_Name__c='General',HexaBPM__Summary__c='Verification of Application');
        insert stepTemplate;
        
        HexaBPM__SR_Steps__c srSteps = new HexaBPM__SR_Steps__c(HexaBPM__SR_Template__c=hst.id,HexaBPM__Step_Template__c=stepTemplate.id,
                                                                HexaBPM__Start_Status__c=stepStatus.id,HexaBPM__Active__c=true,HexaBPM__Summary__c='Verification of Application',
                                                                HexaBPM__Step_RecordType_API_Name__c='General',HexaBPM__Step_Type__c='Quick Action',HexaBPM__Group_Name__c='Verification of Application');
        insert srSteps;
        
        HexaBPM__Step__c step = new HexaBPM__Step__c();
        step.HexaBPM__SR__c = createdSRList[0].id;
        step.HexaBPM__Status__c = status.id;
        step.HexaBPM__SR_Step__c = srSteps.id;
        step.HexaBPM__Step_Template__c = stepTemplate.id;
        insert step;        
        
        HexaBPM__Transition__c transition = new HexaBPM__Transition__c(HexaBPM__From__c=status.id,HexaBPM__To__c=stepStatus.id);
        insert transition;
        HexaBPM__SR_Status__c srStatus = new HexaBPM__SR_Status__c(Name='Awaiting Re-Upload',HexaBPM__Code__c='AWAITING_RE-UPLOAD');
        insert srStatus;
        HexaBPM__SR_Status__c srStatus1 = new HexaBPM__SR_Status__c(Name='Awaiting Re-Upload',HexaBPM__Code__c='AWAITING_RE-UPLOAD1');
        insert srStatus1;
        
        HexaBPM__Step_Transition__c stepTransition = new HexaBPM__Step_Transition__c
            (HexaBPM__SR_Step__c=srSteps.id,HexaBPM__Transition__c=transition.id,HexaBPM__SR_Status_Internal__c=srStatus.id,HexaBPM__SR_Status_External__c=srStatus.id,HexaBPM__Parent_SR_Status__c=srStatus1.id);
        insert stepTransition;
        
        system.debug('--->'+stepTransition);
        system.debug('--->'+stepTransition.HexaBPM__Parent_SR_Status__c);
        ApexPages.standardController SC = new Apexpages.standardController(createdSRList[0]);
        ApexPages.currentpage().getParameters().put('Id',createdSRList[0].id);
        ApexPages.currentpage().getParameters().put('stepId',step.id);
        QuickStepTransitionController qst = new QuickStepTransitionController(SC);
        qst.CheckAccess();
        qst.selTransition = stepStatus.id;
        qst.SaveChanges();
    }
    
    private static testMethod void QuickStepTransitionController_POBox()
    {
        Id contactRecordTypeid;
        Map <String,Schema.RecordTypeInfo> recordTypeMap = Contact.sObjectType.getDescribe().getRecordTypeInfosByName();
        if(recordTypeMap.containsKey('Contact - Employee')) {
            contactRecordTypeid = recordTypeMap.get('Contact - Employee').getRecordTypeId();
        }
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Employment_Type__c = 'Employee Work Permit(UAE/GCC National)';
        newContacts[0].recordtypeid = contactRecordTypeid;
        insert newContacts;  
        
        HexaBPM__SR_Template__c hst = new HexaBPM__SR_Template__c();
        hst.HexaBPM__Active__c = true;
        hst.Name='P.O. Box - New Application';
        hst.HexaBPM__SR_RecordType_API_Name__c = 'PO_Box_New_Application';
        insert hst;
        
        List<HexaBPM__Service_Request__c> createdSRList1 = TestUtility.createSR1(1,'P_O_Box_New','372874');
        createdSRList1[0].Agent_Name__c='test';
        createdSRList1[0].agent_mobile_Number__c ='dfgh';
        createdSRList1[0].Agent_Emirates_ID_Number__c ='353534535';  
        createdSRList1[0].HexaBPM__Customer__c = newAccounts[0].Id;
        insert createdSRList1;
               
        HexaBPM__Status__c stepStatus = new HexaBPM__Status__c(Name='Awaiting Verification',HexaBPM__Code__c='AWAITING_VERIFICATION',HexaBPM__Type__c='Start');
        insert stepStatus;
        
        HexaBPM__Status__c status = new HexaBPM__Status__c(Name='Residence Visa Stamped',HexaBPM__Type__c='Intermediate',HexaBPM__Code__c='DOCUMENT_UPLOADED');
        insert status;
        
         HexaBPM__Status__c stepStatus1 = new HexaBPM__Status__c(Name='Application Verified',HexaBPM__Type__c='End',HexaBPM__Code__c='APPLICATION_VERIFIED');
        insert stepStatus1;
        
        HexaBPM__Step_Template__c stepTemplate = new HexaBPM__Step_Template__c(Name='Verification of Application',HexaBPM__Code__c='RESIDENCE_VISA_STAMPING_PROCESS',HexaBPM__Step_RecordType_API_Name__c='General',HexaBPM__Summary__c='Verification of Application');
        insert stepTemplate;
        
        HexaBPM__SR_Steps__c srSteps = new HexaBPM__SR_Steps__c(HexaBPM__SR_Template__c=hst.id,HexaBPM__Step_Template__c=stepTemplate.id,
                                                                HexaBPM__Start_Status__c=stepStatus.id,HexaBPM__Active__c=true,HexaBPM__Summary__c='Verification of Application',
                                                                HexaBPM__Step_RecordType_API_Name__c='General',HexaBPM__Step_Type__c='Quick Action',HexaBPM__Group_Name__c='Verification of Application');
        insert srSteps;
        
        HexaBPM__Step__c step = new HexaBPM__Step__c();
        step.HexaBPM__SR__c = createdSRList1[0].id;
        step.HexaBPM__Status__c = stepStatus.id;
        step.HexaBPM__SR_Step__c = srSteps.id;
        step.HexaBPM__Step_Template__c = stepTemplate.id;
        step.ownerId =userinfo.getUserId();
        insert step;        
        
        HexaBPM__Transition__c transition = new HexaBPM__Transition__c(HexaBPM__From__c=stepStatus.id,HexaBPM__To__c=stepStatus1.id);
        insert transition;
        HexaBPM__SR_Status__c srStatus = new HexaBPM__SR_Status__c(Name='Application Verified',HexaBPM__Code__c='APPLICATION_VERIFIED');
        insert srStatus;
        //HexaBPM__SR_Status__c srStatus1 = new HexaBPM__SR_Status__c(Name='Application Verified',HexaBPM__Code__c='APPLICATION_VERIFIED');
        //insert srStatus1;
        
        HexaBPM__Step_Transition__c stepTransition = new HexaBPM__Step_Transition__c
            (HexaBPM__SR_Step__c=srSteps.id,HexaBPM__Transition__c=transition.id,
             HexaBPM__SR_Status_Internal__c=srStatus.id,
             HexaBPM__SR_Status_External__c=srStatus.id,
             HexaBPM__Display_on_Portal__c=true);
        insert stepTransition;
        
        system.debug('--->'+stepTransition);
        system.debug('--->'+stepTransition.HexaBPM__Parent_SR_Status__c);
        ApexPages.standardController SC = new Apexpages.standardController(createdSRList1[0]);
        ApexPages.currentpage().getParameters().put('Id',createdSRList1[0].id);
        ApexPages.currentpage().getParameters().put('stepId',step.id);
        QuickStepTransitionController qst = new QuickStepTransitionController(SC);
        qst.userType ='Community';
        qst.CheckAccess();
        qst.AcceptAction();
        qst.selTransition = stepStatus1.Id;
        qst.SaveChanges();
    }
    
    private static testMethod void QuickStepTransitionController_POBox1(){
            Id contactRecordTypeid;
        Map <String,Schema.RecordTypeInfo> recordTypeMap = Contact.sObjectType.getDescribe().getRecordTypeInfosByName();
        if(recordTypeMap.containsKey('Contact - Employee')) {
            contactRecordTypeid = recordTypeMap.get('Contact - Employee').getRecordTypeId();
        }
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Employment_Type__c = 'Employee Work Permit(UAE/GCC National)';
        newContacts[0].recordtypeid = contactRecordTypeid;
        insert newContacts;  
        
        HexaBPM__SR_Template__c hst = new HexaBPM__SR_Template__c();
        hst.HexaBPM__Active__c = true;
        hst.Name='P.O.Box - New Application';
        hst.HexaBPM__SR_RecordType_API_Name__c = 'PO_Box_New_Application';
        insert hst;
        
        List<HexaBPM__Service_Request__c> createdSRList1 = TestUtility.createSR1(1,'P_O_Box_New','372874');
        createdSRList1[0].Agent_Name__c='test';
        createdSRList1[0].agent_mobile_Number__c ='dfgh';
        createdSRList1[0].HexaBPM__SR_Template__c = hst.Id;
        createdSRList1[0].Agent_Emirates_ID_Number__c ='353534535';  
        createdSRList1[0].HexaBPM__Customer__c = newAccounts[0].Id;
        insert createdSRList1;
               
        HexaBPM__Status__c stepStatus = new HexaBPM__Status__c(Name='Awaiting Typing',HexaBPM__Code__c='AWAITING_TYPING',HexaBPM__Type__c='Start');
        insert stepStatus;
        
        HexaBPM__Status__c status = new HexaBPM__Status__c(Name='Residence Visa Stamped',HexaBPM__Type__c='Intermediate',HexaBPM__Code__c='DOCUMENT_UPLOADED');
        insert status;
        
         HexaBPM__Status__c stepStatus1 = new HexaBPM__Status__c(Name='Typing Completed',HexaBPM__Type__c='End',HexaBPM__Code__c='TYPING_COMPLETED');
        insert stepStatus1;
        
        HexaBPM__Step_Template__c stepTemplate = new HexaBPM__Step_Template__c(Name='Typing',HexaBPM__Code__c='TYPING',HexaBPM__Step_RecordType_API_Name__c='General',HexaBPM__Summary__c='Typing');
        insert stepTemplate;
        
        HexaBPM__SR_Steps__c srSteps = new HexaBPM__SR_Steps__c(HexaBPM__SR_Template__c=hst.id,HexaBPM__Step_Template__c=stepTemplate.id,
                                                                HexaBPM__Start_Status__c=stepStatus.id,HexaBPM__Active__c=true,HexaBPM__Summary__c='Typing',
                                                                HexaBPM__Step_RecordType_API_Name__c='General',HexaBPM__Step_Type__c='Quick Action',HexaBPM__Group_Name__c='Typing');
        insert srSteps;
        
        HexaBPM__Step__c step = new HexaBPM__Step__c();
        step.HexaBPM__SR__c = createdSRList1[0].id;
        step.HexaBPM__Status__c = stepStatus.id;
        step.HexaBPM__SR_Step__c = srSteps.id;
        step.HexaBPM__Step_Template__c = stepTemplate.id;
        step.HexaBPM__Summary__c ='Typing';
        step.ownerId =userinfo.getUserId();
       // step.IsDeleted=false;
        insert step;        
        
        HexaBPM__Step__c stp =[select Id,Name,HexaBPM__Summary__c,RecordTypeId,HexaBPM__Step_Status__c,RecordType.DeveloperName,OwnerId,Owner.Name,RecordType.Name,HexaBPM__SR_Step__r.Document_Validity_Check__c,
                HexaBPM__Parent_Step__c,HexaBPM__SR__c,HexaBPM__SR__r.HexaBPM__SR_Template__c,HexaBPM__SR__r.HexaBPM__Parent_Step__c,HexaBPM__SR__r.HexaBPM__Parent_SR__c,HexaBPM__SR__r.Start_Date__c,HexaBPM__SR__r.End_Date__c,
                HexaBPM__SR__r.HexaBPM__Customer__c,HexaBPM__SR__r.HexaBPM__Customer__r.Registration_Date__c,HexaBPM__SR__r.HexaBPM__Customer__r.License_Expiry_Date__c,HexaBPM__SR__r.Service_Request_Name__c,HexaBPM__Status__c,HexaBPM__SR__r.Age_Days__c
                from HexaBPM__Step__c where IsDeleted=false];
        
        system.debug('step--->'+stp);
        stp =[select Id,Name,HexaBPM__Summary__c,RecordTypeId,HexaBPM__Step_Status__c,RecordType.DeveloperName,OwnerId,Owner.Name,RecordType.Name,HexaBPM__SR_Step__r.Document_Validity_Check__c,
                HexaBPM__Parent_Step__c,HexaBPM__SR__c,HexaBPM__SR__r.HexaBPM__SR_Template__c,HexaBPM__SR__r.HexaBPM__Parent_Step__c,HexaBPM__SR__r.HexaBPM__Parent_SR__c,HexaBPM__SR__r.Start_Date__c,HexaBPM__SR__r.End_Date__c,
                HexaBPM__SR__r.HexaBPM__Customer__c,HexaBPM__SR__r.HexaBPM__Customer__r.Registration_Date__c,HexaBPM__SR__r.HexaBPM__Customer__r.License_Expiry_Date__c,HexaBPM__SR__r.Service_Request_Name__c,HexaBPM__Status__c,HexaBPM__SR__r.Age_Days__c
                from HexaBPM__Step__c where Id=:step.Id and HexaBPM__SR__c!=null ];
        system.debug('step--->'+stp);
        
        stp =[select Id,Name,HexaBPM__Summary__c,RecordTypeId,HexaBPM__Step_Status__c,RecordType.DeveloperName,OwnerId,Owner.Name,RecordType.Name,HexaBPM__SR_Step__r.Document_Validity_Check__c,
                HexaBPM__Parent_Step__c,HexaBPM__SR__c,HexaBPM__SR__r.HexaBPM__SR_Template__c,HexaBPM__SR__r.HexaBPM__Parent_Step__c,HexaBPM__SR__r.HexaBPM__Parent_SR__c,HexaBPM__SR__r.Start_Date__c,HexaBPM__SR__r.End_Date__c,
                HexaBPM__SR__r.HexaBPM__Customer__c,HexaBPM__SR__r.HexaBPM__Customer__r.Registration_Date__c,HexaBPM__SR__r.HexaBPM__Customer__r.License_Expiry_Date__c,HexaBPM__SR__r.Service_Request_Name__c,HexaBPM__Status__c,HexaBPM__SR__r.Age_Days__c
                from HexaBPM__Step__c where  HexaBPM__SR__r.HexaBPM__SR_Template__c !=null and IsDeleted=false];
        system.debug('step--->'+stp);
        HexaBPM__Transition__c transition = new HexaBPM__Transition__c(HexaBPM__From__c=stepStatus.id,HexaBPM__To__c=stepStatus1.id);
        insert transition;
        HexaBPM__SR_Status__c srStatus = new HexaBPM__SR_Status__c(Name='Typing',HexaBPM__Code__c='TYPING');
        insert srStatus;
        //HexaBPM__SR_Status__c srStatus1 = new HexaBPM__SR_Status__c(Name='Application Verified',HexaBPM__Code__c='APPLICATION_VERIFIED');
        //insert srStatus1;
        
        HexaBPM__Step_Transition__c stepTransition = new HexaBPM__Step_Transition__c
            (HexaBPM__SR_Step__c=srSteps.id,HexaBPM__Transition__c=transition.id,
             HexaBPM__SR_Status_Internal__c=srStatus.id,
             HexaBPM__SR_Status_External__c=srStatus.id,
             HexaBPM__Display_on_Portal__c=true);
        insert stepTransition;
        
        system.debug('--->'+stepTransition);
        system.debug('--->'+stepTransition.HexaBPM__Parent_SR_Status__c);
        ApexPages.standardController SC = new Apexpages.standardController(createdSRList1[0]);
        ApexPages.currentpage().getParameters().put('Id',createdSRList1[0].id);
        ApexPages.currentpage().getParameters().put('stepId',step.id);
        QuickStepTransitionController qst = new QuickStepTransitionController(SC);
        qst.userType ='Community';
        qst.CheckAccess();
        qst.AcceptAction();
        qst.selTransition = stepStatus1.Id;
        qst.SaveChanges();
      
    }
    
    private static testMethod void QuickStepTransitionControllerDep_Visa() {
        
        Id contactRecordTypeid;
        Map <String,Schema.RecordTypeInfo> recordTypeMap = Contact.sObjectType.getDescribe().getRecordTypeInfosByName();
        if(recordTypeMap.containsKey('Contact - Dependent')) {
         contactRecordTypeid = recordTypeMap.get('Contact - Dependent').getRecordTypeId();
        }
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 
        
         List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        //newContacts[0].Employment_Type__c = 'Employee Work Permit(UAE/GCC National)';
        newContacts[0].recordtypeid = contactRecordTypeid;
        insert newContacts;  
        
        HexaBPM__SR_Template__c hst = new HexaBPM__SR_Template__c();
        hst.HexaBPM__Active__c = true;
        hst.Name='Dependent_Visa_New';
        hst.HexaBPM__SR_RecordType_API_Name__c = 'Dependent_Visa_New';
        insert hst;
            
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR1(1,'Dependent_Visa_New','475937');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].id;
        createdSRList[0].HexaBPM__SR_Template__c = hst.id;
        createdSRList[0].Work_Permit_Validity__c='12';
        createdSRList[0].Residence_Visa_Date_of_Expiry__c=Date.today().addDays(100);
        createdSRList[0].Passport_Expiry_Date__c = Date.today().addDays(100);
        createdSRList[0].Unified_ID_No__c= '1234';
        createdSRList[0].Residence_Visa_Number__c= '1234';
        insert createdSRList;
        HexaBPM__Status__c status = new HexaBPM__Status__c(Name='Awaiting Verification',HexaBPM__Code__c='DOCUMENT_UPLOADED',HexaBPM__Type__c='Start');
        
        HexaBPM__Status__c stepStatus = new HexaBPM__Status__c(Name='Awaiting Verification',HexaBPM__Type__c='Intermediate',HexaBPM__Code__c='DOCUMENT_UPLOADED');
        insert stepStatus;
        
        HexaBPM__Step_Template__c stepTemplate = new HexaBPM__Step_Template__c(Name='Verification of Application',HexaBPM__Code__c='UPLOAD_HEALTH_INSURANCE_CARD',HexaBPM__Step_RecordType_API_Name__c='General',HexaBPM__Summary__c='Verification of Application');
        insert stepTemplate;
        
        HexaBPM__SR_Steps__c srSteps = new HexaBPM__SR_Steps__c(HexaBPM__SR_Template__c=hst.id,HexaBPM__Step_Template__c=stepTemplate.id,
        HexaBPM__Start_Status__c=stepStatus.id,HexaBPM__Active__c=true,HexaBPM__Summary__c='Verification of Application',
        HexaBPM__Step_RecordType_API_Name__c='General',HexaBPM__Step_Type__c='Quick Action',HexaBPM__Group_Name__c='Verification of Application');
        insert srSteps;
        
        HexaBPM__Step__c step = new HexaBPM__Step__c();
        step.HexaBPM__SR__c = createdSRList[0].id;
        step.HexaBPM__Status__c = status.id;
        step.HexaBPM__SR_Step__c = srSteps.id;
        step.HexaBPM__Step_Template__c = stepTemplate.id;
        insert step;        
        
         HexaBPM__Transition__c transition = new HexaBPM__Transition__c(HexaBPM__From__c=status.id,HexaBPM__To__c=stepStatus.id);
        insert transition;
        HexaBPM__SR_Status__c srStatus = new HexaBPM__SR_Status__c(Name='Awaiting Re-Upload',HexaBPM__Code__c='AWAITING_RE-UPLOAD');
        insert srStatus;
        
        HexaBPM__Step_Transition__c stepTransition = new HexaBPM__Step_Transition__c
        (HexaBPM__SR_Step__c=srSteps.id,HexaBPM__Transition__c=transition.id,HexaBPM__SR_Status_Internal__c=srStatus.id,HexaBPM__SR_Status_External__c=srStatus.id);
        insert stepTransition;
        
        ApexPages.standardController SC = new Apexpages.standardController(createdSRList[0]);
        ApexPages.currentpage().getParameters().put('Id',createdSRList[0].id);
        ApexPages.currentpage().getParameters().put('stepId',step.id);
        QuickStepTransitionController qst = new QuickStepTransitionController(SC);
        qst.CheckAccess();
        qst.selTransition = stepStatus.id;
        qst.SaveChanges();
        
        
        // Setup test data
        // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName=uniqueUserName);

        System.runAs(u) {
            SC = new Apexpages.standardController(createdSRList[0]);
            ApexPages.currentpage().getParameters().put('Id',createdSRList[0].id);
            ApexPages.currentpage().getParameters().put('stepId',step.id);
            qst = new QuickStepTransitionController(SC);
            qst.CheckAccess();
            qst.selTransition = stepStatus.id;
          }
    }
}
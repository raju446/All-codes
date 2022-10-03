@isTest
public with sharing class CaseTriggerHandlerTest {
    
    private static List<Case> createdCaseList; 
    private static List<Case> createdChildCase; 
    private static void init(){
    
        List<BusinessHours> busHours = [SELECT Id FROM BusinessHours WHERE Name = 'Business Admin Team Business Hours' LIMIT 1];
        
        createdCaseList = TestClassUtility.createCase(new List<Case>{new Case()});
        createdChildCase  = TestClassUtility.createCase(new List<Case>{new Case()});
       
       List<SLA_Configuration__c> listCaseSLA = new List<SLA_Configuration__c>();
        SLA_Configuration__c sla = new SLA_Configuration__c();
        sla.Name = 'Business Admin Team';
        sla.Business_Hour_Id__c =   busHours[0].Id;
        sla.Queue_Name__c = 'Business Admin Team';
        sla.SLA_Hours__c = 16;
        sla.SLA_Minutes__c = 960;
        listCaseSLA.add(sla);
        sla = new SLA_Configuration__c();
        sla.Name = 'ADGM Support';
        sla.Business_Hour_Id__c =   busHours[0].Id;
        sla.Queue_Name__c = 'ADGM Support';
        sla.SLA_Hours__c = 16;
        sla.SLA_Minutes__c = 960;
        listCaseSLA.add(sla);
        insert listCaseSLA;
        
        
        
    }
    
    public static testmethod void testcase(){
        List<BusinessHours> busHours = [SELECT Id FROM BusinessHours WHERE Name = 'Business Admin Team Business Hours' LIMIT 1];
        List<SLA_Configuration__c> listCaseSLA = new List<SLA_Configuration__c>();
        SLA_Configuration__c sla = new SLA_Configuration__c();
        sla.Name = 'Client Support Centre';
        sla.SLA_Type__c = 'queue & level';
        sla.Business_Hour_Id__c =   busHours[0].Id;
        sla.Queue_Name__c = 'Client Support Centre';
        sla.Level__c = 'Level 1';
        sla.Case_Origin__c = 'Client Support Centre Email,Manual, , ACCESSADGM Portal – Live Chat';
        sla.SLA_Hours__c = 16;
        sla.SLA_Minutes__c = 960;
        listCaseSLA.add(sla);
        sla = new SLA_Configuration__c();
        sla.Name = 'Business Admin Team';
        sla.SLA_Type__c = 'queue';
        sla.Business_Hour_Id__c =   busHours[0].Id;
        sla.Queue_Name__c = 'Business Admin Team';
        sla.Case_Origin__c = 'Client Support Centre Email,Manual,, ACCESSADGM Portal – Live Chat';
        sla.SLA_Hours__c = 16;
        sla.SLA_Minutes__c = 960;
        listCaseSLA.add(sla);
        insert listCaseSLA;

        Group testGroup = new Group(Name='Client Support Centre', Type='Queue');
        insert testGroup;
        Group testGroup2 = new Group(Name='Business Admin Team', Type='Queue');
        insert testGroup2;

        Trigger_Settings__c value = new Trigger_Settings__c();
        value.is_Active__c = true;
        value.Name = 'CaseOwnershipValidation';
        insert value;


        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject testQueue1 = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue1;
            QueuesObject testQueue2 = new QueueSObject(QueueID = testGroup2.id, SObjectType = 'Case');
            insert testQueue2;

            GroupMember gm = new GroupMember(GroupId = testGroup.id, UserOrGroupId = UserInfo.getUserId());
            insert gm;
            GroupMember gm2 = new GroupMember(GroupId = testGroup2.id, UserOrGroupId = UserInfo.getUserId());
            insert gm2;

        }
        
        Case aCase = new Case(origin = 'manual',CRM_First_name__c = 'test',CRM_Last_name__c = 'test',Email_Address__c = 'test@test.com',Priority='Level 1'); //
        insert aCase;
        
        aCase.OwnerId = testGroup2.Id;
        aCase.Origin='Manual';
        aCase.CRM_Automatic_owner_change__c = true;
        aCase.CRM_Update_counter__c = 4;
        CaseTriggerHelper.OwnerChangeFromButton=true;
        update aCase;

        aCase.OwnerId = UserInfo.getUserId();
        update aCase;

        aCase.OwnerId = testGroup.Id;
        aCase.Priority = 'Level 2';
        update aCase;

        aCase.OwnerId = testGroup.Id;
        aCase.Priority = 'Level 1';
        update aCase;

        Case caseRec = new Case(OwnerId = testGroup2.Id,Status='In Progress', Parent_Case__c = aCase.Id, origin = 'Web',CRM_First_name__c = 'test',CRM_Last_name__c = 'test',Email_Address__c = 'test@test.com',Priority='Level 1'); //
        insert caseRec;
        caseRec.OwnerId = UserInfo.getUserId();
        caseRec.Status = 'Closed';
        update caseRec;

    }
    @isTest
    public static void BDCase(){
    
        List<BusinessHours> busHours = [SELECT Id FROM BusinessHours WHERE Name = 'Business Admin Team Business Hours' LIMIT 1];
        
         List<SLA_Configuration__c> listCaseSLA = new List<SLA_Configuration__c>();
        SLA_Configuration__c sla = new SLA_Configuration__c();
        sla.Name = 'Business Admin Team';
        sla.Business_Hour_Id__c =   busHours[0].Id;
        sla.SLA_Hours__c = 16;
        sla.Level__c='New';
        sla.SLA_Minutes__c = 960;
        sla.Module__c = system.label.CaseRecordTypeBDQueries;
        listCaseSLA.add(sla);
        
        sla = new SLA_Configuration__c();
        sla.Name = 'ADGM Support';
        sla.Business_Hour_Id__c =   busHours[0].Id;
        sla.Queue_Name__c = 'ADGM Support';
        sla.Level__c='Accepted';
        sla.SLA_Hours__c = 16;
        sla.SLA_Minutes__c = 960;
        sla.Module__c = system.label.CaseRecordTypeBDQueries;
        listCaseSLA.add(sla);
        
        insert listCaseSLA;
        
        map<String,ID> caseRecordTypeMap=ApexCodeUtility.getRecTypeDetails('Case');
        case caseRec = new Case(Subject='Test',Status='New',origin='Email',recordTypeId= caseRecordTypeMap.get(system.label.CaseRecordTypeBDQueries));
        insert caseRec;
        
        caseRec.Status='Accepted';
        caseRec.OwnerID=UserInfo.getUserId();
        Update caseRec; 
        test.startTest();
        caseRec.Status='Closed';
        Update caseRec; 
        test.stopTest();
    }
}
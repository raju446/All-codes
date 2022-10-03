/**
*   Author      : Azmath
*   Descritpion : Test class for StepTriggerHandler
*/
@isTest
public with sharing class StepTriggerHandlerTest
{
    static testMethod void StepTriggerHandlerUT()
    {
        Account acc                             = ICA_TestDataFactory.CreateAccountwithRolesandAddress();
        HexaBPM__Service_Request__c srrec       = ICA_TestDataFactory.CreateNewEstbSR(acc.id);
        HexaBPM__SR_Template__c template        = ICA_TestDataFactory.createTemplate('Establishment_Card_New');
        HexaBPM__Step_Template__c steptemplate  = new HexaBPM__Step_Template__c(Name='Get New Draft Number',
                                                    HexaBPM__Code__c='GET_NEW_DRAFT_NUMBER',
                                                    HexaBPM__Step_RecordType_API_Name__c='General');
        insert steptemplate;
        HexaBPM__Step_Template__c steptemplate1  = new HexaBPM__Step_Template__c(Name='Get New Draft Number',
                                                    HexaBPM__Code__c='RESUBMIT_APPLICATION',
                                                    HexaBPM__Step_RecordType_API_Name__c='General');
        insert steptemplate1;
        
        
        HexaBPM__Status__c stepstatus = new HexaBPM__Status__c(HexaBPM__Code__c='GET_NEW_DRAFT_NUMBER',Name='Get New Draft Number',
                                                              HexaBPM__Type__c='End');
        insert stepstatus;
        
        HexaBPM__SR_Steps__c srstep = new HexaBPM__SR_Steps__c(HexaBPM__Summary__c='Get New Draft Number',
                                                               HexaBPM__SR_Template__c=template.id,
                                                               HexaBPM__Step_Template__c=steptemplate.id,
                                                               HexaBPM__Step_RecordType_API_Name__c='Get New Draft Number');
        insert srstep;
        HexaBPM__SR_Steps__c srstep1 = new HexaBPM__SR_Steps__c(HexaBPM__Summary__c='Get New Draft Number',
                                                               HexaBPM__SR_Template__c=template.id,
                                                               HexaBPM__Step_Template__c=steptemplate1.id,
                                                               HexaBPM__Step_RecordType_API_Name__c='Get New Draft Number');
        insert srstep1;
        HexaBPM__Step__c step = new HexaBPM__Step__c(HexaBPM__SR__c=srrec.id, 
                                                     HexaBPM__Summary__c='Get New Draft Number', 
                                                     HexaBPM__Start_Date__c=Date.today(), 
                                                     HexaBPM__SR_Step__c=SRstep.id,
                                                     HexaBPM__Step_Template__c=steptemplate.id);
                                                     //HexaBPM__Status__c=stepstatus.id);
        insert step;
        step.HexaBPM__Status__c = stepstatus.id;
        step.HexaBPM__SR_Step__c=SRstep1.id;
        update step;
        
    }
    static testMethod void StepTriggerHandlerUT1()
    {
        Account acc                             = ICA_TestDataFactory.CreateAccountwithRolesandAddress();
        HexaBPM__Service_Request__c srrec       = ICA_TestDataFactory.CreateNewEstbSR(acc.id);
        HexaBPM__SR_Template__c template        = ICA_TestDataFactory.createTemplate('Establishment_Card_New');
        HexaBPM__Step_Template__c steptemplate  = new HexaBPM__Step_Template__c(Name='Re Submit Application',
                                                    HexaBPM__Code__c='RESUBMIT_APPLICATION',
                                                    HexaBPM__Step_RecordType_API_Name__c='General');
        insert steptemplate;
        HexaBPM__Step_Template__c steptemplate1  = new HexaBPM__Step_Template__c(Name='RE UPLOAD DOCUMENTS',
                                                    HexaBPM__Code__c='REUPLOAD_DOCUMENTS',
                                                    HexaBPM__Step_RecordType_API_Name__c='General');
        insert steptemplate1;
        
        
        HexaBPM__Status__c stepstatus = new HexaBPM__Status__c(HexaBPM__Code__c='RESUBMIT_APPLICATION',Name='Re Submit Application',
                                                              HexaBPM__Type__c='End');
        insert stepstatus;
        
        HexaBPM__SR_Steps__c srstep = new HexaBPM__SR_Steps__c(HexaBPM__Summary__c='Re Submit Application',
                                                               HexaBPM__SR_Template__c=template.id,
                                                               HexaBPM__Step_Template__c=steptemplate.id,
                                                               HexaBPM__Step_RecordType_API_Name__c='Re Submit Application');
        insert srstep;
        HexaBPM__SR_Steps__c srstep1 = new HexaBPM__SR_Steps__c(HexaBPM__Summary__c='Re Submit Application',
                                                               HexaBPM__SR_Template__c=template.id,
                                                               HexaBPM__Step_Template__c=steptemplate1.id,
                                                               HexaBPM__Step_RecordType_API_Name__c='Re Submit Application');
        insert srstep1;
        HexaBPM__Step__c step = new HexaBPM__Step__c(HexaBPM__SR__c=srrec.id, 
                                                     HexaBPM__Summary__c='Re Submit Application', 
                                                     HexaBPM__Start_Date__c=Date.today(), 
                                                     HexaBPM__SR_Step__c=SRstep.id,
                                                     HexaBPM__Step_Template__c=steptemplate.id);
                                                     //HexaBPM__Status__c=stepstatus.id);
        insert step;
        step.HexaBPM__Status__c = stepstatus.id;
        step.HexaBPM__SR_Step__c=SRstep1.id;
        update step;
        
    }
    static testMethod void StepTriggerHandlerUT2()
    {
        Account acc                             = ICA_TestDataFactory.CreateAccountwithRolesandAddress();
        HexaBPM__Service_Request__c srrec       = ICA_TestDataFactory.CreateNewEstbSR(acc.id);
        HexaBPM__SR_Template__c template        = ICA_TestDataFactory.createTemplate('Establishment_Card_New');
        HexaBPM__Step_Template__c steptemplate  = new HexaBPM__Step_Template__c(Name='RE UPLOAD DOCUMENTS',
                                                    HexaBPM__Code__c='REUPLOAD_DOCUMENTS',
                                                    HexaBPM__Step_RecordType_API_Name__c='General');
        insert steptemplate;
        HexaBPM__Step_Template__c steptemplate1  = new HexaBPM__Step_Template__c(Name='CONFIRM RESUBMIT',
                                                    HexaBPM__Code__c='CONFIRM_RESUBMIT',
                                                    HexaBPM__Step_RecordType_API_Name__c='General');
        insert steptemplate1;
        
        
        HexaBPM__Status__c stepstatus = new HexaBPM__Status__c(HexaBPM__Code__c='REUPLOAD_DOCUMENTS',Name='Document Uploaded',
                                                              HexaBPM__Type__c='End');
        insert stepstatus;
        
        HexaBPM__SR_Steps__c srstep = new HexaBPM__SR_Steps__c(HexaBPM__Summary__c='REUPLOAD_DOCUMENTS',
                                                               HexaBPM__SR_Template__c=template.id,
                                                               HexaBPM__Step_Template__c=steptemplate.id,
                                                               HexaBPM__Step_RecordType_API_Name__c='REUPLOAD_DOCUMENTS');
        insert srstep;
        HexaBPM__SR_Steps__c srstep1 = new HexaBPM__SR_Steps__c(HexaBPM__Summary__c='REUPLOAD_DOCUMENTS',
                                                               HexaBPM__SR_Template__c=template.id,
                                                               HexaBPM__Step_Template__c=steptemplate1.id,
                                                               HexaBPM__Step_RecordType_API_Name__c='REUPLOAD_DOCUMENTS');
        insert srstep1;
        HexaBPM__Step__c step = new HexaBPM__Step__c(HexaBPM__SR__c=srrec.id, 
                                                     HexaBPM__Summary__c='REUPLOAD_DOCUMENTS', 
                                                     HexaBPM__Start_Date__c=Date.today(), 
                                                     HexaBPM__SR_Step__c=SRstep.id,
                                                     HexaBPM__Step_Template__c=steptemplate.id);
                                                     
        insert step;
        step.HexaBPM__Status__c = stepstatus.id;
        step.HexaBPM__SR_Step__c=SRstep1.id;
        update step;
        
    }
}
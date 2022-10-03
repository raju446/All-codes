@isTest
public with sharing class ParticipantRequiredTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<Account> createdAccountList; 
    
    private static void init(){
        HexaBPM__SR_Template__c srtemp = new HexaBPM__SR_Template__c();
        srtemp.Name = 'Trainings and Seminars Permit';
        srtemp.HexaBPM__SR_RecordType_API_Name__c = 'Initial_Approval';
        insert srtemp;
        createdAccountList = TestClassUtility.createAccounts(1);
        createdAccountList[0].Oracle_Party_Id__c = 'test';
        insert createdAccountList;
        
        createdSRList = TestUtility.createSR(1,'Update_Salary_and_Position');
        createdSRList[0].HexaBPM__SR_Template__c = srtemp.Id;
        createdSRList[0].Type_of_Entertainment__c = 'None';
        createdSRList[0].Speaker_present__c = 'Yes';
        createdSRList[0].HexaBPM__FinalizeAmendmentFlg__c = true;
        createdSRList[0].HexaBPM__Customer__c = createdAccountList[0].Id;
        insert createdSRList;     
    }
    public static testmethod void testcase(){
        init();
        String id  = createdSRList[0].Id;
        ParticipantRequired con = new ParticipantRequired();
        ParticipantRequired.srParticipantValidation(id);
        ParticipantRequired.EmpimageValidation(createdSRList[0].id);
    }
    private static void init2(){
        HexaBPM__SR_Template__c srtemp = new HexaBPM__SR_Template__c();
        srtemp.Name = 'Events and Exhibition Permit';
        srtemp.HexaBPM__SR_RecordType_API_Name__c = 'Initial_Approval';
        insert srtemp;
        createdAccountList = TestClassUtility.createAccounts(1);
        createdAccountList[0].Oracle_Party_Id__c = 'test';
        insert createdAccountList;
        createdSRList = TestUtility.createSR(1,'Update_Salary_and_Position');
        createdSRList[0].HexaBPM__SR_Template__c = srtemp.Id;
        createdSRList[0].Type_of_Entertainment__c = 'None';
        createdSRList[0].Speaker_present__c = 'Yes';
        createdSRList[0].HexaBPM__FinalizeAmendmentFlg__c = true;
        createdSRList[0].HexaBPM__Customer__c = createdAccountList[0].Id;
        insert createdSRList;     
    }
    public static testmethod void testcase2(){
        test.startTest();
        init2();
        String id  = createdSRList[0].Id;
        ParticipantRequired con = new ParticipantRequired();
        ParticipantRequired.srParticipantValidation(id);
        
        try{
        createdAccountList = TestClassUtility.createAccounts(1);
        createdAccountList[0].Oracle_Party_Id__c = 'test1234';
        createdAccountList[0].Name = 'test1234';
        insert createdAccountList;
        createdSRList = TestUtility.createSR(1,'Temporary_Work_Permit_New');
        createdSRList[0].HexaBPM__Customer__c = createdAccountList[0].Id;
        createdSRList[0].HexaBPM__Customer__c = createdAccountList[0].Id;
        insert createdSRList;  
        ParticipantRequired.EmpimageValidation(createdSRList[0].id);
        }catch(exception e){}
        test.stopTest();
    }
  
    
}
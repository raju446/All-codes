@isTest
public with sharing class CC_ParticipantsArabicNameValidationTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    private static Amendment__c objAmm;
    private static HexaBPM__SR_Steps__c createSRstep;
    private static void init(){
    	createdSRList = TestUtility.createSR(1,'Initial_Approval');
        insert createdSRList;
		objAmm = new Amendment__c();
		objAmm.Full_Name__c = 'Test Participant 1';
		objAmm.Full_Name_Arabic__c = 'Test';
		objAmm.Passport_Number_Arabic__c = '123';
		objAmm.Service_Request__c = createdSRList[0].Id;
		objAmm.Nationality_New__c = 'Australia';
		insert objAmm;
    	createSRstep = new  HexaBPM__SR_Steps__c();
        insert createSRstep;
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,createSRstep.Id);
        insert createdstepList;     
    }
    public static testmethod void testcase(){
        init();
        CC_ParticipantsArabicNameValidation con = new CC_ParticipantsArabicNameValidation();
       // List<HexaBPM__Step__c> lstOfSteps = [SELECT Id FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        con.EvaluateCustomCode(null,createdstepList[0]);
    } 
    private static void init2(){
    	createdSRList = TestUtility.createSR(1,'Initial_Approval');
        insert createdSRList;
		objAmm = new Amendment__c();
		objAmm.Full_Name__c = 'Test Participant 1';
		objAmm.Full_Name_Arabic__c = '';
		objAmm.Passport_Number_Arabic__c = null;
		objAmm.Service_Request__c = createdSRList[0].Id;
		objAmm.Nationality_New__c = 'Australia';
		insert objAmm;
    	createSRstep = new  HexaBPM__SR_Steps__c();
        insert createSRstep;
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,createSRstep.Id);
        insert createdstepList;     
    }
    public static testmethod void testcase2(){
        init2();
        CC_ParticipantsArabicNameValidation con = new CC_ParticipantsArabicNameValidation();
        con.EvaluateCustomCode(null,createdstepList[0]);
    } 
}
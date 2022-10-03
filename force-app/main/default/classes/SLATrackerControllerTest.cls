@isTest
public with sharing class SLATrackerControllerTest {
    private static  List<Account> createdAccountList; 
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;
    private static Case_SLA__c csla; 
    private static List<Case> createdCaseList; 
    
    public static void init(){
        createdAccountList = TestClassUtility.createAccounts(1);
        insert createdAccountList;
        
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = createdAccountList[0].Id;  
        insert createdSRList;   
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList; 
        
        List<BusinessHours> busHours = [SELECT Id FROM BusinessHours WHERE Name = 'Business Admin Team Business Hours' LIMIT 1];
        
        createdCaseList = TestClassUtility.createCase(new List<Case>{new Case()});

        csla =new Case_SLA__c();
        csla.Business_Hours_Id__c =   busHours[0].Id;
        csla.From__c = system.today();
        csla.Until__c = system.today();
        csla.Calculated_Business_Minutes__c = 120;
        csla.Parent__c = createdCaseList[0].Id;
        csla.Change_Type__c = 'Owner';
        csla.Due_Date_Time__c = system.today().addDays(2);
        insert csla;
        
    }   
    
    public static testmethod void TestSLATrackerController(){
        init();
        
        system.currentPageReference().getParameters().put('Id', createdCaseList[0].Id);
        SLATrackerController alc = new SLATrackerController(new ApexPages.StandardController(csla));
    
        List<BusinessHours> busHours = [SELECT Id FROM BusinessHours WHERE Name = 'Business Admin Team Business Hours' LIMIT 1];

        csla =new Case_SLA__c();
        csla.Business_Hours_Id__c =   busHours[0].Id;
        csla.From__c = system.today();
        csla.Until__c = null;
        csla.Calculated_Business_Minutes__c = 120;
        csla.Parent__c = createdCaseList[0].Id;
        csla.Change_Type__c = 'Owner';
        csla.Due_Date_Time__c = system.today().addDays(2);
        insert csla;
        
        SLATrackerController alc1 = new SLATrackerController(new ApexPages.StandardController(csla));
    }
}
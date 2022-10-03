@isTest
public with sharing class StepOwnerAssignmentControllerTest {
    private static  List<Account> createdAccountList; 
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;
    
    public static void init(){
        createdAccountList = TestClassUtility.createAccounts(1);
        insert createdAccountList;
        
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = createdAccountList[0].Id;  
        insert createdSRList;   
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList; 
        
        
    }   
    
    public static testmethod void TestStepOwnerAssignmentController(){
        init();
        
        system.currentPageReference().getParameters().put('Id', createdSRList[0].Id);
        system.currentPageReference().getParameters().put('ActionType', 'Assign');
        system.currentPageReference().getParameters().put('StepId', createdstepList[0].Id);
        StepOwnerAssignmentController alc = new StepOwnerAssignmentController(new ApexPages.StandardController(createdstepList[0]));
        alc.DoAction();
        alc.CloseWindow();
    
    }
    public static testmethod void TestStepOwnerAssignmentController2(){
        init();
        
        system.currentPageReference().getParameters().put('Id', createdSRList[0].Id);
        system.currentPageReference().getParameters().put('ActionType', 'Release');
        system.currentPageReference().getParameters().put('StepId', createdstepList[0].Id);
        StepOwnerAssignmentController alc = new StepOwnerAssignmentController(new ApexPages.StandardController(createdstepList[0]));
        alc.DoAction();
        alc.CloseWindow();
    
    }
}
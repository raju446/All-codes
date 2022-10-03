@isTest
public with sharing class CourierConfirmationControllerTest {
    public static  List<Account> createdAccountList; 
    public static List<HexaBPM__Service_Request__c> createdSRList; 
    public static List<HexaBPM__Step__c> createdstepList;
    public static HexaBPM__SR_Steps__c createSRstep;
    
    public static void init(){
    
        createSRstep = new  HexaBPM__SR_Steps__c();
        insert createSRstep;
        
        createdAccountList = TestClassUtility.createAccounts(1);
        insert createdAccountList;
        
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = createdAccountList[0].Id;  
        insert createdSRList;   
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        createdstepList[0].HexaBPM__SR_Step__c = createSRstep.Id;
        insert createdstepList; 
    }   
    
    public static testmethod void TestCourierConfirmationController(){
        init();
        
        
        HexaBPM__Status__c status = new HexaBPM__Status__c();
        status.HexaBPM__Type__c = 'Start';
        status.HexaBPM__Code__c = 'CANCELLED_BY_CUSTOMER';
        insert status;
        
         HexaBPM__Status__c status1 = new HexaBPM__Status__c();
        status1.HexaBPM__Type__c = 'End';
        status1.HexaBPM__Code__c = 'COURIER';
        insert status1;
        
        String str = status1.Id;
        
        HexaBPM__Transition__c trans = new HexaBPM__Transition__c();
        trans.HexaBPM__To__c = status1.Id;
        trans.HexaBPM__From__c = status.Id;
        insert trans;    
        
        HexaBPM__SR_Status__c srStatus = new HexaBPM__SR_Status__c();
        srStatus.HexaBPM__Code__c = 'Test';
        insert srStatus;
        
        HexaBPM__Step_Transition__c stepTransition = new HexaBPM__Step_Transition__c();
        stepTransition.HexaBPM__SR_Status_Internal__c = srStatus.Id;
        stepTransition.HexaBPM__SR_Status_External__c = srStatus.Id;
        stepTransition.HexaBPM__SR_Step__c = createSRstep.Id;
        stepTransition.HexaBPM__Transition__c = trans.Id;
        stepTransition.HexaBPM__Display_on_Portal__c = true;
        insert stepTransition;
        
        system.currentPageReference().getParameters().put('Id', createdSRList[0].Id);
        system.currentPageReference().getParameters().put('StepId', createdstepList[0].Id);
        CourierConfirmationController alc = new CourierConfirmationController(new ApexPages.StandardController(createdstepList[0]));
        alc.CheckAccess();
        alc.selectedTransition = str;
        system.debug('##SELECTED: '+alc.selectedTransition);
        system.debug('##MAP: '+alc.mapStepTransition);
        alc.ConfirmDeliveryOption();
        alc.CancelAction();
         }   
}
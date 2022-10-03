@isTest
public with sharing class PaymentStepControllerTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    
    public static testmethod void TestPaymentStepController(){
	    
	    List<Account> newAccounts = TestClassUtility.createAccounts(1);
		insert newAccounts; 
					
		List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
		newContacts[0].Portal_User_Creation__c = true;
		
        newContacts[0].Community_Username__c = 'test255@adgm.portal';
		insert newContacts;  
		
		createdSRList = TestUtility.createSR(1,'Initial_Approval');
    	createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        insert createdSRList;
        
        HexaBPM__SR_Price_Item__c objPriceItem = new HexaBPM__SR_Price_Item__c();
           objPriceItem.HexaBPM__ServiceRequest__c = createdSRList[0].Id;
           objPriceItem.Entity__c  = newAccounts[0].Id;
           //objPriceItem.HexaBPM__Product__c = objPOBoxProduct[0].Id;
           //objPriceItem.HexaBPM__Price__c = ;
           //objPriceItem.Markup_Amount__c = ;
           //objPriceItem.Cost__c = ;
           objPriceItem.HexaBPM__Sys_Added_through_Code__c = true;
           objPriceItem.HexaBPM__Non_Reevaluate__c = true;
        	insert objPriceItem;
        
        HexaBPM__Status__c status = new HexaBPM__Status__c();
        status.HexaBPM__Type__c = 'End';
        status.HexaBPM__Code__c = 'CANCELLED_BY_CUSTOMER';
        insert status;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        createdstepList[0].HexaBPM__Status__c = status.Id;
        insert createdstepList; 
		
		User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
		
		
		system.runAs(portalUser){
			system.currentPageReference().getParameters().put('StepId', createdstepList[0].Id);
			system.currentPageReference().getParameters().put('Id', createdSRList[0].Id);
		    PaymentStepController prc = new PaymentStepController();
		    prc.CheckAccess();
		    prc.ConfirmPayment();
		    prc.CancelPayment();
		} 
 
	}
    
}
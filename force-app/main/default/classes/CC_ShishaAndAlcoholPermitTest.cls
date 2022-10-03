@isTest
public with sharing class CC_ShishaAndAlcoholPermitTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    private static HexaBPM__SR_Steps__c createSRstep;
    
    private static void init(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
		insert newAccounts; 
		
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
		insert newContacts;  
		  
		HexaBPM__SR_Template__c srtemp = new HexaBPM__SR_Template__c();
        srtemp.Name  = 'Letters & Permits';
        srtemp.HexaBPM__SR_RecordType_API_Name__c = 'Permit_Photography';
        insert srtemp;
                  
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        createdSRList[0].Valid_From__c = system.today();
        createdSRList[0].Valid_To__c = system.today();
        insert createdSRList;
        
        createSRstep = new  HexaBPM__SR_Steps__c();
        insert createSRstep;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,createSRstep.Id);
        insert createdstepList;     
    }
    public static testmethod void TestCC_ShishaAndAlcoholPermit(){
        init();
        Test.startTest();   
        CC_ShishaAndAlcoholPermit con = new CC_ShishaAndAlcoholPermit();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Customer__c, HexaBPM__SR__r.Service_Request_Name__c, HexaBPM__SR__r.Valid_From__c,
        																	HexaBPM__SR__r.Valid_To__c  FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
       	system.debug(lstOfSteps[0].HexaBPM__SR__r.HexaBPM__Customer__c);
        system.debug(lstOfSteps[0].HexaBPM__SR__r.Service_Request_Name__c);
        con.EvaluateCustomCode(null,lstOfSteps[0]);
        Test.stopTest();
    }
    
}
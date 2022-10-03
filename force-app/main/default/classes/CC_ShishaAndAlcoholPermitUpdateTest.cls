@isTest
public with sharing class CC_ShishaAndAlcoholPermitUpdateTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    private static HexaBPM__SR_Steps__c createSRstep;
    
    private static void init(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '00000001';
		insert newAccounts; 
		  
		HexaBPM__SR_Template__c srtemp = new HexaBPM__SR_Template__c();
        srtemp.Name  = 'Alcohol Permit';
        srtemp.HexaBPM__SR_RecordType_API_Name__c = 'Permit_Photography';
        insert srtemp;
                  
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        createdSRList[0].HexaBPM__SR_Template__c = srtemp.Id;
        insert createdSRList;
  		
  		
  		system.debug('#####  '+ createdSRList[0].HexaBPM__Customer__c );
        //createSRstep = new  HexaBPM__SR_Steps__c();
        //insert createSRstep;
        
		createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        
        insert createdstepList;   
        
        Document_Details__c docs = new Document_Details__c();  
	     docs.Document_Last_Renewed_Date__c=system.today();
	     docs.Document_Status__c='Active';
	     docs.Document_Type__c= 'Alcohol Permit';
	     docs.Document_Issue_Date__c= system.today();
	     docs.Document_Expiry_Date__c= system.today().addDays(3);
	     docs.Account__c = newAccounts[0].Id;
	     insert docs; 
	
    
      
    }
    public static testmethod void TestCC_ShishaAndAlcoholPermitUpdate(){
        init();
        Test.startTest();   
        CC_ShishaAndAlcoholPermitUpdate con = new CC_ShishaAndAlcoholPermitUpdate();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__c, HexaBPM__SR__r.HexaBPM__Customer__c, HexaBPM__SR__r.Service_Request_Name__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        
        system.debug(lstOfSteps[0].HexaBPM__SR__r.HexaBPM__Customer__c);
        system.debug(lstOfSteps[0].HexaBPM__SR__r.Service_Request_Name__c);
        con.EvaluateCustomCode(null,lstOfSteps[0]);
        Test.stopTest();
    }
    
}
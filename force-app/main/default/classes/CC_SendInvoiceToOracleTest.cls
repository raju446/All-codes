@isTest
public with sharing class CC_SendInvoiceToOracleTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;
    
    private static void init(){
    	
    	createdSRList = TestUtility.createSR(1,'Initial_Approval');
        insert createdSRList;
        
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        insert acc;
        
        List<Invoice__c> listInvoice = TestClassUtility.createInvoice(1,acc);
        listInvoice[0].GL_Date__c = system.today();
        listInvoice[0].Invoice_Date__c = system.today();
        listInvoice[0].Service_Request__c = createdSRList[0].Id;
        insert listInvoice;
        
        List<Invoice_Line_Item__c> listInvoiceLineItem = TestClassUtility.createInvoiceLineItem(1,listInvoice);
        insert listInvoiceLineItem;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList;
    }
    public static testmethod void TestCC_SendInvoiceToOracle(){
        init();
        CC_SendInvoiceToOracle con = new CC_SendInvoiceToOracle();
        //List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Customer__c,HexaBPM__SR__r.HexaBPM__Contact__c,HexaBPM__SR__r.HexaBPM__Record_Type_Name__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        con.EvaluateCustomCode(null,createdstepList[0]);
        CC_SendInvoiceToOracle.PushInvoiceToOracle_Future(createdSRList[0].Id);
      
    }
       
}
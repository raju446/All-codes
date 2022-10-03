@isTest
public with sharing class ReceiptTriggerHelperTest {
    
    public static testmethod void TestReceiptTriggerHandler(){
        Exchange_Rate__c er = new Exchange_Rate__c(USD_To_AED_Conversion_Rate__c = 3.6725,Conversion_Date__c = Date.today());
        insert er;
        OU_Basd_Invoice_Running_Number__c rn = new OU_Basd_Invoice_Running_Number__c(name = 'fsra',Operating_Unit__c = '103', Type__c = 'Receipt',Running_Number__c =1);
        insert rn;
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        acc[0].Oracle_site_id__c = '103';
        insert acc;
        Receipt__c recp = new Receipt__c(entity__c = acc[0].id);
        recp.Status__c='Success';
        recp.gl_date__c = DATE.today();
        recp.Payment_Method__c = 'Electronic Funds Transfer';
        insert recp;
        List<Receipt__c> recpList = new List<Receipt__c>(); 
        recpList.add(recp);
        ReceiptTriggerHelper rth = new ReceiptTriggerHelper();
        ReceiptTriggerHelper.updateCloseDateErrorJVs(new Set<Receipt__c>{recp});
        //ReceiptTriggerHelper.PustToOracle(recpList);
    }
    public static testmethod void TestReceiptTriggerHandler2(){
        Exchange_Rate__c er = new Exchange_Rate__c(USD_To_AED_Conversion_Rate__c = 3.6725,Conversion_Date__c = Date.today());
        insert er;
        OU_Basd_Invoice_Running_Number__c rn = new OU_Basd_Invoice_Running_Number__c(name = 'fsra',Operating_Unit__c = '103', Type__c = 'Receipt',Running_Number__c =1);
        insert rn;
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        acc[0].Oracle_site_id__c = '103';
        insert acc;
        Receipt__c recp = new Receipt__c(entity__c = acc[0].id);
        recp.Status__c='Success';
        recp.Payment_Method__c = 'Electronic Funds Transfer';
        insert recp;
        
        test.startTest();
            update recp;
        	recp.Status__c = 'Approved';
        	update recp;
        
        ReceiptTriggerHelper.updateCloseDateErrorJVs(new Set<Receipt__c>{recp});
        test.stopTest();
    }
}
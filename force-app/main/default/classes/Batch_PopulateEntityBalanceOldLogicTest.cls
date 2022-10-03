@isTest
public class Batch_PopulateEntityBalanceOldLogicTest {
    
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
    
    static testMethod void runTest1(){
        init();
        CC_SendInvoiceToOracle con = new CC_SendInvoiceToOracle();
        con.EvaluateCustomCode(null,createdstepList[0]);
        
        List<Receipt__c> receipts = TestClassUtility.createReceipt(1, [SELECT Id, Oracle_Party_Id__c, Source_System_Name__c FROM account]);
        receipts[0].Gl_date__c = date.today().addDays(-20);
        receipts[0].Payment_Method__c = 'Credit Card';
        receipts[0].Transaction_Reference__c = 'TRTEST123';
        receipts[0].Journal_Created__c=  true;
        receipts[0].Oracle_Receipt_Id__c = '1234432';
        insert receipts;
        
        CC_SendInvoiceToOracle.PushInvoiceToOracle_Future(createdSRList[0].Id);
        
        Related_Invoice_Receipt__c application = new Related_Invoice_Receipt__c();
        application.Receipt__c = receipts[0].Id;
        application.Invoice__c = [SELECT Id FROM Invoice__c][0].Id;
        application.Oracle_Applied_Amount__c = 100;
        INSERT application;
        UpdateAccessAdgmApplicationInvoices.updateAppliationInvoices();
        Test.startTest();
            Database.executeBatch(new Batch_PopulateEntityBalanceOldLogic());
        Test.stopTest();
        
    }
    
}
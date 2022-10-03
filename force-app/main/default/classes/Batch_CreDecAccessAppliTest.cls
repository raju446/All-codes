@isTest
public class Batch_CreDecAccessAppliTest {
    
    @isTest static void runTest1(){
        BusinessHours bHours = [SELECT Id FROM BusinessHours WHERE name ='FSRA'];
        Operating_Unit__c ou = new Operating_Unit__c(Oracle_Site_Id__c = '103', Source_System__c='FSRA', Business_Hour__c = bHours.Id,
                                                     Operating_Unit_Name__c = 'Financial Services Regulatory Authority OU', Entity_Code__c='02');
        insert ou;
        DateTime dt = Datetime.now();
        String curYear = String.ValueOf(Date.Today().Year());
        GL_Period_Configuration__c gp1 = new GL_Period_Configuration__c(Active__c=true, Month__c =dt.format('MMMM'), Year__c=curYear);
        insert gp1;
        
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        acc[0].Oracle_site_id__c = '103';
        insert acc;
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Permit_Alcohol');
        createdSRList[0].HexaBPM__Customer__c = acc[0].Id;
        insert createdSRList;
        
        List<Invoice__c> listInvoice = TestClassUtility.createInvoice(2,acc);
        listInvoice[0].Invoice_Balance__c = 100;
        listInvoice[0].GL_Date__c = Date.today().addDays(-20);
        listInvoice[0].Service_Request__c = createdSRList[0].Id;
        listInvoice[0].Status__c='Invoiced' ;  
        listInvoice[0].Generate_Document__c = true;
        listInvoice[0].Document_Version__c = 0;
        listInvoice[0].Journal_Created__c = true;
        listInvoice[0].Converted_Invoice_Balance__c = 460;
        listInvoice[0].Invoice_Balance__c = 460;
        
        listInvoice[1].Invoice_Balance__c = 100;
        listInvoice[1].GL_Date__c = Date.today().addDays(-20);
        listInvoice[1].Service_Request__c = createdSRList[0].Id;
        listInvoice[1].Status__c='Invoiced' ;  
        listInvoice[1].Generate_Document__c = true;
        listInvoice[1].Document_Version__c = 0;
        listInvoice[1].Journal_Created__c = true;
        listInvoice[1].Converted_Invoice_Balance__c = 460;
        listInvoice[1].Invoice_Balance__c = 460;
        insert listInvoice;
        
        /*List<Invoice_Line_Item__c> listInvoiceLineItem = TestClassUtility.createInvoiceLineItem(1,listInvoice);
        listInvoiceLineItem[0].recordtypeid = Schema.SObjectType.Invoice_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Invoice_Line_Item').getRecordTypeId();
        listInvoiceLineItem[0].Service_Type__c = 'Test';
        listInvoiceLineItem[0].Discount_Amount__c = 50;
        listInvoiceLineItem[0].Amount__c = 500.00;
        listInvoiceLineItem[0].Tax_Amount__c = 10.00;
        insert listInvoiceLineItem;*/
        
        List<Receipt__c> receipts = TestClassUtility.createReceipt(1, acc);
        receipts[0].Gl_date__c = date.today().addDays(-20);
        receipts[0].Payment_Method__c = 'Credit Card';
        receipts[0].Transaction_Reference__c = 'TRTEST123';
        receipts[0].Journal_Created__c=  true;
        receipts[0].Oracle_Receipt_Id__c = '1234432';
        receipts[0].amount__c = 700;
        receipts[0].Service_Request__c = createdSRList[0].Id;
        insert receipts;
        
        Test.startTest();
            Database.executeBatch(new Batch_CreDecAccessAppliAndJournalLine(), 2);
        Test.stopTest();
    }
    
}
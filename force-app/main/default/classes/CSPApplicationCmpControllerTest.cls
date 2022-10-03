@isTest
public class CSPApplicationCmpControllerTest {
	
    public static TestMethod void runTest1(){
        Journal_Header_Running_Number__c setting = new Journal_Header_Running_Number__c();
        setting.Name = 'Next Running Number';
        setting.Running_Number__c = 001;
        insert setting;
        
        List<GL_Combination_Setting__c> combinationLst = new List<GL_Combination_Setting__c>();
        GL_Combination_Setting__c gls1 = new GL_Combination_Setting__c(RecordTypeId =Schema.sObjectType.GL_Combination_Setting__c.getRecordTypeInfosByName().get('Account').getRecordTypeId(),
                                                                       Account_Type__c = 'Asset',
                                                                       Code__c = '12345',
                                                                       Active__c = true,
                                                                       Journal_Entry_Account__c = 'Receivable',
                                                                       Lookup_Code__c = 'ACCOUNTS RECEIVABLES',
                                                                       Lookup_Code_Meaning__c = 'Accounts Receivables',
                                                                       Payment_Currency__c = 'AED; USD',
                                                                       Related_Object__c = 'Invoice; Receipt');
        combinationLst.add(gls1);
        GL_Combination_Setting__c gls2 = new GL_Combination_Setting__c(RecordTypeId =Schema.sObjectType.GL_Combination_Setting__c.getRecordTypeInfosByName().get('Account').getRecordTypeId(),
                                                                       Account_Type__c = 'Asset',
                                                                       Code__c = '12345',
                                                                       Active__c = true,
                                                                       Journal_Entry_Account__c = 'Revenue',
                                                                       Lookup_Code__c = 'ACCOUNTS Revenue',
                                                                       Lookup_Code_Meaning__c = 'Accounts Revenue',
                                                                       Payment_Currency__c = 'AED; USD',
                                                                       Related_Object__c = 'Invoice; Receipt');
        combinationLst.add(gls2);
        
        GL_Combination_Setting__c gls3 = new GL_Combination_Setting__c(RecordTypeId =Schema.sObjectType.GL_Combination_Setting__c.getRecordTypeInfosByName().get('Cost Centre').getRecordTypeId(),
                                                                       Code__c = '201',
                                                                       Active__c = true,
                                                                       Lookup_Code__c = 'CEO',
                                                                       Lookup_Code_Meaning__c = 'CEO',
                                                                       Related_Object__c = 'Invoice');
        combinationLst.add(gls3);
        
        GL_Combination_Setting__c gls4 = new GL_Combination_Setting__c(RecordTypeId =Schema.sObjectType.GL_Combination_Setting__c.getRecordTypeInfosByName().get('Account').getRecordTypeId(),
                                                                       Code__c = '20225',
                                                                       Active__c = true,
                                                                       Journal_Entry_Account__c = 'Tax',
                                                                       Lookup_Code__c = 'Output VAT',
                                                                       Lookup_Code_Meaning__c = 'Output VAT',
                                                                       Payment_Currency__c = 'AED; USD',
                                                                       Related_Object__c = 'Invoice');
        combinationLst.add(gls4);
        
        GL_Combination_Setting__c gls5 = new GL_Combination_Setting__c(RecordTypeId =Schema.sObjectType.GL_Combination_Setting__c.getRecordTypeInfosByName().get('Account').getRecordTypeId(),
                                                                       Account_Type__c = 'Asset',
                                                                       Code__c = '11221',
                                                                       Active__c = true,
                                                                       Journal_Entry_Account__c = 'Unapplied',
                                                                       Lookup_Code__c = 'UNAPPLIED RECEIPTS',
                                                                       Lookup_Code_Meaning__c = 'Unapplied Receipts',
                                                                       Payment_Currency__c = 'AED; USD',
                                                                       Related_Object__c = 'Invoice; Receipt');
        combinationLst.add(gls5);
        insert combinationLst;
        
        
        
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
        List<Invoice__c> listInvoice = TestClassUtility.createInvoice(1,acc);
        listInvoice[0].Invoice_Balance__c = 100;
        listInvoice[0].GL_Date__c = Date.today().addDays(-70);
        insert listInvoice;
        listInvoice[0].Status__c='Approved' ;  
        listInvoice[0].Generate_Document__c = true;
        listInvoice[0].Document_Version__c = 0;
        listInvoice[0].Journal_Created__c = true;
        listInvoice[0].Payment_Currency__c = 'AED';
        listInvoice[0].Converted_Invoice_Balance__c = 460;
        listInvoice[0].Invoice_Balance__c = 460;
        update listInvoice;
        
        List<Invoice_Line_Item__c> listInvoiceLineItem = TestClassUtility.createInvoiceLineItem(1,listInvoice);
        listInvoiceLineItem[0].recordtypeid = Schema.SObjectType.Invoice_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Invoice_Line_Item').getRecordTypeId();
        listInvoiceLineItem[0].Service_Type__c = 'Test';
        listInvoiceLineItem[0].Discount_Amount__c = 50;
        listInvoiceLineItem[0].Amount__c = 500.00;
        listInvoiceLineItem[0].Tax_Amount__c = 10.00;
        insert listInvoiceLineItem;
        
        List<Receipt__c> receipts = TestClassUtility.createReceipt(1, acc);
        receipts[0].Gl_date__c = date.today().addDays(-70);
        receipts[0].Payment_Method__c = 'Credit Card';
        receipts[0].Transaction_Reference__c = 'TRTEST123';
        receipts[0].Journal_Created__c=  true;
        receipts[0].Oracle_Receipt_Id__c = '1234432';
        insert receipts;
        
        CSPApplicationCmpController.getReceiptDetails(acc[0].id);
        CSPApplicationCmpController.getInvoiceDetails(receipts[0].Id, acc[0].id, 'AED');
        
        
        List<CSPApplicationCmpController.ApplicationWrapper> apPLst = new List<CSPApplicationCmpController.ApplicationWrapper>();
        CSPApplicationCmpController.ApplicationWrapper appObj = new CSPApplicationCmpController.ApplicationWrapper();
        appObj.invoiceName = 'Inv Name';
        appObj.invoiceId = listInvoice[0].Id;
        appObj.receiptId = receipts[0].Id;
        appObj.glDate = System.today();
        appObj.appliedDate = System.today();
        appObj.appliedAmnt = listInvoice[0].Invoice_Balance__c;
        appObj.invAmnt = 100;
        appObj.invBalance = 100;
        appObj.isSelected = true;
		apPLst.add(appObj);

        CSPApplicationCmpController.createApplicationRecords(JSON.serialize(apPLst));
    }
    
}
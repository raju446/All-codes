@isTest
public class Batch_CreateInvoiceCancellationTest {
    @isTest static void runTest1(){
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
        insert gls1;
        GL_Combination_Setting__c gls2 = new GL_Combination_Setting__c(RecordTypeId =Schema.sObjectType.GL_Combination_Setting__c.getRecordTypeInfosByName().get('Account').getRecordTypeId(),
                                                                       Account_Type__c = 'Asset',
                                                                       Code__c = '12345',
                                                                       Active__c = true,
                                                                       Journal_Entry_Account__c = 'Revenue',
                                                                       Lookup_Code__c = 'ACCOUNTS Revenue',
                                                                       Lookup_Code_Meaning__c = 'Accounts Revenue',
                                                                       Payment_Currency__c = 'AED; USD',
                                                                       Related_Object__c = 'Invoice; Receipt');
        insert gls2;
        
         gls1 = new GL_Combination_Setting__c(RecordTypeId =Schema.sObjectType.GL_Combination_Setting__c.getRecordTypeInfosByName().get('Account').getRecordTypeId(),
                                                                       Account_Type__c = 'Asset',
                                                                       Code__c = '12345',
                                                                       Active__c = true,
                                                                       Journal_Entry_Account__c = 'Receivable',
                                                                       Lookup_Code__c = 'ACCOUNTS RECEIVABLES',
                                                                       Lookup_Code_Meaning__c = 'Accounts Receivables',
                                                                       Payment_Currency__c = 'AED; USD',
                                                                       Related_Object__c = 'Invoice; Receipt');
        combinationLst.add(gls1);
         gls2 = new GL_Combination_Setting__c(RecordTypeId =Schema.sObjectType.GL_Combination_Setting__c.getRecordTypeInfosByName().get('Account').getRecordTypeId(),
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
        
         gls1 = new GL_Combination_Setting__c(RecordTypeId =Schema.sObjectType.GL_Combination_Setting__c.getRecordTypeInfosByName().get('Account').getRecordTypeId(),
                                                                       Account_Type__c = 'Asset',
                                                                       Code__c = '11111',
                                                                       Active__c = true,
                                                                       Journal_Entry_Account__c = 'Cash',
                                                                       Lookup_Code__c = 'FAB BANK - AED CURRENT ACCOUNT',
                                                                       Lookup_Code_Meaning__c = 'FAB Bank - AED Current Account',
                                                                       Payment_Currency__c = 'AED',
                                                                       Related_Object__c = 'Receipt');
        combinationLst.add(gls1);
         gls2 = new GL_Combination_Setting__c(RecordTypeId =Schema.sObjectType.GL_Combination_Setting__c.getRecordTypeInfosByName().get('Account').getRecordTypeId(),
                                                                       Account_Type__c = 'Asset',
                                                                       Code__c = '11112',
                                                                       Active__c = true,
                                                                       Journal_Entry_Account__c = 'Cash',
                                                                       Lookup_Code__c = 'FAB BANK - USD CURRENT ACCOUNT',
                                                                       Lookup_Code_Meaning__c = 'FAB Bank - USD Current Account',
                                                                       Payment_Currency__c = 'USD',
                                                                       Related_Object__c = 'Receipt');
        combinationLst.add(gls2);
         gls3 = new GL_Combination_Setting__c(RecordTypeId =Schema.sObjectType.GL_Combination_Setting__c.getRecordTypeInfosByName().get('Account').getRecordTypeId(),
                                                                       Account_Type__c = 'Asset',
                                                                       Code__c = '11221',
                                                                       Active__c = true,
                                                                       Journal_Entry_Account__c = 'Unapplied',
                                                                       Lookup_Code__c = 'UNAPPLIED RECEIPTS',
                                                                       Lookup_Code_Meaning__c = 'Unapplied Receipts',
                                                                       Payment_Currency__c = 'AED; USD',
                                                                       Related_Object__c = 'Invoice; Receipt');
        combinationLst.add(gls3);
        
        gls4 = new GL_Combination_Setting__c(RecordTypeId =Schema.sObjectType.GL_Combination_Setting__c.getRecordTypeInfosByName().get('Account').getRecordTypeId(),
                                                                       Account_Type__c = 'Expense',
                                                                       Code__c = '50705',
                                                                       Active__c = true,
                                                                        Related_Object__c = 'Invoice',
                                                                       Journal_Entry_Account__c = 'Expense',
                                                                       Lookup_Code__c = 'Bank Charge',
                                                                       Lookup_Code_Meaning__c = 'Bank Charge');
        combinationLst.add(gls4);
        
        gls4 = new GL_Combination_Setting__c(RecordTypeId =Schema.sObjectType.GL_Combination_Setting__c.getRecordTypeInfosByName().get('Cost Centre').getRecordTypeId(),
                                                                      Code__c = '900',
                                                                       Active__c = true,
                                                                        Related_Object__c = 'Invoice',
                                                                       Lookup_Code__c = 'CORPORATE ALLCOATIONS',
                                                                       Lookup_Code_Meaning__c = 'Corporate Allcoations');
        combinationLst.add(gls4);
        
        INSERT combinationLst;
        
        BusinessHours bHours = [SELECT Id FROM BusinessHours WHERE name ='FSRA'];
        Operating_Unit__c ou = new Operating_Unit__c(Oracle_Site_Id__c = '104', Source_System__c='Access', Business_Hour__c = bHours.Id,
                                                     Operating_Unit_Name__c = 'Registration Authority OU', Entity_Code__c = '05');
        insert ou;
        DateTime dt = Datetime.now();
        String curYear = String.ValueOf(Date.Today().Year());
        GL_Period_Configuration__c gp1 = new GL_Period_Configuration__c(Active__c=true, Month__c =dt.format('MMMM'), Year__c=curYear);
        insert gp1;
        
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'RA';
        acc[0].Oracle_site_id__c = '104';
        insert acc;
        
        List<Invoice__c> listInvoice = TestClassUtility.createInvoice(1,acc);
        listInvoice[0].GL_Date__c = system.today();
        listInvoice[0].Invoice_Date__c = system.today();
        listInvoice[0].Payment_Term__c = 'IMMEDIATE';
        insert listInvoice;
        
        Journal_Header__c jhObj = new Journal_Header__c();
        jhObj.Transaction_Type__c = 'Sales Invoices';
        jhObj.Invoice__c = listInvoice[0].Id;
        INSERT jhObj;
        
        Journal_Entry__c jeObj = new Journal_Entry__c();
        jeObj.Journal_Header__c = jhObj.Id;
        jeObj.Debit_OC__c = 100;
        jeObj.Entity__c = '02';
        jeObj.Account_Segment__c = '02';
        jeObj.Account_Segment_Description__c = '02';
        jeObj.Entity_Description__c = '02';
        INSERT jeObj;
        
        test.startTest();
        System.debug('Limit SOQL===='+Limits.getQueries());
        Id adjustmentRecType = Schema.SObjectType.Invoice_Line_Item__c.getRecordTypeInfosByName().get('Adjustment').getRecordTypeId();
        List<Invoice_Line_Item__c> listInvoiceLineItem = TestClassUtility.createInvoiceLineItem(2,listInvoice);
        listInvoiceLineItem[0].recordtypeid = adjustmentRecType;
        listInvoiceLineItem[0].Activity_Name__c = 'Fee Waiver';
        listInvoiceLineItem[0].Tax__c = 'Out of scope 0%';
        listInvoiceLineItem[0].Date_Of_Adjustment__c = system.today();
        listInvoiceLineItem[0].Type__c = 'Invoice';
        listInvoiceLineItem[0].Oracle_Adjustment_No__c = '1234';
        listInvoiceLineItem[0].Amount__c = 0;
        listInvoiceLineItem[0].Department__c = 'CEO';
        listInvoiceLineItem[0].Service_Type__c = 'Corporate Services';
        listInvoiceLineItem[0].Service_Class__c = 'Business Service';
        listInvoiceLineItem[0].Revenue_Type__c='Corporate Services';
        
        
        listInvoiceLineItem[1].Tax__c = 'Out of scope 0%';
        listInvoiceLineItem[1].Type__c = 'Invoice';
        listInvoiceLineItem[1].Amount__c = 150;
        listInvoiceLineItem[1].Department__c = 'CEO';
        listInvoiceLineItem[1].Service_Type__c = 'Corporate Services';
        listInvoiceLineItem[1].Service_Class__c = 'Business Service';
        listInvoiceLineItem[1].Revenue_Type__c='Corporate Services';
        insert listInvoiceLineItem;
        
        Database.executeBatch(new Batch_CreateHistoricInvoiceCancellations(), 1);
    }
}
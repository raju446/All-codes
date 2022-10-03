@isTest
public class Batch_CreateDecCreditMemoJVsTest {
    
    @isTest static void runTest1(){
        Journal_Header_Running_Number__c setting = new Journal_Header_Running_Number__c();
        setting.Name = 'Next Running Number';
        setting.Running_Number__c = 001;
        insert setting;
    
        List<GL_Combination_Setting__c> combinationLst = new List<GL_Combination_Setting__c>();
        
        GL_Combination_Setting__c gls3 = new GL_Combination_Setting__c(RecordTypeId =Schema.sObjectType.GL_Combination_Setting__c.getRecordTypeInfosByName().get('Account').getRecordTypeId(),
                                                                       Account_Type__c = 'Asset',
                                                                       Code__c = '11221',
                                                                       Active__c = true,
                                                                       Journal_Entry_Account__c = 'Unapplied',
                                                                       Lookup_Code__c = 'UNAPPLIED RECEIPTS',
                                                                       Lookup_Code_Meaning__c = 'Unapplied Receipts',
                                                                       Payment_Currency__c = 'AED; USD',
                                                                       Related_Object__c = 'Invoice; Receipt');
        combinationLst.add(gls3);
        
        GL_Combination_Setting__c gls4 = new GL_Combination_Setting__c(RecordTypeId =Schema.sObjectType.GL_Combination_Setting__c.getRecordTypeInfosByName().get('Account').getRecordTypeId(),
                                                                       Account_Type__c = 'Asset',
                                                                       Code__c = '12345',
                                                                       Active__c = true,
                                                                       Journal_Entry_Account__c = 'Revenue',
                                                                       Lookup_Code__c = 'Test',
                                                                       Lookup_Code_Meaning__c = 'Test',
                                                                       Related_Service_Type__c = 'Test',
                                                                       Payment_Currency__c = 'AED; USD',
                                                                       Related_Object__c = 'Invoice; Receipt');
        combinationLst.add(gls4);
        
        GL_Combination_Setting__c gls5 = new GL_Combination_Setting__c(RecordTypeId =Schema.sObjectType.GL_Combination_Setting__c.getRecordTypeInfosByName().get('Cost Centre').getRecordTypeId(),
                                                                       Code__c = '201',
                                                                       Active__c = true,
                                                                       Lookup_Code__c = 'CEO',
                                                                       Lookup_Code_Meaning__c = 'CEO',
                                                                       Related_Object__c = 'Invoice');
        combinationLst.add(gls5);
        
        GL_Combination_Setting__c gls6 = new GL_Combination_Setting__c(RecordTypeId =Schema.sObjectType.GL_Combination_Setting__c.getRecordTypeInfosByName().get('Account').getRecordTypeId(),
                                                                       Code__c = '20225',
                                                                       Active__c = true,
                                                                       Journal_Entry_Account__c = 'Tax',
                                                                       Lookup_Code__c = 'Output VAT',
                                                                       Lookup_Code_Meaning__c = 'Output VAT',
                                                                       Payment_Currency__c = 'AED; USD',
                                                                       Related_Object__c = 'Invoice');
        combinationLst.add(gls6);
        INSERT combinationLst;
        
        BusinessHours bHours = [SELECT Id FROM BusinessHours WHERE name ='FSRA'];
        Operating_Unit__c ou = new Operating_Unit__c(Oracle_Site_Id__c = '103', Source_System__c='FSRA', Business_Hour__c = bHours.Id,
                                                     Operating_Unit_Name__c = 'Financial Services Regulatory Authority OU', Entity_Code__c = '02');
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
        listInvoice[0].RecordTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Credit_Memo').getRecordTypeId();
        listInvoice[0].GL_Date__c = Date.today().addDays(-25);
        listInvoice[0].Oracle_Invoice_Id__c = '12345432';
        insert listInvoice;
        listInvoice[0].Status__c='Approved' ; 
        
        listInvoice[0].Generate_Document__c = true;
        listInvoice[0].Document_Version__c = 0;
        update listInvoice;
        
        List<Invoice_Line_Item__c> listInvoiceLineItem = TestClassUtility.createInvoiceLineItem(2,listInvoice);
        listInvoiceLineItem[0].recordtypeid = Schema.SObjectType.Invoice_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Invoice_Line_Item').getRecordTypeId();
        listInvoiceLineItem[0].Revenue_Type__c = 'Test';
        listInvoiceLineItem[0].Service_Type__c = 'Test';
        listInvoiceLineItem[0].Discount_Amount__c = 50;
        listInvoiceLineItem[0].Amount__c = 500.00;
        listInvoiceLineItem[0].Department__c = 'CEO';
        listInvoiceLineItem[0].Tax_Amount__c = 10.00;
        
        
        listInvoiceLineItem[1].recordtypeid = Schema.SObjectType.Invoice_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Invoice_Line_Item').getRecordTypeId();
        listInvoiceLineItem[0].Revenue_Type__c = 'Test';
        listInvoiceLineItem[1].Service_Type__c = 'Test';
        listInvoiceLineItem[1].Discount_Amount__c = 50;
        listInvoiceLineItem[1].is_Discount__c = true;
        listInvoiceLineItem[1].Amount__c = 500.00;
        listInvoiceLineItem[1].Department__c = 'CEO';
        listInvoiceLineItem[1].Tax_Amount__c = 10.00;
        
        insert listInvoiceLineItem;
        
        Test.startTest();
            Database.executeBatch(new Batch_CreateDecCreditMemoJVs(),1);
        Test.stopTest();
    }
    
}
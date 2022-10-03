@isTest
private class BM_JournalEntryEngineTest {
    
    @isTest static void testMethod1() {
        
        Journal_Header_Running_Number__c setting = new Journal_Header_Running_Number__c();
        setting.Name = 'Next Running Number';
        setting.Running_Number__c = 001;
        insert setting;
        List<GL_Combination_Setting__c> combinationLst = new List<GL_Combination_Setting__c>();
        List<GL_Combination_Setting__c> combinationLst2 = new List<GL_Combination_Setting__c>();
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
        
        INSERT combinationLst;
         gls1 = new GL_Combination_Setting__c(RecordTypeId =Schema.sObjectType.GL_Combination_Setting__c.getRecordTypeInfosByName().get('Account').getRecordTypeId(),
                                                                       Account_Type__c = 'Asset',
                                                                       Code__c = '12345',
                                                                       Active__c = true,
                                                                       Journal_Entry_Account__c = 'Receivable',
                                                                       Lookup_Code__c = 'ACCOUNTS RECEIVABLES',
                                                                       Lookup_Code_Meaning__c = 'Accounts Receivables',
                                                                       Payment_Currency__c = 'AED; USD',
                                                                       Related_Object__c = 'Invoice; Receipt');
        insert gls1;
         gls2 = new GL_Combination_Setting__c(RecordTypeId =Schema.sObjectType.GL_Combination_Setting__c.getRecordTypeInfosByName().get('Account').getRecordTypeId(),
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
        combinationLst2.add(gls1);
         gls2 = new GL_Combination_Setting__c(RecordTypeId =Schema.sObjectType.GL_Combination_Setting__c.getRecordTypeInfosByName().get('Account').getRecordTypeId(),
                                                                       Account_Type__c = 'Asset',
                                                                       Code__c = '12345',
                                                                       Active__c = true,
                                                                       Journal_Entry_Account__c = 'Revenue',
                                                                       Lookup_Code__c = 'ACCOUNTS Revenue',
                                                                       Lookup_Code_Meaning__c = 'Accounts Revenue',
                                                                       Payment_Currency__c = 'AED; USD',
                                                                       Related_Object__c = 'Invoice; Receipt');
        combinationLst2.add(gls2);
        
         gls3 = new GL_Combination_Setting__c(RecordTypeId =Schema.sObjectType.GL_Combination_Setting__c.getRecordTypeInfosByName().get('Cost Centre').getRecordTypeId(),
                                                                       Code__c = '201',
                                                                       Active__c = true,
                                                                       Lookup_Code__c = 'CEO',
                                                                       Lookup_Code_Meaning__c = 'CEO',
                                                                       Related_Object__c = 'Invoice');
        combinationLst2.add(gls3);
        
         gls4 = new GL_Combination_Setting__c(RecordTypeId =Schema.sObjectType.GL_Combination_Setting__c.getRecordTypeInfosByName().get('Account').getRecordTypeId(),
                                                                       Code__c = '20225',
                                                                       Active__c = true,
                                                                       Journal_Entry_Account__c = 'Tax',
                                                                       Lookup_Code__c = 'Output VAT',
                                                                       Lookup_Code_Meaning__c = 'Output VAT',
                                                                       Payment_Currency__c = 'AED; USD',
                                                                       Related_Object__c = 'Invoice');
        combinationLst2.add(gls4);
        
         gls1 = new GL_Combination_Setting__c(RecordTypeId =Schema.sObjectType.GL_Combination_Setting__c.getRecordTypeInfosByName().get('Account').getRecordTypeId(),
                                                                       Account_Type__c = 'Asset',
                                                                       Code__c = '11111',
                                                                       Active__c = true,
                                                                       Journal_Entry_Account__c = 'Cash',
                                                                       Lookup_Code__c = 'FAB BANK - AED CURRENT ACCOUNT',
                                                                       Lookup_Code_Meaning__c = 'FAB Bank - AED Current Account',
                                                                       Payment_Currency__c = 'AED',
                                                                       Related_Object__c = 'Receipt');
        combinationLst2.add(gls1);
         gls2 = new GL_Combination_Setting__c(RecordTypeId =Schema.sObjectType.GL_Combination_Setting__c.getRecordTypeInfosByName().get('Account').getRecordTypeId(),
                                                                       Account_Type__c = 'Asset',
                                                                       Code__c = '11112',
                                                                       Active__c = true,
                                                                       Journal_Entry_Account__c = 'Cash',
                                                                       Lookup_Code__c = 'FAB BANK - USD CURRENT ACCOUNT',
                                                                       Lookup_Code_Meaning__c = 'FAB Bank - USD Current Account',
                                                                       Payment_Currency__c = 'USD',
                                                                       Related_Object__c = 'Receipt');
        combinationLst2.add(gls2);
         gls3 = new GL_Combination_Setting__c(RecordTypeId =Schema.sObjectType.GL_Combination_Setting__c.getRecordTypeInfosByName().get('Account').getRecordTypeId(),
                                                                       Account_Type__c = 'Asset',
                                                                       Code__c = '11221',
                                                                       Active__c = true,
                                                                       Journal_Entry_Account__c = 'Unapplied',
                                                                       Lookup_Code__c = 'UNAPPLIED RECEIPTS',
                                                                       Lookup_Code_Meaning__c = 'Unapplied Receipts',
                                                                       Payment_Currency__c = 'AED; USD',
                                                                       Related_Object__c = 'Invoice; Receipt');
        combinationLst2.add(gls3);
        
        INSERT combinationLst2;
        
        
        
        
        BusinessHours bHours = [SELECT Id FROM BusinessHours WHERE name ='FSRA'];
        Operating_Unit__c ou = new Operating_Unit__c(Oracle_Site_Id__c = '103', Source_System__c='FSRA', Business_Hour__c = bHours.Id,
                                                     Operating_Unit_Name__c = 'Financial Services Regulatory Authority OU', Entity_Code__c = '05', OU_Abbreviation__c = 'FSRA');
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
        listInvoice[0].GL_Date__c = Date.today();
        insert listInvoice;
        listInvoice[0].Status__c='Approved' ;  
        listInvoice[0].Generate_Document__c = true;
        listInvoice[0].Document_Version__c = 0;
        update listInvoice;
        
        List<Invoice_Line_Item__c> listInvoiceLineItem = TestClassUtility.createInvoiceLineItem(1,listInvoice);
        listInvoiceLineItem[0].recordtypeid = Schema.SObjectType.Invoice_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Invoice_Line_Item').getRecordTypeId();
        listInvoiceLineItem[0].Revenue_Type__c = 'Accounts Revenue';
        listInvoiceLineItem[0].Service_Type__c = 'Test';
        listInvoiceLineItem[0].Discount_Amount__c = 50;
        listInvoiceLineItem[0].Amount__c = 500.00;
        listInvoiceLineItem[0].Tax_Amount__c = 10.00;
        insert listInvoiceLineItem;
        
        List<Receipt__c> receipts = TestClassUtility.createReceipt(2, acc);
        receipts[0].Gl_date__c = date.today();
        receipts[0].Payment_Method__c = 'Credit Card';
        receipts[0].Transaction_Reference__c = 'TRTEST123';
        receipts[1].Gl_date__c = date.today();
        receipts[1].Payment_Method__c = 'Electronic Funds Transfer';
        receipts[1].Transaction_Reference__c = 'TRTEST1234';
        receipts[1].Status__c = 'Success';
        insert receipts;
        
        List<Receipt__c> listReceipt = receipts;
        
        
        List<Related_Invoice_Receipt__c> listReceiptInvoice = TestClassUtility.createRelatedInvoiceReceipt(1,listInvoice, listReceipt );
        listReceiptInvoice[0].Direction__c = 'From Invoice To Receipt';
        listReceiptInvoice[0].Amount_Applied__c = 10;
        listReceiptInvoice[0].Applied_Date__c = system.today();
        upsert listReceiptInvoice;
        
        List<Fund_Transfer__c> fts = TestClassUtility.createFundTransfer(1,acc,acc);
        fts[0].Reference_Receipt__c = receipts[0].Id;
        fts[0].to_receipt__c = receipts[1].Id;
        insert fts;
        
        List<Refund__c> listRefund = TestClassUtility.createRefund(1, acc, receipts);
        listRefund[0].Payment_Method__c = 'Bank Transfer';
        listRefund[0].Scenario__c = 'Receipt generated but invoice not generated';
        insert listRefund;
        
        Id invId = listInvoice[0].Id;
        Id accId = acc[0].Id;
        Journal_Header__c jh = new Journal_Header__c(Name='JV-001',Transaction_Type__c='Sales Invoices',Invoice__c=invId,Account__c=accId);
        insert jh;
        
        Journal_Entry__c je = new Journal_Entry__c(Name='JV-001-1',Journal_Header__c=jh.Id,Invoice__c=invId,Account__c='Testtt',Account_Segment__c='00000',Debit_OC__c=1045.00,Credit_OC__c=0.0,Entity__c = '00',
                                                   Account_Segment_Description__c = 'TESTTT',Entity_Description__c = 'Registration Authority OU');
        insert je;
        
        test.startTest();
        BM_JournalEntryEngine.getActiveGLDates();
        BM_JournalEntryEngine.invoiceAdjustmentCreationJournal(new List<Id>{listInvoiceLineItem[0].Id});
        BM_JournalEntryEngine.discountAdjustmentCreationJournal(new List<Id>{listInvoiceLineItem[0].Id});
        BM_JournalEntryEngine.creditMemoCreationJournal(new List<Id>{listInvoice[0].Id});
        BM_JournalEntryEngine.invoiceCreationJournal(new List<Id>{listInvoice[0].Id});
        BM_JournalEntryEngine.creditMemoApplicationJournalLines(new List<Id>{listInvoiceLineItem[0].Id});
        BM_JournalEntryEngine.receiptCreationJournal(new List<Id>{receipts[1].Id});
        BM_JournalEntryEngine.receiptApplicationJournalLines(new List<Id>{listReceiptInvoice[0].Id});
        BM_JournalEntryEngine.refundJournalLines(new List<Id>{listRefund[0].Id});
        BM_JournalEntryEngine.fundTransferJournalEntries(new List<Id>{fts[0].Id});
        BM_JournalEntryEngine.createJournalLines('Invoice',listInvoice[0].Id,'Unapplied',Date.today(),'01','FSRA','01','test',0.0,100.0,'','','AED',1.0,'JV-001','');
        BM_JournalEntryEngine.journalEntryCreationForHeaderReversal(new List<Id>{jh.Id},'Sales Invoices');
        
        BM_JournalEntryEngine.fetchRecordDetails(listReceiptInvoice[0].Id);
        BM_JournalEntryEngine.fetchRecordDetails(receipts[0].Id);
        BM_JournalEntryEngine.fetchRecordDetails(listRefund[0].Id);
        BM_JournalEntryEngine.fetchRecordDetails(listInvoice[0].Id);
        BM_JournalEntryEngine.fetchRecordDetails(fts[0].Id);
        BM_JournalEntryEngine.fetchRecordDetails(listInvoiceLineItem[0].Id);
        
        
        test.stoptest();        
    }
    
    
}
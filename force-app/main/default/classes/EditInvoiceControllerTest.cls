@isTest
public class EditInvoiceControllerTest 
{
    public static testmethod void doTest()
    {
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        insert acc;
        
        List<Invoice__c> listInvoice = TestClassUtility.createInvoice(1,acc);
        listInvoice[0].Invoice_Balance__c = 100;
        //listInvoice[0].In_Progress_Amount__c = 0;
        insert listInvoice;
        
        List<Invoice__c> listCreditMemo = TestClassUtility.createInvoice(1,acc);
        insert listCreditMemo;
        
        List<Invoice_Line_Item__c> listInvoiceLineItem = TestClassUtility.createInvoiceLineItem(1,listInvoice);
        listInvoiceLineItem[0].Related_Credit_Memo__c = listCreditMemo[0].id;
        listInvoiceLineItem[0].Amount__c = 100;
        insert listInvoiceLineItem;
        
        EditInvoiceController.fetchInvoiceDetails(listCreditMemo[0].id);
        
        List<EditInvoiceController.RelatedInvRecClass> relatedInvoices = new List<EditInvoiceController.RelatedInvRecClass>();
        EditInvoiceController.RelatedInvRecClass objRelatedInvoice = new EditInvoiceController.RelatedInvRecClass();
        objRelatedInvoice.invoiceId = String.valueOf(listInvoice[0].id);
        objRelatedInvoice.invoiceNo = 'Test';
        objRelatedInvoice.Amount = 100;
        objRelatedInvoice.invoiceBalAmt = 100;
        objRelatedInvoice.invTaxAmount = 10;
        //objRelatedInvoice.lineItemId = listInvoiceLineItem[0].id;
        objRelatedInvoice.LineItem = listInvoiceLineItem[0];
        relatedInvoices.add(objRelatedInvoice);
        
        EditInvoiceController.upsertInvoice(listCreditMemo[0], JSON.serialize(relatedInvoices));
        
        //EditInvoiceController.pushCMLineToOracle(JSON.serialize(relatedInvoices));
        
    }
    public static testmethod void doTest1()
    {
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        insert acc;
        
        List<Invoice__c> listInvoice = TestClassUtility.createInvoice(1,acc);
        listInvoice[0].Invoice_Balance__c = 100;
        insert listInvoice;
        
        List<Invoice__c> listCreditMemo = TestClassUtility.createInvoice(1,acc);
        insert listCreditMemo;
        
        List<Invoice_Line_Item__c> listInvoiceLineItem = TestClassUtility.createInvoiceLineItem(1,listInvoice);
        listInvoiceLineItem[0].Related_Credit_Memo__c = listCreditMemo[0].id;
        listInvoiceLineItem[0].Amount__c = 100;
        listInvoiceLineItem[0].Applied__c=true;
        insert listInvoiceLineItem;
        test.startTest();
        EditInvoiceController.fetchInvoiceDetails(listCreditMemo[0].id);
        
        List<EditInvoiceController.RelatedInvRecClass> relatedInvoices = new List<EditInvoiceController.RelatedInvRecClass>();
        EditInvoiceController.RelatedInvRecClass objRelatedInvoice = new EditInvoiceController.RelatedInvRecClass();
        objRelatedInvoice.invoiceId = String.valueOf(listInvoice[0].id);
        objRelatedInvoice.invoiceNo = 'Test';
        objRelatedInvoice.Amount = 100;
        objRelatedInvoice.invoiceBalAmt = 100;
        objRelatedInvoice.invTaxAmount = 10;
        objRelatedInvoice.lineItemId = listInvoiceLineItem[0].id;
        objRelatedInvoice.LineItem = listInvoiceLineItem[0];
        relatedInvoices.add(objRelatedInvoice);
        
        EditInvoiceController.upsertInvoice(listCreditMemo[0], JSON.serialize(relatedInvoices));
        test.stopTest();
    }
}
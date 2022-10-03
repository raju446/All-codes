/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class CreditMemoControllerTest {
    public static testmethod void doTest(){
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        insert acc;
        CreditMemoController.getEntityDetail(acc[0].id);
        CreditMemoController.getListViews();
        
        List<Invoice__c> listOldInvoice = TestClassUtility.createInvoice(1,acc);
        insert listOldInvoice;
        
        List<Invoice_Line_Item__c> listOldInvoiceLineItem = TestClassUtility.createInvoiceLineItem(1,listOldInvoice);
        insert listOldInvoiceLineItem;
        
        Id creditMemoRecType = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Credit Memo').getRecordTypeId();
        List<Invoice__c> listInvoice = TestClassUtility.createInvoice(1,acc);
        listInvoice[0].RecordtypeId = creditMemoRecType;
        insert listInvoice;
        List<Invoice_Line_Item__c> listInvoiceLineItem = TestClassUtility.createInvoiceLineItem(1,listInvoice);
        insert listInvoiceLineItem;
        CreditMemoController.getCreditMemoStatus(listInvoice[0].id);
        
        listInvoice[0].Invoice_Type__c = 'Credit Memo';
        listInvoice[0].Status__c = 'Invoiced';
        listInvoice[0].Invoice_Balance__c = 100;
        update listInvoice;
        CreditMemoController.getCreditMemoStatus(listInvoice[0].id);
        CreditMemoController.fetchPicklistVal('Invoice__c','CurrencyIsoCode',null);
        CreditMemoController.getSavedCreditMemo(listInvoice[0].id);
        List<Invoice__c> listInvoiceNew = TestClassUtility.createInvoice(1,acc);
        listInvoiceNew[0].RecordtypeId = creditMemoRecType;
        
        CreditMemoController.RelatedInvoicLinesClass objRelatedInvoicLinesClass = new CreditMemoController.RelatedInvoicLinesClass();
        List<CreditMemoController.RelatedInvoicLinesClass> listRelatedInvoicLinesClass = new List<CreditMemoController.RelatedInvoicLinesClass>();
        
        CreditMemoController.RelatedLineDetails objRelatedLineDetails = new CreditMemoController.RelatedLineDetails();
        List<CreditMemoController.RelatedLineDetails> listRelatedLineDetails = new List<CreditMemoController.RelatedLineDetails>();
        objRelatedLineDetails.InvoiceLineRec = listOldInvoiceLineItem[0];
        objRelatedLineDetails.dAmount = 20;
        objRelatedLineDetails.isSelected = true;
        listRelatedLineDetails.add(objRelatedLineDetails);
        
        objRelatedInvoicLinesClass.invoiceRec = listOldInvoice[0];
        objRelatedInvoicLinesClass.listInvoiceLineRec = listRelatedLineDetails;
        listRelatedInvoicLinesClass.add(objRelatedInvoicLinesClass);
        CreditMemoController.saveCreditMemo(listInvoiceNew[0],listRelatedInvoicLinesClass ,string.valueOf(acc[0].id),100,'Invoice Not Paid / Partially Paid');
        
        CreditMemoController.fetchBillingManagementMDTDetail();
        CreditMemoController.pushMemoToOracle(listInvoiceNew[0].Id,false);
    }
}
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
public class Lex_EditReceiptControllerTest {
    public static testmethod void doTest(){
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        insert acc;
        List<Invoice__c> listInvoice = TestClassUtility.createInvoice(1,acc);
        listInvoice[0].Invoice_Balance__c = 100;
        insert listInvoice;
        
        List<Receipt__c> listReceipt = TestClassUtility.createReceipt(1,acc);
        listReceipt[0].Payment_Method__c = 'Electronic Funds Transfer';
        insert listReceipt;
        Lex_EditReceiptController.fetchReceiptDetails(listReceipt[0].id);
        
        
        List<Lex_EditReceiptController.RelatedInvRecClass> relatedInvoices = new List<Lex_EditReceiptController.RelatedInvRecClass>();
        Lex_EditReceiptController.RelatedInvRecClass objRelatedInvoice = new Lex_EditReceiptController.RelatedInvRecClass();
        objRelatedInvoice.invoiceId = String.valueOf(listInvoice[0].id);
        objRelatedInvoice.invoiceNo = 'Test';
        objRelatedInvoice.Amount = 100;
        objRelatedInvoice.invoiceBalAmt = 100;
        objRelatedInvoice.AppliedDate = string.valueOf(system.today());
        relatedInvoices.add(objRelatedInvoice);
        
        Lex_EditReceiptController.upsertRelatedInvoiceReceipt(listReceipt[0], JSON.serialize(relatedInvoices));
        relatedInvoices[0].Amount = 20;
        Lex_EditReceiptController.upsertRelatedInvoiceReceipt(listReceipt[0], JSON.serialize(relatedInvoices));
        
    }
}
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
public class BillingManagementControllerTest {
    public static testmethod void doTest(){
        BillingManagementController.fetchReceiptPicklistVal('CurrencyIsoCode',null);  
        BillingManagementController.fetchInvoicePicklistVal('CurrencyIsoCode',null);
        BillingManagementController.invoiceInitialization();
        BillingManagementController.lineItemInitialization();
        BillingManagementController.fetchUserDetails();
        BillingManagementController.fetchAccountPicklistVal('CurrencyIsoCode',null);  
        BillingManagementController.fetchAddressPicklistVal('CurrencyIsoCode',null);  
        
        List<Recordtype> listRecordTypes = BillingManagementController.fetchEntityRecordTypeValues();
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        insert acc;
        BillingManagementController.pushAccountToOracle(acc[0]);
        BillingManagementController.fetchAccountDetail(acc[0].id);
        BillingManagementController.fetchAccounts(acc[0].id);
        BillingManagementController.TaxValues();
        List<Address__c> listAddress = TestClassUtility.createAddress(1,acc);
        listAddress[0].Type__c = 'Physical';
        insert listAddress;
        BillingManagementController.cloneEntity(acc[0].id, 'ADGM', 'BM');
        BillingManagementController.saveAccount(acc[0],listRecordTypes[0].id, false, 'United Arab Emirates', null, null, listAddress[0], null, 'BM');
        
        
        Contact[] listContact = TestClassUtility.createContacts(1,acc[0].id);
        listContact[0].Country__c = 'United Arab Emirates';
        insert listContact;
        
        BillingManagementController.saveAccount(acc[0],listRecordTypes[0].id, true, 'United Arab Emirates', listContact[0].id, null, listAddress[0], null, 'BM' );
        BillingManagementController.getRelatedEntity('Test',null,null,null,null);
        BillingManagementController.getRelatedEntity('Test','123','123',acc[0].id,'BM');
        
        List<Receipt__c> listReceipt = TestClassUtility.createReceipt(1,acc);
        listReceipt[0].Payment_Method__c = 'Electronic Funds Transfer';
        insert listReceipt;
        system.debug('---->'+listReceipt);
        
        BillingManagementController.fetchReceiptDetails(listReceipt[0].id);
        
        List<Invoice__c> listInvoice = TestClassUtility.createInvoice(1,acc);
        insert listInvoice;
        
        List<Invoice_Line_Item__c> listInvoiceLineItem = TestClassUtility.createInvoiceLineItem(1,listInvoice);
        insert listInvoiceLineItem;
        test.startTest();
        BillingManagementController.fetchInvoiceDetails(listInvoice[0].id);
        List<Invoice__c> listInvoiceNew = TestClassUtility.createInvoice(1,acc);
        List<Invoice_Line_Item__c> listInvoiceLineItemNew = TestClassUtility.createInvoiceLineItem(1,listInvoice);
        
        List<BillingManagementController.RelatedReceiptClass> relatedReceipts = new List<BillingManagementController.RelatedReceiptClass>();
        BillingManagementController.RelatedReceiptClass objRelatedReceipt = new BillingManagementController.RelatedReceiptClass();
        objRelatedReceipt.Id = String.valueOf(listReceipt[0].id);
        objRelatedReceipt.Name = 'Test';
        objRelatedReceipt.RecAmt = 100;
        relatedReceipts.add(objRelatedReceipt);
        
        BillingManagementController.AttachmentWrapper objAttachmentWrapper = new BillingManagementController.AttachmentWrapper();
        List<BillingManagementController.AttachmentWrapper> listAttachmentWrapper = new List<BillingManagementController.AttachmentWrapper>();
        objAttachmentWrapper.fileName = 'Test';
        objAttachmentWrapper.isUploaded = true;
        objAttachmentWrapper.blobval = 'Test file';
        listAttachmentWrapper.add(objAttachmentWrapper);
        
        
        BillingManagementController.upsertInvoiceAndRelatedReceipts(listInvoiceNew[0], listInvoiceLineItemNew, relatedReceipts, true, listAttachmentWrapper,'Default');
        listInvoiceNew = [select id from Invoice__c where id !=: listInvoice[0].id];
        BillingManagementController.upsertInvoiceAndRelatedReceipts(listInvoiceNew[0], listInvoiceLineItemNew, relatedReceipts, true, listAttachmentWrapper, 'Default');
        BillingManagementController.upsertCreditMemo(listInvoiceNew[0], listInvoiceLineItemNew, null, true, 'Default');
         
        
        List<Receipt__c> listReceiptNew = TestClassUtility.createReceipt(1,acc);
        List<BillingManagementController.RelatedInvClass> relatedInvoices = new List<BillingManagementController.RelatedInvClass>();
        BillingManagementController.RelatedInvClass objRelatedInvoice = new BillingManagementController.RelatedInvClass();
        objRelatedInvoice.invoiceId = String.valueOf(listInvoice[0].id);
        objRelatedInvoice.invoiceNo = 'Test';
        objRelatedInvoice.Amount = 100;
        objRelatedInvoice.invoiceBalAmt = 100;
        objRelatedInvoice.AppliedDate = string.valueOf(system.today());
        relatedInvoices.add(objRelatedInvoice);
        BillingManagementController.fetchEntityDetails(acc[0].Id);
        BillingManagementController.upsertReceiptAndRelatedInvoices(listReceiptNew[0],relatedInvoices,listAttachmentWrapper);
        //listReceiptNew = [select id from Receipt__c where id !=: listReceipt[0].id];
        BillingManagementController.upsertReceiptAndRelatedInvoices(listReceiptNew[0],relatedInvoices,listAttachmentWrapper);
        BillingManagementController.getRelatedReceipts(acc[0].id);
        BillingManagementController.getRelatedInvoice(acc[0].id);
        BillingManagementController.pushReciptToERP(listInvoice[0].Id,False);
        BillingManagementController.getInvoiceRevenueMapping(acc[0].Id, false);
        BillingManagementController.getInvoiceRevenue('104',false,'Invoice',false);
        BillingManagementController.submitRecordsForApproval(null,null);
        BillingManagementController.fetchAccountDetails(acc[0].Id);
        BillingManagementController.fetchInvoiceLineItemPicklistVal('Authority__c',false);
        test.stopTest();
        
        BillingManagementController.cancelInvoice(listInvoice[0].Id);
        
    }
    
    public static testmethod void doTest1(){
        Account[] accNew = TestClassUtility.createAccounts(1);
        accNew[0].Name = 'Test'+system.today();
        accNew[0].Oracle_Party_Id__c = '123';
        accNew[0].Source_System_Name__c = 'FSRA';
        List<Address__c> listAddress = TestClassUtility.createAddress(1,accNew);
        List<Recordtype> listRecordTypes = BillingManagementController.fetchEntityRecordTypeValues();
        //insert listAddress;
        BillingManagementController.saveAccount(accNew[0],listRecordTypes[0].id, false, 'United Arab Emirates', null, null, listAddress[0], null, 'BM');   
        BillingManagementController.getRelatedEntity('Test','123','123',null,'null');
        BillingManagementController.InvoiceLineClass objInvoiceLineClass = new BillingManagementController.InvoiceLineClass ();
        objInvoiceLineClass.Amount = 100;
        objInvoiceLineClass.TaxAmount = 10;
        objInvoiceLineClass.DiscountAmount = 10 ;
        objInvoiceLineClass.DiscountTaxAmount = 10;
        objInvoiceLineClass.ItemDescription = 'test';
        objInvoiceLineClass.ItemReference = 'Test';
        objInvoiceLineClass.RecId = '';
        BillingManagementController.fetchBillingManagementMDTDetail();
        BillingManagementController.fetchEntityDetails(accNew[0].Id);
        BillingManagementController.fetchInvoiceLineItemPicklistVal('Tax__c', false);
        BillingManagementController.fetchAccountDetails(accNew[0].Id);
        
        BillingManagementController.getInvoiceRevenueMapping(accNew[0].Id, false);
    }
}
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
public class RefundControllerTest {
    public static testmethod void doTest(){
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        insert acc;
        List<Receipt__c> listReceipt = TestClassUtility.createReceipt(1,acc);
        listReceipt[0].Payment_Method__c = 'Electronic Funds Transfer';
        insert listReceipt;
        List<Refund__c> listRefund = TestClassUtility.createRefund(1, acc, listReceipt);
        listRefund[0].Payment_Method__c = 'Bank Transfer';
        insert listRefund;
        RefundController.getRefundDetails(listRefund[0].id);
        
        RefundUtil.ResponseRefundWrapper objResponseRefundWrapper = new RefundUtil.ResponseRefundWrapper();
        objResponseRefundWrapper.P_OP_VENDOR_NAME = 'Test';
        objResponseRefundWrapper.P_OP_VENDOR_NUMBER = 'Test';
        objResponseRefundWrapper.P_OP_BANK_ACCOUNT_NUM = 'Test';
        objResponseRefundWrapper.P_OP_BANK_NAME = 'Test';
        objResponseRefundWrapper.P_OP_IBAN = 'Test';
        RefundController.saveIBAN(listRefund[0], objResponseRefundWrapper, '16662');
        RefundController.fetchIBAN(acc[0].id, '662yhyshs');
        RefundController.fetchPicklistVal('Refund__c','Payment_Method__c',null);  
        List<Invoice__c> listInvoice = TestClassUtility.createInvoice(1,acc);
        insert listInvoice;
        List<Invoice_Line_Item__c> listInvoiceLineItem = TestClassUtility.createInvoiceLineItem(1,listInvoice);
        insert listInvoiceLineItem;
        
        List<Related_Invoice_Receipt__c> listReceiptInvoice = TestClassUtility.createRelatedInvoiceReceipt(1,listInvoice, listReceipt);
        insert listReceiptInvoice;
        RefundController.getOldData(listRefund[0].id);
        RefundController.fetchCreditMemoDetails(listInvoice[0].id);
        RefundController.fetchReceiptDetails(listReceipt[0].id);
        
        RefundController.AttachmentWrapper objAttachmentWrapper = new RefundController.AttachmentWrapper();
        List<RefundController.AttachmentWrapper> listAttachmentWrapper = new List<RefundController.AttachmentWrapper>();
        objAttachmentWrapper.fileName = 'Test';
        objAttachmentWrapper.isUploaded = true;
        objAttachmentWrapper.blobval = 'Test file';
        listAttachmentWrapper.add(objAttachmentWrapper);
        
        RefundController.RelatedLineDetails objRelatedLineDetails = new RefundController.RelatedLineDetails();
        List<RefundController.RelatedLineDetails> listRelatedLineDetails = new List<RefundController.RelatedLineDetails>();
        objRelatedLineDetails.InvoiceLineRec = listInvoiceLineItem[0];
        objRelatedLineDetails.refundAmount = 100;
        objRelatedLineDetails.isSelected = true;
        listRelatedLineDetails.add(objRelatedLineDetails);
        
        RefundController.InvoiceWrapper objInvoiceWrapper = new RefundController.InvoiceWrapper();
        List<RefundController.InvoiceWrapper> listInvoiceWrapper = new List<RefundController.InvoiceWrapper>();
        objInvoiceWrapper.appliedAmount = 10;
        objInvoiceWrapper.invoiceRec = listInvoice[0];
        objInvoiceWrapper.listInvoiceLineRec = listRelatedLineDetails;
        listInvoiceWrapper.add(objInvoiceWrapper);
        List<Refund__c> listRefundNew = TestClassUtility.createRefund(1, acc, listReceipt);
        RefundController.saveRefundRecord(listRefundNew[0], listInvoiceWrapper,listAttachmentWrapper );
        
        Test.startTest();
        	RefundController.fetchRefundDetails(listRefundNew[0].Id);
        	listRefundNew[0].status__c = 'Draft';
        	upsert listRefundNew;
        	RefundController.submitForApproval(listRefundNew[0].Id);
        	RefundController.pushRefundRecToOrale(listRefundNew[0].Id);
        	RefundController.fetchBillingManagementMDTDetail();
        Test.stopTest();
    }
}
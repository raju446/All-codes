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
public class CreditMemoUtilTest {
    public static testmethod void doTest(){
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        insert acc;
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
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CreditMemoMockCallout());
        //CreditMemoUtil.pushToOracleCreditMemoFuture(new List<String>{listInvoice[0].id});
        CreditMemoUtil.pushToOracleCreditMemo(new List<String>{listInvoice[0].id});
        //CreditMemoUtil.pushCreditMemoUpdateToOracle(new List<String>{listInvoiceLineItem[0].id});
        Test.stopTest();
    }
    
    public static testmethod void doTestUpdateCreditMemo(){
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
        listInvoiceLineItem[0].Amount__c = 1;
        insert listInvoiceLineItem;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CreditMemoMockCallout());
		//CreditMemoUtil.pushToOracleCreditMemoFuture(new List<String>{listInvoice[0].id});
        CreditMemoUtil.pushToOracleCreditMemo(new List<String>{listInvoice[0].id});
        //CreditMemoUtil.pushCreditMemoUpdateToOracle(new List<String>{listInvoiceLineItem[0].id});
        Test.stopTest();
        
    }
}
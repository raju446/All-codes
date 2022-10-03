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
public class InvoiceLineItemTriggerHandlerTest {
    public static testmethod void doTest(){
        Operating_Unit__c ou = new Operating_Unit__c(Invoice_Type__c = 'Test');
        insert ou;
        
        Revenue_Classification__c rc = new Revenue_Classification__c(Service_Type__c = 'Test',Line_Item_Type__c='test',Operating_Unit__c = ou.Id);
        insert rc;
        
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Operating_Unit__c = ou.id;
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        insert acc;
        List<Invoice__c> listInvoice = TestClassUtility.createInvoice(1,acc);
        listInvoice[0].Invoice_Balance__c = 100;
        insert listInvoice;
        
        List<Invoice_Line_Item__c> listInvoiceLineItem = TestClassUtility.createInvoiceLineItem(1,listInvoice);
        listInvoiceLineItem[0].recordtypeid = Schema.SObjectType.Invoice_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Invoice_Line_Item').getRecordTypeId();
        listInvoiceLineItem[0].Service_Type__c = 'Test';
        listInvoiceLineItem[0].Discount_Amount__c = 50;
        listInvoiceLineItem[0].Amount__c = 500.00;
        listInvoiceLineItem[0].Tax_Amount__c = 10.00;
        insert listInvoiceLineItem;
        
        List<Invoice_Line_Item__c> listInvoiceLineItem1 = TestClassUtility.createInvoiceLineItem(1,listInvoice);
        listInvoiceLineItem1[0].recordtypeid = Schema.SObjectType.Invoice_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Adjustment').getRecordTypeId();
        listInvoiceLineItem1[0].Activity_Name__c = 'Invoice Cancellation';
        //listInvoiceLineItem1[0].Amount__c = 500.00;
        listInvoiceLineItem1[0].Date_Of_Adjustment__c = Date.today();
        listInvoiceLineItem1[0].Tax__c = '5%';
        insert listInvoiceLineItem1;
        
        listInvoiceLineItem[0].Discount_Amount__c = null;
        update listInvoiceLineItem;
        
        InvoiceLineItemTriggerHandler.deleteDiscountLine(new List<Id>{listInvoiceLineItem[0].Id});
        InvoiceLineItemTriggerHandler.updateCloseDateErrorJVs(new Set<Invoice_Line_Item__c>{listInvoiceLineItem[0]});
    }

    public static testmethod void doTest1(){

        Test.setMock(HttpCalloutMock.class, new InvoiceMockCallout());

        Operating_Unit__c ou = new Operating_Unit__c(Invoice_Type__c = 'Test', Oracle_Site_Id__c='123');
        insert ou;
        
        Revenue_Classification__c rc = new Revenue_Classification__c(Service_Type__c = 'Test',Line_Item_Type__c='test',Operating_Unit__c = ou.Id);
        insert rc;
        
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Operating_Unit__c = ou.id;
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Oracle_Site_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        insert acc;
        List<Invoice__c> listInvoice = TestClassUtility.createInvoice(1,acc);
        listInvoice[0].Invoice_Balance__c = 100;
        listInvoice[0].Payment_Term__c = '20 days';
        insert listInvoice;
        
        
        List<Invoice_Line_Item__c> listInvoiceLineItem1 = TestClassUtility.createInvoiceLineItem(1,listInvoice);
        listInvoiceLineItem1[0].recordtypeid = Schema.SObjectType.Invoice_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Adjustment').getRecordTypeId();
        listInvoiceLineItem1[0].Activity_Name__c = 'Invoice Cancellation';
        listInvoiceLineItem1[0].Status__c = 'Invoiced';
        //listInvoiceLineItem1[0].Amount__c = 500.00;
        listInvoiceLineItem1[0].Date_Of_Adjustment__c = Date.today();
        listInvoiceLineItem1[0].Tax__c = '5%';
        insert listInvoiceLineItem1;
        
        listInvoiceLineItem1[0].Discount_Amount__c = null;
        update listInvoiceLineItem1;

    }

    
}
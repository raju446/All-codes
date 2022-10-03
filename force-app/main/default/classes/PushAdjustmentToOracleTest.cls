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
public class PushAdjustmentToOracleTest {
    public static testmethod void doTest(){
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        insert acc;
        
        List<Invoice__c> listInvoice = TestClassUtility.createInvoice(1,acc);
        listInvoice[0].Invoice_Balance__c = 100;
        //listInvoice[0].In_Progress_Amount__c = 0;
        insert listInvoice;
        List<Invoice_Line_Item__c> listInvoiceLineItem = TestClassUtility.createInvoiceLineItem(1,listInvoice);
        insert listInvoiceLineItem;
        Id adjustmentRecType = Schema.SObjectType.Invoice_Line_Item__c.getRecordTypeInfosByName().get('Adjustment').getRecordTypeId();
        List<Invoice_Line_Item__c> listAdjustment = TestClassUtility.createInvoiceLineItem(1,listInvoice);
        listAdjustment[0].recordtypeid = adjustmentRecType;
        listAdjustment[0].Invoice_Line_Item__c = listInvoiceLineItem[0].id;
        //listAdjustment[0].Tax__c = '0%';
        listAdjustment[0].Date_Of_Adjustment__c = system.today();
        insert listAdjustment;
        
        PushAdjustmentToOracle.getDefaultValues(listInvoice[0].id);
        listInvoice[0].Oracle_Invoice_Id__c = '12345';
        update listInvoice;
        PushAdjustmentToOracle.getDefaultValues(listInvoice[0].id);
        PushAdjustmentToOracle.pushAdjustmentToOracle(listAdjustment[0].id);
        PushAdjustmentToOracle.validateAdjustment(listAdjustment[0].id);
        listAdjustment[0].Status__c = 'Invoiced';
        update listAdjustment;
        PushAdjustmentToOracle.validateAdjustment(listAdjustment[0].id);
        PushAdjustmentToOracle.validateAdjustment(listInvoiceLineItem[0].id);
        
        listAdjustment[0].Status__c = 'Draft';
        update listAdjustment[0];
        PushAdjustmentToOracle.submitForApproval(listAdjustment[0].Id);
        
        PushAdjustmentToOracle.getAdjustmentDetails(listAdjustment[0].Id);
        //listInvoiceLineItem[0].recordtypeid = adjustmentRecType;
        //update listInvoiceLineItem;
    }
}
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
private class RA_Receipt_Invoice_TriggerTest {

    static testMethod void myUnitTest() {
        
        Receipt_Description__c RD = new Receipt_Description__c();
        RD.Receipt_Date__c = system.today();
        RD.Receipt_Number__c = 'RA-X12342421';
        insert RD;
        
        RA_Receipt_Invoice__c RI = new RA_Receipt_Invoice__c();
        RI.Receipt_Description__c = RD.Id;
        RI.Authority_Name__c = 'Registration Authority';
        RI.Category__c = 'Non-Financial (Category B)';
        RI.Entity_Name__c = 'ABC XYZ LTD';
        RI.Entity_Number__c = '1432';
        RI.Fee_Amount_in_AED__c = 36725;
        RI.Fee_Amount_in_USD__c = 1000;
        RI.Fee_Description__c = 'Reserve a Company Name';
        RI.Fee_Type__c = 'Application Fee for License';
        RI.General_Ledger_Code__c = '3101';
        RI.General_Ledger_Entry_Description__c = 'Registration Authority';
        RI.Payment_ID__c = 'RA-X12342421';
        RI.Payment_Method__c = 'Credit Card';
        RI.Receipt_Date__c = system.today().addDays(-1);
        RI.Receipt_Number__c = 'RA-X12342421';
        RI.Receipt_Number_Unique__c = 'RA-X12342421';
        RI.Service_Type__c = 'Registration & Incorporation';
        RI.Total_Fee_in_AED__c = 10000;
        RI.Total_Paid_in_AED__c = 36725;
        insert RI;
        
        RI.Receipt_Description__c = null;
        update RI;
        
        RA_Invoice_Line_Item__c RLI = new RA_Invoice_Line_Item__c();
        RLI.RA_Receipt_Invoice__c = RI.Id;
        RLI.Total_Paid_in_AED__c = 999;
        Insert RLI;
        
        
        RI = new RA_Receipt_Invoice__c();
        RI.Receipt_Description__c = RD.Id;
        RI.Authority_Name__c = 'Registration Authority';
        RI.Category__c = 'Non-Financial (Category B)';
        RI.Fee_Amount_in_AED__c = 36725;
        RI.Fee_Amount_in_USD__c = 1000;
        RI.Fee_Description__c = 'Reserve a Company Name';
        RI.Fee_Type__c = 'Application Fee for License';
        RI.General_Ledger_Code__c = '3101';
        RI.General_Ledger_Entry_Description__c = 'Registration Authority';
        RI.Payment_ID__c = 'RA-X12342422';
        RI.Payment_Method__c = 'Electronic Funds Transfer (direct credit)';
        RI.Receipt_Date__c = system.today().addDays(-1);
        RI.Receipt_Number__c = 'RA-X12342422';
        RI.Receipt_Number_Unique__c = 'RA-X12342422';
        RI.Service_Type__c = 'Registration & Incorporation';
        RI.Total_Fee_in_AED__c = 10000;
        RI.Total_Paid_in_AED__c = 36725;
        insert RI;
        
        RA_InvoiceLineItemTriggerHandler.Execute_AU(null,null);
        RA_InvoiceLineItemTriggerHandler.Execute_BU(null,null);
        
        
        Batch_RAFinancialTransactionExt1 objBatchExt1 = new Batch_RAFinancialTransactionExt1();
        Database.executeBatch(objBatchExt1,1);
        Batch_RAFinancialTransactionExt2 objBatchExt2 = new Batch_RAFinancialTransactionExt2();
        Database.executeBatch(objBatchExt2,1);
        Batch_RAFinancialTransactionExt3 objBatchExt3 = new Batch_RAFinancialTransactionExt3();
        Database.executeBatch(objBatchExt3,1);
    }
}
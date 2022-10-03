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
public class InvoiceTriggerHandlerTest {
    public static testmethod void doTest(){
        Exchange_Rate__c er = new Exchange_Rate__c(USD_To_AED_Conversion_Rate__c = 3.6725,Conversion_Date__c = Date.today());
        insert er;
        OU_Basd_Invoice_Running_Number__c rn = new OU_Basd_Invoice_Running_Number__c(name = 'fsra',Operating_Unit__c = '103', Type__c = 'Invoice',Running_Number__c =1);
        insert rn;
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        acc[0].Oracle_site_id__c = '103';
        insert acc;
        List<Invoice__c> listInvoice = TestClassUtility.createInvoice(1,acc);
        listInvoice[0].Invoice_Balance__c = 100;
        
        insert listInvoice;
        listInvoice[0].Status__c='Approved' ;  
        listInvoice[0].Generate_Document__c = true;
        listInvoice[0].Document_Version__c = 0;
        update listInvoice;
    }
    
    public static testmethod void doTest1(){
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        insert acc;
        List<Invoice__c> listInvoice = TestClassUtility.createInvoice(1,acc);
        listInvoice[0].Invoice_Balance__c = 100;
        listInvoice[0].Status__c='Success';
        insert listInvoice;
    }
    
    public static testmethod void doTest2(){
        Exchange_Rate__c er = new Exchange_Rate__c(USD_To_AED_Conversion_Rate__c = 3.6725,Conversion_Date__c = Date.today());
        insert er;
        OU_Basd_Invoice_Running_Number__c rn = new OU_Basd_Invoice_Running_Number__c(name = 'fsra',Operating_Unit__c = '103', Type__c = 'Credit Memo',Running_Number__c =1);
        insert rn;
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        acc[0].Oracle_site_id__c = '103';
        insert acc;
        List<Invoice__c> listInvoice = TestClassUtility.createInvoice(1,acc);
        listInvoice[0].Invoice_Balance__c = 100;
        listInvoice[0].Recordtypeid = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Credit_Memo').getRecordTypeId();
        insert listInvoice;
        listInvoice[0].Status__c='Approved' ;    
        update listInvoice;
        
         List<Invoice__c> listInvoice1 = TestClassUtility.createInvoice(1,acc);
        listInvoice1[0].Invoice_Balance__c = 100;
        listInvoice1[0].Recordtypeid = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Credit_Memo').getRecordTypeId();
        insert listInvoice1;
    }

    public static testmethod void doTest3(){
        Exchange_Rate__c er = new Exchange_Rate__c(USD_To_AED_Conversion_Rate__c = 3.6725,Conversion_Date__c = Date.today());
        insert er;
        OU_Basd_Invoice_Running_Number__c rn = new OU_Basd_Invoice_Running_Number__c(name = 'fsra',Operating_Unit__c = '103', Type__c = 'Credit Memo',Running_Number__c =1);
        insert rn;
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        acc[0].Oracle_site_id__c = '103';
        insert acc;

        BusinessHours bHours = [SELECT Id FROM BusinessHours WHERE name ='FSRA'];

        Operating_Unit__c ou = new Operating_Unit__c(Oracle_Site_Id__c = '103', Source_System__c='FSRA', Business_Hour__c = bHours.Id,
                                Operating_Unit_Name__c = 'Financial Services Regulatory Authority OU');
        insert ou;
        
        List<Invoice__c> listInvoice1 = TestClassUtility.createInvoice(1,acc);
        listInvoice1[0].Invoice_Balance__c = 100;
        listInvoice1[0].Payment_Term__c = '20 days';
        listInvoice1[0].Invoice_Date__c = system.today();
        listInvoice1[0].Recordtypeid = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Credit_Memo').getRecordTypeId();
        insert listInvoice1;
    }
}
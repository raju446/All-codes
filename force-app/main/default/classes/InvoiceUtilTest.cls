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
public class InvoiceUtilTest {
    public static testmethod void doTestInvoice(){
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        insert acc;
        System.debug('Limit SOQL===='+Limits.getQueries());
        List<Receipt__c> listReceipt = TestClassUtility.createReceipt(1,acc);
        listReceipt[0].Amount__c = 100;
        listReceipt[0].Status__c = 'Success';
        listReceipt[0].Receipt_Reference__c = '1';
        listReceipt[0].Payment_Method__c = 'Electronic Funds Transfer';
        insert listReceipt;
        System.debug('Limit SOQL===='+Limits.getQueries());
        List<Invoice__c> listInvoice = TestClassUtility.createInvoice(1,acc);
        listInvoice[0].GL_Date__c = system.today();
        listInvoice[0].Invoice_Date__c = system.today();
        listInvoice[0].Payment_Term__c = 'IMMEDIATE';
        insert listInvoice;
        test.startTest();
        System.debug('Limit SOQL===='+Limits.getQueries());
        //Id adjustmentRecType = Schema.SObjectType.Invoice_Line_Item__c.getRecordTypeInfosByName().get('Adjustment').getRecordTypeId();
        List<Invoice_Line_Item__c> listInvoiceLineItem = TestClassUtility.createInvoiceLineItem(1,listInvoice);
        //listInvoiceLineItem[0].recordtypeid = adjustmentRecType;
        //listInvoiceLineItem[0].Invoice_Line_Item__c = listInvoiceLineItem[0].id;
        listInvoiceLineItem[0].Tax__c = 'Out of scope 0%';
        listInvoiceLineItem[0].Date_Of_Adjustment__c = system.today();
        listInvoiceLineItem[0].Type__c = 'Invoice';
        listInvoiceLineItem[0].Amount__c = 0;
        listInvoiceLineItem[0].Department__c = 'CEO';
        listInvoiceLineItem[0].Service_Type__c = 'Corporate Services';
        listInvoiceLineItem[0].Service_Class__c = 'Business Service';
        listInvoiceLineItem[0].Revenue_Type__c='Corporate Services';
        insert listInvoiceLineItem;
        
        List<Related_Invoice_Receipt__c> listReceiptInvoice = TestClassUtility.createRelatedInvoiceReceipt(1,listInvoice, listReceipt );
        listReceiptInvoice[0].Direction__c = 'From Invoice To Receipt';
        listReceiptInvoice[0].Amount_Applied__c = 10;
        listReceiptInvoice[0].Applied_Date__c = system.today();
        upsert listReceiptInvoice;
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Permit_Alcohol');
        createdSRList[0].HexaBPM__Customer__c = acc[0].Id;
        insert createdSRList;
        
        List<HexaBPM__SR_Price_Item__c> newPriceItems = new List<HexaBPM__SR_Price_Item__c>();
        HexaBPM__SR_Price_Item__c priceItem = new HexaBPM__SR_Price_Item__c();
        priceItem.HexaBPM__Status__c = 'Added';
        priceItem.HexaBPM__ServiceRequest__c = createdSRList[0].Id;
        priceItem.Cost__c = 2000;
        priceItem.Is_Refund_Line__c = true;
        priceItem.Department__c = 'CEO';
        priceItem.Service_Type__c = 'Corporate Services';
        priceItem.Service_Class__c = 'Business Service';
        priceItem.Revenue_Type__c='Corporate Services';
        newPriceItems.add(priceItem);
        priceItem = new HexaBPM__SR_Price_Item__c();
        priceItem.HexaBPM__Status__c = 'Added';
        priceItem.HexaBPM__ServiceRequest__c = createdSRList[0].Id;
        priceItem.Cost__c = 1000;
        newPriceItems.add(priceItem);
        insert newPriceItems;
        
        String iltId = newPriceItems[0].Id;
        
        
        
        
        
        Test.setMock(HttpCalloutMock.class, new InvoiceMockCallout());
        InvoiceUtil.pricingItemMap = new Map<Id,HexaBPM__SR_Price_Item__c>();
        InvoiceUtil.pricingItemMap.put(iltId,newPriceItems[0]);
        InvoiceUtil.pushToOracleFuture(createdSRList[0].Id);
        InvoiceUtil.pushToOracleInvoice(new List<String>{listInvoice[0].id});
        InvoiceUtil.pushToOracleInvoice_Future(new List<String>{listInvoice[0].id});
        InvoiceUtil.ConstructInvoicePayload(listInvoice[0]);
        Test.setMock(HttpCalloutMock.class, new AdjustmentMockCallout());
        InvoiceUtil.PushAdjToOracle(listInvoiceLineItem[0].id);
        InvoiceUtil.PushAdjToSourceSystem(listInvoiceLineItem[0].Id);
        InvoiceUtil.trimAllValues(new List<String>{'test'});
        InvoiceUtil.getAdjustmentTaxActivities('');
        InvoiceUtil.LINE_REC_TYPE_CLASS objRefundLine = new InvoiceUtil.LINE_REC_TYPE_CLASS('0.0','0.0','Test123',iltId,String.valueOf(2345.5),'5%','Testinggg','','CEO','Default','Default','Default','Default','Default','Corporate Services');
        InvoiceUtil.mapInvoiceLineItem(objRefundLine,true,listInvoice[0].Id,listInvoiceLineItem[0].Id);
        String DateVal = listInvoice[0].GL_Date__c.DAY()+'-'+listInvoice[0].GL_Date__c.Month()+'-'+listInvoice[0].GL_Date__c.Year();
        InvoiceUtil.InputParameters_Class invObj = new InvoiceUtil.InputParameters_Class('INV-12345',String.ValueOf(listInvoice[0].Id),listInvoice[0].Entity__r.Oracle_Party_Id__c,listInvoice[0].Source_System__c,'Test12345',listInvoice[0].Oracle_Invoice_Type__c,DateVal,listInvoice[0].Entity__r.Oracle_Site_Id__c,'test1234','Immediate',listInvoice[0].Payment_Currency__c,listInvoice[0].Transaction_Type__c,'');
        InvoiceUtil.constructFinalWrapper(invObj,new List<InvoiceUtil.LINE_REC_TYPE_CLASS>{objRefundLine});
        test.stopTest();
    }
    
   /* @isTest static void test1(){

        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Permit_Alcohol');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        insert createdSRList;
        
        List<HexaBPM__SR_Price_Item__c> newPriceItems = new List<HexaBPM__SR_Price_Item__c>();
        HexaBPM__SR_Price_Item__c priceItem = new HexaBPM__SR_Price_Item__c();
        priceItem.HexaBPM__Status__c = 'Added';
        priceItem.HexaBPM__ServiceRequest__c = createdSRList[0].Id;
        priceItem.Cost__c = 2000;
        priceItem.Is_Refund_Line__c = true;
        newPriceItems.add(priceItem);
        
        priceItem = new HexaBPM__SR_Price_Item__c();
        priceItem.HexaBPM__Status__c = 'Added';
        priceItem.HexaBPM__ServiceRequest__c = createdSRList[0].Id;
        priceItem.Cost__c = 1000;
        newPriceItems.add(priceItem);
        
        insert newPriceItems;
        
        List<Receipt__c> listReceipt = TestClassUtility.createReceipt(1,newAccounts);
        listReceipt[0].Amount__c = 100;
        listReceipt[0].Status__c = 'Success';
        listReceipt[0].Receipt_Reference__c = '1';
        listReceipt[0].Payment_Method__c = 'Electronic Funds Transfer';
        insert listReceipt;
        
        User objUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Admin'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
            //UserRoleId = r.Id
        );
        
        insert objUser;
        
        test.startTest();
            system.runAs(objUser){
                // This causes a fake response to be generated
                Test.setMock(HttpCalloutMock.class, new InvoiceMockCallout());
                //InvoiceUtil.pushToOracle(new List<String>{createdSRList[0].id});
            }
        test.stoptest();

        
        
    }*/
    
    /* @isTest static void test2_salesAndPromotions(){

        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Permit_Sales_and_Promotion');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        insert createdSRList;
        
        List<HexaBPM__SR_Price_Item__c> newPriceItems = new List<HexaBPM__SR_Price_Item__c>();
        HexaBPM__SR_Price_Item__c priceItem = new HexaBPM__SR_Price_Item__c();
        priceItem.HexaBPM__Status__c = 'Added';
        priceItem.HexaBPM__ServiceRequest__c = createdSRList[0].Id;
        priceItem.Cost__c = 2000;
        priceItem.Is_Refund_Line__c = true;
        newPriceItems.add(priceItem);
        
        priceItem = new HexaBPM__SR_Price_Item__c();
        priceItem.HexaBPM__Status__c = 'Added';
        priceItem.HexaBPM__ServiceRequest__c = createdSRList[0].Id;
        priceItem.Cost__c = 1000;
        newPriceItems.add(priceItem);
        
        insert newPriceItems;
        
        List<Receipt__c> listReceipt = TestClassUtility.createReceipt(1,newAccounts);
        listReceipt[0].Amount__c = 100;
        listReceipt[0].Status__c = 'Success';
        listReceipt[0].Receipt_Reference__c = '1';
        insert listReceipt;
        
        User objUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Admin'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
            //UserRoleId = r.Id
        );
        
        insert objUser;
        
        test.startTest();
            system.runAs(objUser){
                // This causes a fake response to be generated
                Test.setMock(HttpCalloutMock.class, new InvoiceMockCallout());
                InvoiceUtil.pushToOracle(new List<String>{createdSRList[0].id});
            }
        test.stoptest();

        
        
    }*/
   /* public static testmethod void doTestAdjustmentWithoutTax(){
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        insert acc;
        
        List<Receipt__c> listReceipt = TestClassUtility.createReceipt(1,acc);
        listReceipt[0].Amount__c = 100;
        listReceipt[0].Status__c = 'Success';
        listReceipt[0].Receipt_Reference__c = '1';
        listReceipt[0].Payment_Method__c = 'Electronic Funds Transfer';
        insert listReceipt;
        List<Invoice__c> listInvoice = TestClassUtility.createInvoice(1,acc);
        listInvoice[0].GL_Date__c = system.today();
        listInvoice[0].Invoice_Date__c = system.today();
        listInvoice[0].Conversion_Rate__c = 13;
        listInvoice[0].Invoice_Balance__c = 10;
        insert listInvoice;
        
        List<Invoice_Line_Item__c> listInvoiceLineItem = TestClassUtility.createInvoiceLineItem(1,listInvoice);
        insert listInvoiceLineItem;
        List<Related_Invoice_Receipt__c> listReceiptInvoice = TestClassUtility.createRelatedInvoiceReceipt(1,listInvoice, listReceipt );
        listReceiptInvoice[0].Direction__c = 'From Invoice To Receipt';
        listReceiptInvoice[0].Amount_Applied__c = 10;
        listReceiptInvoice[0].Applied_Date__c = system.today();
        upsert listReceiptInvoice;
        
        Id adjustmentRecType = Schema.SObjectType.Invoice_Line_Item__c.getRecordTypeInfosByName().get('Adjustment').getRecordTypeId();
        List<Invoice_Line_Item__c> listAdjustment = TestClassUtility.createInvoiceLineItem(1,listInvoice);
        listAdjustment[0].recordtypeid = adjustmentRecType;
        listAdjustment[0].Invoice_Line_Item__c = listInvoiceLineItem[0].id;
        listAdjustment[0].Tax__c = 'Out of scope 0%';
        listAdjustment[0].Date_Of_Adjustment__c = system.today();
        listAdjustment[0].Type__c = 'Invoice';
        listAdjustment[0].Amount__c = 0;
        insert listAdjustment;
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new AdjustmentMockCallout());
        InvoiceUtil.PushAdjToOracle(listAdjustment[0].id);
        test.stopTest();
    }
    
    public static testmethod void doTestAdjustmentWithTax(){
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        insert acc;
        
        List<Receipt__c> listReceipt = TestClassUtility.createReceipt(1,acc);
        listReceipt[0].Amount__c = 100;
        listReceipt[0].Status__c = 'Success';
        listReceipt[0].Receipt_Reference__c = '1';
        listReceipt[0].Payment_Method__c = 'Electronic Funds Transfer';
        insert listReceipt;
        List<Invoice__c> listInvoice = TestClassUtility.createInvoice(1,acc);
        listInvoice[0].GL_Date__c = system.today();
        listInvoice[0].Invoice_Date__c = system.today();
        listInvoice[0].Conversion_Rate__c = 13;
        listInvoice[0].Invoice_Balance__c = 10;
        insert listInvoice;
        
        List<Invoice_Line_Item__c> listInvoiceLineItem = TestClassUtility.createInvoiceLineItem(1,listInvoice);
        insert listInvoiceLineItem;
        List<Related_Invoice_Receipt__c> listReceiptInvoice = TestClassUtility.createRelatedInvoiceReceipt(1,listInvoice, listReceipt );
        listReceiptInvoice[0].Direction__c = 'From Invoice To Receipt';
        listReceiptInvoice[0].Amount_Applied__c = 10;
        listReceiptInvoice[0].Applied_Date__c = system.today();
        upsert listReceiptInvoice;
        
        Id adjustmentRecType = Schema.SObjectType.Invoice_Line_Item__c.getRecordTypeInfosByName().get('Adjustment').getRecordTypeId();
        List<Invoice_Line_Item__c> listAdjustment = TestClassUtility.createInvoiceLineItem(1,listInvoice);
        listAdjustment[0].recordtypeid = adjustmentRecType;
        listAdjustment[0].Invoice_Line_Item__c = listInvoiceLineItem[0].id;
        listAdjustment[0].Activity_Name__c = 'Invoice Cancellation';
        listAdjustment[0].Tax__c = '5%';
        listAdjustment[0].Date_Of_Adjustment__c = system.today();
        listAdjustment[0].Type__c = 'Invoice';
        listAdjustment[0].Amount__c = 1;
        listAdjustment[0].Tax_Amount__c = 1;
        listAdjustment[0].From_Data_Load__c = true;
        insert listAdjustment;

        List<Invoice_Line_Item__c> listAdjustment1 = TestClassUtility.createInvoiceLineItem(1,listInvoice);
        listAdjustment1[0].recordtypeid = adjustmentRecType;
        listAdjustment1[0].Invoice_Line_Item__c = listInvoiceLineItem[0].id;
        listAdjustment1[0].Activity_Name__c = 'Fee Waiver';
        listAdjustment1[0].Tax__c = '5%';
        listAdjustment1[0].Date_Of_Adjustment__c = system.today();
        listAdjustment1[0].Type__c = 'Invoice';
        listAdjustment1[0].Amount__c = 1;
        listAdjustment1[0].Tax_Amount__c = 1;
        listAdjustment1[0].From_Data_Load__c = true;
        insert listAdjustment1;

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new AdjustmentMockCallout());
        InvoiceUtil.PushAdjToOracle(listAdjustment[0].id);
        InvoiceUtil.PushAdjToOracle_Future(listAdjustment1[0].id);
        test.stopTest();
    }

    public static testmethod void doTestAdjustment(){

        Operating_Unit__c ou = new Operating_Unit__c(Invoice_Type__c = 'Test', Oracle_Site_Id__c='103', Invoice_Adjustment_Source_Endpoint__c= 'Test');
        insert ou;
        
        Revenue_Classification__c rc = new Revenue_Classification__c(Service_Type__c = 'Test',Line_Item_Type__c='test',Operating_Unit__c = ou.Id);
        insert rc;
        
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Operating_Unit__c = ou.id;
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Oracle_Site_Id__c = '103';
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

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new InvoiceMockCallout());
        InvoiceUtil.PushAdjToSourceSystem(listInvoiceLineItem1[0].Id);
        test.stopTest();

    }

    public static testmethod void doTestAdjustmentException(){

        Operating_Unit__c ou = new Operating_Unit__c(Invoice_Type__c = 'Test', Oracle_Site_Id__c='103', Invoice_Adjustment_Source_Endpoint__c= 'Test');
        insert ou;
        
        Revenue_Classification__c rc = new Revenue_Classification__c(Service_Type__c = 'Test',Line_Item_Type__c='test',Operating_Unit__c = ou.Id);
        insert rc;
        
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Operating_Unit__c = ou.id;
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Oracle_Site_Id__c = '103';
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

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new InvoiceMockCallout());
        InvoiceUtil.PushAdjToSourceSystem(listInvoiceLineItem1[0].Id);
        test.stopTest();

    }*/
}
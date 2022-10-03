@iSTest
public class Batch_CreatedAccessInvoiceAndJVTest {
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
        
        test.startTest();
            System.debug('Limit SOQL===='+Limits.getQueries());
        //Id adjustmentRecType = Schema.SObjectType.Invoice_Line_Item__c.getRecordTypeInfosByName().get('Adjustment').getRecordTypeId();
        //List<Invoice_Line_Item__c> listInvoiceLineItem = TestClassUtility.createInvoiceLineItem(1,listInvoice);
        //listInvoiceLineItem[0].recordtypeid = adjustmentRecType;
        //listInvoiceLineItem[0].Invoice_Line_Item__c = listInvoiceLineItem[0].id;
        /*listInvoiceLineItem[0].Tax__c = 'Out of scope 0%';
        listInvoiceLineItem[0].Date_Of_Adjustment__c = system.today();
        listInvoiceLineItem[0].Type__c = 'Invoice';
        listInvoiceLineItem[0].Amount__c = 0;
        listInvoiceLineItem[0].Department__c = 'CEO';
        listInvoiceLineItem[0].Service_Type__c = 'Corporate Services';
        listInvoiceLineItem[0].Service_Class__c = 'Business Service';
        listInvoiceLineItem[0].Revenue_Type__c='Corporate Services';
        insert listInvoiceLineItem;*/
        
        
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Permit_Alcohol');
        createdSRList[0].HexaBPM__Customer__c = acc[0].Id;
        insert createdSRList;
        
        List<HexaBPM__SR_Price_Item__c> newPriceItems = new List<HexaBPM__SR_Price_Item__c>();
        HexaBPM__SR_Price_Item__c priceItem = new HexaBPM__SR_Price_Item__c();
        priceItem.HexaBPM__Status__c = 'Consumed';
        priceItem.HexaBPM__ServiceRequest__c = createdSRList[0].Id;
        priceItem.Cost__c = 2000;
        priceItem.Is_Refund_Line__c = true;
        priceItem.Department__c = 'CEO';
        priceItem.Service_Type__c = 'Corporate Services';
        priceItem.Service_Class__c = 'Business Service';
        priceItem.Revenue_Type__c='Corporate Services';
        newPriceItems.add(priceItem);
        priceItem = new HexaBPM__SR_Price_Item__c();
        priceItem.HexaBPM__Status__c = 'Consumed';
        priceItem.HexaBPM__ServiceRequest__c = createdSRList[0].Id;
        priceItem.Cost__c = 1000;
        newPriceItems.add(priceItem);
        insert newPriceItems;
        
        List<Invoice__c> listInvoice = TestClassUtility.createInvoice(1,acc);
        listInvoice[0].GL_Date__c = system.today().addDays(-20);
        listInvoice[0].Invoice_Date__c = system.today().addDays(-20);
        listInvoice[0].Payment_Term__c = 'IMMEDIATE';
        listInvoice[0].Service_Request__c = createdSRList[0].Id;
        insert listInvoice;
        
        String iltId = newPriceItems[0].Id;
        
        
        Database.executeBatch(new Batch_CreatedDecAccessInvoicesAndJVs(), 1);
                
        
        /*Test.setMock(HttpCalloutMock.class, new InvoiceMockCallout());
        InvoiceUtil.pricingItemMap = new Map<Id,HexaBPM__SR_Price_Item__c>();
        InvoiceUtil.pricingItemMap.put(iltId,newPriceItems[0]);
        Test.setMock(HttpCalloutMock.class, new AdjustmentMockCallout());
        InvoiceUtil.LINE_REC_TYPE_CLASS objRefundLine = new InvoiceUtil.LINE_REC_TYPE_CLASS('0.0','0.0','Test123',iltId,String.valueOf(2345.5),'5%','Testinggg','','CEO','Default','Default','Default','Default','Default','Corporate Services');
        InvoiceUtil.mapInvoiceLineItem(objRefundLine,true,listInvoice[0].Id,listInvoiceLineItem[0].Id);
        String DateVal = listInvoice[0].GL_Date__c.DAY()+'-'+listInvoice[0].GL_Date__c.Month()+'-'+listInvoice[0].GL_Date__c.Year();
        InvoiceUtil.InputParameters_Class invObj = new InvoiceUtil.InputParameters_Class('INV-12345',String.ValueOf(listInvoice[0].Id),listInvoice[0].Entity__r.Oracle_Party_Id__c,listInvoice[0].Source_System__c,'Test12345',listInvoice[0].Oracle_Invoice_Type__c,DateVal,listInvoice[0].Entity__r.Oracle_Site_Id__c,'test1234','Immediate',listInvoice[0].Payment_Currency__c,listInvoice[0].Transaction_Type__c,'');
        InvoiceUtil.constructFinalWrapper(invObj,new List<InvoiceUtil.LINE_REC_TYPE_CLASS>{objRefundLine});*/
        test.stopTest();
    }
}
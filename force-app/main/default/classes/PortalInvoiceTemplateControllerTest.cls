@isTest
private class PortalInvoiceTemplateControllerTest{
    static testmethod void portalInvControllertest1(){
        List<Account> createdAccountList = TestClassUtility.createAccounts(1);
        createdAccountList[0].Oracle_Party_Id__c = '0000001';
        insert createdAccountList;
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Dependent_Visa_Cancellation');
        createdSRList[0].HexaBPM__Customer__c = createdAccountList[0].Id;
        insert createdSRList;
        
        HexaBPM__SR_Price_Item__c objPriceItem = new HexaBPM__SR_Price_Item__c();
        objPriceItem.HexaBPM__ServiceRequest__c = createdSRList[0].Id;
        objPriceItem.HexaBPM__Price__c = 1000;
        objPriceItem.Tax_Amount__c = 50;
        insert objPriceItem;
        
        test.startTest();
            PortalInvoiceTemplateController portalInvoice = new PortalInvoiceTemplateController();
            portalInvoice.SRID = createdSRList[0].Id;
            portalInvoice.getTotalAmount();
            portalInvoice.getPaymentLines();
        test.stopTest();
    }
}
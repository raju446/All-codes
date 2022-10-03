@isTest
private class ReceiptManagementControllerTest{
    static testmethod void receiptManagementControllertest1(){
        
        Receipt__c newReceipt = new Receipt__c();
        test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(newReceipt);
            ReceiptManagementController receiptMan = new ReceiptManagementController(sc);
            receiptMan.getPaymentModes();
            receiptMan.selPaymentMode = 'POS';
            receiptMan.bankTransRefNum = 'ref98164614';
            receiptMan.cancel();
            receiptMan.saveReceipt();
        test.stopTest();
    }
    
    static testmethod void receiptManagementControllertest2(){
        
        Receipt__c newReceipt = new Receipt__c();
        test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(newReceipt);
            ReceiptManagementController receiptMan = new ReceiptManagementController(sc);
            receiptMan.getPaymentModes();
            receiptMan.cancel();
            receiptMan.saveReceipt();
        test.stopTest();
    }
}
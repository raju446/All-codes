@isTest 
public with sharing class WS_CreateReceiptTest{
    public static testmethod void testcase(){
        Account acc = new Account();
        acc.Name = 'Oracle Test';
        acc.Oracle_Party_Id__c = '12345';
        insert acc;
        
        Receipt_Running_Number__c objCS = new Receipt_Running_Number__c();
        objCS.Name = 'Receipt_Reference_Number';
        objCS.Receipt_Prefix__c = 'R-';
        objCS.Running_Number__c = 1;
        insert objCS;
        
        WS_CreateReceipt.ReceiptInformation objRequest = new WS_CreateReceipt.ReceiptInformation();
        objRequest.OracleReceiptNumber = 'ORA-12345';
        objRequest.Amount = -100;
        objRequest.OraclePartyId = acc.Oracle_Party_Id__c;
        objRequest.Description = 'Customer Refund';
        objRequest.PaymentMode = 'Credit Card';
        objRequest.ReceiptDate = '12-12-2018';
        objRequest.PaymentPurpose = 'Portal Deposit';
        objRequest.CurrencyType = 'AED';
        WS_CreateReceipt.PushReceiptInformation(objRequest);
        
        objRequest = new WS_CreateReceipt.ReceiptInformation();
        objRequest.OracleReceiptNumber = 'ORA-12345';
        objRequest.Amount = -100;
        objRequest.OraclePartyId = '123456';
        objRequest.Description = 'Customer Refund';
        objRequest.PaymentMode = 'Credit Card';
        objRequest.ReceiptDate = '12-12-2018';
        objRequest.PaymentPurpose = 'Portal Deposit';
        objRequest.CurrencyType = 'AED';
        WS_CreateReceipt.PushReceiptInformation(objRequest);
        
        objRequest = new WS_CreateReceipt.ReceiptInformation();
        objRequest.OracleReceiptNumber = 'ORA-12345';
        objRequest.Amount = -100;
        objRequest.OraclePartyId = '12345';
        objRequest.Description = 'Customer Refund';
        objRequest.PaymentMode = 'Credit Card';
        objRequest.ReceiptDate = '12-12-2018';
        objRequest.PaymentPurpose = 'Portal Deposit';
        objRequest.CurrencyType = 'AED';
        WS_CreateReceipt.PushReceiptInformation(objRequest);
    }
    public static testmethod void testcase2(){
        Account acc = new Account();
        acc.Name = 'Oracle Test2';
        acc.Oracle_Party_Id__c = '123456';
        insert acc;
        
        Receipt_Running_Number__c objCS = new Receipt_Running_Number__c();
        objCS.Name = 'Receipt_Reference_Number';
        objCS.Receipt_Prefix__c = 'R-';
        objCS.Running_Number__c = 2;
        insert objCS;
        
        
        WS_CreateReceipt.ReceiptInformation objRequest = new WS_CreateReceipt.ReceiptInformation();
        objRequest.OracleReceiptNumber = 'ORA-123456';
        objRequest.Amount = -100;
        objRequest.OraclePartyId = acc.Oracle_Party_Id__c;
        objRequest.Description = 'Customer Refund';
        objRequest.PaymentMode = 'Credit Card';
        objRequest.ReceiptDate = '12-12-2018';
        objRequest.PaymentPurpose = 'Portal Deposit';
        objRequest.CurrencyType = 'AED';
        WS_CreateReceipt.PushReceiptInformation(objRequest);
        
        
    }
}
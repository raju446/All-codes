@isTest
public with sharing class SRPriceItemTriggerHandlerTest {
    
    private static  HexaBPM__SR_Price_Item__c createdSRPriceItem; 
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static  HexaBPM__Pricing_Line__c pricing; 
    private static  HexaBPM__Dated_Pricing__c datedPricing;
    
    
    private static void init(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '0000001';
        newAccounts[0].Is_ADGM_Company__c= true;
        insert newAccounts; 
        
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        insert createdSRList;   
        
        update createdSRList;
        
        pricing = new HexaBPM__Pricing_Line__c();
        pricing.Is_Refund_Line__c = true;
        pricing.HexaBPM__Priority__c = 1;
        insert pricing;
        
        datedPricing = new HexaBPM__Dated_Pricing__c();
        datedPricing.Cancellation_Fee__c = 20;
        datedPricing.Cost__c = 30;
        datedPricing.HexaBPM__Unit_Price__c = 40;
        datedPricing.MarkupAmount__c = 5;
        datedPricing.VAT__c = 50;
        datedPricing.HexaBPM__Date_From__c = system.today().addDays(-2);
        datedPricing.HexaBPM__Date_To__c = system.today().addDays(1);
        datedPricing.HexaBPM__Pricing_Line__c = pricing.Id;
        insert datedPricing;
        
        List<HexaBPM__SR_Price_Item__c> listSRPriceItem = new List<HexaBPM__SR_Price_Item__c>();
        createdSRPriceItem = new HexaBPM__SR_Price_Item__c();
        createdSRPriceItem.HexaBPM__ServiceRequest__c = createdSRList[0].Id;
        createdSRPriceItem.Is_Refund_Line__c = true;
        createdSRPriceItem.Cancellation_Fee__c = 33;
        createdSRPriceItem.HexaBPM__Price__c = 40;
        createdSRPriceItem.HexaBPM__Pricing_Line__c = pricing.Id;
        listSRPriceItem.add(createdSRPriceItem);
        
        
        createdSRPriceItem = new HexaBPM__SR_Price_Item__c();
        createdSRPriceItem.HexaBPM__ServiceRequest__c = createdSRList[0].Id;
        createdSRPriceItem.Is_Refund_Line__c = true;
        createdSRPriceItem.Cancellation_Fee__c = 33;
        createdSRPriceItem.HexaBPM__Price__c = 40;
        createdSRPriceItem.HexaBPM__Pricing_Line__c = pricing.Id;
        listSRPriceItem.add(createdSRPriceItem);
        insert listSRPriceItem;
        
        listSRPriceItem = new List<HexaBPM__SR_Price_Item__c>();
        createdSRPriceItem = new HexaBPM__SR_Price_Item__c();
        createdSRPriceItem.HexaBPM__ServiceRequest__c = createdSRList[0].Id;
        createdSRPriceItem.Is_Refund_Line__c = true;
        createdSRPriceItem.Cancellation_Fee__c = 33;
        createdSRPriceItem.HexaBPM__Price__c = 40;
        createdSRPriceItem.HexaBPM__Pricing_Line__c = pricing.Id;
        listSRPriceItem.add(createdSRPriceItem);
        
        
        createdSRPriceItem = new HexaBPM__SR_Price_Item__c();
        createdSRPriceItem.HexaBPM__ServiceRequest__c = createdSRList[0].Id;
        createdSRPriceItem.Is_Refund_Line__c = true;
        createdSRPriceItem.Cancellation_Fee__c = 33;
        createdSRPriceItem.HexaBPM__Price__c = 40;
        createdSRPriceItem.HexaBPM__Pricing_Line__c = pricing.Id;
        listSRPriceItem.add(createdSRPriceItem);
        insert listSRPriceItem;
        newAccounts[0].Is_ADGM_Company__c= false;
        update newAccounts; 
        listSRPriceItem[0].Cost__c = 123;
        listSRPriceItem[0].Oracle_Response__c = 'Test';
        update listSRPriceItem[0];
   }
    
    public static testmethod void testcase(){
        init();
        createdSRPriceItem.Cancellation_Fee__c = 10;
        SRPriceItemTriggerHandler.Execute_AI(null);
        //SRPriceItemTriggerHandler.Execute_AU(null,null);
        update createdSRPriceItem;
    }
    
}
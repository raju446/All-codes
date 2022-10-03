@isTest
private class PriceItemRollupControllerTest{
    static testMethod void PriceItemRollupControllerTest1(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Permit_Alcohol');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        insert createdSRList;
        
        HexaBPM__SR_Price_Item__c priceItem = new HexaBPM__SR_Price_Item__c();
        priceItem.HexaBPM__ServiceRequest__c = createdSRList[0].Id;
        priceItem.HexaBPM__Price__c = 1000;
        insert priceItem;
            
        test.startTest();
            system.currentPageReference().getParameters().put('Id', newAccounts[0].Id);
            PriceItemRollupController priceItemRollUp = new PriceItemRollupController();
            priceItemRollUp.SRID = createdSRList[0].Id;
            priceItemRollUp.getTotalAmount();
        test.stopTest();

    }
}
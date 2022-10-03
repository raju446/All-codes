@isTest
public class ExchangeRateTriggerHandlerTest {
    public static testmethod void testExchangeRateTrigger(){
        Operating_Unit__c ou = new Operating_Unit__c();
        insert ou;
        
        Test.startTest();
        	Exchange_Rate__c er = new Exchange_Rate__c();
        	insert er;
        Test.stopTest();
    }
}
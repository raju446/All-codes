/*
    Author      : Jayanta Karmakar
    Date        : 1-July-2020
    Description : Test class for ExchangeRateUtil class. Mock Class name : ExchangeRateMock
    ------------------------------------------------------------------
*/

@isTest
public class ExchangeRateUtilTest {
    public static testmethod void testExchangeRate(){
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new ExchangeRateMock());
        	String sch = '0 0 23 * * ?';
        	system.schedule('Test check', sch, new ExchangeRateUtil_New());
        //ExchangeRateUtil_new.doExchangeRateCall();
        
        Test.stopTest();
    }
    
    public static testmethod void testExchangeRateExc(){
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new ExchangeRateMock());
        	//ExchangeRateUtil.doCalloutFromFuture('Error');
        Test.stopTest();
    }
}
@isTest
public class WS_FetchRefundStatusServiceTest {
    public static testmethod void test1(){
        Refund__c refund = new Refund__c(Source_Refund_Reference_No__c = 'xyz');
        insert refund;
        test.startTest();
        	WS_FetchRefundStatusService.fetchRefundSts(null);
        	WS_FetchRefundStatusService.fetchRefundSts('abc');
        	WS_FetchRefundStatusService.fetchRefundSts('xyz');
        test.stopTest();
    }
}
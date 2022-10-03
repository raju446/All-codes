@isTest
public class WS_CreateRefundServiceTest {
    public static testmethod void test1(){
        WS_CreateRefundService.Refund_Wrapper refWrap = new WS_CreateRefundService.Refund_Wrapper();
        WS_CreateRefundService.Attachment_Wrapper attach = new WS_CreateRefundService.Attachment_Wrapper();
        attach.File_Body = 'xyz';
        attach.File_Name = 'abc.txt';
        refWrap.Attachment_List.add(attach);
        test.startTest();
        	WS_CreateRefundService.ProcessRefund(refWrap);
        	refWrap.Receipt_Id = 'acv';
        	WS_CreateRefundService.ProcessRefund(refWrap);
        test.stopTest();
    }
}
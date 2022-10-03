@isTest
public class ApproveRejectReceiptControllerTest {
    public static testmethod void test1(){
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '103';
        acc[0].Source_System_Name__c = 'FSRA';
        insert acc;
        
        Receipt__c objReceipt = new Receipt__c(Entity__c = acc[0].Id);
        objReceipt.Status__c = 'Draft';
        objReceipt.Source_Receipt_Id__c = 'abc123';
        objReceipt.Payment_Method__c = 'Electronic Funds Transfer';
        insert objReceipt;
        
        test.startTest();
        	ApproveRejectReceiptController.returnProcessInstance(objReceipt.id);
        
        	Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
            req.setComments('Submitting approval request using Trigger');        
            req.setObjectId(objReceipt.id);       
            Approval.ProcessResult result = Approval.process(req);  
        
        	ApproveRejectReceiptController.returnProcessInstance(objReceipt.id);
        	ApproveRejectReceiptController.approveOrRejectReceipt(null, 'Approved', 'cmnt', 'payeeName', 'paymentStatus', 1000, 1000);
        	ApproveRejectReceiptController.approveOrRejectReceipt(objReceipt.id, 'Approve', 'cmnt', 'payeeName', 'Payment Verified', 100, 1000);
        Test.stopTest();
    }
}
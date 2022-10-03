/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class RefundRequestControllerTest {
        
    static testMethod void testRefundRequest(){
        
        list<Account> testAccount = TestClassUtility.createAccounts(2);
        insert testAccount;
        
        Receipt__c rec = new Receipt__c(Entity__c = testAccount[0].id, Status__c = 'Draft',Payment_Method__c='Credit Card');
        insert rec;
          
        List<Fund_Transfer__c> fts = TestClassUtility.createFundTransfer(1,new List<Account>{testAccount[0]}, new List<Account>{testAccount[1]});
        fts[0].Reference_Receipt__c = rec.Id;
        insert fts;
        
        RefundRequestController.AttachmentWrapper aw = new RefundRequestController.AttachmentWrapper();
        aw.blobval =  EncodingUtil.base64Encode(Blob.valueOf('o')); //String.valueof(Blob.valueOf('o'));
        aw.fileName = 'test file';
        aw.isUploaded = true;     
        
        RefundRequestController.fetchPicklistVal('Receipt__c','Payment_Currency__c',null);
        RefundRequestController.submitForApproval(fts[0].Id);  
        RefundRequestController.getOldData(fts[0].Id);
        RefundRequestController.pushFundToOracle(fts[0].Id);
        RefundRequestController.getRecordDetail(fts[0].Id);
        RefundRequestController.fetchUnidentifiedEntityDetails(testAccount[0].Id);
        RefundRequestController.fetchFromEntityDetails(testAccount[0].Id);
        RefundRequestController.saveFundTransfer(fts[0],'Funds Transfer in same currency','Same Operating Unit' ,new List<RefundRequestController.AttachmentWrapper>{aw});
        RefundRequestController.fetchChildAccounts(testAccount[0].Id, false);
        RefundRequestController.fetchReceiptBalance(rec.id);
        
        //RefundRequestController.createRefundReceipt(rec, 'testFileName', 'testData');
        //RefundRequestController.createReceipt(testAccount[0].id,testAccount[1].id, rec);
        //RefundRequestController.createMemoReceipt( rec);
    }

}
/*
    Author      : Jayanta Karmakar
    Date        : 1-July-2020
    Description : Test class for RefundUtil class. Mock Class name : IBANCheckMock
    ------------------------------------------------------------------
*/

@isTest
public class RefundUtilTest {
    public static testmethod void testIBANCheckExc(){
        RefundUtil.getIBANDetail('null', 'null');
    }
    
    public static testmethod void testIBANCheck(){
        List<Account> accs = TestClassUtility.createAccounts(1);
        insert accs;
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new IBANCheckMock());
            RefundUtil.getIBANDetail(accs[0].Id, 'AE000001');
            RefundUtil.getIBANDetail_New(accs[0].Id, 'AE000001');
        Test.stopTest();
    }
    
    public static testmethod void testRefundMethod(){
        List<Account> accs = TestClassUtility.createAccounts(1);
        insert accs;
        List<Receipt__c> receipts = TestClassUtility.createReceipt(1, accs);
        receipts[0].Gl_date__c = date.today();
        receipts[0].Payment_Method__c = 'Electronic Funds Transfer';
        insert receipts;
        List<Refund__c> refunds = TestClassUtility.createRefund(1,accs,receipts);
        refunds[0].Amount__c = 100.00;
        insert refunds;
        
        ContentVersion cv = new ContentVersion(
                Title = 'Test',
                PathOnClient = 'Test.jpg',
                VersionData = blob.valueof('Test Content Data'),
                IsMajorVersion = true
            );
            insert cv;
            
            ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
             ContentDocumentLink contentlink=new ContentDocumentLink();
             contentlink.LinkedEntityId=refunds[0].id;  
             contentlink.ShareType= 'I';               
             contentlink.ContentDocumentId=documents[0].Id;
             contentlink.Visibility = 'AllUsers'; 
             insert contentlink;

        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new IBANCheckMock());
            RefundUtil.pushRefundToOracleFuture(new List<String>{refunds[0].Id});
            RefundUtil.pushRefundToOracle(refunds[0].Id);
        Test.stopTest();
    }
}
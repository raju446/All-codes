@isTest
private class ReceiptsAttachmentControllerTest{
    static testmethod void receiptAttachControllertest1(){
        Receipt__c newReceipt = new Receipt__c();
        newReceipt.Status__c='Success';
        insert newReceipt;    
        
        Attachment objAttachment = new Attachment();
        objAttachment.Name = 'Test Document';
        objAttachment.Body = blob.valueOf('test');
        objAttachment.ParentId = newReceipt.Id;
        insert objAttachment;
        
        test.startTest();
            system.currentPageReference().getParameters().put('Id', newReceipt.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(newReceipt);
            ReceiptsAttachmentController receiptAtt = new ReceiptsAttachmentController(sc);
        test.stopTest();
    }
}
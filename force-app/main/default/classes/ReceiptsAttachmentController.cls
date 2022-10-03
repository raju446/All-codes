public without sharing class ReceiptsAttachmentController{

    public ReceiptsAttachmentController(ApexPages.StandardController controller) {
        string receiptID = ApexPages.currentPage().getParameters().get('id');
        lstAttachment = new list<Attachment>();
        if(receiptID!=null){
           	for(Attachment attch:[select Id,LastModifiedDate,Name,createdby.Name FROM Attachment where parentid =:receiptID]){
           		lstAttachment.add(attch);
           	}
        }
    }
    public list<Attachment> lstAttachment {get;set;}

}
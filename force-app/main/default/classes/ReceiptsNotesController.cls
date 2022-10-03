public without sharing class ReceiptsNotesController{
    public list<Attachment> lstAttachment {get;set;}
    public ReceiptsNotesController(){
        string receiptID = ApexPages.currentPage().getParameters().get('id');
        lstAttachment = new list<Attachment>();
        lstAttachment = [select Id,LastModifiedDate,Name,CreatedById FROM Attachment where parentid = :receiptID];
    }
}
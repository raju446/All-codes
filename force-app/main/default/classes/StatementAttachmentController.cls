public without sharing class StatementAttachmentController{

    public StatementAttachmentController(ApexPages.StandardController controller) {
        string id = ApexPages.currentPage().getParameters().get('id');
        lstAttachment = new list<Attachment>();
        if(id!=null){
             for(Attachment attch:[select Id,LastModifiedDate,Name,createdby.Name FROM Attachment where parentid =:id]){
               lstAttachment.add(attch);
             }
        }
    }
    public list<Attachment> lstAttachment {get;set;}

}
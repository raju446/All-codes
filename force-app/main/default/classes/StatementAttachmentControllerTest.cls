@isTest
public with sharing class StatementAttachmentControllerTest {
    private static  List<Account> createdAccountList; 
    private static  List<Attachment> createdAttachmentList;
    
    public static void init(){
        createdAccountList = TestClassUtility.createAccounts(1);
        insert createdAccountList;
        
        createdAttachmentList = TestClassUtility.createAttachment(
                                new List<Attachment>{
                                    new Attachment(ParentId = createdAccountList[0].Id)});
    }   
    
    public static testmethod void TestStatementAttachmentController(){
        init();
        system.currentPageReference().getParameters().put('Id', createdAccountList[0].Id);
        StatementAttachmentController alc = new StatementAttachmentController(new ApexPages.StandardController(createdAttachmentList[0]));
    
    }
}
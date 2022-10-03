@isTest
public class CaseCommentsUnreadTest {
    static testMethod void CaseCommentTest(){
        case[] createdCaseList  = TestClassUtility.createCase(new List<Case>{new Case()}); 
        CaseCommentsUnread.getCaseCommentss(createdCaseList[0].id);
        createdCaseList[0].Case_Comment_Record__c = 'test';
        
        Test.startTest();
        update createdCaseList  ;
        CaseCommentsUnread.getCaseCommentss(createdCaseList[0].id);
        
        case[] createdCaseList2  = TestClassUtility.createCase(new List<Case>{new Case(Case_Comment_Record__c = 'cc.id')}); 
        CaseCommentsUnread.getCaseCommentss(createdCaseList[0].id);
        CaseComment cc          = new CaseComment(CommentBody = 'test',ParentId = createdCaseList2[0].id);
        insert cc;
        String testComment = CaseCommentsUnread.ShowComment(createdCaseList2[0].id,cc .id);
        createdCaseList2[0].Case_Comment_Record__c = 'pass thorugh else';
        update createdCaseList2;
        
        
        String testComment2 = CaseCommentsUnread.ShowComment(createdCaseList2[0].id,cc .id);
        
        CaseCommentsUnread.CreateCaseComment(createdCaseList2[0].id,'test',false);
        Test.stopTest();
    }
    
  
}
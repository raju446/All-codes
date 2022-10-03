@isTest
public class CaseCommentTriggerHandlerTest {
   // private static List<Case> createdCaseList; 
    static testmethod void testcaseComment(){
        
        Case[] createdCaseList = TestClassUtility.createCase(new List<Case>{new Case()});
        
        Test.startTest();
        CaseComment ccRec 	   = new CaseComment (ParentId = createdCaseList[0].Id,CommentBody='test',IsPublished=False);
        insert ccRec; 
        createdCaseList[0].Case_Comment_Record__c='test';
        update createdCaseList;
        CaseComment ccRec1 = new CaseComment (ParentId = createdCaseList[0].Id,CommentBody='test',IsPublished=False);
        insert ccRec1;
        Test.stopTest();
    }

}
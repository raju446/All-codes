@isTest
public class RatingControllerTest 
{
		static testMethod void TestRatingController()
        {
            Test.startTest();
            Case[] createdCaseList = TestClassUtility.createCase(new List<Case>{new Case()});
            createdCaseList[0].ownerId = UserInfo.getUserId();
            createdCaseList[0].status = 'Closed';
            update createdCaseList[0];
            ApexPages.currentPage().getParameters().put('caseId', createdCaseList[0].id);
            ApexPages.currentPage().getParameters().put('Rating', '1');
            ApexPages.currentPage().getParameters().put('ReopenCount', '0');
            RatingController testt = new RatingController();
            testt.UpdateRating();
        }
        
}
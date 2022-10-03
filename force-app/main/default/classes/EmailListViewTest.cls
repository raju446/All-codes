@isTest
public class EmailListViewTest {
    
     static testMethod void testEmailList(){
     	case[] createdCaseList 		   = TestClassUtility.createCase(new List<Case>{new Case()});  
        List <EmailMessage> testList   = EmailListView.getEmailMessages(createdCaseList[0].id);
        EmailMessage email 			   = new EmailMessage(FromAddress = 'test@abc.org',Incoming = True,
                                                          ToAddress= 'test@xyz.org',Subject = 'Test email',
                                                          HtmlBody = 'Test email body',ParentId = createdCaseList[0].id);
        insert email;
        EmailListView.UnreadEmailCheck(createdCaseList[0].id,email.id);
        case[] createdCaseList2 		   = TestClassUtility.createCase(new List<Case>{new Case()}); 
        EmailListView.UnreadEmailCheck(createdCaseList2[0].id,email.ParentId);
    }

}
@isTest
public class FeedbackControllerTest {
     static testMethod void TestFeedback(){
       
        FeedbackController nwtTest = new FeedbackController(); 
       
        test.startTest();
        LiveChatVisitor testVisitor = new LiveChatVisitor();
        insert testVisitor;
        
        LiveChatTranscript testChat = new LiveChatTranscript();
        testChat.LiveChatVisitorId =testVisitor.id;
        testchat.chatKey = '123';
        insert testChat;
         
        LiveChatTranscriptEvent lctEvent = new LiveChatTranscriptEvent();
        lctEvent.LiveChatTranscriptId = testChat.id;
        lctEvent.type = 'ChatRequest';
        lctEvent.time = system.now();
         
        FeedbackController.MarkCheckBox(testChat.ChatKey);
        FeedbackController.submit(testChat.ChatKey, '2', 'Checked');
        FeedbackController.submit(testChat.ChatKey, '1', 'Unchecked'); 
         
        test.stopTest();
          
	}
}
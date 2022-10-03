global class FeedbackController {

    
    public FeedbackController(){
    }
   
   @RemoteAction
   global static void  MarkCheckBox(string chatKeyvar){
      try{
            system.debug('--->'+ chatKeyvar);
            if(chatKeyvar != null && chatKeyvar != '') {
                List<LiveChatTranscript> listChat = [SELECT Name, Chat_Rating__c, Client_Satisfaction__c from LiveChatTranscript 
                                           where ChatKey = : chatKeyvar];
                if(listChat <> null && listChat.size() > 0)  {
                    listChat[0].Chat_End_Without_Feedback__c = true;
                   
                    update listChat[0];
                }//end if
            }//end if
        }catch(exception ex) {}
      
   }
    
    @RemoteAction
    global static void submit(string chatKeyvar, string rating, string clientSatisfaction ){
        
        
        try{
            system.debug('--->'+ chatKeyvar);
            if(chatKeyvar != null && chatKeyvar != '') {
                List<LiveChatTranscript> listChat = [SELECT Name, Chat_Rating__c, Client_Satisfaction__c,
CRM_Client_Not_Satisfied__c
                                           from LiveChatTranscript 
                                           where ChatKey = : chatKeyvar];
                if(listChat <> null && listChat.size() > 0)  {
                   
                    listChat[0].Chat_Rating__c = rating;
                    
                    
                    if (clientSatisfaction  == 'Checked'){
                        listChat[0].Client_Satisfaction__c = true;               
                    }
                    else if(clientSatisfaction  == 'Unchecked'){
                        listChat[0].CRM_Client_Not_Satisfied__c = true;

                    }
                    update listChat[0];
                }//end if
            }//end if
        }catch(exception ex) {}
        
       // LiveChatTranscript chat = [SELECT Id from LiveChatTranscript where Id = :ApexPages.currentPage().getParameters().get('chatKey')];
        
        //return null;
    }
}
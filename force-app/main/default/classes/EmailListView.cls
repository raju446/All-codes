public class EmailListView {
      @AuraEnabled
      public static List <EmailMessage> getEmailMessages(String CaseId) {
        return [SELECT Subject,FromAddress,ToAddress,MessageDate,toLabel(status),Id  FROM EmailMessage WHERE RelatedToId =:CaseId ORDER BY MessageDate DESC];
      }
       @AuraEnabled
       public static void UnreadEmailCheck(string CaseId,String idSelected){
           List<EmailMessage> unreadEmail = [SELECT Status,RelatedToId FROM EmailMessage WHERE RelatedToId =:CaseId AND Status='0' AND id !=:idSelected ];
           if(unreadEmail.size()==0 ){
               Case objcs = new Case(Id=CaseId);
    	       objcs.CRM_Has_Unread_Message__c = false;
               try{
    			update objcs;
           	   }catch(Exception e){
               }    
              
           }
            
       }  

}
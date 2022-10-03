public class CaseCommentsUnread {
    
     @AuraEnabled
    public static wrapperClass getCaseCommentss(String CaseId){
       
        wrapperClass returnwrapperClass = new  wrapperClass ();
        case getNewComments = [SELECT Case_Comment_Record__c from case WHERE id =:CaseId ];
        
        if(getNewComments.Case_Comment_Record__c != null && getNewComments.Case_Comment_Record__c != ''){ 
            list<String> newCaseIds               = getNewComments.Case_Comment_Record__c.split(',');
            returnwrapperClass.newCaseComments    = [SELECT CommentBody,CreatedDate,IsPublished,Id,CreatedBy.name  FROM CaseComment WHERE ParentId =:CaseId AND id in :newCaseIds ORDER BY CreatedDate DESC]; 
            returnwrapperClass.readCaseComments   = [SELECT CommentBody,CreatedDate,IsPublished,Id,CreatedBy.name  FROM CaseComment WHERE ParentId =:CaseId AND id not in  :newCaseIds ORDER BY CreatedDate DESC];
        }else{
            returnwrapperClass.newCaseComments    = null;
            returnwrapperClass.readCaseComments   = [SELECT CommentBody,CreatedDate,IsPublished,Id,CreatedBy.name  FROM CaseComment WHERE ParentId =:CaseId   ORDER BY CreatedDate DESC];
        }   
       return returnwrapperClass;    
    }
    
  
    public class wrapperClass{
        @AuraEnabled public List<CaseComment> newCaseComments{get;set;}
        @AuraEnabled public List<CaseComment> readCaseComments{get;set;}
    }  
    
    @AuraEnabled
     public static String ShowComment(String CaseId, String emailID) {
         CaseComment cc 		 = [SELECT CommentBody FROM CaseComment WHERE ParentId =:CaseId AND id =:emailID ];
         case objcs     	     = [SELECT Case_Comment_Record__c FROM case WHERE id =:CaseId];
         list<String> newCaseIds =  objcs.Case_Comment_Record__c.split(',');
         if (newCaseIds.contains(emailID)){
             newCaseIds.remove(newCaseIds.indexOf(emailID));
             String newIDList = string.join(newCaseIds,',');
			 objcs.Case_Comment_Record__c = newIDList;
             if (newIDList == '' || newIDList == null )
                 objcs.CRM_Has_Unread_Comments__c = false;
               try{
                 update objcs;
                 }catch(Exception e){
                     }
             return cc.CommentBody; 
             
         }else{
            return null;         
            }
         

      }  
    
@AuraEnabled
 public static void CreateCaseComment(String CaseId,String CommentBody, boolean IsPublic  ) {
    CaseComment cc = new CaseComment(ParentId = CaseId,CommentBody=CommentBody,IsPublished=IsPublic);
    insert cc;
    
    } 
}
public class CaseCommentTriggerHandler {
	public static void Execute_AI(list<CaseComment> TriggerNew){
        String RelatedID;
        String CaseCommentID;
        for(CaseComment cs:TriggerNew){
            RelatedID     = cs.ParentId;
            CaseCommentID = cs.id;            
        }
        if (RelatedID != null && CaseCommentID !=null){
            case objcs = [SELECT Case_Comment_Record__c, CRM_Has_Unread_Comments__c FROM case WHERE id =:RelatedID LIMIT 1 ];
            if(objcs.Case_Comment_Record__c != null && objcs.Case_Comment_Record__c !=''){
                
                    objcs.Case_Comment_Record__c += ',' + CaseCommentID;
                	objcs.CRM_Has_Unread_Comments__c = true;
                    try{
                        update  objcs;
                    }catch(Exception e){
                    }
			}else{
				objcs.Case_Comment_Record__c  = CaseCommentID;
                objcs.CRM_Has_Unread_Comments__c  = true;
                try{
                	update  objcs;
                }catch(Exception e){
                }
			}
                
}  
        
}
}
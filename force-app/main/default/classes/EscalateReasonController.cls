public without sharing class EscalateReasonController {

    //method to Escalate Case
	@AuraEnabled
    public static map<boolean,string> EscalateData(string CaseId){
        
        map <boolean,string> m1 = new map<boolean,string>();
	    string CaseOwnerId;
    	string strResult = 'You are not allowed to do this operation.';
        boolean hasAccess = false;
        
        Case caseRec = [SELECT OwnerId,IsClosed,status  FROM Case WHERE Id = :CaseId];
        CaseOwnerId = caseRec.OwnerId;
			
        if(caseRec.IsClosed){
				strResult ='Case is already closed.';
                m1.put(hasAccess,strResult);
                return m1;
                
        }else if(CaseOwnerId!=null && CaseOwnerId.startsWith('005') && CaseOwnerId == userinfo.getuserid()){
            if(caseRec.status != 'Escalated'){
                hasAccess = true;
                strResult ='The case can be escalated';
                
                m1.put(hasAccess,strResult);
                return m1;
            }else{
                hasAccess = false;
                strResult ='The case is already esclated';
                m1.put(hasAccess,strResult);
                return m1;
            }
       }else if(CaseOwnerId!=null && CaseOwnerId.startsWith('00G')){
            for(GroupMember GrpMem:[select Id,GroupId,UserOrGroupId from GroupMember where GroupId=:CaseOwnerId and UserOrGroupId=:userinfo.getuserid()]){
                hasAccess = False;
                strResult ='Please Accept the case First';
                m1.put(hasAccess,strResult);
                return m1;
          }
            
    	} 
                m1.put(hasAccess,strResult);
                return m1;
    	}
    
        @AuraEnabled
        public static String changeOwner(string CaseId,string escReason){
            String strResult = 'Case has been escalated';
            
            Case objcs = new Case(Id=CaseId);
    	    objcs.OwnerId = label.Business_Admin_Queue_Id;
            objcs.CRM_Reason_for_Escalation__c = escReason;
            objcs.CRM_Previous_Owner__c = userinfo.getFirstName() + ' ' + userinfo.getLastName();
    	    objcs.Priority = 'Level 1';
		    objcs.IsEscalated = true;
		    objcs.Status = 'Escalated';
            objcs.CRM_Update_counter__c = 0;
            objcs.CRM_Automatic_owner_change__c = false;
            objcs.CRM_Is_From_Escalate__c = true;
           

    	    try{
                CaseTriggerHelper.OwnerChangeFromButton=false;
    		    update objcs;
                
    	    }catch(Exception e){
    		strResult = e.getMessage()+'';
    	    }
    	   return strResult;
    
    }
}
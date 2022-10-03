public without sharing class AcceptCaseController{

    @AuraEnabled
    public static Case getCase(Id caseId) {
        return [SELECT IsClosed,OwnerId,Status FROM Case WHERE Id = :caseId];
    }
    
    @AuraEnabled
    public static string saveCaseWithOwner(Id caseId) {
        boolean hasAccess = false;
        string CaseOwnerId;
        for(Case caseRec : [SELECT OwnerId FROM Case WHERE Id = :caseId]){
            CaseOwnerId = caseRec.OwnerId;
        }
        if(CaseOwnerId!=null && CaseOwnerId.startsWith('005')){
            if(CaseOwnerId == userinfo.getuserid()){
                hasAccess = true;
            }else{
                
                return 'Case is already accepted by another user.';
            }
      }else if(CaseOwnerId!=null && CaseOwnerId.startsWith('00G')){
        for(GroupMember GrpMem:[select Id,GroupId,UserOrGroupId from GroupMember where GroupId=:CaseOwnerId and UserOrGroupId=:userinfo.getuserid()]){
              hasAccess = true;
          }
      }
        if(hasAccess){
            Case caseObj = new Case(
                    Id=caseId,
                    OwnerId=UserInfo.getUserId(),
                    Status='Accepted',
                    CRM_Update_counter__c = 0
                    );
            CaseTriggerHelper.OwnerChangeFromButton=false;
            upsert caseObj;
            return 'Case was assigned to you successfully';
        }
        else
            return 'You are not able to accept this Case since you do not belong to this queue.';
        /*
        contact.AccountId = accountId;
        upsert contact;
        return contact;
        */
    }
    @AuraEnabled
    public static String getUserId() {
        return UserInfo.getUserId();
    }
    @AuraEnabled
    public static String releaseCaseToQueue(Id caseId) {
        boolean QueueOwner = false;
        boolean hasAccess = false;
        string strResult = '';
        Case objCase = [SELECT Id, OwnerId, Queue_Name__c FROM Case WHERE Id = :caseId];
        List <User> allowed = [select Id from User where UserRole.Name in ('Contact Centre Manager', 'Business Admin') and id=:userinfo.getuserid()];
        if(objCase != null && String.IsNotEmpty(objCase.Queue_Name__c)){
            string CaseOwnerId = objCase.OwnerId;
            //Checking the case ownership
            if(CaseOwnerId!=null && CaseOwnerId.startsWith('005')){
                if(CaseOwnerId == userinfo.getuserid())
                    hasAccess = true;
            }else if(CaseOwnerId!=null && CaseOwnerId.startsWith('00G')){
                QueueOwner = true;
                
            }
            if(!hasAccess && (allowed.size()==0)){
                strResult = 'You are not allowed to do this operation.';
                return strResult;
            }else if(QueueOwner){
                strResult = 'The case is already a part of a queue';
                return strResult;
            }else{
                List<Group> queueName = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = :objCase.Queue_Name__c];
                system.debug(queueName);
                if(queueName.size() > 0){
                    objCase.OwnerId = queueName[0].Id;
                    objCase.status = 'Released to Queue';
                    objCase.CRM_Update_counter__c = 0;
                    CaseTriggerHelper.OwnerChangeFromButton=false;
                    try{
                        update objCase;
                    }
                    catch(System.DmlException ex){
                        return ex.getDmlMessage(0);
                    }
                }
            }
        }
        return 'success';
    }
    
    @AuraEnabled
    public static List<ListView> getListViews() {
    List<ListView> listviews = 
        [SELECT Id, Name FROM ListView WHERE SobjectType = 'Case'];

    
    return listviews;
}

}
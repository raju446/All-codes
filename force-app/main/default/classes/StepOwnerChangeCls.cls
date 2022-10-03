global without sharing class StepOwnerChangeCls{
    WebService static string AcceptStep(string stepId,string OwnerId){
        string responseStr = '';
        try{
            if(string.isNotBlank(stepId)){
                if(OwnerId.startsWith('00G')){
                    if(IsGroupMember(UserInfo.getUserId(),OwnerId)){
                        HexaBPM__Step__c step = new HexaBPM__Step__c(Id = stepId);
                        step.OwnerId = userInfo.getUserId();
                        update step;
                        responseStr = 'Action Item Assigned Successfully.';
                    }else{
                        responseStr = 'Action Item can only be Assigned to the Member of the Queue.';
                    }
                }else{
                    responseStr = 'Only Action Items in Queue can be Assigned.';
                }
            }
        }catch(DMLException e){
            responseStr = e.getMessage();
        }
        return responseStr;
    }
    public static Boolean IsGroupMember(string userId,string GroupId){
        Boolean isMember = false;
        for(GroupMember gm:[SELECT GroupId FROM GroupMember WHERE UserOrGroupId=:userId AND Group.Type='Queue' AND GroupId=:GroupId]){
            isMember = true;
        }
        return isMember;
    }
    WebService static string ReleaseStep(string stepId,string OwnerId,string srStepOwnerId){
        string responseStr = '';
        try{
            if(string.isNotBlank(stepId)){
                if(!OwnerId.startsWith('00G')){
                    HexaBPM__Step__c step = new HexaBPM__Step__c(Id = stepId);
                    step.OwnerId = srStepOwnerId;
                    update step;
                    responseStr = 'Action Item Released Successfully.';
                }else{
                    responseStr = 'Action Item Released Successfully.';
                }
            }
        }catch(DMLException e){
            responseStr = e.getMessage();
        }
        return responseStr;
    }
}
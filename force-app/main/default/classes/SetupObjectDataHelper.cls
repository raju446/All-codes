public without sharing class SetupObjectDataHelper{
    public static list<GroupDetails> lstGroupsData = new list<GroupDetails>();
    /* Returns the Group/Queue Information for the requested Group */
    public static list<GroupDetails> getGroupData(string strGroupId){
        if(lstGroupsData.size()==0){
            for(GroupMember GrpMem:[select Id,GroupId,UserOrGroupId from GroupMember where GroupId=:strGroupId]){
                GroupDetails objGrp = new GroupDetails();
                objGrp.GroupOrUserId = GrpMem.UserOrGroupId;
                lstGroupsData.add(objGrp);
            }
        }
        return lstGroupsData;
    }
    /* Returns list of Users under the requested Groups */
    public static map<string,list<GroupDetails>> getGroupMembers(list<string> listGroupNames){
    	map<string,list<GroupDetails>> MapGroupMembers = new map<string,list<GroupDetails>>();
        if(listGroupNames!=null && listGroupNames.size()>0){
            for(GroupMember GrpMem:[select Id,GroupId,UserOrGroupId,Group.Name from GroupMember where Group.Name IN:listGroupNames]){
            	list<GroupDetails> lstGrpMembers = new list<GroupDetails>();
            	if(MapGroupMembers.get(GrpMem.Group.Name)!=null)
            		lstGrpMembers = MapGroupMembers.get(GrpMem.Group.Name);
            		
                GroupDetails objGrp = new GroupDetails();
                objGrp.GroupOrUserId = GrpMem.UserOrGroupId;
                lstGrpMembers.add(objGrp);
                MapGroupMembers.put(GrpMem.Group.Name,lstGrpMembers);
            }
        }
        return MapGroupMembers;
    }
    public class GroupDetails{
        public string GroupOrUserId;
    }
    public static map<string,string> getsObjectQueues(string ObjectName){
        map<string,string> MapQueueDetails = new map<string,string>();
        for(QueueSobject objQueue:[Select Queue.Name,Queue.DeveloperName,SobjectType,QueueId From QueueSobject where sObjectType=:ObjectName]){
            MapQueueDetails.put(objQueue.Queue.DeveloperName,objQueue.QueueId);
        }
        return MapQueueDetails;
    }
    public static map<string,string> getEmailTemplates(){
        map<string,string> Map_Email_SMS_Templates = new map<string,string>();
        for(EmailTemplate et:[select id,Name,Folder.Name from EmailTemplate limit 50000]){
            Map_Email_SMS_Templates.put(et.Name,et.Id);
        }
        return Map_Email_SMS_Templates;
    }
    public static map<string,string> GetDelegatedUsers(string CurrentUserId){
        map<string,string> MapDelegatedUsers = new map<string,string>();
        for(User usr:[select Id,DelegatedApproverId from User where DelegatedApproverId=:CurrentUserId]){
            MapDelegatedUsers.put(usr.Id,usr.DelegatedApproverId);
        }
        return MapDelegatedUsers;
    }
}
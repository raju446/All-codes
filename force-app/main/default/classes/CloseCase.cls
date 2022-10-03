/*
Author      :   prateek
Class Name  :   CloseCase
Description :   It is used as a controller for the CloseCase
Date        :   05/13/2019     
--------------------------------------------------------------------------------------
* @Change History
* Author            Date            Description
Yogesh Mahajan     05-Sept-2019     Added quick text object SOQL
Yogesh Mahajan     25-Nov-2019      Added Dept. Wise filter into quick text
*/
public class CloseCase {
    /*
Method Name : CloseCaseAccsess
Description : Used to check case status
*/
    @AuraEnabled
    public static map<boolean,string> CloseCaseAccsess(string CaseId){
        
        map <boolean,string> m1 = new map<boolean,string>();
        string CaseOwnerId;
        string strResult = 'You are not allowed to do this operation.';
        boolean hasAccess = false;
        
        Case caseRec = [SELECT OwnerId,IsClosed,status  FROM Case WHERE Id = :CaseId];
        CaseOwnerId = caseRec.OwnerId;
        
        if(caseRec.IsClosed == true){
            strResult ='Case is already closed.';
            m1.put(hasAccess,strResult);
            return m1;
            
        }else {
            if(CaseOwnerId == userinfo.getuserid()){
                hasAccess = true;
                strResult ='The case can be closed';
                m1.put(hasAccess,strResult);
                return m1;
            } else{
                strResult ='Please accept the case first'; 
                m1.put(hasAccess,strResult);
                return m1;
            } 
        }
    }
    /*
Method Name : fetchQuickText
Description : Used to quick text
*/
    @AuraEnabled
    public static List<QuickText> fetchQuickText(){
        String uRoleId = UserInfo.getUserRoleId();
        List<UserRole> listRole = [select id, Name from UserRole where id = :uRoleId];
        List<QuickText> listQuickText = new List<QuickText >();
        if(listRole <> null && listRole.size() > 0) {
            listQuickText = [SELECT ID, Message, Name FROM QuickText WHERE Department__c INCLUDES (: listRole[0].Name)];
        }
        
        if(listQuickText <> null && listQuickText.size() > 0) {
            return listQuickText;   
        }
        return null;        
    }
    /*
Method Name : closeCase
Description : Used to close Case
*/
    @AuraEnabled
    public static String closeCase(string CaseId,string reason){
        String strResult = 'The Case has been Closed';
        
        Case objcs = new Case(Id=CaseId);
        
        objcs.CRM_Case_Resolution__c = reason;
        objcs.Status = 'Closed';
        
        try{
            update objcs;
            
        }catch(DMLException e) {
            string DMLError = e.getdmlMessage(0) + '';
            if(DMLError == null) {
                DMLError = e.getMessage() + '';
            }
            strResult = DMLError;
        }
        /*catch(Exception e){
strResult = e.getMessage()+'';
throw new AuraHandledException('Exception occured:\r\n' + e.getMessage() + '\r\n' + e.getStackTraceString() + '\r\n');
}*/
        return strResult;
        
    }
}
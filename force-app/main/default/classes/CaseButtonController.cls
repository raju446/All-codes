/*
    Author      : Kim Noceda
    Date        : 17-Dec-2017
    Description : Class that accept/release case to queue
    --------------------------------------------------------------------------------------
*/
global without sharing class CaseButtonController{
    webservice static string AcceptCase(string CaseId){
        string strResult = 'Success';
        if(CaseId!=null){
            Case objCase = new Case(Id=CaseId);
            objCase.OwnerId = userinfo.getUserId();
            try{
                update objCase;
            }catch(Exception e){
                strResult = e.getMessage()+'';
            }
        }
        return strResult;
    }
    
    //method to release case to queue
    webservice static String releaseCaseToQueue(String caseId){
        String resultStr = '';
        
        Case objCase = [SELECT Id, OwnerId, Queue_Name__c FROM Case WHERE Id = :caseId];
        system.debug(objCase);
        List<Group> queueName = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = :objCase.Queue_Name__c];
        system.debug(queueName);
        objCase.OwnerId = queueName[0].Id;
        try{
            update objCase;
            resultStr = 'Success';
        } catch(Exception e){
            resultStr = e.getmessage();
        }
        
        return resultStr;
    }
}
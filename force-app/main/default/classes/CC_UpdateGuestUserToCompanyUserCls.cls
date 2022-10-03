/*
    Author      : Kim Noceda
    Date        : 26-Dec-2017
    Description : Custom code to create convert Guest user to Company user.
    --------------------------------------------------------------------------------------
*/
global without sharing class CC_UpdateGuestUserToCompanyUserCls implements HexaBPM.iCustomCodeExecutable {
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step.HexaBPM__SR__c!=null){
        
            HexaBPM__Service_Request__c objSR = [SELECT Id, CreatedById FROM HexaBPM__Service_Request__c WHERE Id = :step.HexaBPM__SR__c LIMIT 1];
            User guestUser = [SELECT Id, ContactId FROM User WHERE Id = :objSR.CreatedById];
            Contact objCon = [SELECT Id, Is_Guest_User__c FROM Contact WHERE Id = :guestUser.ContactId];
            objCon.Is_Guest_User__c = false;
            try{
                update objCon;
                
                List<Id> objSRList = new List<Id>();
                objSRList.add(step.HexaBPM__SR__c);
                updateGuestUser(objSRList);
                
            } catch(Exception e){
                strResult = e.getMessage();
            }
        }
        return strResult;
    }
    
    @future
    static void updateGuestUser(List<Id> srId){
    
        List<Profile> profileCommunityAdmin = [SELECT Id, Name FROM Profile WHERE Name = :Label.Community_Profile_Name LIMIT 1]; 
        List<Profile> profileCommunityNonAdmin = [SELECT Id, Name FROM Profile WHERE Name = :Label.Community_Profile_Non_Admin_Name LIMIT 1];
        HexaBPM__Service_Request__c objSR = [SELECT Id, CreatedById, Role__c FROM HexaBPM__Service_Request__c WHERE Id IN :srId LIMIT 1];
        List<User> guestUser = [SELECT Id, ProfileId FROM User WHERE Id = :objSR.CreatedById];
        
        if(objSR.Role__c == 'Lead Admin'){
            guestUser[0].ProfileId = profileCommunityAdmin[0].Id;
        } else if(objSR.Role__c == 'Admin'){
            guestUser[0].ProfileId = profileCommunityNonAdmin[0].Id;
        }
        
        update guestUser;
    }
}
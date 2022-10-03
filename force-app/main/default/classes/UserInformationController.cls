public without sharing class UserInformationController{
    public string UserId{get;set;}
    public string getUserName(){
        string UserName;
        Log__c log = new Log__c();
        log.User_Name__c = UserId;
        for(User usr:[Select Id,UserName from User where Id=:UserId]){
            UserName = usr.UserName ;
            log.Message__c = usr.UserName;
        }
        //insert log;
        return UserName;
    }
}
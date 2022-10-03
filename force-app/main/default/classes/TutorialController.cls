public without sharing class TutorialController{
    public boolean isGuestUser {get;set;}
    public TutorialController(){
        list<User> lstUser = [Select contact.Is_Guest_User__c from User where id =: Userinfo.getUserid() limit 1];
        if(!lstUser.IsEmpty()){
            isGuestUser = lstUser[0].contact.Is_Guest_User__c;
        }
    }
}
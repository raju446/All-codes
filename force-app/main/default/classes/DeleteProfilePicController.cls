/*
    Author      : Rajil Ravindran
    Date        : 24-Mar-2018
    Description : Deletes the profile picture of the Portal User.
    --------------------------------------------------------------------------------------
*/
public without sharing class DeleteProfilePicController{
    public pagereference deleteProfilePic(){
        User currentuser = [Select contact.Profile_Picture_Id__c,ContactId  from User where Id=:userinfo.getuserId()];
        string profilePicId,ContactId;
        if(currentuser != null){
            profilePicId = currentuser.contact.Profile_Picture_Id__c;
            ContactId = currentUser.ContactId;
        }
        if(profilePicId!=null){
            list<Attachment> lstatt = [select Id from Attachment where Id=:profilePicId];
            if(lstatt!=null && lstatt.size()>0)
                delete lstatt;
        }
        profilePicId = null;
        Contact objCon = new Contact(Id=ContactId);
        objCon.Profile_Picture_Id__c = null;
        update objCon;
        pagereference pg = new pagereference('/apex/home');
        pg.setRedirect(true);
        return pg;
    }

}
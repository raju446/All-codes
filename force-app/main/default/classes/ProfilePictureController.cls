/*
    Author      : Durga Prasad
    Date        : 25-Sep-2017
    Description : Page Controller to upload the profile picture of the Portal User.
    --------------------------------------------------------------------------------------
*/
public with sharing class ProfilePictureController{
    public string DEFAULT_NAME = 'Profile.jpg';
    public string strCroppedData{get;set;}
    public string ContactId{get;set;}
    public string ProfilePictureId {get;set;}
    public ProfilePictureController(){
        for(User usr:[Select Id,ContactId,Contact.Profile_Picture_Id__c from user where Id=:userinfo.getUserId()]){
            if(usr.ContactId!=null){
                ProfilePictureId = usr.Contact.Profile_Picture_Id__c;
                ContactId= usr.ContactId;
            }
        }
    }
    /*
        Description : Saves the Selected Photo as Profile Picture for the Contact.
    */
    public pagereference SaveCroppedImage(){
        if(apexpages.currentPage().getParameters().get('Id')!=null)
            ContactId = apexpages.currentPage().getParameters().get('Id');
        for(User usr:[Select Id,ContactId,Contact.Profile_Picture_Id__c from user where Id=:userinfo.getUserId()]){
            if(usr.ContactId!=null){
                ContactId = usr.ContactId;
                ProfilePictureId = usr.Contact.Profile_Picture_Id__c;
            }
        }
        if(strCroppedData!=null && ContactId!=null){
            try{
                addContactPhoto(ContactId);
                Cancel();
            }catch(Exception ex){
                System.debug('Attachment on SR failed ==>' + ex.getMessage());
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,ex.getMessage()));
                return null;
            }
        }
        return new pagereference('/apex/home');
    }
    /*
        Description : Adds photo on Contact from the captured base64 string and deletes the existing photo
    */
    public void addContactPhoto(string userContactId){
        string strSplittedString = '';
        if(strCroppedData!=null && strCroppedData!='' && strCroppedData.indexOf('base64,')>-1){
            list<string> lstSplittedString = strCroppedData.split('base64,');
            if(lstSplittedString!=null && lstSplittedString.size()>=2)
                strSplittedString = lstSplittedString[1];
            try{
                Attachment newPhotoAttachment= new Attachment();
                newPhotoAttachment.ContentType = 'image/jpeg';
                newPhotoAttachment.Name= DEFAULT_NAME;//'photo.jpeg';
                newPhotoAttachment.Body = EncodingUtil.base64Decode(strSplittedString);
                newPhotoAttachment.parentId=userContactId;
                insert newPhotoAttachment;
                system.debug('strCroppedData==>'+strCroppedData);
                
                Contact objCon = new Contact(Id=userContactId);
                objCon.Profile_Picture_Id__c = newPhotoAttachment.Id;
                //objCon.Profile_Picture__c = '<img alt="Profile_Picture" src="data:image/jpeg;base64,'+EncodingUtil.base64Encode(newPhotoAttachment.Body)+'"></img>';
                update objCon;
                if(ProfilePictureId!=null){
                    list<Attachment> lstatt = [select Id from Attachment where Id=:ProfilePictureId];
                    if(lstatt!=null && lstatt.size()>0)
                        delete lstatt;
                }
            }catch(Exception ex){
                
            }finally{
                strCroppedData = null;
            }
        }
    }
    
    /*
        Description : Cancel the Changes and reloads the same page
    */
    public PageReference Cancel(){
        for(User usr:[Select Id,ContactId,Contact.Profile_Picture_Id__c from user where Id=:userinfo.getUserId()]){
            if(usr.ContactId!=null){
                ProfilePictureId = usr.Contact.Profile_Picture_Id__c;
            }
        }
        pagereference pg = new pagereference('/apex/home');
        pg.setRedirect(true);
        return pg;
    }
}
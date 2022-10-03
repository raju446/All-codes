/*
    Author      : Kim Noceda
    Date        : 20-Dec-2017
    Description : Page Controller to upload the announcement images
    --------------------------------------------------------------------------------------
*/
public with sharing class AnnouncementImageUploadController{

    public Notice__c objAnnouncement {get;set;}

    public string DEFAULT_NAME = 'Profile.jpg';
    public string strCroppedData{get;set;}
    public string ContactId{get;set;}
    public string ProfilePictureId {get;set;}
    public String richtextURL {get;set;}
    
    public AnnouncementImageUploadController(ApexPages.StandardController stdController){
        this.objAnnouncement = (Notice__c)stdController.getRecord();
        objAnnouncement = [SELECT Id, Announcement_Header_Content__c FROM Notice__c WHERE Id = :objAnnouncement.Id];
        
        richtextURL = '';
        if(objAnnouncement.Announcement_Header_Content__c != null){
            String firstSubString = objAnnouncement.Announcement_Header_Content__c.substringBetween('<img', 'img>');
            System.debug('First substring: ' + firstSubString);

            String secondSubString = firstSubString.substringBetween('src="', '"');
            System.debug('Second substring: ' + secondSubString);

            richtextURL = secondSubString.replace('amp;', '');
        }
        

        for(User usr:[Select Id,ContactId,Contact.Profile_Picture_Id__c from user where Id=:userinfo.getUserId()]){
            if(usr.ContactId!=null){
                ProfilePictureId = usr.Contact.Profile_Picture_Id__c;
            }
        }
    }
    /*
        Description : Saves the Selected Photo as Profile Picture for the Contact.
    */
    public pagereference SaveCroppedImage(){
        /*if(apexpages.currentPage().getParameters().get('Id')!=null)
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
        }*/
        return new pagereference('/'+objAnnouncement.Id);
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
        pagereference pg = new pagereference('/'+objAnnouncement.Id);
        pg.setRedirect(true);
        return pg;
    }
}
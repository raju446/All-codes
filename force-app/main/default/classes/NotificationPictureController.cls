/*
    Author      : Rajil Ravindran
    Date        : 21-Jan-2018
    Description : Page Controller to upload the notification picture for the relevant notification.
    --------------------------------------------------------------------------------------
*/
public with sharing class NotificationPictureController{
    public string DEFAULT_NAME = 'Profile.jpg';
    public string strCroppedData{get;set;}
    public string ContactId{get;set;}
    public string ProfilePictureId {get;set;}
    public string notificationId {get;set;}
    ApexPages.StandardController controller;
    public Notice__c notice{get;set;}
    public PageReference rtn;
    public NotificationPictureController(ApexPages.StandardController c){
        notice = (Notice__c )c.getRecord();
        rtn = c.view();
        
        for(Notice__c notice:[Select Notification_Picture_Id__c from Notice__c where Id=:apexpages.currentPage().getParameters().get('Id')]){
            if(notice.Notification_Picture_Id__c !=null){
                ProfilePictureId = notice.Notification_Picture_Id__c;
            }
        }
        
    }
    /*
        Description : Saves the Selected Photo as Profile Picture for the Contact.
    */
    public pagereference SaveCroppedImage(){
        if(apexpages.currentPage().getParameters().get('Id')!=null)
            notificationId = apexpages.currentPage().getParameters().get('Id');
        
        if(strCroppedData!=null && notificationId !=null){
            try{
                addContactPhoto(notificationId);
                Cancel();
            }catch(Exception ex){
                System.debug('Attachment on SR failed ==>' + ex.getMessage());
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,ex.getMessage()));
                return null;
            }
        }
        return rtn ;
    }
    /*
        Description : Adds photo on Contact from the captured base64 string and deletes the existing photo
    */
    public void addContactPhoto(string notificationId){
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
                newPhotoAttachment.parentId=notificationId;
                insert newPhotoAttachment;
                system.debug('strCroppedData==>'+strCroppedData);
                
                Notice__c objNotice = new Notice__c(Id=notificationId);
                objNotice.Notification_Picture_Id__c = newPhotoAttachment.Id;
                objNotice.Announcement_Header_Content__c= '<img alt="Profile_Picture" src="data:image/jpeg;base64,'+EncodingUtil.base64Encode(newPhotoAttachment.Body)+'" ></img>';
                update objNotice;
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
        for(Notice__c notice:[Select Notification_Picture_Id__c from Notice__c where Id=:apexpages.currentPage().getParameters().get('Id')]){
            if(notice.Notification_Picture_Id__c !=null){
                ProfilePictureId = notice.Notification_Picture_Id__c;
            }
        }
        
        return rtn ;
    }
}
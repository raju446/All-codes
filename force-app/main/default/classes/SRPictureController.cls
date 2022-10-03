/*
    Author      : Rajil Ravindran
    Date        : 26-July-2018
    Description : Page Controller to upload the image for the relevant Service Request.
    --------------------------------------------------------------------------------------
*/
public without sharing class SRPictureController{
    public string DEFAULT_NAME = 'EmployeePicture.jpg';
    public string strCroppedData{get;set;}
    public string ContactId{get;set;}
    public string ProfilePictureId {get;set;}
    public string srId {get;set;}
    ApexPages.StandardController controller;
    public HexaBPM__Service_Request__c serviceRequest{get;set;}
    public PageReference rtn;
    public SRPictureController(ApexPages.StandardController c){
        serviceRequest = (HexaBPM__Service_Request__c )c.getRecord();
        rtn = c.view();
        
       for(Attachment attachment:[Select id from Attachment where parentId=:apexpages.currentPage().getParameters().get('Id') limit 1]){
               ProfilePictureId = attachment.id;
        }
        
    }
    /*
        Description : Saves the Selected Photo as Profile Picture for the Contact.
    */
    public pagereference SaveCroppedImage(){
        if(apexpages.currentPage().getParameters().get('Id')!=null)
            srId = apexpages.currentPage().getParameters().get('Id');
        Savepoint sp = Database.setSavepoint();
        if(strCroppedData!=null && srId !=null){
            try{
                addSRPicture(srId);
                Cancel();
            }catch(Exception ex){
                Database.rollback(sp);
                strCroppedData = null;
                System.debug('Attachment on SR failed ==>' + ex.getMessage());
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,ex.getMessage()));
                return null;
            }
        }
        return rtn ;
    }
    /*
        Description : Adds photo on Contact from the captured base64 string and deletes the existing photo.
    */
    public void addSRPicture(string srId)
    {
        Savepoint sp = Database.setSavepoint();
        string strSplittedString = '';
        if(strCroppedData!=null && strCroppedData!='' && strCroppedData.indexOf('base64,')>-1){
            list<string> lstSplittedString = strCroppedData.split('base64,');
            if(lstSplittedString!=null && lstSplittedString.size()>=2)
                strSplittedString = lstSplittedString[1];
            //try{
                //Delete all the attachments first with the description having the default name
                list<Attachment> lstatt = [select Id from Attachment where Description = :DEFAULT_NAME];
                if(lstatt!=null && lstatt.size()>0)
                    delete lstatt;
                
                //Add the new picture.
                Attachment newPhotoAttachment= new Attachment();
                newPhotoAttachment.ContentType = 'image/jpeg';
                newPhotoAttachment.Name= DEFAULT_NAME;//'photo.jpeg';
                newPhotoAttachment.Body = EncodingUtil.base64Decode(strSplittedString);
                newPhotoAttachment.Description = DEFAULT_NAME;
                newPhotoAttachment.parentId=srId;
                insert newPhotoAttachment;
                system.debug('strCroppedData==>'+strCroppedData);

                HexaBPM__Service_Request__c srObj = new HexaBPM__Service_Request__c(Id=srId);
                srObj.Employee_Picture__c= '<img alt="Profile_Picture"  src="data:image/jpeg;base64,'+EncodingUtil.base64Encode(newPhotoAttachment.Body)+'" ></img>';
                update srObj;
                
            //}catch(Exception ex){
                //Database.rollback(sp);
            //}finally{
               // Database.rollback(sp);
                //strCroppedData = null;
            //}
        }
    }
    /*
        Description : Cancel the Changes and reloads the same page
    */
    public PageReference Cancel(){
        for(Attachment attachment:[Select id from Attachment where parentId=:apexpages.currentPage().getParameters().get('Id') limit 1]){
                ProfilePictureId = attachment.id;
        }
        
        return rtn ;
    }
}
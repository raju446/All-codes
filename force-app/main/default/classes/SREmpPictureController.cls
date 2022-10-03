public without sharing class SREmpPictureController
{
    HexaBPM__Service_Request__c sr;
    public boolean displayLinks {get;set;}
    
    public SREmpPictureController(ApexPages.StandardController c)
    {
        displayLinks = true;
        sr = (HexaBPM__Service_Request__c )c.getRecord();
        sr = [Select Work_Permit_Card_Number__c, HexaBPM__IsClosedStatus__c FROM HexaBPM__Service_Request__c where id=:sr.id];
        if(sr.HexaBPM__IsClosedStatus__c == true)
            displayLinks = false;
    }
    public void removephoto()
    {
        system.debug('=========');
        sr.Employee_Picture__c = null;
        update sr;
        
        for(Attachment attachment:[Select id from Attachment where parentId=:sr.id]){
               delete attachment;
        }
        //return new pageReference('/'+sr.id).setRedirect(true);
        
    }
}
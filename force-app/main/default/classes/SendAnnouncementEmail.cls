/*
@Author : Azmath
@Desc : This class will be called from the list view custom button "Send Email" to call to the batch class which takes care of sending notification emails.
*/ 
global without sharing class SendAnnouncementEmail 
{
    webservice static void invokeBatch(boolean isGeneric,string atype, string aId)
    {
    	if(isGeneric)
    	{
    		Batch_SendAnnouncementNotifications bc = new Batch_SendAnnouncementNotifications(atype,true,aId);
    		database.executeBatch(bc, 100);
    	}else{
    		Batch_SendAnnouncementNotifications bc = new Batch_SendAnnouncementNotifications(null,false,null);
    		database.executeBatch(bc, 100);
    	}
    }
}
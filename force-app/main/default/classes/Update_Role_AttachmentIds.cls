global without sharing class Update_Role_AttachmentIds{
    @future
    public static void updateAttachmentIds_Future(string roleid,list<id> attids){
        Role__c role = [Select Passport_Evidence_FileId__c,Evidence_of_Appointment_FileId__c,Visa_Entry_Stamp_FileId__c,UAE_NationalId_FileId__c 
                        FROM Role__c WHERE Id=:roleId LIMIT 1];
        boolean isUpdateRole = false;
        for(Attachment att : [Select id,Description FROM Attachment WHERE ID IN:attids]){
            isUpdateRole = true;
            if(att.Description == role.Passport_Evidence_FileId__c)
            {
                role.Passport_Evidence_Attachment_Id__c = att.id;
            }
            else if(att.Description == role.Evidence_of_Appointment_FileId__c)
            {
                role.Evidence_Of_Appointment_Attachment_Id__c = att.id;
            }
            else if(att.Description == role.Visa_Entry_Stamp_FileId__c)
            {
                role.Visa_or_Entry_Stamp_Attachment_Id__c = att.id;
            }
            else if(att.Description == role.UAE_NationalId_FileId__c)
            {
                role.UAE_National_Attachment_Id__c = att.id;
            }
        }
        if(isUpdateRole)
            update role;
    }
    @future
    public static void updateEntityAttachmentIds_Future(string AccountId,string AttachmentId){
        Account acc = new Account(Id=AccountId);
        acc.Commercial_License_Attachment_Id__c = AttachmentId;
        try{
            update acc;
        }catch(Exception e){
        
        }
    }
}
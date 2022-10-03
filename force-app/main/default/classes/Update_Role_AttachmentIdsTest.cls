@isTest
public class Update_Role_AttachmentIdsTest
{
    public static testMethod void Update_Role_AttachmentIds_UT()
    {
        Account acc = new Account(Name='test account');
        insert acc;
        Role__c role = new Role__c(Subject_Account__c=acc.id,Passport_Evidence_FileId__c='1');
        insert role;
        
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');

        Attachment objAttachment = new Attachment();
        objAttachment.ParentId = role.Id;
        objAttachment.Name = 'Test Attachment';
        objAttachment.Body = bodyBlob;
        objAttachment.Description = '1';
        insert objAttachment;
        test.startTest();
        Update_Role_AttachmentIds.updateAttachmentIds_Future(role.id,new list<id>{objAttachment.id});
        
        role.Evidence_of_Appointment_FileId__c='1';
        role.Passport_Evidence_FileId__c='2';
        update role;
        Update_Role_AttachmentIds.updateAttachmentIds_Future(role.id,new list<id>{objAttachment.id});
        
        role.Evidence_of_Appointment_FileId__c='3';
        role.Passport_Evidence_FileId__c='2';
        role.Visa_Entry_Stamp_FileId__c='1';
        update role;
        Update_Role_AttachmentIds.updateAttachmentIds_Future(role.id,new list<id>{objAttachment.id});
        
        role.Evidence_of_Appointment_FileId__c='3';
        role.Passport_Evidence_FileId__c='2';
        role.Visa_Entry_Stamp_FileId__c='4';
        role.UAE_NationalId_FileId__c='1';
        update role;
        Update_Role_AttachmentIds.updateAttachmentIds_Future(role.id,new list<id>{objAttachment.id});
        
        test.stopTest();
    
    }
}
@isTest
public with sharing class AttachmentTriggerTest{
    public static testmethod void TestMethod1(){
        Account acc = new Account();
        acc.Name = 'Test Acc';
        insert acc;
        
        Role__c objRole = new Role__c();
        objRole.Subject_Account__c = acc.Id;
        objRole.Role_Id__c = '12345';
        objRole.UAE_NationalId_FileId__c = '12345';
        insert objRole;
        
        list<Attachment> lstAttachment = new list<Attachment>();
        Attachment atch = new Attachment();
        atch.Name = 'Passport Evidence';
        atch.ParentId = objRole.Id;
        atch.Body = blob.valueof('test');
        lstAttachment.add(atch);
        
        atch = new Attachment();
        atch.Name = 'Evidence of Appointment';
        atch.ParentId = objRole.Id;
        atch.Body = blob.valueof('test');
        lstAttachment.add(atch);
        
        atch = new Attachment();
        atch.Name = 'UAE Visa or Entry Stamp';
        atch.ParentId = objRole.Id;
        atch.Body = blob.valueof('test');
        lstAttachment.add(atch);
        
        atch = new Attachment();
        atch.Name = 'UAE NationalID';
        atch.ParentId = objRole.Id;
        atch.Body = blob.valueof('test');
        lstAttachment.add(atch);
        
        insert lstAttachment;
    }
}
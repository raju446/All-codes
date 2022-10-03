/*
    Author      : Rajil
    Date        : 15-Nov-2018
    Description : Test Class for Batch_GenericExpiryNotifications
    -------------------------------------------------------------------------------------------
*/
@isTest
private class Batch_GenericExpiryNotificationsTest {
    @isTest 
    static void testBatch() {
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Entity_Status__c = 'Registered';
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Community_Username__c = 'test+1@adgm.portal';
        newContacts[0].RecordTypeId = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('Contact - Portal User').getRecordTypeId();
        insert newContacts; 
        
        String recId = Schema.Sobjecttype.Document_Details__c.getRecordTypeInfosByName().get('Entity Documents').getRecordTypeId();
        Document_Details__c docs = new Document_Details__c();  
        docs.RecordTypeId  = recId;
        docs.Document_Status__c='Active';
        docs.Document_Type__c= 'Employee Work Permit(UAE/GCC National)';
        docs.Account__c = newAccounts[0].Id;
        docs.Contact__c = newContacts[0].Id;
        docs.Document_Expiry_Date__c = system.today().addDays(14);
        insert docs; 
        
        Test.startTest();
        Batch_GenericExpiryNotifications batchJob = new Batch_GenericExpiryNotifications();
        Database.executeBatch(batchJob);
        Test.stopTest();
    }
    @isTest
    static void testSchedule(){
        Integer addTime =30;
        DateTime now =  System.now().addMinutes(addTime);
        String day = string.valueOf(now.day());
        String month = string.valueOf(now.month());
        String hour = string.valueOf(now.hour());
        String minute = string.valueOf(now.minute());
        String second = string.valueOf(now.second());
        String year = string.valueOf(now.year());

        String strJobName = 'Notification_JOB : ' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;
        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        
        Test.startTest();
            System.schedule(strJobName, strSchedule, new Batch_GenericExpiryNotificationsSchedule());
        Test.stopTest();
    }
}
/*
    Author      :   Yogesh Mahajan 
    Class Name  :   ContactPrivateViewController
    Description :   It is used to make contact field private.
    Date        :   03/04/2019   
*/
public with sharing class ContactPrivateViewController {
    /*
    Name : getContactData
    Description : check contact is private or not
    */
    @AuraEnabled  
    public static Boolean checkContactPrivate(String contactId) {
        List<Contact> listContact = new List<Contact>();
        listContact = [SELECT id FROM contact WHERE id =: contactId AND CRM_Private__c =: false];
        if(listContact <> null && listContact.size() > 0) {
            return true;
        }//end if
        return false;
    }//end checkContactPrivate()
}//end class
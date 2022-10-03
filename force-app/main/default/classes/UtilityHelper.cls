/*
    Author      : Azmath
    Date        : 24-Dec-2018
    --------------------------------------------------------------------------------------
*/
public without sharing class UtilityHelper 
{
    public static Id getDocumentDetailRecordtypeId(string docType)
    {
		Id rid 	= Schema.SObjectType.Document_Details__c.getRecordTypeInfosByDeveloperName().get(docType).getRecordTypeId();
		return rid; 
    }
}
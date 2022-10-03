/*
    Author      : Durga Prasad
    Date        : 17-Sep-2017
    Description : Utility class with Custom Codes
    -------------------------------------------------------------------------
*/
public without sharing class CustomCodeUtilCls {
    /*
    	Method Name :	HasActiveEmployees
    	Description :	Checks all the Employees under the company are Inactive or not
    	Input Params:	EntityId(i.e. AccountId)
    	Output Param:	string
    */
    public static boolean HasActiveEmployees(string EntityId){
    	boolean AllVisasCancelled = true;
    	system.debug('EntityId==>'+EntityId);
    	if(EntityId!=null){
	    	for(Contact con:[Select Id from Contact where AccountId=:EntityId and Employment_Status__c='Active']){
	    		AllVisasCancelled = false;
	    		break;
	    	}
    	}
    	return AllVisasCancelled;
    }
}
/*
    Author      : Durga Kandula
    Date        : 28-Mar-2018
    Description : Custom code to check SVP Business Activity is there or not
    --------------------------------------------------------------------------------------
*/
global without sharing class CC_Check_SVPActivity implements HexaBPM.iCustomCodeExecutable { 
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
    	string strResult = 'false';
    	
    	return strResult;
    }
}
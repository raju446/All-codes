/*
    Author      : Khushboo Agarwal
    Date        : 08-Nov-2017
    Description : Custom code to calculate the Renewal Date and Expiry date of Establishment Card after Renewal
    ------------------------------------------------------------------------------------------------------------
*/

global without sharing class  CC_EstablishmentCardRenewal implements HexaBPM.iCustomCodeExecutable 
{ 
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) 
    {
        string strResult = 'Success';
        if(step.Id!=null && step.HexaBPM__SR__c!=null)
        {
        	list<HexaBPM__Service_Request__c> objSR = [Select id,HexaBPM__Customer__c, Establishment_Card_Expiry_Date__c FROM HexaBPM__Service_Request__c where Id=:step.HexaBPM__SR__c];
        	if(!objSR.isEmpty())
        	{
        		try{
        			//objSR.Establishment_Card_Expiry_Date__c = system.today().addYears(3);
	                //update objSR;
	                
	                Account acc = new Account(Id=objSR[0].HexaBPM__Customer__c);
	                acc.Establishment_Card_Expiry_Date__c = objSR[0].Establishment_Card_Expiry_Date__c;
	                acc.Establishment_Card_Status__c = 'Active';
	                update acc;
	                
	                list<Document_Details__c> lstEstablishmentCard = [select Id,Document_Expiry_Date__c,Document_Last_Renewed_Date__c,Document_Status__c from Document_Details__c where Account__c=:step.HexaBPM__SR__r.HexaBPM__Customer__c and Document_Type__c='Establishment Card'  limit 1];
	                if(lstEstablishmentCard !=null && lstEstablishmentCard .size()>0){
	                   lstEstablishmentCard [0].Document_Last_Renewed_Date__c = system.today();
	                   lstEstablishmentCard [0].Document_Expiry_Date__c = objSR[0].Establishment_Card_Expiry_Date__c;
	                   lstEstablishmentCard [0].Document_Status__c = 'Active';
	                   update lstEstablishmentCard ;
	                }
	                
	            }catch(DMLException e){
	                strResult = e.getMessage();
	            }
        	}
        }
        return strResult;
    }
}
/*
    Author      : Durga Prasad
    Company		: PwC
    Date        : 02-Jan-2018
    Description : Custom code to create the Fine amount as SR Price Item
    -------------------------------------------------------------------------------------------
*/
global without sharing class CC_CreateFineLineItem implements HexaBPM.iCustomCodeExecutable {
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
    	if(step.Id!=null && step.HexaBPM__SR__c!=null && step.HexaBPM__SR__r.Fine_Amount__c!=null && step.HexaBPM__SR__r.Fine_Amount__c>0){
    		HexaBPM__SR_Price_Item__c SRP = new HexaBPM__SR_Price_Item__c();
    		SRP.HexaBPM__ServiceRequest__c = step.HexaBPM__SR__c;
    		SRP.HexaBPM__Status__c = 'Added';
    		SRP.HexaBPM__Price__c = step.HexaBPM__SR__r.Fine_Amount__c;
    		SRP.Cost__c = step.HexaBPM__SR__r.Fine_Amount__c;
    		SRP.Markup_Amount__c = 0;
    		SRP.Cancellation_Fee__c = 0;
    		SRP.Tax_Amount__c = 0;
    		SRP.HexaBPM__Non_Reevaluate__c = true;
    		SRP.HexaBPM__Sys_Added_through_Code__c = true;
    		for(Product2 pd:[select Id from Product2 where productcode='AUTOMATIC_FINES']){
    			SRP.HexaBPM__Product__c = pd.Id;
    		}
    		try{
    			insert SRP;
    		}catch(Exception e){
    			strResult = e.getMessage()+'';
    		}
    	}
    	return strResult;   
    }
}
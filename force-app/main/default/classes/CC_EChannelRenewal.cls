/*
    Author      : Khushboo Agarwal
    Date        : 01-Nov-2017
    Description : Custom code to calculate the Expiry date of E-Channel on renewal and copy fields to Entity
    ------------------------------------------------------------------------------------------------------
*/
global without sharing class  CC_EChannelRenewal implements HexaBPM.iCustomCodeExecutable { 
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step.Id!=null && step.HexaBPM__SR__c!=null){
            HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c(Id=step.HexaBPM__SR__c);
             objSR.EChannel_Expiry_Date__c = system.today().addYears(1);
            try{
                update objSR;
                
                Account acc = new Account(Id=step.HexaBPM__SR__r.HexaBPM__Customer__c);
                 acc.EChannel_Expiry_Date__c=objSR.EChannel_Expiry_Date__c;
                 acc.EChannel_Status__c = 'Active';
                 update acc;
                
                
               list<Document_Details__c> lstEChannel = [select Id,Document_Expiry_Date__c,Document_Last_Renewed_Date__c,Document_Status__c  from Document_Details__c where Account__c=:step.HexaBPM__SR__r.HexaBPM__Customer__c and Document_Type__c='E-Channels' limit 1];
                if(lstEChannel!=null && lstEChannel.size()>0){
                   lstEChannel[0].Document_Last_Renewed_Date__c = system.today();
                   lstEChannel[0].Document_Expiry_Date__c = system.today().addyears(1);
                   lstEChannel[0].Document_Status__c = 'Active';
                   update lstEChannel;
              }
                
            }catch(DMLException e){
                strResult = e.getMessage();
            }
        }
        return strResult;
    }
    
}
/*
    Author      : Khushboo Agarwal
    Date        : 01-Nov-2017
    Description : Custom code to calculate the Expiry date of E-Channel and copy fields to Entity
    -------------------------------------------------------------------------------------------
*/
global without sharing class  CC_EChannelApproval implements HexaBPM.iCustomCodeExecutable { 
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step.Id!=null && step.HexaBPM__SR__c!=null){
            HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c(Id=step.HexaBPM__SR__c);
      //      objSR.EChannel_Issue_Date__c = system.today();
            objSR.EChannel_Expiry_Date__c = step.HexaBPM__SR__r.EChannel_Issue_Date__c.addYears(1);
           objSR.EChannel_Status__c='Active';
            try{
                update objSR;
                
                Account acc = new Account(Id=step.HexaBPM__SR__r.HexaBPM__Customer__c);
                  // acc.EChannel_Account_Number__c = step.HexaBPM__SR__r.EChannel_Account_Number__c;
                   acc.EChannel_Status__c='Active';
                   acc.EChannel_Issue_Date__c=step.HexaBPM__SR__r.EChannel_Issue_Date__c;
                   acc.EChannel_Expiry_Date__c=objSR.EChannel_Expiry_Date__c;
             //      acc.EChannel_Transaction_Number__c=step.HexaBPM__SR__r.EChannel_Transaction_Number__c;
              update acc;
           /*   
               Document_Details__c docs = new Document_Details__c();  
          //       docs.RecordTypeId='01226000000577h';
                 docs.Document_Status__c='Active';
                 docs.Document_Type__c='EChannel';
                 docs.Document_Issue_Date__c= objSR.EChannel_Issue_Date__c;
                 docs.Document_Expiry_Date__c= objSR.EChannel_Expiry_Date__c;
                 docs.Document_Cancel_Date__c=acc.EChannel_Cancelled_Date__c;
                docs.Account__c=acc.Id;
                insert docs; 
            */    
            }catch(DMLException e){
                strResult = e.getMessage();
            }
        }
        return strResult;
    }
    
}
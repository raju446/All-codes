/*
    Author      : Khushboo Agarwal
    Date        : 01-Nov-2017
    Description : Custom code to populate CID Approval Date
    -------------------------------------------------------------------------------------------
*/
global without sharing class  CC_CIDApprovalDate implements HexaBPM.iCustomCodeExecutable { 
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step.Id!=null && step.HexaBPM__SR__c!=null){
            Integer addExpiryDays = 0;
            if(Label.CID_Expiry_Date_Days != ''){
                addExpiryDays = Integer.valueOf(Label.CID_Expiry_Date_Days);
            }
            HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c(Id=step.HexaBPM__SR__c);
            //objSR.Initial_Approval_Issue_Date__c= system.today();
            //objSR.Initial_Approval_Expiry_Date__c= step.HexaBPM__SR__r.Initial_Approval_Issue_Date__c.addDays(addExpiryDays);
            objSR.Initial_Approval_Issue_Date__c= step.HexaBPM__SR__r.Valid_From__c;
            objSR.Initial_Approval_Expiry_Date__c= step.HexaBPM__SR__r.Valid_From__c.addDays(addExpiryDays);
         
            try{
                update objSR;
                
                Account acc = new Account(Id=step.HexaBPM__SR__r.HexaBPM__Customer__c);
                acc.Initial_Approval_Issue_Date__c=objSR.Initial_Approval_Issue_Date__c;
                acc.Initial_Approval_Expiry_Date__c=objSR.Initial_Approval_Expiry_Date__c;
                acc.Initial_Approval_Flag__c= true;
                
                update acc;
                
            }catch(DMLException e){
                strResult = e.getMessage();
            }
        }
        return strResult;
    }
    
}
/*
    Author      : Kim Noceda
    Date        : 07-Apr-2018
    Description : Custom code to update the document detail based on the document type selected to cancelled.
    --------------------------------------------------------------------------------------
*/
global class CC_CancelPermitDocDetailCls implements HexaBPM.iCustomCodeExecutable {
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step.HexaBPM__SR__c !=null && step.HexaBPM__SR__r.HexaBPM__Customer__c != null && step.HexaBPM__SR__r.Document_Type__c != null){
            List<Document_Details__c> objDocDetails = new List<Document_Details__c>();
            for(Document_Details__c objDoc : [SELECT Id, Document_Type__c, Document_Status__c, Document_Expiry_Date__c 
                                                FROM Document_Details__c WHERE Account__c = :step.HexaBPM__SR__r.HexaBPM__Customer__c 
                                                AND Document_Type__c = :step.HexaBPM__SR__r.Document_Type__c AND Document_Status__c = 'Active']){
                objDoc.Document_Status__c = 'Cancelled';
                objDoc.Document_Expiry_Date__c = Date.Today();
                objDocDetails.add(objDoc);
            }
            
            if(!objDocDetails.isEmpty()){
                try{
                    update objDocDetails;
                } catch(Exception e){
                    strResult = e.getMessage();
                }
            }
        }
        
        return strResult;
    }
}
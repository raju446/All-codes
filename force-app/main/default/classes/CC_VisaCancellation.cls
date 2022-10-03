/*  Author      : Khushboo Agarwal
    Date        : 06-Dec-2017
    Description : Custom code to calculate the cancellation date on Visa Cancellation and copy fields to Contact

    ------------------------------------------------------------------------------------------------------
*/

global without sharing class  CC_VisaCancellation implements HexaBPM.iCustomCodeExecutable { 
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step.Id!=null && step.HexaBPM__SR__c!=null){
            HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c(Id=step.HexaBPM__SR__c);
            objSR.Residence_Visa_Cancellation_Date__c  = system.today();

            try{

                update objSR;
                
                list<Contact> lstCont;
                
                if(step.HexaBPM__SR__r.HexaBPM__Contact__c!=null)
                    lstCont = [select Id, Name, Passport_No__c from Contact where id =:step.HexaBPM__SR__r.HexaBPM__Contact__c limit 1];

                if(lstCont!=null && lstCont.size()>0){
                    lstCont[0].Employment_Status__c='Terminated';
                    update lstCont;            

                }           

               

               list<Document_Details__c> lstVisaCancellation = [select Id,Document_Cancel_Date__c,Document_Status__c from Document_Details__c where Account__c=:step.HexaBPM__SR__r.HexaBPM__Customer__c and Contact__c=:step.HexaBPM__SR__r.HexaBPM__Contact__c and Document_Type__c='Residence Visa' and Document_Status__c='Active' limit 1];
               
               if(lstVisaCancellation!=null && lstVisaCancellation.size()>0){
                   lstVisaCancellation[0].Document_Cancel_Date__c = system.today();
                   lstVisaCancellation[0].Document_Status__c = 'Cancelled';
                   update lstVisaCancellation;                                   

               }

                

            }catch(DMLException e){

                strResult = e.getMessage();

            }

        }

        return strResult;

    }

    

}
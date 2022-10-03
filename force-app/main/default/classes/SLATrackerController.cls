public without sharing class SLATrackerController{
    public string caseId{get;Set;}   
    Public string MileStoneName{get;set;}
    public boolean isOverDue{get;set;}
    Public SLATrackerWrapper objTrackerDetails{get;set;} 
    public SLATrackerController(ApexPages.StandardController controller) {
        isOverDue= true;
        caseId = apexpages.currentpage().getParameters().get('Id');
        SLADifference();     
    } 
    public void SLADifference(){
        objTrackerDetails = new SLATrackerWrapper();
        for(Case_SLA__c cmObj :[select Parent__c,From__c,Due_Date_Time__c,Until__c,Business_Hours_Id__c  from Case_SLA__c where Parent__c =:caseId]){
                objTrackerDetails = new SLATrackerWrapper();                             
                objTrackerDetails.MileStoneStartTime = cmObj.From__c;
                objTrackerDetails.MileStoneEndTime = cmObj.Due_Date_Time__c;
                objTrackerDetails.MilestoneName= 'Case Milestone';
                objTrackerDetails.completedDate = cmObj.Until__c;                
                objTrackerDetails.BusinessHourId = cmObj.Business_Hours_Id__c;
                if(cmObj.Until__c !=null && cmObj.Due_Date_Time__c !=null && cmObj.From__c !=null){
                    objTrackerDetails.SlaMet = true;
                    objTrackerDetails.BackgroundStyle = 'background:grey !important;';           
                }   
        }
        if(objTrackerDetails.MileStoneStartTime !=null && objTrackerDetails.MileStoneEndTime !=null && objTrackerDetails.MileStoneEndTime >= DateTime.Now() && objTrackerDetails.completedDate ==null && objTrackerDetails.BusinessHourId !=null){
            Long difference =  BusinessHours.diff(objTrackerDetails.BusinessHourId,DateTime.now(),objTrackerDetails.MileStoneEndTime);                   
            objTrackerDetails.RemainingDays = Math.floor(difference/(1000 * 60 * 60 * 24));
            objTrackerDetails.RemainingHours = Math.floor(Math.MOD(difference,(1000 * 60 * 60 * 24))/(1000 * 60 * 60));
            objTrackerDetails.RemainingMinutes= Math.floor(Math.MOD(difference,(1000 * 60 * 60))/(1000 * 60));   
            objTrackerDetails.RemainingSeconds= Math.floor(Math.MOD(difference,(1000 * 60))/1000);
            objTrackerDetails.BackgroundStyle = 'background:green';          
        }else if(objTrackerDetails.MileStoneStartTime !=null && objTrackerDetails.MileStoneEndTime !=null && objTrackerDetails.MileStoneEndTime <= DateTime.Now() && objTrackerDetails.completedDate == null && objTrackerDetails.BusinessHourId !=null){
            Long difference =  BusinessHours.diff(objTrackerDetails.BusinessHourId,objTrackerDetails.MileStoneEndTime,DateTime.now());                     
            objTrackerDetails.RemainingDays = Math.floor(difference/(1000 * 60 * 60 * 24));
            objTrackerDetails.RemainingHours = Math.floor(Math.MOD(difference,(1000 * 60 * 60 * 24))/(1000 * 60 * 60));
            objTrackerDetails.RemainingMinutes= Math.floor(Math.MOD(difference,(1000 * 60 * 60))/(1000 * 60));   
            objTrackerDetails.RemainingSeconds= Math.floor(Math.MOD(difference,(1000 * 60))/1000);
            objTrackerDetails.isOverDue = true; 
            objTrackerDetails.BackgroundStyle = 'background:red'  ;       
        }
    }
    public class SLATrackerWrapper{
        Public DateTime MileStoneStartTime{get;set;}
        Public DateTime MileStoneEndTime{get;set;}
        Public Double RemainingDays{get;set;}
        Public Double RemainingHours{get;set;}
        Public Double RemainingMinutes{get;set;}
        Public Double RemainingSeconds{get;Set;}
        Public string MilestoneName{get;set;}
        public string BackgroundStyle{get;set;}
        Public boolean isOverDue{get;set;}
        Public DateTime completedDate{get;set;}
        public boolean SLAMet{get;set;}
        Public string BusinessHourId;
        
        public SLATrackerWrapper(){  
            RemainingDays = 0;         
            RemainingHours =0;
            RemainingMinutes = 0;
            RemainingSeconds = 0; 
            isOverDue = false; 
            SLAMet = false;
        }
    }
}
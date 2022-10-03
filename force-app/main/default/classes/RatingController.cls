/*
    Author      : Durga Kandula
    Date        : 17-Aug-2020
    Description : Controller to save the feedback for closed case
    ---------------------------------------------------------------
*/
public without sharing class RatingController{
    public string CaseId;
    public string Rating;
    public integer reopencount;
    public boolean isFeedbackCaptured {get;set;}
    public string PrimaryLogoURL{get;set;} 
    
    public RatingController(){
    	reopencount = 0;
        caseId = ApexPages.currentPage().getParameters().get('caseId');
        Rating = ApexPages.currentPage().getParameters().get('Rating');
        string reopencounter = ApexPages.currentPage().getParameters().get('ReopenCount');
        if(reopencounter != null && reopencounter != ''){
        	reopencount = Integer.valueof(reopencounter);
        }
        isFeedbackCaptured = false;
        PrimaryLogoURL = Label.ADGM_Logo_URL;
    }
    public pagereference UpdateRating(){
        if(caseId!=null && caseId!='' && Rating!=null && Rating!='')
        {
            Case objcs = new Case();
            for(Case cs:[Select Id,Re_opened_Date__c,Case_Re_Open_Count__c,ClosedDate from Case where Id=:caseId]){
                objcs = cs;
            }
            
            if(objcs.Id!=null)
            {
            	
            	list<Case_Feedback__c> lstFeedback = new list<Case_Feedback__c>();
            	if(objcs.ClosedDate!=null)
                {
                    for(Case_Feedback__c CF:[Select Id from Case_Feedback__c where Case__c=:objcs.Id and Case_Re_Open_Count__c =: objcs.Case_Re_Open_Count__c]){
                        lstFeedback.add(CF);
                    }
                    if(lstFeedback.size()==0){
                    	lstFeedback.add(new Case_Feedback__c(Case__c = objcs.Id,Feedback__c = Rating,Case_Closed_Date__c=objcs.ClosedDate,Case_Re_Open_Count__c=objcs.Case_Re_Open_Count__c,Case_Re_open_Date__c=objcs.Re_opened_Date__c));
                    	insert lstFeedback;
                    }else{
                    	isFeedbackCaptured = true;
                    }
                        
                }
            	/*
                list<Case_Feedback__c> lstFeedback = new list<Case_Feedback__c>();
                if(objcs.ClosedDate!=null)
                {
                    for(Case_Feedback__c CF:[Select Id from Case_Feedback__c where Case__c=:objcs.Id and Case_Closed_Date__c=:objcs.ClosedDate]){
                        lstFeedback.add(CF);
                    }
                    if(lstFeedback.size()==0)
                        lstFeedback.add(new Case_Feedback__c(Case__c = objcs.Id,Feedback__c = Rating,Case_Closed_Date__c=objcs.ClosedDate,Case_Re_Open_Count__c=objcs.Case_Re_Open_Count__c));
                }
                else if(objcs.Re_opened_Date__c!=null)
                {
                    for(Case_Feedback__c CF:[Select Id from Case_Feedback__c where Case__c=:objcs.Id and Case_Re_open_Date__c=:objcs.Re_opened_Date__c]){
                        lstFeedback.add(CF);
                    }
                    if(lstFeedback.size()==0)
                        lstFeedback.add(new Case_Feedback__c(Case__c = objcs.Id,Feedback__c = Rating,Case_Re_open_Date__c=objcs.Re_opened_Date__c));
                }
                try{
                    if(lstFeedback.size()>0)
                        upsert lstFeedback;
                }catch(Exception e){
                
                }*/
            }
        }
        
        return null;
    }
}
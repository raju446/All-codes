/*
    Author      :   Yogesh Mahajan 
    Class Name  :   EventsDetailPDFController
    Description :   It is used as a controller for the Events Details PDF
    Date        :   02/20/2019      
*/
public class EventsDetailPDFController{
   
    public List<Campaign> listCampaigns {get;set;}
    public Boolean isTableShow          {get;set;}
    Public Date fromDateToShow		{get;set;}
    Public Date toDateToShow			{get;set;}
    /*
        Method Name : submitCampaign
        Description : It is used to assign data to page 
    */ 
    public void fetchEvents() {
        isTableShow = true;
        Datetime dtFrmDate = system.now();
        Datetime dtToDate = system.now();
        String fromDate = ApexPages.currentPage().getParameters().get('fromDate') + ' 00:00:00';
        String toDate = ApexPages.currentPage().getParameters().get('toDate') + ' 23:59:59';
        if(string.isNotEmpty(fromDate) && string.isNotEmpty(toDate)){
            dtFrmDate = DateTime.valueOf(fromDate);
            dtToDate = DateTime.valueOf(toDate);
        }
        fromDateToShow = Date.valueOf(fromDate);
        toDateToShow =  Date.valueOf(toDate);
        listCampaigns = new List<Campaign>();
        listCampaigns = [SELECT Id
                                , Category__c
                         		, Main_Category__c
                         		, Status
                         		, CRM_End_Date__c
                                , Name
                                , Type
                                , CRM_Meeting_Date_Time__c
                                , Description
                         FROM Campaign
                         WHERE CRM_Meeting_Date_Time__c >=:dtFrmDate 
                            AND CRM_Meeting_Date_Time__c <=:dtToDate 
                         ORDER BY CRM_Meeting_Date_Time__c
						];
        if(listCampaigns == null || listCampaigns.size() == 0)  {
            isTableShow = false;
        }
    }

}
/**************************************************************************************************
* Name               : TicketManagementController                                                 *
* Description        : This is a controller class for ticket management page. Has below function  *
*                       - Displays All Users the tickets created in the system.                   *
*                       - Filter for tickets based on user.                                       *
*                       - Create new tickets in the system.                                       *
* Created Date       : 09/01/2017                                                                 *
* Created By         : NSI                                                                        *
* Last Modified Date : 09/01/2017                                                                 *
* Last Modified By   :                                                                            *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE              COMMENTS                                              *
* 1.0         NSI         09/01/2017        Initial Draft                                         *
**************************************************************************************************/
public without sharing class TicketManagementController {
    public Boolean showTickets{get;set;}
    public Boolean showFilter{get;set;}
    public string selectedView{get;set;}
    public string objectKeyPrefix{get;set;}
    public string SelectedType{get;set;}
    public string SelectedStatus{get;set;}
    public list<SelectOption> lstIssueStatus{get;set;}
    public list<SelectOption> lstIssueTypes{get;set;}
    public transient list<Issue__c> bugList{get;set;}
    private Map<String, list<Issue__c>> filterTicketListMap = new Map<String, list<Issue__c>>();
    public Issue__c objIssue{get;set;}
    public integer TicketsCount{get;set;}
    /*********************************************************************************************
    * @Description : Controller.                                                                 *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public TicketManagementController(){
        objIssue = new Issue__c();
        objIssue.Status__c = '';
        try{
            //Calling method to get ticket list
            filterTicketListMap = getTicketsList();
            selectedView = 'All Users';
            showFilter = true;
            TicketsCount = 0;
            PrepareFilterOptions();
            getFilteredTickets();
            objectKeyPrefix = Issue__c.SObjectType.getDescribe().getKeyPrefix();
        }catch(Exception ex){
            throwError('Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }
    }    
    public void PrepareFilterOptions(){
        SelectedStatus = 'All';
        SelectedType = 'All';
        lstIssueStatus = new list<SelectOption>();
        lstIssueTypes = new list<SelectOption>();
        Schema.DescribeFieldResult FieldResult = Issue__c.Status__c.getDescribe();
        list<Schema.PicklistEntry> PLE = FieldResult.getPicklistValues();
        lstIssueStatus.add(new SelectOption('All','All'));
        for(Schema.PicklistEntry f : PLE){
            lstIssueStatus.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        FieldResult = Issue__c.Type__c.getDescribe();
        PLE = FieldResult.getPicklistValues();
        lstIssueTypes.add(new SelectOption('All','All'));
        for(Schema.PicklistEntry f : PLE){
            lstIssueTypes.add(new SelectOption(f.getLabel(), f.getValue()));
        }
    }
    /*********************************************************************************************
    * @Description : Get assigned to user configured in custom setting TicketManagementTeam__c.  *
    * @Params      : void                                                                        *
    * @Return      : list<SelectOption>                                                          *
    *********************************************************************************************/
    public list<SelectOption> getAssignedTos(){
        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('All Users', 'All Users'));
        options.add(new SelectOption('Unassigned', 'Unassigned'));
        for(TicketManagementTeam__c thisUser : TicketManagementTeam__c.getAll().Values()){
            options.add(new SelectOption(thisUser.Name, thisUser.Name));
        }             
        return options;
    }
    
    /*********************************************************************************************
    * @Description : Get relevant tickets on filter change.                                      *  
    * @Params      : String                                                                      *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void getFilteredTickets(){
        try{
            system.debug('Ticket Status==>'+objIssue.Ticket_Status__c);
            System.debug('selectedView'+selectedView);
            TicketsCount = 0;
            bugList = new list<Issue__c>();
            string AssignToFilter;
            if(selectedView=='Unassigned')
                AssignToFilter = null;
            else if(selectedView!='All Users')
                AssignToFilter = selectedView;
            string strQuery = 'Select Id,Name,Sequence__c,Estimation__c,Approved_By_Client__c,Assigned_To__c,Severity__c,Milestone__c,Assigned_To_Email__c,Status__c,Completed_Date__c,CreatedDate,LastModifiedDate,CreatedById,Type__c,CreatedBy.Name,Issue_Description__c,Expected_End_Date__c,Issue_Summary__c FROM Issue__c';
            
            boolean hasFilter = false;
            if(selectedView=='Unassigned'){
                strQuery += ' where Assigned_To__c=null';
                hasFilter = true;
            }else if(selectedView!='All Users'){
                strQuery += ' where Assigned_To__c=:selectedView';
                hasFilter = true;
            }
            string MileStoneValue = objIssue.Milestone__c;
            System.debug('MileStoneValue'+MileStoneValue);
            if(MileStoneValue!=null){
                if(hasFilter)
                    strQuery += ' and Milestone__c=:MileStoneValue';
                else
                    strQuery += ' where Milestone__c=:MileStoneValue';
                hasFilter = true;
            }
            
            if(objIssue.Ticket_Type__c!=null){
                list<string> lstSelectedTypes = new list<string>();
                if(objIssue.Ticket_Type__c.indexof(';')>-1)
                    lstSelectedTypes = objIssue.Ticket_Type__c.split(';');
                else
                    lstSelectedTypes.add(objIssue.Ticket_Type__c);
                
                if(hasFilter)
                    strQuery += ' and Type__c IN:lstSelectedTypes';
                else
                    strQuery += ' where Type__c IN:lstSelectedTypes';
                hasFilter = true;
            }
            
            if(objIssue.Ticket_Status__c!=null){
                list<string> lstSelectedStatus = new list<string>();
                if(objIssue.Ticket_Status__c.indexof(';')>-1)
                    lstSelectedStatus = objIssue.Ticket_Status__c.split(';');
                else
                    lstSelectedStatus.add(objIssue.Ticket_Status__c);
                
                if(hasFilter)
                    strQuery += ' and Status__c IN:lstSelectedStatus';
                else
                    strQuery += ' where Status__c IN:lstSelectedStatus';
                hasFilter = true;
            }
            
            /*
            if(SelectedStatus!='All'){
                if(hasFilter)
                    strQuery += ' and Status__c=:SelectedStatus';
                else
                    strQuery += ' where Status__c=:SelectedStatus';
                hasFilter = true;
            }
            */
            
            strQuery += ' order by Name desc';
            bugList = database.query(strQuery);
            if(bugList!=null && bugList.size()>0){
                showTickets = true;
                TicketsCount = bugList.size();
            }else{
                showTickets = false;
            }
        }catch(Exception ex){
            throwError('Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }   
    }
    
    /*********************************************************************************************
    * @Description : Method to get ticket details in the system.                                 *
    * @Params      : void                                                                        *
    * @Return      : Map<String, list<Issue__c>>                                                 *
    *********************************************************************************************/
    private Map<String, list<Issue__c>> getTicketsList(){ 
        Id loggedInUserId = UserInfo.getUserId();
        list<Issue__c> allBugsList = new list<Issue__c>();
        list<Issue__c> unassignedBugsList = new list<Issue__c>();
        Map<String, list<Issue__c>> filterTicketListMap = new Map<String, list<Issue__c>>();
        if(!allBugsList.isEmpty()){
            filterTicketListMap.put('All Users', allBugsList);  
        }
        if(!unassignedBugsList.isEmpty()){
            filterTicketListMap.put('Unassigned', unassignedBugsList);  
        }
        return filterTicketListMap;
    }
        
    /*********************************************************************************************
    * @Description : Handle Exception and show an error message on page.                         *
    * @Params      : String                                                                      *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void throwError(String error){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, error);
        ApexPages.addMessage(myMsg);
    }
    
}// End of class.
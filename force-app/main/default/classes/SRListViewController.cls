/*
    Author      : Rajil
    Date        : 15-Nov-2018
    Description : List Views for Service Request and ActionItems for the community
    -------------------------------------------------------------------------------------------
*/
public without sharing class SRListViewController{
    public Integer noOfRecords{get; set;}
    public Integer size{get;set;}
    public string loggedInUserAccountId;
    public string selectedView {get;set;}
    public string requestObjView;
    public SRListViewController() {
        requestObjView = ApexPages.currentPage().getParameters().get('view');
        selectedView = ApexPages.currentPage().getParameters().get('type');
        list<User> lstUser = [Select contact.accountid from User where id =: Userinfo.getUserid() limit 1];
        if(!lstUser.IsEmpty()){
            loggedInUserAccountId = lstUser[0].contact.accountid;
        }
    }
    public ApexPages.StandardSetController setCon {
        get{
            if(setCon == null){
                size = 10;
                noOfRecords = 0;
                string queryString = 'select '; 
                list<string> lstAccessibleSRTemplateId = new list<string>();
                list<HexaBPM__SR_Template__c> menuServicesList = new list<HexaBPM__SR_Template__c>();
                menuServicesList = HelperUtil.getAccessibleMenu();
                if(menuServicesList.size() > 0){
                    for(HexaBPM__SR_Template__c srTemplate : menuServicesList){
                        lstAccessibleSRTemplateId.add(srTemplate.id);
                    }
                }
                if(lstAccessibleSRTemplateId.size() > 0){
                    if(selectedView == 'savedrequests'){
                        for(Schema.FieldSetMember fsm :SObjectType.HexaBPM__Service_Request__c.FieldSets.Saved_Requests.getFields()) {
                            queryString += fsm.getFieldPath() + ', ';
                        }
                        queryString = queryString.substring(0,queryString.length()-2); //removing the last 2 char to form a proper queryString.
                        queryString += ' from HexaBPM__Service_Request__c where HexaBPM__Internal_Status_Name__c = \'Draft\' and HexaBPM__External_SR_Status__r.Name = \'Draft\' '+
                                        ' and HexaBPM__Record_Type_Name__c != \'User_Access_Request_for_Registered_Company\'  '+
                                        ' and HexaBPM__Record_Type_Name__c != \'Guest_User_Access_Request\'  '+
                                        ' and HexaBPM__Record_Type_Name__c != \'Guest_User_Access_Request\'  '+
                                        ' and HexaBPM__Customer__c = :loggedInUserAccountId  '+
                                        ' and HexaBPM__SR_Template__c in :lstAccessibleSRTemplateId ';
                    }
                    else if(selectedView == 'currentrequests'){
                        for(Schema.FieldSetMember fsm :SObjectType.HexaBPM__Service_Request__c.FieldSets.Current_Requests.getFields()) {
                            queryString += fsm.getFieldPath() + ', ';
                        }
                        queryString = queryString.substring(0,queryString.length()-2); //removing the last 2 char to form a proper queryString.
                        queryString += ' from HexaBPM__Service_Request__c where HexaBPM__Is_Rejected__c = false '+
                                        ' and HexaBPM__IsClosedStatus__c = false  '+
                                        ' and HexaBPM__External_Status_Name__c != \'Draft\'  '+
                                        ' and HexaBPM__Record_Type_Name__c != \'Initial_Approval\'  '+
                                        ' and HexaBPM__Record_Type_Name__c != \'Guest_User_Access_Request\'  '+
                                        ' and HexaBPM__Record_Type_Name__c != \'User_Access_Request_for_Registered_Company\'  '+
                                        ' and HexaBPM__Customer__c = :loggedInUserAccountId '+
                                        ' and HexaBPM__SR_Template__c in :lstAccessibleSRTemplateId ';
                    }
                    else if(selectedView == 'rejectedrequests'){
                        for(Schema.FieldSetMember fsm :SObjectType.HexaBPM__Service_Request__c.FieldSets.Current_Requests.getFields()) {
                            queryString += fsm.getFieldPath() + ', ';
                        }
                        queryString = queryString.substring(0,queryString.length()-2); //removing the last 2 char to form a proper queryString.
                        queryString += ' from HexaBPM__Service_Request__c where HexaBPM__Is_Rejected__c = true  '+
                                        ' and HexaBPM__Record_Type_Name__c != \'Initial_Approval\'  '+
                                        ' and HexaBPM__Record_Type_Name__c != \'Guest_User_Access_Request\'  '+
                                        ' and HexaBPM__Record_Type_Name__c != \'User_Access_Request_for_Registered_Company\'  '+
                                        ' and HexaBPM__Customer__c = :loggedInUserAccountId '+
                                        ' and HexaBPM__SR_Template__c in :lstAccessibleSRTemplateId ';
                    }
                    else if(selectedView == 'approvedrequests'){
                        for(Schema.FieldSetMember fsm :SObjectType.HexaBPM__Service_Request__c.FieldSets.Current_Requests.getFields()) {
                            queryString += fsm.getFieldPath() + ', ';
                        }
                        queryString = queryString.substring(0,queryString.length()-2); //removing the last 2 char to form a proper queryString.
                        queryString += ' from HexaBPM__Service_Request__c where HexaBPM__IsClosedStatus__c = true  '+
                                        ' and HexaBPM__Is_Rejected__c = false '+
                                        ' and HexaBPM__Record_Type_Name__c != \'Initial_Approval\'  '+
                                        ' and HexaBPM__Record_Type_Name__c != \'Guest_User_Access_Request\'  '+
                                        ' and HexaBPM__Record_Type_Name__c != \'User_Access_Request_for_Registered_Company\'  '+
                                        ' and HexaBPM__Customer__c = :loggedInUserAccountId '+
                                        ' and HexaBPM__SR_Template__c in :lstAccessibleSRTemplateId ';
                    }
                    else if(selectedView == 'pendingactions'){
                        for(Schema.FieldSetMember fsm :SObjectType.HexaBPM__Step__c.FieldSets.Pending_Actions.getFields()) {
                            queryString += fsm.getFieldPath() + ', ';
                        }
                        queryString = queryString.substring(0,queryString.length()-2); //removing the last 2 char to form a proper queryString.
                        queryString += ' ,HexaBPM__SR__r.Name from HexaBPM__Step__c where HexaBPM__Status_Type__c != \'End\'  '+
                                        ' and Owner_Alias__c = \'Client\'  '+
                                        ' and Service_Request_Name__c != \'Initial Approval\'  '+
                                        ' and HexaBPM__SR__r.HexaBPM__Customer__c = :loggedInUserAccountId '+
                                        ' and HexaBPM__SR__r.HexaBPM__SR_Template__c in :lstAccessibleSRTemplateId ';
                    }
                    else if(selectedView == 'cancellationrequests'){
                        for(Schema.FieldSetMember fsm :SObjectType.HexaBPM__Step__c.FieldSets.Pending_Actions.getFields()) {
                            queryString += fsm.getFieldPath() + ', ';
                        }
                        queryString = queryString.substring(0,queryString.length()-2); //removing the last 2 char to form a proper queryString.
                        queryString += ' ,HexaBPM__SR__r.Name from HexaBPM__Step__c where HexaBPM__Step_Template__r.Name = \'Cancellation Request by Client\'  '+
                                        ' and HexaBPM__SR__r.HexaBPM__Customer__c = :loggedInUserAccountId '+
                                        ' and HexaBPM__SR__r.HexaBPM__SR_Template__c in :lstAccessibleSRTemplateId ';
                    }
                    else if(selectedView == 'couriersteps'){
                        for(Schema.FieldSetMember fsm :SObjectType.HexaBPM__Step__c.FieldSets.Pending_Actions.getFields()) {
                            queryString += fsm.getFieldPath() + ', ';
                        }
                        queryString = queryString.substring(0,queryString.length()-2); //removing the last 2 char(, ) to form a proper queryString.
                        queryString += ' ,HexaBPM__SR__r.Name from HexaBPM__Step__c where RecordType.Name = \'Courier Step\'  '+
                                        ' and HexaBPM__SR__r.HexaBPM__Customer__c = :loggedInUserAccountId '+
                                        ' and HexaBPM__SR__r.HexaBPM__SR_Template__c in :lstAccessibleSRTemplateId ';
                    }
                    queryString +=' order by CreatedDate desc';
                    System.debug('queryString '+queryString );
                }
                if(queryString.indexOf(',') > -1){
                    setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                    setCon.setPageSize(size);
                    noOfRecords = setCon.getResultSize();
                }
            }
            return setCon;
        }set;
    }
    public List<HexaBPM__Service_Request__c> getServiceRequest(){
        List<HexaBPM__Service_Request__c> srList = new List<HexaBPM__Service_Request__c>();
        if(setCon != null){
            for(HexaBPM__Service_Request__c srRecord : (List<HexaBPM__Service_Request__c>)setCon.getRecords())
                srList.add(srRecord);
        }
        return srList;
    }
    public List<HexaBPM__Step__c> getActionItem(){
        List<HexaBPM__Step__c> actionItemList = new List<HexaBPM__Step__c>();
        if(setCon != null){
            for(HexaBPM__Step__c actionItem : (List<HexaBPM__Step__c>)setCon.getRecords())
                actionItemList.add(actionItem);
        }
        return actionItemList;
    }
     
    public pageReference refresh() {
        setCon = null;
        if(requestObjView == 'servicerequest')
            getServiceRequest();
        else if(requestObjView == 'actionitem')
            getActionItem();
        if(setCon != null)
            setCon.setPageNumber(1);
        return null;
    }
    public Integer getTotalPages() {
        return Integer.valueof(Math.ceil((Double) noOfRecords / size));
    }
    public SelectOption[] getselectValues(){
        List<SelectOption> options = new List<SelectOption>();
        if(requestObjView == 'servicerequest'){
            options.add(new SelectOption('approvedrequests','Approved Requests'));
            options.add(new SelectOption('rejectedrequests','Rejected Requests'));
            options.add(new SelectOption('currentrequests','Current Requests'));
            options.add(new SelectOption('savedrequests','Saved Requests'));
        }
        else if(requestObjView == 'actionitem'){
            options.add(new SelectOption('cancellationrequests','Cancellation Requests'));
            options.add(new SelectOption('couriersteps','Courier Steps'));
            options.add(new SelectOption('pendingactions','Pending Actions'));
        }
        return options;
    }
    public void reloadView(){
        refresh();
    }
}
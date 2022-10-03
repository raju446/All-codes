/******************************************************************************************
 *  Author      : Durga Prasad
 *  Company     : HexaBPM
 *  Date        : 11-April-2017
 *  Description : PageFlow Page Controller which will builds the dynamic form.
*******************************************************************************************/
public with sharing class PageFlowController{
    
    public HexaBPM__Service_Request__c objRequest{get;set;}
    public string strPageId{get;set;}
    public string stringActionId{get;set;}
    public string PageFlowId;
    public string pageTitle{get;set;}
    public string pageDescription{get;set;}
    public string strHiddenPageIds{get;set;} 
    public string strSRID{get;set;}
    public string strReqFieldIds{get;set;}
    public map<string,string> mapParameters;
    public string strNavigatePageId{get;set;}
    public string urltitle {get;set;}
    
    /*
        Constructor codes when the Page loads
    */
    public PageFlowController(){
        strPageId = '';
        strSRID = '';
        strHiddenPageIds = '';
        objRequest = new HexaBPM__Service_Request__c();
        stringActionId = '';
        strReqFieldIds = '';
        urltitle = '';
         
        mapParameters = new map<string,string>();
        // all the parameters in the url are stored in this map
        if(apexpages.currentPage().getParameters()!=null && apexpages.currentPage().getParameters().size()>0)
            mapParameters = apexpages.currentPage().getParameters();
        if(apexpages.currentPage().getParameters().get('FlowId')!=null)
            pageflowId = string.escapeSingleQuotes(apexpages.currentPage().getparameters().get('FlowId'));
        if(apexpages.currentPage().getParameters().get('Id')!=null)
            strSRID = string.escapeSingleQuotes(apexpages.currentPage().getParameters().get('Id'));
        if(mapParameters.get('PageId')!=null)
            strPageId = string.escapeSingleQuotes(mapParameters.get('PageId'));
        list<HexaBPM__Page__c> lstPages = new list<HexaBPM__Page__c>();
        
        if(strPageId!=null && strPageId!='')
            lstPages = [select id,Name,HexaBPM__Is_Custom_Component__c,HexaBPM__Page_Order__c,HexaBPM__Page_Description__c,HexaBPM__Page_Flow__c,HexaBPM__Page_Flow__r.Name,HexaBPM__Page_Flow__r.HexaBPM__Record_Type_API_Name__c,HexaBPM__Render_By_Default__c,HexaBPM__VF_Page_API_Name__c from HexaBPM__Page__c where HexaBPM__Page_Flow__c=:pageflowId and Id=:strPageId order by HexaBPM__Page_Order__c];
        else
            lstPages = [select id,Name,HexaBPM__Is_Custom_Component__c,HexaBPM__Page_Order__c,HexaBPM__Page_Description__c,HexaBPM__Page_Flow__c,HexaBPM__Page_Flow__r.Name,HexaBPM__Page_Flow__r.HexaBPM__Record_Type_API_Name__c,HexaBPM__Render_By_Default__c,HexaBPM__VF_Page_API_Name__c from HexaBPM__Page__c where HexaBPM__Page_Flow__c=:pageflowId order by HexaBPM__Page_Order__c];

        // get the SR template id for the given rec type api name 
        if(lstPages!=null && lstPages.size()>0){
            string strRecordType = '';
            if(lstPages[0].HexaBPM__Page_Flow__r.HexaBPM__Record_Type_API_Name__c!=null){
                strRecordType = lstPages[0].HexaBPM__Page_Flow__r.HexaBPM__Record_Type_API_Name__c;
                for(HexaBPM__SR_Template__c srtemp:[select Id,Disclaimer_Text__c,HexaBPM__Portal_Service_Request_Name__c from HexaBPM__SR_Template__c where HexaBPM__SR_RecordType_API_Name__c=:lstPages[0].HexaBPM__Page_Flow__r.HexaBPM__Record_Type_API_Name__c]){
                    objRequest.HexaBPM__SR_Template__c = srtemp.Id;
                    objRequest.disclaimer__c = srtemp.Disclaimer_Text__c;
                    urltitle = '?service_request_title='+srtemp.HexaBPM__Portal_Service_Request_Name__c+'&type=New_Work_Permit_Full_Time_Non_Sponsored_Employee';
                }
            }
            // page title and description are shown here
            if(strPageId == null || (strPageId!=null && strPageId == '')){
                if(lstPages[0].HexaBPM__Render_By_Default__c==true){
                    apexpages.currentPage().getParameters().put('PageId',lstPages[0].id);
                    strPageId = lstPages[0].id;
                }
            }
        }
        if(strSRID!=null && strSRID!=''){
            if(pageflowId!=null && pageflowId!=''){
                //query all the fields configured in the page are query here.
                set<string> SetstrFields = PageFlowControllerHelper.FetchObjectFields(pageflowId,'HexaBPM__Service_Request__c');
                string strQuery = 'select Id';
                if(setstrFields==null || (setstrFields!=null && setstrFields.size()==0))
                    setstrFields = new set<string>();
                setstrFields.add('hexabpm__customer__c');
                setstrFields.add('hexabpm__flow_request__c');
                setstrFields.add('recordtypeid');
                setstrFields.add('hexabpm__record_type_name__c');
                setstrFields.add('name');

                system.debug('setstrFields==>'+setstrFields);
                //building the query
                for(String strFld:SetstrFields){
                    if(strFld.toLowerCase()!='id')
                        strQuery += ','+strFld.toLowerCase();
                }
                strQuery = strQuery+' from HexaBPM__Service_Request__c where Id=:strSRID';
                for(HexaBPM__Service_Request__c SR:database.query(strQuery)){
                    objRequest = SR;
                }
            }
         }
         lstPages = new list<HexaBPM__Page__c>();
         
         for(User usr:[Select Id,ContactId,Contact.AccountId,contact.Email from User where Id=:UserInfo.getUserId() and ContactId!=null]){
           objRequest.HexaBPM__Customer__c = usr.Contact.AccountId;
           
           if(objRequest.HexaBPM__Email__c == null)
           objRequest.HexaBPM__Email__c = usr.contact.Email;
         }
         objRequest.HexaBPM__Flow_Request__c = true;
         PreparePageDescription();
         system.debug('=====srid==='+strSRID);
         //if(strSRID == null || strSRID == ''){
             //objRequest.HexaBPM__Email__c = email;
         //}
    }
    /*
        Method Name :   PreparePageDescription
        Description :   This will Prepares the Page title & Description for the Current Page.
    */
    public void PreparePageDescription(){
        if(strPageId!=null && strPageId!=''){
            for(HexaBPM__Page__c objPG:[select id,Name,HexaBPM__Page_Description__c,HexaBPM__Page_Flow__r.Name from HexaBPM__Page__c where id=:strPageId]){
                pageTitle = objPG.HexaBPM__Page_Flow__r.Name;
                pageDescription = objPG.HexaBPM__Page_Description__c;
            }
        }
    }
    /*
        Method Name :   getDyncPgMainPB
        Description :   Method which will creates the Dynamic VF Components based on the Configuration defined
    */
    public Component.Apex.PageBlock getDyncPgMainPB(){
        strHiddenPageIds = '';
        Component.Apex.PageBlock pb = new Component.Apex.PageBlock();
        if(mapParameters.get('PageId')!=null)
            strPageId = String.escapeSingleQuotes(mapParameters.get('PageId'));
        if(pageflowId!=null && pageflowId!='' && strPageId!=null && strPageId!=''){
            PageFlowControllerHelper objPFUtil = new PageFlowControllerHelper();
            objPFUtil.objRequest = objRequest;
            pb = objPFUtil.getFlowPageContent(pageflowId,strPageId);
            //strHiddenPageIds = PageFlowControllerHelper.getHiddenPageIds(pageflowId,objRequest);
            strReqFieldIds = PageFlowControllerHelper.ReqFieldIds;
        }
        return pb;
    }
    
    /*
        Method Name :   RePrepareSection
        Description :   Method which is used to refresh the Dynamic PB to re-prepare the Fields based on new Values
    */
    public void RePrepareSection(){
        
    }
    
    /*
        Method Name :   DynamicButtonAction
        Description :   Action Method which Dynamically Changes the layout & Actions based on the Configuration
    */
    public PageReference DynamicButtonAction(){
        string whatId = ''; 
        try{
            if(stringActionId!=null && stringActionId!=''){
                boolean isNext = false;
                for(HexaBPM__Section_Detail__c objSecDtl:[select id,Name,HexaBPM__Navigation_Directions__c from HexaBPM__Section_Detail__c where Id=:stringActionId]){
                    if(objSecDtl.HexaBPM__Navigation_Directions__c=='Forward')
                        isNext = true;
                }
                //HexaBPM__Service_Request__c objTempSR = objRequest;
                try{
                    upsert objRequest;
                    apexpages.currentPage().getParameters().put('Id',string.valueOf(objRequest.Id));
                }catch(DMLException e){
                  	AddErrorMessage(e);
                  	//objRequest = objTempSR;
                    return null;
                }
        /*
                PageFlowControllerHelper.objSR = objRequest;
                PageFlowControllerHelper objPB = new PageFlowControllerHelper();
                pagereference pg = objPB.getButtonAction(stringActionId);
                */
                pagereference pg = new pagereference('/'+objRequest.Id);
                return pg;
                
            }
        }catch(Exception e){
            
        }
        return null;
    }
    
    /*
        Method Name :   CommitRecord
        Description :   This will saves the record i.e. Insert or Update.
    */
    public void CommitRecord(){
        try{
            upsert objRequest;
            apexpages.currentPage().getParameters().put('Id',string.valueOf(objRequest.Id));
        }catch(DMLException e){
            system.debug('======'+e.getmessage());
            AddErrorMessage(e);
        }
    }
    /*
        Method Name :   CancelSR
        Decription  :   This will cancel the Open SR and the PriceItems of the SR also get cancelled.
    */
    public pagereference CancelSR(){
        pagereference pg;
        if(mapParameters.get('Id')!=null && !mapParameters.get('Id').startsWith('012'))
            pg = new pagereference('/'+mapParameters.get('Id'));
        else
            pg = new pagereference('/apex/CommunityServices');
        pg.setredirect(true);
        return pg;
    }
    public pagereference goTopage(){
        //when user clicks on any of the side bar page, id will be assinged to this variable
        /*
        if(strNavigatePageId!=null && strNavigatePageId!=''){
            try{
                upsert objRequest;
                apexpages.currentPage().getParameters().put('Id',string.valueOf(objRequest.Id));    
                PageFlowControllerHelper objSidebarRef = new PageFlowControllerHelper();
                PageFlowControllerHelper.objSR = objRequest;
                return objSidebarRef.getSideBarReference(strNavigatePageId); // page reference is return dynamically
            }catch(DMLException e){
                AddErrorMessage(e);
                return null;
            }
        }
        */
      return null;
    }
    public void AddErrorMessage(DMLException e){
      string DMLError = e.getdmlMessage(0)+'';
        if(DMLError==null)
            DMLError = e.getMessage()+'';
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,DMLError));
    }
}
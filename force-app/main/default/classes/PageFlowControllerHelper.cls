/******************************************************************************************
 *  Author      : Durga Prasad
 *  Company     : HexaBPM
 *  Date        : 09-Mar-2017
 *  Description : Utility Class for Evaluating the rules & preparing the page content.
*******************************************************************************************/
global without sharing class PageFlowControllerHelper{
    global static sObject objSR;
    global static string ReqFieldIds;
    global static string strHiddenPageIds;
    global HexaBPM__Service_Request__c objRequest;
    
    private static set<Id> sectionId{set;get;} // Id's of section object
    public static HexaBPM__Section__c commandButtonSection; //  button section
    public static list<HexaBPM__Section_Detail__c> commandButtonList; // List of buttons
    
    global PageFlowControllerHelper(){
        objRequest = new HexaBPM__Service_Request__c();
    }
    /*
        Method Name :   getDyncPgMainPB
        Description :   Method which will creates the Dynamic VF Components based on the Configuration defined
    */
    global Component.Apex.PageBlock getFlowPageContent(string FlowId,string PageId){
        strHiddenPageIds = '';
        Component.Apex.OutputPanel OpPanel = new Component.Apex.OutputPanel();
        Component.Apex.PageBlock pb = new Component.Apex.PageBlock();
        pb.Id = 'MainPB';
        pb.Title='Service Request';
        Component.Apex.PageBlockButtons PBtns = new Component.Apex.PageBlockButtons();
        pb.childComponents.add(PBtns);
        
        
        /* Code to Construct the Page Description */
        Component.Apex.PageBlockSection PageDescription = new Component.Apex.PageBlockSection();
        PageDescription.Id = 'PageDesPBS';
        PageDescription.columns = 1;
        PageDescription.collapsible = false;
        
        Component.Apex.OutPutPanel PageDescPnl = new Component.Apex.OutPutPanel();
        PageDescPnl.layout = 'block';
        PageDescPnl.styleClass = 'pageDescription';
        
        Component.Apex.outputtext PageDescLabel = new Component.Apex.outputtext(escape=false);
                    
        Map<String,Schema.SObjectField> FieldMap = Schema.SObjectType.HexaBPM__Service_Request__c.fields.getMap();
        
        if(PageId!=null && PageId!=''){
            list<HexaBPM__Section__c> lstSec = new list<HexaBPM__Section__c>();
            map<id,list<HexaBPM__Page_Navigation_Rule__c>> mapSecDetailRenderRules = new map<id,list<HexaBPM__Page_Navigation_Rule__c>>();
            set<Id> setSectionDetailIds = new set<Id>();
            for(HexaBPM__Section__c objSec:[select id,Name,HexaBPM__Order__c,HexaBPM__Page__c,HexaBPM__Page__r.HexaBPM__Page_Description__c,HexaBPM__Section_Type__c,HexaBPM__Section_Description__c,HexaBPM__Default_Rendering__c,HexaBPM__layout__c,(select id,HexaBPM__Rule_Text_Condition__c from HexaBPM__Page_Navigation_Rule__r limit 100),(select id,Name,HexaBPM__Button_Location__c, HexaBPM__Component_Label__c,HexaBPM__Component_Type__c,HexaBPM__Field_API_Name__c,HexaBPM__button_position__c,HexaBPM__Commit_the_Record__c,HexaBPM__Disable__c,HexaBPM__Cancel_Request__c,HexaBPM__Object_Name__c,HexaBPM__Order__c,HexaBPM__Section__c,HexaBPM__Field_Description__c,HexaBPM__Default_Value__c,HexaBPM__hasOnChange__c,HexaBPM__Mark_it_as_Required__c,HexaBPM__Render_By_Default__c,HexaBPM__Ignore_Required_Fields__c from HexaBPM__Section_Details__r order by HexaBPM__Order__c limit 1000) 
                                   from HexaBPM__Section__c where HexaBPM__Page__c=:PageId order by HexaBPM__Order__c,HexaBPM__Section_Type__c]){
                if(objSec.HexaBPM__Section_Details__r!=null && objSec.HexaBPM__Section_Details__r.size()>0){
                    lstSec.add(objSec);
                    for(HexaBPM__Section_Detail__c objSecDet:objSec.HexaBPM__Section_Details__r){
                        if(objSecDet.HexaBPM__Render_By_Default__c==false)
                            setSectionDetailIds.add(objSecDet.Id);
                    }
                }
            }

            if(setSectionDetailIds!=null && setSectionDetailIds.size()>0){
                for(HexaBPM__Page_Navigation_Rule__c SDRenRule:[select id,HexaBPM__Rule_Text_Condition__c,HexaBPM__Section_Detail__c from HexaBPM__Page_Navigation_Rule__c where HexaBPM__Section_Detail__c IN:setSectionDetailIds]){
                    list<HexaBPM__Page_Navigation_Rule__c> lstSDRenRules = new list<HexaBPM__Page_Navigation_Rule__c>();
                    if(mapSecDetailRenderRules.get(SDRenRule.HexaBPM__Section_Detail__c)!=null && mapSecDetailRenderRules.get(SDRenRule.HexaBPM__Section_Detail__c).size()>0){
                        lstSDRenRules = mapSecDetailRenderRules.get(SDRenRule.HexaBPM__Section_Detail__c);
                        lstSDRenRules.add(SDRenRule);
                    }else{
                        lstSDRenRules.add(SDRenRule);
                    }
                    mapSecDetailRenderRules.put(SDRenRule.HexaBPM__Section_Detail__c,lstSDRenRules);
                }
            }
            
            integer i = 1;
            //looping all section of the current page 
            for(HexaBPM__Section__c objSec:lstSec){
            	/*
                if(i==1 && objSec.HexaBPM__Page__c!=null && objSec.HexaBPM__Page__r.HexaBPM__Page_Description__c!=null){
                    PageDescLabel.value = objSec.HexaBPM__Page__r.HexaBPM__Page_Description__c;
                    PageDescPnl.childComponents.add(PageDescLabel);
                    PageDescription.childComponents.add(PageDescPnl);
                    pb.childComponents.add(PageDescription);
                    i++;
                }
                */
                boolean bBuildSection = false;
                if(objSec.HexaBPM__Default_Rendering__c==true){
                    bBuildSection = true;
                }else{
                    if(objSec.HexaBPM__Page_Navigation_Rule__r!=null && objSec.HexaBPM__Page_Navigation_Rule__r.size()>0){
                        boolean RulesResult = false;
                        //Evaluating the Section render rule and showing accordingly
                        for(HexaBPM__Page_Navigation_Rule__c SRendRule:objSec.HexaBPM__Page_Navigation_Rule__r){
                            boolean eachCondition = HexaBPM.PageFlowUtil.executeNavigationRules(SRendRule.HexaBPM__Rule_Text_Condition__c,objRequest);
                            if(eachCondition!=null && eachCondition==true)
                                RulesResult = true;                         
                        }
                        bBuildSection = RulesResult;
                    }
                }
                if(bBuildSection==true && objSec.HexaBPM__Section_Type__c=='PageBlockSection'){
                    Component.Apex.PageBlockSection dycPB = new Component.Apex.PageBlockSection();
                    dycPB.Id = 'PBS_'+objSec.Id;
                    dycPB.columns = Integer.valueOf(objSec.HexaBPM__layout__c);
                    //dycPB.Title = objSec.Name;
                    dycPB.collapsible = false;
                    
                    Component.Apex.OutputPanel pageBlockSectionWrapper = new Component.Apex.OutputPanel();
                    pageBlockSectionWrapper.layout = 'block';
                    pageBlockSectionWrapper.styleClass = 'colLayout' + objSec.HexaBPM__layout__c+' pageBlockSectionWrapper';
                    
                    if(objSec.HexaBPM__Section_Description__c != '' && objSec.HexaBPM__Section_Description__c != null){
                        Component.Apex.PageBlockSection DescriptionPBS = new Component.Apex.PageBlockSection();
                        DescriptionPBS.Id = 'DesPBS_'+objSec.Id;
                        DescriptionPBS.columns = 1;
                        DescriptionPBS.collapsible = false;
                        DescriptionPBS.Title = objSec.Name;
                        
                        
                        Component.Apex.OutPutPanel sectDesc = new Component.Apex.OutPutPanel();
                        sectDesc.layout = 'block';
                        sectDesc.styleClass = 'sectionDescription';
                        Component.Apex.outputtext sectDescLabel = new Component.Apex.outputtext(escape=false);
                        sectDescLabel.value = objSec.HexaBPM__Section_Description__c;
                        sectDesc.childComponents.add(sectDescLabel);
                        //dycPB.childComponents.add(sectDesc);
                        DescriptionPBS.childComponents.add(sectDesc);
                        pageBlockSectionWrapper.childComponents.add(DescriptionPBS);
                        DescriptionPBS.childComponents.add(dycPB);
                        //pageBlockSectionWrapper.childComponents.add(sectDesc);
                    }else{
                        dycPB.Title = objSec.Name;
                    }
                    
                    pageBlockSectionWrapper.childComponents.add(dycPB);
                    // input or output field
                    if(objSec.HexaBPM__Section_Details__r!=null && objSec.HexaBPM__Section_Details__r.size()>0){
                        //dycPB.Title = objSec.Name;
                        for(HexaBPM__Section_Detail__c objSecDet:objSec.HexaBPM__Section_Details__r){
                            boolean bRenderSecDetail = false;
                            if(objSecDet.HexaBPM__Render_By_Default__c==true){
                                bRenderSecDetail = true;
                            }else{
                                if(mapSecDetailRenderRules!=null && mapSecDetailRenderRules.get(objSecDet.Id)!=null){
                                    boolean RulesResult = false;
                                    for(HexaBPM__Page_Navigation_Rule__c SDRendRule:mapSecDetailRenderRules.get(objSecDet.Id)){
                                        boolean eachRule = HexaBPM.PageFlowUtil.executeNavigationRules(SDRendRule.HexaBPM__Rule_Text_Condition__c,objRequest);
                                        if(eachRule!=null && eachRule==true)
                                            RulesResult = true;                         
                                    }
                                    bRenderSecDetail = RulesResult;
                                }
                            }
                            
                            if(bRenderSecDetail==true && objSecDet.HexaBPM__Component_Type__c=='Input Field' && objSecDet.HexaBPM__Field_API_Name__c!=null && objSecDet.HexaBPM__Field_API_Name__c!='' && objSecDet.HexaBPM__Object_Name__c=='HexaBPM__Service_Request__c' && FieldMap.get(objSecDet.HexaBPM__Field_API_Name__c)!=null && FieldMap.get(objSecDet.HexaBPM__Field_API_Name__c).getDescribe().isCreateable()){
                                pb.mode = 'Edit';
                                Component.Apex.PageBlockSectionItem PBSItem = new Component.Apex.PageBlockSectionItem();
                                Component.Apex.OutPutPanel PBSItemPnl = new Component.Apex.OutPutPanel();
                                
                                PBSItemPnl.layout = 'block';
                                PBSItemPnl.styleClass = 'rowWrapper';
                                if(objSecDet.HexaBPM__Default_Value__c!=null && objRequest.get(objSecDet.HexaBPM__Field_API_Name__c)==null && fieldMap!=null && fieldMap.get(objSecDet.HexaBPM__Field_API_Name__c)!=null){
                                    string FieldDataType = fieldMap.get(objSecDet.HexaBPM__Field_API_Name__c).getDescribe().getType()+'';
                                    if(FieldDataType=='DOUBLE' || FieldDataType=='PERCENT'){
                                        objRequest.put(objSecDet.HexaBPM__Field_API_Name__c,ConvertToDecimal(objSecDet.HexaBPM__Default_Value__c));
                                    }else if(FieldDataType=='DATE'){
                                        objRequest.put(objSecDet.HexaBPM__Field_API_Name__c,ConvertToDate(objSecDet.HexaBPM__Default_Value__c));
                                    }else if(FieldDataType=='DATETIME'){
                                        objRequest.put(objSecDet.HexaBPM__Field_API_Name__c,ConvertToDateTime(objSecDet.HexaBPM__Default_Value__c));
                                    }else if(FieldDataType=='BOOLEAN'){
                                        if(ConvertToBoolean(objSecDet.HexaBPM__Default_Value__c)!=null)
                                            objRequest.put(objSecDet.HexaBPM__Field_API_Name__c,ConvertToBoolean(objSecDet.HexaBPM__Default_Value__c));
                                    }else{
                                        objRequest.put(objSecDet.HexaBPM__Field_API_Name__c,objSecDet.HexaBPM__Default_Value__c);
                                    }
                                }
                                    
                                Component.Apex.inputfield inpFld = new Component.Apex.inputfield();
                                inpFld.Id = objSecDet.HexaBPM__Field_API_Name__c.ReplaceAll('_','');
                                PBSItem.Id = 'PBSItem'+'_'+inpFld.Id;
                                	
                                if(objSecDet.HexaBPM__Object_Name__c=='HexaBPM__Service_Request__c'){
                                    inpFld.expressions.value = '{!objRequest.'+objSecDet.HexaBPM__Field_API_Name__c+'}';
                                }
                                //on change event is invoking the javascript method
                                if(objSecDet.HexaBPM__hasOnChange__c==true)
                                    inpFld.onChange='InvokeChangeEvent();return false;';
                                    
                                // if label is not defined for a field then get it from definition
                                Component.Apex.outputlabel Fldlabel = new Component.Apex.outputlabel();
                                Fldlabel.value = objSecDet.HexaBPM__Component_Label__c;
                                if((objSecDet.HexaBPM__Component_Label__c == '' || objSecDet.HexaBPM__Component_Label__c == null) && fieldMap!=null && fieldMap.get(objSecDet.HexaBPM__Field_API_Name__c)!=null)
                                    Fldlabel.value = fieldMap.get(objSecDet.HexaBPM__Field_API_Name__c).getDescribe().getLabel();
                                else
                                    Fldlabel.value = objSecDet.HexaBPM__Component_Label__c;
                                //help text after the field
                                Component.Apex.outputlabel FldDescription = new Component.Apex.outputlabel(escape=false);
                                FldDescription.value = objSecDet.HexaBPM__Field_Description__c;
                                // three panels to display label field description
                                Component.Apex.OutPutPanel labelPanel = new Component.Apex.OutPutPanel();
                                labelPanel.layout = 'block';
                                labelPanel.styleClass = objSecDet.HexaBPM__Field_API_Name__c=='i_agree__c' ? 'labelWrapper descriptionLbl' : 'labelWrapper';
                                
                                Component.Apex.OutPutPanel fieldPanel = new Component.Apex.OutPutPanel();
                                fieldPanel.layout = 'block';
                                fieldPanel.styleClass = 'fieldWrapper';
                                
                                Component.Apex.OutPutPanel fDescPanel = new Component.Apex.OutPutPanel();
                                fDescPanel.layout = 'block';
                                fDescPanel.styleClass = 'descWrapper';

                                labelPanel.childComponents.add(Fldlabel);
                                // to bring the red bar for required field
                                if(objSecDet.HexaBPM__Mark_it_as_Required__c){
                                    Component.Apex.OutPutPanel ReqBlockMainPnl = new Component.Apex.OutPutPanel();
                                    ReqBlockMainPnl.styleClass = 'requiredInput';
                                    ReqBlockMainPnl.layout = 'block';
                                    
                                    Component.Apex.OutPutPanel ReqBlockFldPnl = new Component.Apex.OutPutPanel();
                                    ReqBlockFldPnl.id=inpFld.Id+'_ReqBlock';
                                    ReqBlockFldPnl.styleClass = 'requiredBlock';
                                    ReqBlockFldPnl.layout = 'block';
                                    
                                    ReqBlockMainPnl.childComponents.add(ReqBlockFldPnl);
                                    
                                    ReqBlockMainPnl.childComponents.add(inpFld);
                                    
                                    Component.Apex.OutPuttext ErrorText = new Component.Apex.OutPuttext();
                                    ErrorText.id = inpFld.Id+'_ErrorText';
                                    ErrorText.value = '<div class="errorMsg" id="'+inpFld.Id+'"></div>';
                                    ErrorText.escape = false;
                                    ReqBlockMainPnl.childComponents.add(ErrorText);
                                    
                                    fieldPanel.childComponents.add(ReqBlockMainPnl);
                                    string FieldId = inpFld.Id;
                                    if(ReqFieldIds==''){
                                        ReqFieldIds = inpFld.Id;
                                    }else{
                                        ReqFieldIds = ReqFieldIds+','+inpFld.Id;
                                    }
                                    inpFld.onblur='check_FieldValue("'+FieldId+'");return false;';
                                    
                                }else{
                                    fieldPanel.childComponents.add(inpFld);
                                }
                                
                                if(objSec.HexaBPM__layout__c == '2' && objSecDet.HexaBPM__Field_Description__c!=null && objSecDet.HexaBPM__Field_Description__c!=''){
                                    // PBSItem.helpText = objSecDet.HexaBPM__Field_Description__c;
                                    // PBSItem.labelTitle = objSecDet.HexaBPM__Field_Description__c;
                                    Component.Apex.OutPutText HelpIcon = new Component.Apex.OutPutText(escape=false);
                                    //HelpIcon.value = '<span id="helpicon" class="glyphicon glyphicon-question-sign" data-toggle="tooltip" aria-hidden="true" style="color: #404041;padding-left: 1px; font-size: 14px;vertical-align:middle;" title="'+objSecDet.HexaBPM__Field_Description__c+'"></span>';
                                    HelpIcon.value = '<span><img src="/img/s.gif" alt="" class="helpOrb" title="'+objSecDet.HexaBPM__Field_Description__c+'" /></span>';
                                    labelPanel.childComponents.add(HelpIcon);
                                }
                                    
                                fDescPanel.childComponents.add(FldDescription);
                                
                                PBSItemPnl.childComponents.add(labelPanel);
                                
                                PBSItemPnl.childComponents.add(fieldPanel);
                                
                                if(objSec.HexaBPM__layout__c == '1')
                                    PBSItemPnl.childComponents.add(fDescPanel);
                                
                                PBSItem.childComponents.add(PBSItemPnl);
                                
                                dycPB.childComponents.add(PBSItem);
                                
                            }else if(bRenderSecDetail==true && objSecDet.HexaBPM__Component_Type__c=='Blank Space'){
                                dycPB.collapsible = false;
                                pb.mode = 'edit';
                                Component.Apex.PageBlockSectionItem PBSItem = new Component.Apex.PageBlockSectionItem();
                                Component.Apex.OutPutPanel PBSItemPnl = new Component.Apex.OutPutPanel();
                                
                                PBSItemPnl.layout = 'block';
                                PBSItemPnl.styleClass = 'rowWrapper';
                                PBSItem.childComponents.add(PBSItemPnl);
                                dycPB.childComponents.add(PBSItem);
                                
                            }else if(bRenderSecDetail==true && objSecDet.HexaBPM__Component_Type__c=='Output Field' && objSecDet.HexaBPM__Field_API_Name__c!=null && objSecDet.HexaBPM__Field_API_Name__c!='' && objSecDet.HexaBPM__Object_Name__c=='HexaBPM__Service_Request__c' && FieldMap.get(objSecDet.HexaBPM__Field_API_Name__c)!=null && FieldMap.get(objSecDet.HexaBPM__Field_API_Name__c).getDescribe().isAccessible()){
                                pb.mode = 'Detail';
                                dycPB.collapsible = false;
                                Component.Apex.PageBlockSectionItem PBSItem = new Component.Apex.PageBlockSectionItem();
                                Component.Apex.OutPutPanel PBSItemPnl = new Component.Apex.OutPutPanel();
                                PBSItemPnl.layout = 'block';
                                PBSItemPnl.styleClass = 'rowWrapper';
                                
                                Component.Apex.OutputText outputFld = new Component.Apex.OutputText();
                                outputFld.escape = false;
                                outputFld.Id = objSecDet.HexaBPM__Field_API_Name__c.ReplaceAll('_','');
                                if(objSecDet.HexaBPM__Object_Name__c=='HexaBPM__Service_Request__c'){
                                    outputFld.expressions.value = '{!objRequest.'+objSecDet.HexaBPM__Field_API_Name__c+'}';
                                }
                                Component.Apex.outputlabel Fldlabel = new Component.Apex.outputlabel();
                                Fldlabel.value = objSecDet.HexaBPM__Component_Label__c;
                                if((objSecDet.HexaBPM__Component_Label__c == '' || objSecDet.HexaBPM__Component_Label__c == null) && fieldMap!=null && fieldMap.get(objSecDet.HexaBPM__Field_API_Name__c)!=null)
                                    Fldlabel.value = fieldMap.get(objSecDet.HexaBPM__Field_API_Name__c).getDescribe().getLabel();
                                else
                                    Fldlabel.value = objSecDet.HexaBPM__Component_Label__c;
                                
                                Component.Apex.outputlabel FldDescription = new Component.Apex.outputlabel();
                                FldDescription.value = objSecDet.HexaBPM__Field_Description__c;
                                
                                Component.Apex.OutPutPanel labelPanel = new Component.Apex.OutPutPanel();
                                labelPanel.layout = 'block';
                                labelPanel.styleClass = objSecDet.HexaBPM__Field_API_Name__c=='disclaimer__c' ? 'labelWrapper descriptionLbl' : 'labelWrapper';
                                
                                Component.Apex.OutPutPanel fieldPanel = new Component.Apex.OutPutPanel();
                                fieldPanel.layout = 'block';
                                fieldPanel.styleClass = 'fieldWrapper';
                                
                                Component.Apex.OutPutPanel fDescPanel = new Component.Apex.OutPutPanel();
                                fDescPanel.layout = 'block';
                                fDescPanel.styleClass = 'descWrapper';

                                labelPanel.childComponents.add(Fldlabel);
                                fieldPanel.childComponents.add(outputFld);
                                
                                fDescPanel.childComponents.add(FldDescription);
                                
                                PBSItemPnl.childComponents.add(labelPanel);
                                PBSItemPnl.childComponents.add(fieldPanel);
                                
                                if(objSec.HexaBPM__layout__c == '1')
                                    PBSItemPnl.childComponents.add(fDescPanel);
                                else if(objSec.HexaBPM__layout__c == '2' && objSecDet.HexaBPM__Field_Description__c!=null && objSecDet.HexaBPM__Field_Description__c!=''){
                                    Component.Apex.OutPutText HelpIcon = new Component.Apex.OutPutText(escape=false);
                                    HelpIcon.value = '<span id="helpicon" class="glyphicon glyphicon-question-sign" data-toggle="tooltip" aria-hidden="true" style="color: #404041;padding-left: 1px; font-size: 14px;vertical-align:middle;" title="'+objSecDet.HexaBPM__Field_Description__c+'"></span>';
                                    labelPanel.childComponents.add(HelpIcon);
                                }
                                PBSItem.childComponents.add(PBSItemPnl);
                                dycPB.childComponents.add(PBSItem);
                            }
                        }
                    }
                    pb.childComponents.add(pageBlockSectionWrapper);
                }else if(bBuildSection==true && objSec.HexaBPM__Section_Type__c=='CommandButtonSection'){
                    if(objSec.HexaBPM__Section_Details__r!=null && objSec.HexaBPM__Section_Details__r.size()>0){
                        for(HexaBPM__Section_Detail__c objSecDet:objSec.HexaBPM__Section_Details__r){
                            boolean bRenderSecDetail = false;
                            if(objSecDet.HexaBPM__Render_By_Default__c==true){
                                bRenderSecDetail = true;
                            }else{
                                if(mapSecDetailRenderRules!=null && mapSecDetailRenderRules.get(objSecDet.Id)!=null){
                                    boolean RulesResult = false;
                                    for(HexaBPM__Page_Navigation_Rule__c SDRendRule:mapSecDetailRenderRules.get(objSecDet.Id)){
                                        boolean eachRule = HexaBPM.PageFlowUtil.executeNavigationRules(SDRendRule.HexaBPM__Rule_Text_Condition__c,objRequest);
                                        if(eachRule!=null && eachRule==true)
                                            RulesResult = true;                         
                                    }
                                    bRenderSecDetail = RulesResult;
                                }
                            }
                            if(bRenderSecDetail==true){
                                Component.Apex.CommandButton dycBtn = new Component.Apex.CommandButton();
                                dycBtn.value = objSecDet.HexaBPM__Component_Label__c;
                                dycBtn.style = 'min-width:70px;min-height:20px;';
                                dycBtn.Disabled = objSecDet.HexaBPM__Disable__c;
                                // on click of commit record = true  it is a save button
                                if(objSecDet.HexaBPM__Commit_the_Record__c==false && objSecDet.HexaBPM__Cancel_Request__c==false){
                                    //for prev button HexaBPM__Ignore_Required_Fields__c is marked as true 
                                    dycBtn.onClick='DoAction("'+objSecDet.Id+'","'+objSecDet.HexaBPM__Ignore_Required_Fields__c+'");return false;';
                                }else if(objSecDet.HexaBPM__Commit_the_Record__c==true){
                                    dycBtn.onClick='SaveDetails();return false;';
                                }else if(objSecDet.HexaBPM__Cancel_Request__c==true){
                                    dycBtn.onClick = 'CancelRequest();return false;';
                                }
                                //button locations                             
                                if(objSecDet.HexaBPM__Button_Location__c!=null)
                                    PBtns.location = objSecDet.HexaBPM__Button_Location__c;
                                if (objSecDet.HexaBPM__Button_Position__c == 'left')
                                    dycBtn.styleClass = 'left';
                                else if (objSecDet.HexaBPM__Button_Position__c == 'right')
                                    dycBtn.styleClass = 'right';
                                PBtns.childComponents.add(dycBtn);
                            }
                        }
                    }
                }
            }
        }
        /*
        if(FlowId!=null && FlowId!=''){
            strHiddenPageIds = getHiddenPageIds(FlowId,objRequest);
        }
        */
        return pb;
    }
    
    /*
    global Component.Apex.PageBlock getFlowPageReadonlyContent(string FlowId,string PageId){
        ReqFieldIds = '';
        strHiddenPageIDS = '';
        Component.Apex.OutputPanel OpPanel = new Component.Apex.OutputPanel();
        Component.Apex.PageBlock pb = new Component.Apex.PageBlock();
        pb.Id = 'MainPB';
        pb.mode = 'detail';
        Component.Apex.PageBlockButtons PBtns = new Component.Apex.PageBlockButtons();
        pb.childComponents.add(PBtns);
        
        Map<String,Schema.SObjectField> FieldMap = Schema.SObjectType.HexaBPM__Service_Request__c.fields.getMap();
        
        if(FlowId!=null && FlowId!=''){
            list<HexaBPM__Section__c> lstSec = new list<HexaBPM__Section__c>();
            map<id,list<HexaBPM__Page_Navigation_Rule__c>> mapSecDetailRenderRules = new map<id,list<HexaBPM__Page_Navigation_Rule__c>>();
            set<Id> setSectionDetailIds = new set<Id>();
            map<id,id> mapHiddenPageIDs = new map<id,id>();
            strHiddenPageIDS = getHiddenPageIds(FlowId,objRequest);
            if(strHiddenPageIDS!=null && strHiddenPageIDS!=''){
                if(strHiddenPageIDS.indexOf(',')>-1){
                    for(string PgID:strHiddenPageIDS.split(',')){
                        mapHiddenPageIDs.put(PgID,PgID);
                    }
                }else if(strHiddenPageIDS.indexOf(',')==-1){
                    mapHiddenPageIDs.put(strHiddenPageIDS,strHiddenPageIDS);
                }
            }
            for(HexaBPM__Section__c objSec:[select id,Name,HexaBPM__Order__c,HexaBPM__Page__c,HexaBPM__Section_Type__c,HexaBPM__Section_Description__c,HexaBPM__Default_Rendering__c,HexaBPM__layout__c,HexaBPM__Page__r.HexaBPM__Is_Custom_Component__c,(select id,HexaBPM__Rule_Text_Condition__c from HexaBPM__Page_Navigation_Rule__r limit 100),(select id,Name,HexaBPM__Button_Location__c,
                                   HexaBPM__Component_Label__c,HexaBPM__Component_Type__c,HexaBPM__Field_API_Name__c,HexaBPM__Button_Position__c,HexaBPM__Commit_the_Record__c,HexaBPM__Disable__c,HexaBPM__Cancel_Request__c,HexaBPM__Object_Name__c,HexaBPM__Order__c,HexaBPM__Section__c,HexaBPM__Field_Description__c,HexaBPM__hasOnChange__c,HexaBPM__Mark_it_as_Required__c,HexaBPM__Render_By_Default__c,HexaBPM__Ignore_Required_Fields__c from HexaBPM__Section_Details__r order by HexaBPM__Order__c limit 1000) 
                                   from HexaBPM__Section__c where HexaBPM__Page__r.HexaBPM__Page_Flow__c=:FlowId order by HexaBPM__Page__r.HexaBPM__Page_Order__c,HexaBPM__Order__c,HexaBPM__Section_Type__c]){
                if(mapHiddenPageIDs.get(objSec.HexaBPM__Page__c)==null){
                    if(objSec.HexaBPM__Section_Details__r!=null && objSec.HexaBPM__Section_Details__r.size()>0){
                        lstSec.add(objSec);
                        for(HexaBPM__Section_Detail__c objSecDet:objSec.HexaBPM__Section_Details__r){
                            if(objSecDet.HexaBPM__Render_By_Default__c==false)
                                setSectionDetailIds.add(objSecDet.Id);
                        }
                    }
                }
            }

            if(setSectionDetailIds!=null && setSectionDetailIds.size()>0){
                for(HexaBPM__Page_Navigation_Rule__c SDRenRule:[select id,HexaBPM__Rule_Text_Condition__c,HexaBPM__Section_Detail__c from HexaBPM__Page_Navigation_Rule__c where HexaBPM__Section_Detail__c IN:setSectionDetailIds]){
                        list<HexaBPM__Page_Navigation_Rule__c> lstSDRenRules = new list<HexaBPM__Page_Navigation_Rule__c>();
                        if(mapSecDetailRenderRules.get(SDRenRule.HexaBPM__Section_Detail__c)!=null && mapSecDetailRenderRules.get(SDRenRule.HexaBPM__Section_Detail__c).size()>0){
                            lstSDRenRules = mapSecDetailRenderRules.get(SDRenRule.HexaBPM__Section_Detail__c);
                            lstSDRenRules.add(SDRenRule);
                        }else{
                            lstSDRenRules.add(SDRenRule);
                        }
                        mapSecDetailRenderRules.put(SDRenRule.HexaBPM__Section_Detail__c,lstSDRenRules);
                    }
            }
            
            for(HexaBPM__Section__c objSec:lstSec){
                if(objSec.HexaBPM__Section_Type__c=='PageBlockSection' && objSec.HexaBPM__Page__r.HexaBPM__Is_Custom_Component__c==false){
                    boolean bBuildSection = false;
                    if(objSec.HexaBPM__Default_Rendering__c==true){
                        bBuildSection = true;
                    }else{
                        if(objSec.HexaBPM__Page_Navigation_Rule__r!=null && objSec.HexaBPM__Page_Navigation_Rule__r.size()>0){
                            boolean RulesResult = false;
                            for(HexaBPM__Page_Navigation_Rule__c SRendRule:objSec.HexaBPM__Page_Navigation_Rule__r){
                                boolean eachCondition = HexaBPM.PageFlowUtil.executeNavigationRules(SRendRule.HexaBPM__Rule_Text_Condition__c,objRequest);
                                if(eachCondition!=null && eachCondition==true)
                                    RulesResult = true;                         
                            }
                            bBuildSection = RulesResult;
                        }
                    }
                    if(bBuildSection==true){
                        Component.Apex.PageBlockSection dycPB = new Component.Apex.PageBlockSection();
                        dycPB.columns = 2;
                        dycPB.collapsible = false;
                        dycPB.Title = objSec.Name;
                        Component.Apex.OutputPanel pageBlockSectionWrapper = new Component.Apex.OutputPanel();
                        pageBlockSectionWrapper.layout = 'block';
                        pageBlockSectionWrapper.styleClass = 'colLayout2 pageBlockSectionWrapper';
                        pageBlockSectionWrapper.childComponents.add(dycPB);
                        if(objSec.HexaBPM__Section_Details__r!=null && objSec.HexaBPM__Section_Details__r.size()>0){
                            for(HexaBPM__Section_Detail__c objSecDet:objSec.HexaBPM__Section_Details__r){
                                boolean bRenderSecDetail = false;
                                if(objSecDet.HexaBPM__Render_By_Default__c==true){
                                    bRenderSecDetail = true;
                                }else{
                                    if(mapSecDetailRenderRules!=null && mapSecDetailRenderRules.get(objSecDet.Id)!=null){
                                        boolean RulesResult = false;
                                        for(HexaBPM__Page_Navigation_Rule__c SDRendRule:mapSecDetailRenderRules.get(objSecDet.Id)){
                                            boolean eachRule = HexaBPM.PageFlowUtil.executeNavigationRules(SDRendRule.HexaBPM__Rule_Text_Condition__c,objRequest);
                                            if(eachRule!=null && eachRule==true)
                                                RulesResult = true;
                                        }
                                        bRenderSecDetail = RulesResult;
                                    }
                                }
                                if(bRenderSecDetail==true && (objSecDet.HexaBPM__Component_Type__c=='Input Field' || objSecDet.HexaBPM__Component_Type__c=='Output Field') && objSecDet.HexaBPM__Object_Name__c=='HexaBPM__Service_Request__c' && objSecDet.HexaBPM__Field_API_Name__c!=null && FieldMap.get(objSecDet.HexaBPM__Field_API_Name__c)!=null && FieldMap.get(objSecDet.HexaBPM__Field_API_Name__c).getDescribe().isAccessible()){
                                    pb.mode = 'detail';
                                    Component.Apex.PageBlockSectionItem PBSItem = new Component.Apex.PageBlockSectionItem();
                                    Component.Apex.OutPutPanel PBSItemPnl = new Component.Apex.OutPutPanel();
                                    PBSItemPnl.layout = 'block';
                                    PBSItemPnl.styleClass = 'rowWrapper';
                                    
                                    Component.Apex.outputfield inpFld = new Component.Apex.outputfield();
                                    inpFld.Id = objSecDet.HexaBPM__Field_API_Name__c.ReplaceAll('_','');
                                    if(objSecDet.HexaBPM__Object_Name__c=='HexaBPM__Service_Request__c'){
                                        inpFld.expressions.value = '{!objRequest.'+objSecDet.HexaBPM__Field_API_Name__c+'}';
                                    }
                                    Component.Apex.outputlabel Fldlabel = new Component.Apex.outputlabel();
                                    Fldlabel.value = objSecDet.HexaBPM__Component_Label__c;
                                    if ((objSecDet.HexaBPM__Component_Label__c == '' || objSecDet.HexaBPM__Component_Label__c == null) && fieldMap!=null && fieldMap.get(objSecDet.HexaBPM__Field_API_Name__c)!=null)
                                        Fldlabel.value = fieldMap.get(objSecDet.HexaBPM__Field_API_Name__c).getDescribe().getLabel();
                                    else
                                        Fldlabel.value = objSecDet.HexaBPM__Component_Label__c;
                                    Component.Apex.outputlabel FldDescription = new Component.Apex.outputlabel();
                                    FldDescription.value = objSecDet.HexaBPM__Field_Description__c;
                                    Component.Apex.OutPutPanel labelPanel = new Component.Apex.OutPutPanel();
                                    labelPanel.layout = 'block';
                                    labelPanel.styleClass = 'labelWrapper';
                                    Component.Apex.OutPutPanel fieldPanel = new Component.Apex.OutPutPanel();
                                    fieldPanel.layout = 'block';
                                    fieldPanel.styleClass = 'fieldWrapper';
                                    Component.Apex.OutPutPanel fDescPanel = new Component.Apex.OutPutPanel();
                                    fDescPanel.layout = 'block';
                                    fDescPanel.styleClass = 'descWrapper';
                                    labelPanel.childComponents.add(Fldlabel);
                                    if(objSecDet.HexaBPM__Field_Description__c!=null && objSecDet.HexaBPM__Field_Description__c!=''){
                                        Component.Apex.OutPutText HelpIcon = new Component.Apex.OutPutText(escape=false);
                                        HelpIcon.value = '<span id="helpicon" class="glyphicon glyphicon-question-sign" data-toggle="tooltip" aria-hidden="true" style="color: #404041;padding-left: 1px; font-size: 14px;vertical-align:middle;" title="'+objSecDet.HexaBPM__Field_Description__c+'"></span>';
                                        labelPanel.childComponents.add(HelpIcon);
                                    }
                                    fieldPanel.childComponents.add(inpFld);
                                    PBSItemPnl.childComponents.add(labelPanel);
                                    PBSItemPnl.childComponents.add(fieldPanel);
                                    PBSItem.childComponents.add(PBSItemPnl);
                                    dycPB.childComponents.add(PBSItem);
                                }
                            }
                        }
                        pb.childComponents.add(pageBlockSectionWrapper);
                    }
                }
            }
        }
        return pb;
    }
    global static boolean executeNavigationRules(string strTextCondition,sObject DyncObject){
        system.debug('strTextCondition===>'+strTextCondition);
        system.debug('DyncObject===>'+DyncObject);
        if(DyncObject!=null && strTextCondition!=null && strTextCondition!=''){
            Boolean FieldParseFlag=true;
            Boolean ConditionParseFlag=false;
            Boolean combinedConditionFlag=false;
            Boolean ValueParseFlag=false;
            Boolean parseResult;
            Boolean lastParseResult;
            Boolean combinedConditionResult;
            String SRFieldValue;
            String valueName;
            String operator;
            String condition;
            String combinedConditionStrng;
           
           //set of predefined operators
           Set<String> operatorSet = new Set<String>{'=','>=','<=','CONTAINS','STARTS','!='};
           
           //set of predefined conditions
           Set<String> conditionSet = new Set<String>{'AND','OR'};
           
           //string to be executed
           string conditionStrng = strTextCondition;
           
           //split the condition string by #
           list<String> conditionStringLstRaw = new list<string>();
           list<String> conditionStringLst = new list<string>();
           if(conditionStrng!=null && conditionStrng.trim()!='')
                conditionStringLstRaw = conditionStrng.split('#');
           if(conditionStringLstRaw!=null && conditionStringLstRaw.size()>0){
                for(string str:conditionStringLstRaw){
                    if(str!=null && str!='' && str.trim()!=''){
                        conditionStringLst.add(str.trim());
                    }
                }
           }
           system.debug('conditionStringLst===>'+conditionStringLst);
           for(string eachString:conditionStringLst){
              system.debug('eachString===>'+eachString);
              if(eachString=='('){
                 parseResult=null;
                 lastparseResult=null;
                 ValueParseFlag=false;
                 FieldParseFlag=true;
                 continue;
              }else if(eachString==')'){
                 if(combinedConditionStrng==null){
                    combinedConditionResult=parseResult;
                 }else{
                    combinedConditionResult = parseConditions(combinedConditionResult,parseResult,combinedConditionStrng);
                    parseResult=combinedConditionResult;
                 }
                 combinedConditionFlag=true;
                 continue;
              }else if(combinedConditionFlag){
                 combinedConditionStrng=eachString;
                 combinedConditionFlag=false;   
                 continue; 
              }else if(FieldParseFlag){
                    if(operatorSet.contains(eachString)){
                        operator=eachString;
                        FieldParseFlag=false;
                        ValueParseFlag=true;      
                    }else{
                        system.debug('Navigation Cond string before Split===>'+eachString);
                        list<string> lstObjectFld = new list<string>();
                        if(eachString!=null && eachString!=''){
                            eachString = eachString.replace('->','#');
                            lstObjectFld = eachString.split('#');
                            system.debug('lstObjectFld===>'+lstObjectFld);
                            if(lstObjectFld!=null && lstObjectFld.size()>=2){
                                eachString = lstObjectFld[1];
                            }
                        }
                        system.debug('Navigation Cond string after split===>'+eachString);
                        if(lstObjectFld!=null && lstObjectFld.size()>=2){
                            system.debug('1');
                            if(lstObjectFld[0].tolowercase()=='hexabpm__service_request__c'){
                                system.debug('2');
                                if(DyncObject!=null){
                                    system.debug('3');
                                    SRFieldValue = String.valueOf(DyncObject.get(eachString));
                                }
                            }
                        }
                    }
              }else if(ValueParseFlag){
                    if(conditionSet.contains(eachString)){
                        condition=eachString;
                        ValueParseFlag=false;
                        FieldParseFlag=true;      
                    }else{
                        valueName=eachString;
                        if(parseResult!=null){
                            lastParseResult=parseResult;
                        }
                        if(SRFieldValue==null){
                            SRFieldValue = 'null';
                        }
                        parseResult = parseEachCondition(SRFieldValue,operator,valueName); 
                        if(lastParseResult!=null){
                            parseResult = parseConditions(lastParseResult,parseResult,condition);
                        }
                    }
              }
              system.debug('parseResult====>'+parseResult);
           }
           system.debug('final parseResult====>'+parseResult);
           return parseResult;
        }
        return false;
    }
    */
    
    //method executes one condition and returns True/False
    global static boolean parseEachCondition(String SRVal,String oprtr,String conditionVal){
        system.debug('SRVal=>'+SRVal+', oprtr=>'+oprtr+', conditionVal=>'+conditionVal+';');
        boolean EachCondResult = false;
        if(oprtr=='='){
          if(SRVal==conditionVal){
              EachCondResult = true;
          }else{
              EachCondResult = false;
          }
          }else if(oprtr=='>=' && SRVal!=null && conditionVal!=null && SRVal!='null' && conditionVal!='null'){
              if(integer.valueOf(SRVal)>=integer.valueOf(conditionVal)){
                  EachCondResult = true;
              }else{
                  EachCondResult = false;
              }
          }else if(oprtr=='<=' && SRVal!=null && conditionVal!=null && SRVal!='null' && conditionVal!='null'){
              if(integer.valueOf(SRVal)<=integer.valueOf(conditionVal)){
                  EachCondResult = true;
              }else{
                  EachCondResult = false;
              }
          }else if(oprtr=='!='){
              if(SRVal!=conditionVal){
                  EachCondResult = true;
              }else{
                  EachCondResult = false;
              }
          }
          system.debug('EachCondResult==>('+ SRVal+' '+oprtr+' '+conditionVal+') = '+EachCondResult);
          return EachCondResult;
    }
    global static boolean parseConditions(Boolean lastConditionResult,Boolean conditionResult,String conditionStrng){
        system.debug('lastConditionResult==>'+lastConditionResult+' **conditionStrng** '+conditionStrng+' **conditionResult** '+conditionResult);
        if(conditionStrng=='AND'){
          return lastConditionResult && conditionResult;
        }else if(conditionStrng=='OR'){
          return lastConditionResult || conditionResult;
        }
        return false;
    }
    global static set<string> FetchObjectFields(string strFlowId,string strObjectName){
        set<string> setFields = new set<string>();
        if(strFlowId!=null && strFlowId!='' && strFlowId.length()==18)
          strFlowId = strFlowId.substring(0,15);
        map<string,string> mapUniqueFlds = new map<string,string>();
        if(strFlowId!=null && strFlowId!='' && strObjectName!=null && strObjectName!=''){
            //fields to be displayed
            Map<String,Schema.SObjectField> sObjectFieldMap = Schema.SObjectType.HexaBPM__Service_Request__c.fields.getMap();
            for(HexaBPM__Section_Detail__c Fld:[select id,Name,HexaBPM__Field_API_Name__c,HexaBPM__Object_Name__c from HexaBPM__Section_Detail__c where HexaBPM__Section__r.HexaBPM__Page__r.HexaBPM__Page_Flow__c=:strFlowId and HexaBPM__Object_Name__c=:strObjectName and HexaBPM__Field_API_Name__c!=null and (HexaBPM__Component_Type__c='Input Field' or HexaBPM__Component_Type__c='Output Field')]){
                string strFldName = Fld.HexaBPM__Field_API_Name__c;
                strFldName = strFldName.toLowerCase();
                if(mapUniqueFlds.get(strFldName)==null && sObjectFieldMap!=null && sObjectFieldMap.get(strFldName)!=null)
                    setFields.add(Fld.HexaBPM__Field_API_Name__c.toLowerCase());
            }
            // fields to be included conditions
            for(HexaBPM__Page_Flow_Condition__c Condfld:[select id,Name,HexaBPM__Field_Name__c,HexaBPM__Object_Name__c from HexaBPM__Page_Flow_Condition__c where HexaBPM__Object_Name__c=:strObjectName and HexaBPM__Flow_Id__c=:strFlowId and HexaBPM__Field_Name__c!=null]){
                string strFldName = Condfld.HexaBPM__Field_Name__c;
                strFldName = strFldName.toLowerCase();
                if(mapUniqueFlds.get(strFldName)==null && sObjectFieldMap!=null && sObjectFieldMap.get(strFldName)!=null)
                    setFields.add(Condfld.HexaBPM__Field_Name__c.toLowerCase());
            }
        }
        return setFields;
    }
    /*
        Method Name :   getHiddenPageIds
        Description :   Preparing the page Id's which should hide based on the conditions.
    */
    /*
    global static string getHiddenPageIds(string strFlowId,sObject objDycObject){
        string strHiddenPageElemIds = '';
        if(strFlowId!=null && strFlowId!='' && objDycObject!=null){
            for(HexaBPM__Page__c pg:[select id,Name,(select id,HexaBPM__Rule_Text_Condition__c from HexaBPM__Page_Navigation_Rule__r limit 100) from HexaBPM__Page__c where HexaBPM__Page_Flow__c=:strFlowId and HexaBPM__Render_by_Default__c=false]){
                if(pg.HexaBPM__Page_Navigation_Rule__r!=null && pg.HexaBPM__Page_Navigation_Rule__r.size()>0){
                    boolean bShowPage = false;
                    for(HexaBPM__Page_Navigation_Rule__c PRR:pg.HexaBPM__Page_Navigation_Rule__r){
                        if(PRR.HexaBPM__Rule_Text_Condition__c!=null && PRR.HexaBPM__Rule_Text_Condition__c!=''){
                            bShowPage = HexaBPM.PageFlowUtil.executeNavigationRules(PRR.HexaBPM__Rule_Text_Condition__c,objDycObject);
                            if(bShowPage==true)
                                break;
                        }else{
                            bShowPage = true;
                        }
                    }
                    if(bShowPage==false){
                        if(strHiddenPageElemIds==''){
                            strHiddenPageElemIds = pg.Id;
                        }else{
                            strHiddenPageElemIds = strHiddenPageElemIds+','+pg.Id;
                        }
                    }
                }
            }
        }
        return strHiddenPageElemIds;
    }
    */
    /*
        Method Name :   getButtonsPB
        Description :   Preparing the Command buttons for an Custom Page.
    */
    /*
    global Component.Apex.PageBlock getButtonsPB(string FlowId,string PageId,string PanelId){
        string strPageId = PageId;
        ReqFieldIds = '';
        Component.Apex.OutputPanel OpPanel = new Component.Apex.OutputPanel();
        Component.Apex.PageBlock Btnspb = new Component.Apex.PageBlock();
        if(PanelId!=null)
            Btnspb.Id = PanelId;
        else
            Btnspb.Id = 'MainPB';
        Component.Apex.PageBlockButtons PBtns = new Component.Apex.PageBlockButtons();
        Btnspb.childComponents.add(PBtns);
        if(strPageId!=null && strPageId!=''){
            list<HexaBPM__Section__c> lstSec = new list<HexaBPM__Section__c>();
            map<id,list<HexaBPM__Page_Navigation_Rule__c>> mapSecDetailRenderRules = new map<id,list<HexaBPM__Page_Navigation_Rule__c>>();
            set<Id> setSectionDetailIds = new set<Id>();
            for(HexaBPM__Section__c objSec:[select id,Name,HexaBPM__Order__c,HexaBPM__Page__c,HexaBPM__Section_Type__c,HexaBPM__Section_Description__c,HexaBPM__Default_Rendering__c,HexaBPM__layout__c,(select id,Name,HexaBPM__Button_Location__c,HexaBPM__Component_Label__c,HexaBPM__Component_Type__c,HexaBPM__Field_API_Name__c,   HexaBPM__button_position__c,HexaBPM__Commit_the_Record__c,HexaBPM__Disable__c,HexaBPM__Object_Name__c,HexaBPM__Order__c,HexaBPM__Section__c,HexaBPM__Field_Description__c,HexaBPM__hasOnChange__c,HexaBPM__Mark_it_as_Required__c,HexaBPM__Render_By_Default__c,HexaBPM__Ignore_Required_Fields__c from HexaBPM__Section_Details__r order by HexaBPM__Order__c limit 1000) from HexaBPM__Section__c where HexaBPM__Section_Type__c='CommandButtonSection' and HexaBPM__Page__c=:strPageId order by HexaBPM__Order__c,HexaBPM__Section_Type__c]){
                lstSec.add(objSec);
                if(objSec.HexaBPM__Section_Details__r!=null && objSec.HexaBPM__Section_Details__r.size()>0){
                    for(HexaBPM__Section_Detail__c objSecDet:objSec.HexaBPM__Section_Details__r){
                        if(objSecDet.HexaBPM__Render_By_Default__c==false)
                            setSectionDetailIds.add(objSecDet.Id);
                    }
                }
            }
            if(setSectionDetailIds!=null && setSectionDetailIds.size()>0){
                for(HexaBPM__Page_Navigation_Rule__c SDRenRule:[select id,HexaBPM__Rule_Text_Condition__c,HexaBPM__Section_Detail__c from HexaBPM__Page_Navigation_Rule__c where HexaBPM__Section_Detail__c IN:setSectionDetailIds]){
                    list<HexaBPM__Page_Navigation_Rule__c> lstSDRenRules = new list<HexaBPM__Page_Navigation_Rule__c>();
                    if(mapSecDetailRenderRules.get(SDRenRule.HexaBPM__Section_Detail__c)!=null && mapSecDetailRenderRules.get(SDRenRule.HexaBPM__Section_Detail__c).size()>0){
                        lstSDRenRules = mapSecDetailRenderRules.get(SDRenRule.HexaBPM__Section_Detail__c);
                        lstSDRenRules.add(SDRenRule);
                    }else{
                        lstSDRenRules.add(SDRenRule);
                    }
                    mapSecDetailRenderRules.put(SDRenRule.HexaBPM__Section_Detail__c,lstSDRenRules);
                }
            }
            for(HexaBPM__Section__c objSec:lstSec){
                boolean bBuildSection = false;
                if(objSec.HexaBPM__Default_Rendering__c==true){
                    bBuildSection = true;
                }else{
                    if(objSec.HexaBPM__Page_Navigation_Rule__r!=null && objSec.HexaBPM__Page_Navigation_Rule__r.size()>0){
                        boolean RulesResult = false;
                        for(HexaBPM__Page_Navigation_Rule__c SRendRule:objSec.HexaBPM__Page_Navigation_Rule__r){
                            boolean eachCondition = HexaBPM.PageFlowUtil.executeNavigationRules(SRendRule.HexaBPM__Rule_Text_Condition__c,objSR);
                            if(eachCondition!=null && eachCondition==true)
                                RulesResult = true;                         
                        }
                        bBuildSection = RulesResult;
                    }
                }
                if(bBuildSection==true && objSec.HexaBPM__Section_Type__c=='CommandButtonSection'){
                    if(objSec.HexaBPM__Section_Details__r!=null && objSec.HexaBPM__Section_Details__r.size()>0){
                        for(HexaBPM__Section_Detail__c objSecDet:objSec.HexaBPM__Section_Details__r){
                            boolean bRenderSecDetail = false;
                            if(objSecDet.HexaBPM__Render_By_Default__c==true){
                                bRenderSecDetail = true;
                            }else{
                                if(mapSecDetailRenderRules!=null && mapSecDetailRenderRules.get(objSecDet.Id)!=null){
                                    boolean RulesResult = false;
                                    for(HexaBPM__Page_Navigation_Rule__c SDRendRule:mapSecDetailRenderRules.get(objSecDet.Id)){
                                        boolean eachRule = HexaBPM.PageFlowUtil.executeNavigationRules(SDRendRule.HexaBPM__Rule_Text_Condition__c,objSR);
                                        if(eachRule!=null && eachRule==true)
                                            RulesResult = true;
                                    }
                                    bRenderSecDetail = RulesResult;
                                }
                            }
                            if(bRenderSecDetail==true){
                                Component.Apex.CommandButton dycBtn = new Component.Apex.CommandButton();
                                dycBtn.value = objSecDet.HexaBPM__Component_Label__c;
                                dycBtn.style = 'min-width:70px;';
                                dycBtn.Disabled = objSecDet.HexaBPM__Disable__c;
                                if(objSecDet.HexaBPM__Commit_the_Record__c==false){
                                    dycBtn.onClick='DoAction("'+objSecDet.Id+'","'+objSecDet.HexaBPM__Ignore_Required_Fields__c+'");return false;';
                                }else if(objSecDet.HexaBPM__Commit_the_Record__c==true){
                                    dycBtn.onClick='SaveDetails();return false;';
                                }
                                PBtns.location = 'Top';
                                if (objSecDet.HexaBPM__Button_Position__c == 'left')
                                    dycBtn.styleClass = 'left';
                                else if (objSecDet.HexaBPM__Button_Position__c == 'right')
                                    dycBtn.styleClass = 'right';
                                PBtns.childComponents.add(dycBtn);
                            }
                        }
                    }
                }
            }
        }
        return Btnspb;
    }
    */
    /*
        Method Name :   getButtonAction
        Description :   Preparing the pagereference based on the button action.
    */
    /*
    global PageReference getButtonAction(string ActionId){
        string stringActionId = ActionId;
        string whatId = ''; 
        Pagereference pg;
        string strBaseUrl = System.Url.getSalesforceBaseURL().toExternalForm();
        boolean isManagedPackage = false;
        if(strBaseUrl.indexof('hexabpm.')>-1)
            isManagedPackage = true;
        try{
            if(stringActionId!=null && stringActionId!=''){
                boolean hasPGNavRule = false;
                for(HexaBPM__Page_Navigation_Rule__c objSecDtl:[select id,HexaBPM__Section_Detail__c from HexaBPM__Page_Navigation_Rule__c where HexaBPM__Section_Detail__c=:stringActionId limit 1]){
                    hasPGNavRule = true;
                }
                if(hasPGNavRule==true){
                    for(HexaBPM__Page_Navigation_Rule__c PGNRule:[select id,Name,HexaBPM__Rule_Text_Condition__c,(select id,HexaBPM__Is_Custom_Component__c,HexaBPM__Page__c,HexaBPM__Page__r.HexaBPM__Is_Custom_Component__c,HexaBPM__Page__r.HexaBPM__VF_Page_API_Name__c,HexaBPM__Page__r.HexaBPM__What_Id__c,HexaBPM__Page__r.HexaBPM__Page_Flow__c from HexaBPM__Page_Flow_Actions__r limit 100) from HexaBPM__Page_Navigation_Rule__c where HexaBPM__Section_Detail__c=:stringActionId]){
                        if(PGNRule!=null && PGNRule.HexaBPM__Rule_Text_Condition__c!=null && PGNRule.HexaBPM__Rule_Text_Condition__c!=''){
                            boolean BRRuleResult = HexaBPM.PageFlowUtil.executeNavigationRules(PGNRule.HexaBPM__Rule_Text_Condition__c,objSR);
                            if(BRRuleResult!=null && BRRuleResult==true && PGNRule.HexaBPM__Page_Flow_Actions__r!=null && PGNRule.HexaBPM__Page_Flow_Actions__r.size()>0){
                                for(HexaBPM__Page_Flow_Action__c PGAct:PGNRule.HexaBPM__Page_Flow_Actions__r){
                                    if(PGAct.HexaBPM__Page__c!=null && PGAct.HexaBPM__Page__r.HexaBPM__VF_Page_API_Name__c!=null){
                                        string PageName = PGAct.HexaBPM__Page__r.HexaBPM__VF_Page_API_Name__c;
                                        PageName = PageName.tolowercase();
                                        if(PageName.indexOf('hexabpm__')==-1 && isManagedPackage)
                                            strBaseUrl = strBaseUrl.replace('hexabpm.','c.');
                                        whatId = string.valueOf(objSR.get('Id'));
                                        if(whatId==null || (whatId!=null && whatId=='')){
                                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Please Save the Record to proceed.'));
                                            return null;
                                        }
                                        if(PGAct.HexaBPM__Page__r.HexaBPM__VF_Page_API_Name__c.indexof('?')>-1){
                                            pg = new PageReference(strBaseUrl+'/apex/'+PGAct.HexaBPM__Page__r.HexaBPM__VF_Page_API_Name__c+'&Id='+whatId+'&FlowId='+PGAct.HexaBPM__Page__r.HexaBPM__Page_Flow__c+'&PageId='+PGAct.HexaBPM__Page__c);
                                        }else{
                                            pg = new PageReference(strBaseUrl+'/apex/'+PGAct.HexaBPM__Page__r.HexaBPM__VF_Page_API_Name__c+'?Id='+whatId+'&FlowId='+PGAct.HexaBPM__Page__r.HexaBPM__Page_Flow__c+'&PageId='+PGAct.HexaBPM__Page__c);
                                        }
                                        pg.setRedirect(true);
                                        return pg;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }catch(Exception e){}
        return pg;
    }
    */
    /*
        Method Name :   getSideBarReference
        Description :   Preparing the pagereference when user clicks on the sidebar.
    */
    /*
    global pagereference getSideBarReference(string strSideBarPageId){
        Pagereference pg;
        if(strSideBarPageId!=null && strSideBarPageId!=''){
            string whatId;
            if(objSR!=null && objSR.get('Id')!=null)
                whatId = string.valueOf(objSR.get('Id'));
            HexaBPM__Page__c pgFlow = new HexaBPM__Page__c();
            
            string strBaseUrl = System.Url.getSalesforceBaseURL().toExternalForm();
            boolean isManagedPackage = false;
            if(strBaseUrl.indexof('hexabpm.')>-1)
                isManagedPackage = true;
            for(HexaBPM__Page__c page:[select Id,HexaBPM__VF_Page_API_Name__c,HexaBPM__What_Id__c,HexaBPM__Page_Flow__c,HexaBPM__Is_Custom_Component__c from HexaBPM__Page__c where Id=:strSideBarPageId]){
                pgFlow = page;
            }
            if(whatId==null || (whatId!=null && whatId=='')){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Please Save the Record to proceed.'));
                return null;
            }
            if(pgFlow.HexaBPM__VF_Page_API_Name__c!=null && pgFlow.HexaBPM__VF_Page_API_Name__c!=''){
                string PageName = pgFlow.HexaBPM__VF_Page_API_Name__c;
                PageName = PageName.tolowercase();
                if(PageName.indexOf('hexabpm__')==-1 && isManagedPackage)
                    strBaseUrl = strBaseUrl.replace('hexabpm.','c.');

                if(pgFlow.HexaBPM__VF_Page_API_Name__c.indexof('?')>-1)
                    pg = new PageReference(strBaseUrl+'/apex/'+pgFlow.HexaBPM__VF_Page_API_Name__c+'&Id='+whatId+'&FlowId='+pgFlow.HexaBPM__Page_Flow__c+'&PageId='+pgFlow.Id);
                else
                    pg = new PageReference(strBaseUrl+'/apex/'+pgFlow.HexaBPM__VF_Page_API_Name__c+'?Id='+whatId+'&FlowId='+pgFlow.HexaBPM__Page_Flow__c+'&PageId='+pgFlow.Id);                                  
                pg.setRedirect(true);
            }
            return pg;
        }
        return pg;
    }
    */
    
    /* Method to Convert the string to Decimal */
    global static decimal ConvertToDecimal(string FieldValue){
        decimal DecimalVal = null;
        if(FieldValue!=null && FieldValue!=''){
            FieldValue = FieldValue.trim();
            if(FieldValue.isNumeric())
                DecimalVal = decimal.valueof(FieldValue);
        }
        return DecimalVal;
    }
    /* Method to Convert the string to Date */
    global static date ConvertToDate(string FieldValue){
        Date DateVal = null;
        list<string> lstDtVals = new list<string>();
        if(FieldValue!=null && FieldValue!='' && FieldValue.indexOf('/')>-1){
            lstDtVals = FieldValue.split('/');
            if(lstDtVals != null && lstDtVals.size() == 3)
                DateVal = Date.newInstance(integer.valueOf(lstDtVals[2]), integer.valueOf(lstDtVals[1]), integer.valueOf(lstDtVals[0]));
        }
        return DateVal;
    }
    /* Method to Convert the string to DateTime */
    global static datetime ConvertToDateTime(string FieldValue){
        DateTime DateTimeVal = null;
        if(FieldValue!=null && FieldValue!=''){
            try{
                DateTimeVal = Datetime.parse(FieldValue);//'11/20/2010 12:00:00 PM'
            }catch(Exception e){
                DateTimeVal = null; 
            }
        }
        return DateTimeVal;
    }
    /* Method to Convert the string to Boolean */
    global static boolean ConvertToBoolean(string FieldValue){
        boolean BooleanValue = null;
        if(FieldValue!=null && FieldValue!='' && FieldValue.trim().tolowercase()=='true')
            BooleanValue = true;
        else if(FieldValue!=null && FieldValue!='' && FieldValue.trim().tolowercase()=='false')
            BooleanValue = false;
        return BooleanValue;
    }
}
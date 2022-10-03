@isTest
public with sharing class PageFlowControllerHelperTest {
    
    private static List<HexaBPM__Page__c> pageRecords;
    private static List<HexaBPM__Page_Flow__c> pageFlows;
    public static void init(){
        
        pageFlows = TestUtility.createPageFlow('WP_Female_Under_Father_Or_Husband_Sponsorship_New',1);
        
        pageRecords = TestUtility.createPageRecords(pageFlows);
    }
    
    @isTest static void test(){
        
        init();
        
        HexaBPM__Section__c section = new HexaBPM__Section__c(HexaBPM__Page__c=pageRecords[0].id);
        section.HexaBPM__Default_Rendering__c=false;
        section.HexaBPM__Section_Type__c='PageBlockSection';
        section.HexaBPM__Section_Description__c='PageBlockSection';
        insert section;
        
        HexaBPM__Section_Detail__c sec= new HexaBPM__Section_Detail__c();
        sec.HexaBPM__Section__c=section.id;
        sec.HexaBPM__Render_By_Default__c=false;
        insert sec;
        
        apexpages.currentPage().getParameters().put('PageId',pageRecords[0].id);
        //apexpages.currentPage().getParameters().put('Id',createdSrList[0].id);
        apexpages.currentPage().getParameters().put('FlowId',pageFlows[0].id);
        PageFlowControllerHelper t1= new PageFlowControllerHelper();
        
        HexaBPM__Page_Navigation_Rule__c objPgNavRule = new HexaBPM__Page_Navigation_Rule__c();
        objPgNavRule.HexaBPM__Rule_Name__c = 'Page Rule';
        objPgNavRule.HexaBPM__Page__c = pageRecords[0].id;
        objPgNavRule.HexaBPM__Section_Detail__c = sec.id;
        objPgNavRule.HexaBPM__Rule_Text_Condition__c='HexaBPM__Service_Request__c->Id#!=#null';  
        objPgNavRule.HexaBPM__Section__c=section.id;
        objPgNavRule.HexaBPM__Rule_Type__c='Render Rule';
        insert ObjPgNavRule;
        
        HexaBPM__Page_Flow_Condition__c ObjPgFlowCond = new HexaBPM__Page_Flow_Condition__c();
        ObjPgFlowCond.HexaBPM__Object_Name__c = 'HexaBPM__Service_Request__c';
        ObjPgFlowCond.HexaBPM__Field_Name__c = 'Id';
        ObjPgFlowCond.HexaBPM__Operator__c = '!='; 
        ObjPgFlowCond.HexaBPM__Value__c = 'null';
        ObjPgFlowCond.HexaBPM__Page_Navigation_Rule__c = ObjPgNavRule.id; 
        insert ObjPgFlowCond;
        
        HexaBPM__Page_Flow_Action__c ObjPgFlowAction = new HexaBPM__Page_Flow_Action__c();
        ObjPgFlowAction.HexaBPM__Page_Navigation_Rule__c = ObjPgNavRule.id;
        insert ObjPgFlowAction;
        
        t1.getFlowPageContent(pageFlows[0].id,pageRecords[0].id);
        
        PageFlowControllerHelper.parseEachCondition('10','=','10');
        PageFlowControllerHelper.parseEachCondition('10','>=','10');
        PageFlowControllerHelper.parseEachCondition('10','<=','10');
        PageFlowControllerHelper.parseEachCondition('10','>','10');
        PageFlowControllerHelper.parseEachCondition('10','<','10');
        PageFlowControllerHelper.parseEachCondition('10','!=','10');
        PageFlowControllerHelper.parseEachCondition('11','<','10');
    }
    
    @isTest static void test1(){
        
        init();
        
        HexaBPM__Section__c section = new HexaBPM__Section__c(HexaBPM__Page__c=pageRecords[0].id);
        section.HexaBPM__Default_Rendering__c=false;
        section.HexaBPM__Section_Type__c='PageBlockSection';
        section.HexaBPM__Section_Description__c='PageBlockSection';
        section.HexaBPM__layout__c='2';
        section.HexaBPM__Page__c =pageRecords[0].id;
        insert section;
        section.HexaBPM__Default_Rendering__c=true;
        update section;
        
        
        HexaBPM__Section_Detail__c sec= new HexaBPM__Section_Detail__c();
        sec.HexaBPM__Section__c=section.id;
        sec.HexaBPM__Component_Type__c='Input Field';
        sec.HexaBPM__Field_API_Name__c='first_name__c';
        sec.HexaBPM__Object_Name__c='HexaBPM__Service_Request__c';
        sec.HexaBPM__Default_Value__c='0';
        sec.HexaBPM__Mark_it_as_Required__c=true;
        sec.HexaBPM__Field_Description__c = 'desc';
        sec.HexaBPM__Render_By_Default__c=false;
        insert sec;
        
        sec= new HexaBPM__Section_Detail__c();
        sec.HexaBPM__Section__c=section.id;
        sec.HexaBPM__Component_Type__c='Input Field';
        sec.HexaBPM__Field_API_Name__c='last_name__c';
        sec.HexaBPM__Object_Name__c='HexaBPM__Service_Request__c';
        sec.HexaBPM__Default_Value__c='0';
        sec.HexaBPM__Mark_it_as_Required__c=true;
        sec.HexaBPM__Field_Description__c = 'desc';
        sec.HexaBPM__Render_By_Default__c=true;
        insert sec;
        
        pageRecords[0].HexaBPM__Is_Custom_Component__c = false;
        update pageRecords[0];
        
        update section;
        
        apexpages.currentPage().getParameters().put('PageId',pageRecords[0].id);
        //apexpages.currentPage().getParameters().put('Id',createdSrList[0].id);
        apexpages.currentPage().getParameters().put('FlowId',pageFlows[0].id);
        PageFlowControllerHelper t1= new PageFlowControllerHelper();
        System.assertEquals(123,PageFlowControllerHelper.ConvertToDecimal('123'));
        System.assertEquals(Date.newInstance(2015,02,01),PageFlowControllerHelper.ConvertToDate('01/02/2015'));
        System.assertEquals(false,PageFlowControllerHelper.ConvertToDateTime('10/10/2011')!=null);
        System.assertEquals(true,PageFlowControllerHelper.ConvertToBoolean('true'));
        System.assertEquals(false,PageFlowControllerHelper.ConvertToBoolean('false'));
        HexaBPM__Page_Navigation_Rule__c objPgNavRule = new HexaBPM__Page_Navigation_Rule__c();
        objPgNavRule.HexaBPM__Rule_Name__c = 'Page Rule';
        objPgNavRule.HexaBPM__Page__c = pageRecords[0].id;
        objPgNavRule.HexaBPM__Section_Detail__c = sec.id;
        objPgNavRule.HexaBPM__Rule_Text_Condition__c='HexaBPM__Service_Request__c->Id#!=#null';  
        objPgNavRule.HexaBPM__Section__c=section.id;
        objPgNavRule.HexaBPM__Rule_Type__c='Render Rule';
        insert ObjPgNavRule;
        
        HexaBPM__Page_Flow_Condition__c ObjPgFlowCond = new HexaBPM__Page_Flow_Condition__c();
        ObjPgFlowCond.HexaBPM__Object_Name__c = 'HexaBPM__Service_Request__c';
        ObjPgFlowCond.HexaBPM__Field_Name__c = 'Id';
        ObjPgFlowCond.HexaBPM__Operator__c = '!='; 
        ObjPgFlowCond.HexaBPM__Value__c = 'null';
        ObjPgFlowCond.HexaBPM__Page_Navigation_Rule__c = ObjPgNavRule.id; 
        insert ObjPgFlowCond;
        
        HexaBPM__Page_Flow_Action__c ObjPgFlowAction = new HexaBPM__Page_Flow_Action__c();
        ObjPgFlowAction.HexaBPM__Page_Navigation_Rule__c = ObjPgNavRule.id;
        insert ObjPgFlowAction;
        system.debug('#### pageflowid'+pageFlows[0].id);
        system.debug('#### pagerecordid'+pageRecords[0].id);
        t1.getFlowPageContent(pageFlows[0].id,pageRecords[0].id); 
        
        sec.HexaBPM__Component_Type__c='Blank Space';
        update sec;
        
        t1.getFlowPageContent(pageFlows[0].id,pageRecords[0].id); 
        
        sec.HexaBPM__Component_Type__c='Output Field';
        update sec;
        
        t1.getFlowPageContent(pageFlows[0].id,pageRecords[0].id); 
    }
    
    @isTest static void test2(){
        
        init();
        
        HexaBPM__Section__c section = new HexaBPM__Section__c(HexaBPM__Page__c=pageRecords[0].id);
        section.HexaBPM__Default_Rendering__c=false;
        section.HexaBPM__Section_Type__c='CommandButtonSection';
        section.HexaBPM__Section_Description__c='PageBlockSection';
        section.HexaBPM__layout__c='2';
        section.HexaBPM__Default_Rendering__c=true;
        insert section;
        
        
        HexaBPM__Section_Detail__c sec= new HexaBPM__Section_Detail__c();
        sec.HexaBPM__Section__c=section.id;
        sec.HexaBPM__Component_Type__c='Blank Space';
        sec.HexaBPM__Field_API_Name__c='first_name__c';
        sec.HexaBPM__Object_Name__c='HexaBPM__Service_Request__c';
        sec.HexaBPM__Default_Value__c='0';
        sec.HexaBPM__Mark_it_as_Required__c=true;
        sec.HexaBPM__Field_Description__c = 'desc';
        sec.HexaBPM__Render_By_Default__c=false;
        sec.HexaBPM__Button_Position__c  = 'left';
        insert sec;
        
        
        
        apexpages.currentPage().getParameters().put('PageId',pageRecords[0].id);
        //apexpages.currentPage().getParameters().put('Id',createdSrList[0].id);
        apexpages.currentPage().getParameters().put('FlowId',pageFlows[0].id);
        PageFlowControllerHelper t1= new PageFlowControllerHelper();
        
        HexaBPM__Page_Navigation_Rule__c objPgNavRule = new HexaBPM__Page_Navigation_Rule__c();
        objPgNavRule.HexaBPM__Rule_Name__c = 'Page Rule';
        objPgNavRule.HexaBPM__Page__c = pageRecords[0].id;
        objPgNavRule.HexaBPM__Section_Detail__c = sec.id;
        objPgNavRule.HexaBPM__Rule_Text_Condition__c='HexaBPM__Service_Request__c->Id#!=#null';  
        objPgNavRule.HexaBPM__Section__c=section.id;
        objPgNavRule.HexaBPM__Rule_Type__c='Render Rule';
        insert ObjPgNavRule;
        
        HexaBPM__Page_Flow_Condition__c ObjPgFlowCond = new HexaBPM__Page_Flow_Condition__c();
        ObjPgFlowCond.HexaBPM__Object_Name__c = 'HexaBPM__Service_Request__c';
        ObjPgFlowCond.HexaBPM__Field_Name__c = 'Id';
        ObjPgFlowCond.HexaBPM__Operator__c = '!='; 
        ObjPgFlowCond.HexaBPM__Value__c = 'null';
        ObjPgFlowCond.HexaBPM__Page_Navigation_Rule__c = ObjPgNavRule.id; 
        insert ObjPgFlowCond;
        
        HexaBPM__Page_Flow_Action__c ObjPgFlowAction = new HexaBPM__Page_Flow_Action__c();
        ObjPgFlowAction.HexaBPM__Page_Navigation_Rule__c = ObjPgNavRule.id;
        ObjPgFlowAction.HexaBPM__Page__c = pageRecords[0].id;
        system.debug('PF --> '+pageRecords[0].HexaBPM__Page_Flow__c);
        ObjPgFlowAction.HexaBPM__Page_Flow__c = pageFlows[0].id;
        insert ObjPgFlowAction;
        
        system.debug('#### pageflowid'+pageFlows[0].id);
        system.debug('#### pagerecordid'+pageRecords[0].id);
        t1.getFlowPageContent(pageFlows[0].id,pageRecords[0].id); 
        
        sec.HexaBPM__Component_Type__c='Blank Space';
        update sec;
        
        t1.getFlowPageContent(pageFlows[0].id,pageRecords[0].id); 
        
        sec.HexaBPM__Component_Type__c='Output Field';
        update sec;
        
        t1.getFlowPageContent(pageFlows[0].id,pageRecords[0].id); 
        Boolean b2 = PageFlowControllerHelper.parseConditions(true,true,'AND');
        Boolean b3 = PageFlowControllerHelper.parseConditions(true,false,'OR');
        system.debug('last part');
        pageRecords[0].HexaBPM__Render_by_Default__c = false;
        pageRecords[0].HexaBPM__VF_Page_API_Name__c = 'Test_Page?';
        update pageRecords[0];
        set<string> stringSet = PageFlowControllerHelper.FetchObjectFields(pageFlows[0].id,'HexaBPM__Service_Request__c');
        section.HexaBPM__Default_Rendering__c=false;
        update section;
        sec.HexaBPM__Button_Position__c  = 'right';
        sec.HexaBPM__Commit_the_Record__c = true;
        update sec;
        
    }
    
}
@isTest
public with sharing class PageFlowControllerTest {
    
    private static List<Account> createdAccountList;
    private static List<HexaBPM__Service_Request__c> createdSrList;
    private static List<HexaBPM__Page__c> pageRecords;
    private static List<HexaBPM__Page_Flow__c> pageFlows;
    public static List<Contact> con;
    //private static Id recordTypeId;
    public static void init(){ 
        //recordTypeId = Schema.SobjectType.HexaBPM__Service_Request__c.getRecordTypeInfosByName().get('New Work Permit – Full Time Non Sponsored Employee').getRecordTypeID();
        createdSrList = new list<HexaBPM__Service_Request__c>();
        createdSrList = TestUtility.createSR(5,'New_Work_Permit_Full_Time_Non_Sponsored_Employee');
        insert createdSrList;
    }
    @isTest 
    static void test(){
        
        init();
        pageFlows = TestUtility.createPageFlow('Initial_Approval',1);
        pageRecords = TestUtility.createPageRecords(pageFlows);
        
        apexpages.currentPage().getParameters().put('PageId',pageRecords[0].id);
        apexpages.currentPage().getParameters().put('Id',createdSrList[0].id);
        apexpages.currentPage().getParameters().put('FlowId',pageFlows[0].id);
        PageFlowController t1= new PageFlowController();
        t1.stringActionId = pageRecords[0].id;
        t1.DynamicButtonAction();
        t1.getDyncPgMainPB();
        t1.CommitRecord();
        t1.RePrepareSection();
        t1.CancelSR();
    }
    

    @isTest 
    static void test11(){
        
        init();
        
        pageFlows=TestUtility.createPageFlow('WP_Female_Under_Father_Or_Husband_Sponsorship_New',5);
        pageRecords=TestUtility.createPageRecords(pageFlows);
        apexpages.currentPage().getParameters().put('Id',createdSrList[0].id);
        apexpages.currentPage().getParameters().put('FlowId',pageFlows[0].id);
        
        PageFlowController t1= new PageFlowController();
    }
    
    
    
}
/**************************************************************************************************
* Name               : TicketManagementControllerTest                                             *
* Description        : This is a test class for TicketManagementController.                       *
* Created Date       : 09/01/2017                                                                 *
* Created By         : NSI                                                                        *
* Last Modified Date : 09/01/2017                                                                 *
* Last Modified By   :                                                                            *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE              COMMENTS                                              *
* 1.0         NSI         09/01/2017        Initial Draft                                         *
**************************************************************************************************/
@isTest
private class TicketManagementControllerTest {

	static Issue__c createIssueRecord;
    static Related_Comment__c rcObject;
    
    private static void init(){
        List<Issue__c> createIssueList = new List<Issue__c>();
        createIssueRecord = new Issue__c();
        createIssueRecord.Status__c = 'New';
        createIssueRecord.Issue_Summary__c = 'Test Issue';
        createIssueRecord.Issue_Description__c = 'Test Issue';
        createIssueRecord.Severity__c = 'High';
        createIssueRecord.Expected_End_Date__c = system.today();
        createIssueRecord.Assigned_To__c = 'Test';
        createIssueRecord.Milestone__c = 'UAT';
        createIssueRecord.Ticket_Type__c = 'Enhancement';
        createIssueList.add(createIssueRecord);
        
        createIssueRecord = new Issue__c();
        createIssueRecord.Status__c = 'New'; 
        createIssueRecord.Issue_Summary__c = 'Test Issue';
        createIssueRecord.Issue_Description__c = 'Test Issue';
        createIssueRecord.Severity__c = 'High';
        createIssueRecord.Expected_End_Date__c = system.today();
        createIssueRecord.Assigned_To__c = 'Test';
        createIssueRecord.Milestone__c = 'UAT';
        createIssueRecord.Ticket_Type__c = 'Enhancement';
        createIssueList.add(createIssueRecord);
        
        createIssueRecord = new Issue__c();
        createIssueRecord.Status__c = 'New';
        createIssueRecord.Issue_Summary__c = 'Test Issue';
        createIssueRecord.Issue_Description__c = 'Test Issue';
        createIssueRecord.Severity__c = 'High';
        createIssueRecord.Milestone__c = 'UAT';
        createIssueRecord.Ticket_Type__c = 'Enhancement';
        createIssueRecord.Expected_End_Date__c = system.today();
        createIssueList.add(createIssueRecord);
        insert createIssueList;
        
        TicketManagementTeam__c tmtObject = new TicketManagementTeam__c();
        tmtObject.Name = 'Test';
        tmtObject.Email__c = 'test@test.com';
        insert tmtObject;
    }
    
    static testMethod void testTickets() {
        init();
        PageReference pageRef = Page.TicketManagement;
        System.Test.setCurrentPageReference(pageRef);
        TicketManagementController controllerObject = new TicketManagementController();  
        controllerObject.throwError('test');
    }
    
    static testMethod void testAssignedTo() {
        init();
        PageReference pageRef = Page.TicketManagement;
        System.Test.setCurrentPageReference(pageRef);
        TicketManagementController controllerObject = new TicketManagementController();  
        controllerObject.getAssignedTos();
    }
    
    static testMethod void testGetFilteredTickets() {
        init();
        TicketManagementController controllerObject = new TicketManagementController();  
        controllerObject.selectedView = 'All Users';
        Issue__c createIssueRecord = new Issue__c();
        createIssueRecord.Status__c = 'New';
        createIssueRecord.Issue_Summary__c = 'Test Issue';
        createIssueRecord.Issue_Description__c = 'Test Issue';
        createIssueRecord.Severity__c = 'High';
        createIssueRecord.Expected_End_Date__c = system.today();
        createIssueRecord.Assigned_To__c = 'Test';
        createIssueRecord.Milestone__c = 'UAT';
        createIssueRecord.Ticket_Type__c = 'Enhancement';
        controllerObject.objIssue = createIssueRecord;
        controllerObject.getFilteredTickets();
    }
}// End of class.
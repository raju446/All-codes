/**************************************************************************************************
* Name               : TicketDetailsControllerTest                                                *
* Description        : This is a test class for TicketDetailsController.                          *
* Created Date       : 09/01/2017                                                                 *
* Created By         : NSI                                                                        *
* Last Modified Date : 09/01/2017                                                                 *
* Last Modified By   :                                                                            *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE              COMMENTS                                              *
* 1.0         NSI         09/01/2017        Initial Draft                                         *
**************************************************************************************************/
@isTest
private class TicketDetailsControllerTest {
    static Issue__c createIssueRecord;
    static Related_Comment__c rcObject;
    
    private static void init(){
        createIssueRecord = new Issue__c();
        createIssueRecord.Status__c = 'New';
        createIssueRecord.Issue_Summary__c = 'Test Issue';
        createIssueRecord.Issue_Description__c = 'Test Issue';
        createIssueRecord.Severity__c = 'High';
        createIssueRecord.Expected_End_Date__c = system.today();
        createIssueRecord.Assigned_To__c = 'Test';
        insert createIssueRecord;
        
        TicketManagementTeam__c tmtObject = new TicketManagementTeam__c();
        tmtObject.Name = 'Test';
        tmtObject.Email__c = 'test@test.com';
        insert tmtObject;
        
        rcObject = new Related_Comment__c();
        rcObject.Comment_Description__c = 'Test';
        rcObject.Related_Ticket__c = createIssueRecord.Id;
        insert rcObject;
        
        Attachment newAttachment = new Attachment();
        newAttachment.ParentId = createIssueRecord.Id;
        newAttachment.Body = Blob.valueOf('Test');
        newAttachment.Name = 'Test';
        newAttachment.contentType = '.txt';
        insert newAttachment;
    }
    
    static testMethod void testWithoutTicket() {
        init();
        PageReference pageRef = Page.TicketDetails;
        System.Test.setCurrentPageReference(pageRef);
        TicketDetailsController controllerObject = new TicketDetailsController();  
        controllerObject.throwError('test');
    }
    
    static testMethod void testTicketPositive() {
        init();
        PageReference pageRef = Page.TicketDetails;
        System.Test.setCurrentPageReference(pageRef);
        System.currentPageReference().getParameters().put('tid', createIssueRecord.Id);
        TicketDetailsController controllerObject = new TicketDetailsController();  
        controllerObject.newComment.Comment_Description__c = 'Test';
        controllerObject.selectedAssinger = 'Test';
        controllerObject.saveNote();
        controllerObject.getAssignedTos();
        controllerObject.throwError('Test');
    }
    
    static testMethod void testTicketWithoutNotes() {
        init();
        delete rcObject;
        PageReference pageRef = Page.TicketDetails;
        System.Test.setCurrentPageReference(pageRef);
        System.currentPageReference().getParameters().put('tid', createIssueRecord.Id);
        TicketDetailsController controllerObject = new TicketDetailsController();  
    }
    
     static testMethod void testTicketWithoutAssignedTo() {
        init();
        PageReference pageRef = Page.TicketDetails;
        System.Test.setCurrentPageReference(pageRef);
        System.currentPageReference().getParameters().put('tid', createIssueRecord.Id);
        TicketDetailsController controllerObject = new TicketDetailsController();  
        controllerObject.selectedAssinger = '';
        controllerObject.saveNote(); 
    }
}// End of class.
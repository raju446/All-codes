/**************************************************************************************************
* Name               : TicketDetailsController                                                    *
* Description        : This is a controller class for ticket details page. Has below function     *
*                       - Displays all the selected ticket's details.                             *
*                       - Related Comments.                                                       *
*                       - Related Files.                                                          *
*                       - Related History.                                                        *
*                       - Add Files to the ticket.                                                *
*                       - Add Comments to the ticket.                                             *
*                       - Update assigned to and status of the tickets.                           *
* Created Date       : 09/01/2017                                                                 *
* Created By         : NSI                                                                        *
* Last Modified Date : 09/01/2017                                                                 *
* Last Modified By   :                                                                            *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE              COMMENTS                                              *
* 1.0         NSI         09/01/2017        Initial Draft                                         *
**************************************************************************************************/
public class TicketDetailsController {
	
	public Boolean showDetails {get; set;}
	public Boolean showNotes {get; set;}
	public Boolean showFiles {get; set;}
	public String selectedAssinger {get; set;}
	public Related_Comment__c newComment {get; set;}
	public List<Related_Comment__c> selectedBugRelatedNotes {get; set;}
	public List<NoteAndAttachment> selectedTicketRelatedFiles {get; set;}
	public Issue__c selectedBugRecord {get; set;}
	private String ticketId; 
	private Map<String, Issue__c> ticketsMap;
	
	/*********************************************************************************************
    * @Description : Method to initialize variables.                                             *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
	private void init(){
		showDetails = false;
		showNotes = false;
		showFiles = false; 
		newComment = new Related_Comment__c();
	}
	
	/*********************************************************************************************
    * @Description : StandardController.                                                         *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
	public TicketDetailsController(){ 
		init();
		try{
			ticketId = ApexPages.currentPage().getParameters().get('tid');	
			if(String.isNotBlank(ticketId)){
				ticketsMap = getBugsList(ticketId);	
				showDetails = true;	
				if(ticketsMap != null && !ticketsMap.isEmpty() && ticketsMap.containsKey(ticketId)){
					selectedBugRecord = ticketsMap.get(ticketId);
					if(String.isNotBlank(selectedBugRecord.Assigned_To__c)){
					    selectedAssinger = selectedBugRecord.Assigned_To__c;
					}
					if(!selectedBugRecord.Related_Comments__r.isEmpty()){
						showNotes = true;
						selectedBugRelatedNotes = new List<Related_Comment__c>(selectedBugRecord.Related_Comments__r);
					}else{
						selectedBugRelatedNotes = new List<Related_Comment__c>();
					}
					
					if(!selectedBugRecord.NotesAndAttachments.isEmpty()){
						showFiles = true;
						selectedTicketRelatedFiles = new List<NoteAndAttachment>(selectedBugRecord.NotesAndAttachments);
					}else{
						selectedTicketRelatedFiles = new List<NoteAndAttachment>();
					}
				}
			}else{
				throwError('Ticket record not available.');	
			}
		}catch(Exception ex){
			throwError('Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
		}
	}  
	
	/*********************************************************************************************
    * @Description : Saving Note nad updating bug details.                                       *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
	public pagereference saveNote(){
		pagereference pg;
		try{
			ticketId = ApexPages.currentPage().getParameters().get('tid');	
			Map<String, TicketManagementTeam__c> ticketManagementTeamMap = TicketManagementTeam__c.getAll();
			if(String.isNotBlank(ticketId) && String.isNotBlank(newComment.Comment_Description__c)){
				Related_Comment__c insertNote = new Related_Comment__c();
				insertNote.Related_Ticket__c = ticketId;
				insertNote.Comment_Description__c = newComment.Comment_Description__c;
				insert insertNote;	
				for(Related_Comment__c thisComment : [SELECT Id, Name, CreatedById, CreatedBy.Name, CreatedDate, 
																   Comment_Description__c, Related_Ticket__c 
															FROM Related_Comment__c
															WHERE Id =: insertNote.Id]){
					selectedBugRelatedNotes.add(thisComment);	
					break;
				}
				newComment = new Related_Comment__c();
				showNotes = true;	
			}
			selectedBugRecord.Assigned_To__c = selectedAssinger;
			if(String.isNotBlank(selectedAssinger) && ticketManagementTeamMap != null && 
			   !ticketManagementTeamMap.isEmpty() && 
			   ticketManagementTeamMap.containsKey(selectedAssinger) && 
			   ticketManagementTeamMap.get(selectedAssinger) != null){
				selectedBugRecord.Assigned_To_Email__c = ticketManagementTeamMap.get(selectedAssinger).Email__c;
			}else{
			    selectedBugRecord.Assigned_To_Email__c = '';    
			}
			update selectedBugRecord;
			pg = new pagereference('/apex/TicketManagement');
			pg.setredirect(true);
		}catch(Exception ex){
			throwError('Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
		}
		return pg;
	}
	
	/*********************************************************************************************
    * @Description : Handle Exception and show an error message on page.                         *
    * @Params      : String                                                                      *
    * @Return      : void                                                                        *
    *********************************************************************************************/
	public List<SelectOption> getAssignedTos(){
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', '--None--'));
		for(TicketManagementTeam__c thisUser : TicketManagementTeam__c.getAll().Values()){
			options.add(new SelectOption(thisUser.Name, thisUser.Name));
		}             
		return options;
	}
	
	/*********************************************************************************************
    * @Description : Method to get selected bug details.                                         *
    * @Params      : String                                                                      *
    * @Return      : Map<String, Issue__c>                                                       *
    *********************************************************************************************/
	public Map<String, Issue__c> getBugsList(String ticketId){ 
		Map<String, Issue__c> ticketsMap = new Map<String, Issue__c>();
		for(Issue__c thisTicket : [SELECT Id, Name, Assigned_To__c, Severity__c, Assigned_To_Email__c,
								          Status__c, Completed_Date__c,Approved_By_Client__c,CreatedDate, LastModifiedDate, 
								          CreatedById, CreatedBy.Name, Issue_Description__c, 
								          Expected_End_Date__c, Issue_Summary__c, Milestone__c,Type__c,
		                                  (SELECT Id, Name, CreatedById, CreatedBy.Name, CreatedDate, 
		                                          Comment_Description__c, Related_Ticket__c 
                                           FROM Related_Comments__r),
                                          (SELECT Id, Title, CreatedBy.Name FROM NotesAndAttachments WHERE IsNote = false) 
 				                  FROM Issue__c 
 								  ORDER BY Name ASC]){
			ticketsMap.put(thisTicket.Id, thisTicket);
		}
		return ticketsMap;
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
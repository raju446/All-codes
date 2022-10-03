/*********************************************************
    *   Author      :   Durga Prasad
    *   Company     :   PwC
    *   Date        :   19-Aug-2018
    *   Description :   Controller to show the Private Notes
 *********************************************************/
public without sharing class PrivateNotesController {
	public list<PrivateNotes> lstNotes{get;set;}
	public list<Note__c> lstPrivateNotes{get;set;}
	public string LeadId{get;set;}
    public PrivateNotesController(ApexPages.StandardController controller){
    	LeadId = apexpages.currentPage().getParameters().get('Id');
    	lstNotes = new list<PrivateNotes>();
    	lstPrivateNotes = new list<Note__c>();
    	if(LeadId!=null){
    		// and OwnerId!=:userinfo.getUserId()
    		for(Note__c nt:[Select Name,Share_Note_With__c,Lead__c,CreatedBy.Name,LastModifiedBy.Name,CreatedDate,LastModifiedDate from Note__c where Lead__c=:LeadId and Share_Note_With__c='None']){
    			PrivateNotes objNote = new PrivateNotes();
    			objNote.NoteRef = nt.Name;
    			objNote.CreatedBy = nt.CreatedBy.Name;
    			objNote.CreatedDate = nt.CreatedDate;
    			objNote.LastModifiedDate = nt.LastModifiedDate;
    			lstNotes.add(objNote);
    			lstPrivateNotes.add(nt);
    		}
    	}
    }
    public class PrivateNotes{
    	public string NoteRef{get;set;}
    	public string CreatedBy{get;set;}
    	public Datetime CreatedDate{get;set;}
    	public Datetime LastModifiedDate{get;set;}
    }
}
/**
* The UnSelectPrimaryLead Class is invoked from the Process Builder - "Update Primary Contact on Lead Entity V3"
* This class helps to uncheck the Primary__c Field to "false" whenever the user makes any lead contact as "Primary" 
* Acts like a radio button feature [Only one lead contact can be made as "Primary"
*
* @author  
* @version 1.0
* @date    08-08-2018 
*/
public class UnSelectPrimaryLead{
    @InvocableMethod(label='Unselect Primary lead checkbox' description='Unselect Primary lead checkbox on other Lead Contacts')
    public static void updateLead(List<Id> leadIds){
    
        Set<Id> leadEntityIds = new Set<Id>();
        for(Lead objLead : [SELECT Id, Related_Lead_Entity__c FROM Lead WHERE Id = :leadIds]){
            if(objLead.Related_Lead_Entity__c != null){
                leadEntityIds.add(objLead.Related_Lead_Entity__c);
            }
        }
        
        List<Lead> updateLeadList = new List<Lead>();
        for(Lead objLead : [SELECT Id, Related_Lead_Entity__c, Primary__c FROM Lead WHERE Related_Lead_Entity__c = :leadEntityIds AND Id NOT IN :leadIds AND  Primary__c  = true]){
            objLead.Primary__c = false;
            updateLeadList.add(objLead);
        }
        
        if(!updateLeadList.isEmpty()){
            update updateLeadList;
        }
    }
}
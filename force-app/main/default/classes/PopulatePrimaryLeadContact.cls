public class PopulatePrimaryLeadContact{
    @InvocableMethod(label='Populate Primary Lead Contact' description='Populates Primary Lead Contact on Create of lead Entity')
    public static void updateLead(List<Id> leadIds){
        Map<Id,Id> leadEntityContactMap = new Map<Id,Id>();
        for(Lead objLead : [SELECT Id, Related_Lead_Entity__c FROM Lead WHERE Related_Lead_Entity__c = :leadIds]){
            leadEntityContactMap.put(objLead.Related_Lead_Entity__c,objLead.Id);
        }
        
        List<Lead> leadEntityList = new List<Lead>();
        for(Lead objLead : [SELECT Id, Primary_Lead_Contact__c FROM Lead WHERE Id IN :leadIds]){
            if(leadEntityContactMap.containskey(objLead.Id)){
                objLead.Primary_Lead_Contact__c = leadEntityContactMap.get(objLead.Id);
                leadEntityList.add(objLead);
            }
        }
        
        if(!leadEntityList.isEmpty()){
            update leadEntityList;
        }
    }
}
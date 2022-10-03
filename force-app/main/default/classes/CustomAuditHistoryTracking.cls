/*
    Author      : Yogesh Mahajan
    Date        : 18-Aug-2019
    Description : It is used as helper to track log text field in audit history (store old and new value in custom object)
    --------------------------------------------------------------------------------------
*/
public class CustomAuditHistoryTracking {
	/*
        Method Name :   addAuditHistoryDetails
        Description :   Method to store log text area audit history.
    
    public static void addAuditHistoryDetails(String objectAPIName, Map<Id, sObject> mapOldvalues, List<sObject> listNewValues) {
        try {
            // fetch metadata for audit field details
            List<Audit_History_Field_Detail__mdt> listAuditHistoryFieldDetails = new List<Audit_History_Field_Detail__mdt>();
            listAuditHistoryFieldDetails = [SELECT Id, Field_API_Name__c, Relationship_API_Name__c FROM Audit_History_Field_Detail__mdt WHERE Object_API_Name__c =: objectAPIName AND Is_Active__c = true AND Field_API_Name__c <> null];
            List<Audit_History__c> listNewAuditHistory = new List<Audit_History__c>();
            Audit_History__c objAuditHistory;
            String oldval , newVal;
            
            for (sObject sObjectValue : listNewValues) {
                for(Audit_History_Field_Detail__mdt objField : listAuditHistoryFieldDetails) {
                    oldVal = '';
                    newVal = '';
                    newVal = (String) sObjectValue.get(objField.Field_API_Name__c);
                    oldVal = (String)(mapOldvalues.get((Id)sObjectValue.get('Id'))).get(objField.Field_API_Name__c);
                    if(newVal <> oldval) {
                        objAuditHistory = new Audit_History__c();
                        objAuditHistory.Old_Value__c = oldVal;
                        objAuditHistory.New_Value__c = newVal;
                        objAuditHistory.put(objField.Relationship_API_Name__c, (Id)sObjectValue.get('Id'));
                    }
                }
            } 
        } catch (Exception ex) {
            system.debug('----->'+ex.getMessage());
        }
        
    }
    
    */
    /*
        Method Name :   addSRPriceItemAuditHistory
        Description :   Method to store Oracle_Response__c field audit history.
	*/
    public static void addSRPriceItemAuditHistory(Map<Id, HexaBPM__SR_Price_Item__c> mapOldvalues, List<HexaBPM__SR_Price_Item__c> listNewValues) {
        try {
            List<Audit_History__c> listNewAuditHistory = new List<Audit_History__c>();
            Audit_History__c objAuditHistory;
            for (HexaBPM__SR_Price_Item__c objSRPriceItem : listNewValues) {
                if(objSRPriceItem.Oracle_Response__c <> mapOldvalues.get(objSRPriceItem.id).Oracle_Response__c) {
                    objAuditHistory = new Audit_History__c();
                    objAuditHistory.Old_Value__c = mapOldvalues.get(objSRPriceItem.id).Oracle_Response__c;
                    objAuditHistory.New_Value__c = objSRPriceItem.Oracle_Response__c;
                    objAuditHistory.SR_Price_Item__c = objSRPriceItem.id;
                    listNewAuditHistory.add(objAuditHistory);
                }
            } 
            if(listNewAuditHistory <> null && listNewAuditHistory.size() > 0) {
                insert listNewAuditHistory;
            }
        } catch (Exception ex) {
            system.debug('----->'+ex.getMessage());
        }
        
    }
}
/*
    Author      :   Yogesh Mahajan 
    Class Name  :   LEX_Helper
    Description :   It is used helper for ligthing components
    Date        :   02/20/2019       
*/
public class LEX_Helper  {
    /*
    Name : getPicklistValues
    Description : getDescribe to fetch picklist data 
    */
    public static List<PicklistValueWrapper> getPicklistValues(String objectAPIname, String fieldAPIname, Boolean nullRequired) {
        List<PicklistValueWrapper> optionlist = new List<PicklistValueWrapper>();
        PicklistValueWrapper objPicklistValueWrapper;
        Map<String, String> selectOptionMap = new Map<String, String>();
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get(objectAPIname.toLowerCase()).getDescribe().fields.getMap(); 
        
        List<Schema.PicklistEntry> picklistValues = field_map.get(fieldAPIname).getDescribe().getPickListValues();
        
        if(nullRequired == true){
            objPicklistValueWrapper = new PicklistValueWrapper();
            objPicklistValueWrapper.picklistVal = 'None';
            objPicklistValueWrapper.picklistLabel = '--None--';
            optionlist.add(objPicklistValueWrapper);
        }
        
        for (Schema.PicklistEntry pv : picklistValues) {
            objPicklistValueWrapper = new PicklistValueWrapper();
            objPicklistValueWrapper.picklistVal = pv.getValue();
            objPicklistValueWrapper.picklistLabel = pv.getLabel();
            
            optionlist.add(objPicklistValueWrapper);
        }
        
        return optionlist;
    }//end getPicklistValues()
    
    /************************************************************************************
    Name : Wrapper for picklist
    ************************************************************************************/
    public class PicklistValueWrapper {
        @AuraEnabled public String picklistVal {get;set;}
        @AuraEnabled public String picklistLabel {get;set;}
    }//end ReceiptsWrapper 
}
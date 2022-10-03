/**
 * @File Name          : AddressTriggerHandler.cls
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 3/30/2020, 6:34:23 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/30/2020   Jayanta Karmakar     Initial Version
**/
public class AddressTriggerHandler{
    public static void handleBI(List<Address__c> newList){
        populateCountry(newList,null);
    }
    
    public static void handleBU(List<Address__c> newList, Map<Id,Address__c> oldMap){
        populateCountry(newList,oldMap);
    }
    
    
    public static void populateCountry(List<Address__c> newList, Map<Id,Address__c> oldMap){
        Map<String,String> ISOvsNameMap = new Map<String,String>();
        Map<String,String> NamevsISOMap = new Map<String,String>();
        
        for(LEX_Helper.PicklistValueWrapper eachVal : LEX_Helper.getPicklistValues('Address__c', 'Country_ALPHA_3__c', false)){
            NamevsISOMap.put(eachVal.picklistLabel,eachVal.picklistVal);
            ISOvsNameMap.put(eachVal.picklistVal,eachVal.picklistLabel);
        }

        if(oldMap == null){
            System.debug('In insert condition');
            for(Address__c eachAddress : newList){
                if(eachAddress.Country__c != null){
                    if(NamevsISOMap.containskey(eachAddress.Country__c.trim())){
                        eachAddress.Country_ALPHA_3__c = NamevsISOMap.get(eachAddress.Country__c.trim());
                    }
                } else if(eachAddress.Country_ALPHA_3__c != null ){
                    if(ISOvsNameMap.containskey(eachAddress.Country_ALPHA_3__c)){
                        eachAddress.Country__c = ISOvsNameMap.get(eachAddress.Country_ALPHA_3__c);
                    }
                }
            }
        } else {
            System.debug('In Update Condition');
            for(Address__c eachAddress : newList){
                system.debug(eachAddress.Country__c != oldMap.get(eachAddress.Id).Country__c);
                System.debug('---->'+ eachAddress.Country__c);
                System.debug('---->'+ oldMap.get(eachAddress.Id).Country__c);
                system.debug(eachAddress.Country_ALPHA_3__c != oldMap.get(eachAddress.Id).Country_ALPHA_3__c);
                if(eachAddress.Country__c != oldMap.get(eachAddress.Id).Country__c || (eachAddress.Country__c != null && oldMap.get(eachAddress.Id).Country_ALPHA_3__c == null)){
                    if(NamevsISOMap.containskey(eachAddress.Country__c.trim())){
                        eachAddress.Country_ALPHA_3__c = NamevsISOMap.get(eachAddress.Country__c.trim());
                    }
                } else if(eachAddress.Country_ALPHA_3__c != oldMap.get(eachAddress.Id).Country_ALPHA_3__c || (eachAddress.Country_ALPHA_3__c != null && oldMap.get(eachAddress.Id).Country__c == null)){
                    if(ISOvsNameMap.containskey(eachAddress.Country_ALPHA_3__c)){
                        eachAddress.Country__c = ISOvsNameMap.get(eachAddress.Country_ALPHA_3__c);
                    }
                }
            }
        }
    }
}
/*********************LeadTriggerHandler********************/
/***
***Author:  Azmath
***Date:    29-Apr-2019
***Purpose: LeadTriggerHelper used for Lead Object */
/***Version History
 * Prachi   21-Sept-2021   Bypass the phone mapping for FSRA Leads
**/

public without sharing class LeadTriggerHelper 
{
	public static Boolean isFirstTime = true;
    public static void updatePrimaryLeadContactinfo(list<Lead> newLeads, map<Id,Lead> TriggerOldMap)
    {
    	map<id,Lead> LeadEntityMap = new map<id,Lead>();
    	
    	for(Lead lead : newLeads)
    	{
    		Lead oldLeamap = TriggerOldMap.get(lead.id);
    		if(lead.Record_Type_Name__c == 'Lead_Entity' && lead.isConverted == false && (oldLeamap.Salutation != lead.Salutation ||
    													     oldLeamap.LastName != lead.LastName ||
    													     oldLeamap.FirstName != lead.FirstName ||
    													     oldLeamap.Role__c != lead.Role__c ||
    													     oldLeamap.Other_Position__c != lead.Other_Position__c ||
    													     oldLeamap.Key_Account__c != lead.Key_Account__c ||
    													     oldLeamap.Received_Consent__c != lead.Received_Consent__c ||
    													     oldLeamap.Received_Consent_Date__c != lead.Received_Consent_Date__c ||
    													     oldLeamap.Contact_Preference__c != lead.Contact_Preference__c ||
    													     oldLeamap.MobilePhone != lead.MobilePhone ||
    													     oldLeamap.Email != lead.Email ||
    													     oldLeamap.Lead_Country__c != lead.Lead_Country__c ||
    													     oldLeamap.State_Province__c != lead.State_Province__c ||
    													     oldLeamap.Lead_City__c != lead.Lead_City__c ||
    													     oldLeamap.Lead_Zip_Postal_Code__c != lead.Lead_Zip_Postal_Code__c ||
    													     oldLeamap.Lead_Street__c != lead.Lead_Street__c ||
    													     oldLeamap.Channel_Partner__c != lead.Channel_Partner__c ||
    													     oldLeamap.LeadSource != lead.LeadSource ||
    													     oldLeamap.ADGM_Referrer__c != lead.ADGM_Referrer__c ||
    													     oldLeamap.Phone != lead.Phone
    													 )
    			)
    		{
    			LeadEntityMap.put(lead.id,Lead);
    		}
    	}
    	
    	if(!LeadEntityMap.isEmpty())
    	{
    		list<Lead> LeadContactsList = new list<Lead>();
    		for(Lead lead : [SELECT id,Related_Lead_Entity__c FROM Lead WHERE Related_Lead_Entity__c IN:LeadEntityMap.keyset() 
    				and Primary__c=true and Record_Type_Name__c='Lead_Contact'])
    		{
    			Lead LE = LeadEntityMap.get(lead.Related_Lead_Entity__c);
    			
    			lead.ADGM_Referrer__c 			= LE.ADGM_Referrer__c;
    			lead.Channel_Partner__c 		= LE.Channel_Partner__c;
    			lead.Contact_Preference__c 		= LE.Contact_Preference__c;
    			lead.Email 						= LE.Email;
    			lead.Event_Name__c 				= LE.Event_Name__c;
    			lead.Event_Name_Lookup__c 		= LE.Event_Name_Lookup__c;
    			lead.FirstName 					= LE.FirstName;
    			lead.LastName 					= LE.LastName;
    			lead.LeadSource 				= LE.LeadSource;
    			lead.Lead_City__c 				= LE.Lead_City__c;
    			lead.Lead_Country__c 			= LE.Lead_Country__c;
    			lead.Lead_Street__c 			= LE.Lead_Street__c;
    			lead.Lead_Zip_Postal_Code__c 	= LE.Lead_Zip_Postal_Code__c;
    			lead.Other_Position__c 			= LE.Other_Position__c;
    			lead.Phone	 					= LE.Phone;
    			lead.MobilePhone 				= LE.MobilePhone;
    			lead.Received_Consent_Date__c 	= LE.Received_Consent_Date__c;
    			lead.Received_Consent__c 		= LE.Received_Consent__c;
    			lead.Role__c 					= LE.Role__c;
    			lead.Salutation 				= LE.Salutation;
    			lead.State_Province__c 			= LE.State_Province__c;
    			lead.Key_Account__c 			= LE.Key_Account__c;
    			
    			LeadContactsList.add(lead);
    		}
    		if(!LeadContactsList.isEmpty()){
    			update LeadContactsList;
    		}
    	}
    }
    
    public static void updateLeadEntityPrimaryContactInfo(list<Lead> newLeads, map<Id,Lead> TriggerOldMap)
    {
    	set<id> LeadEntityIds = new set<id>();
    	map<id,Lead> leadContacts = new map<id,Lead>();
    	set<id> primaryLeadContacts = new set<id>();
    	for(Lead lead : newLeads)
    	{
    		//Lead oldLeadContactmap = TriggerOldMap.get(lead.id);
    		system.debug('====record type=='+lead.Record_Type_Name__c+'====='+lead.Related_Lead_Entity__c);
    		if(lead.Record_Type_Name__c == 'Lead_Contact' && lead.Related_Lead_Entity__c != null && lead.Primary__c == true && lead.From_FSRA__c == false)
    		{
    			LeadEntityIds.add(lead.Related_Lead_Entity__c);
    			leadContacts.put(lead.Related_Lead_Entity__c, lead);
    			primaryLeadContacts.add(lead.id);
    		}
    	}
    	
    	if(!LeadEntityIds.isEmpty())
    	{
    		list<Lead> leadEntitylist = new list<Lead>();
    		for(Lead lead : [SELECT id from Lead where ID IN:LeadEntityIds and isConverted = false])
    		{
    			Lead LC = leadContacts.get(Lead.id);
    			//lead.ADGM_Referrer__c 						= LC.ADGM_Referrer__c;
    			lead.Alternative_Contact_Email__c 			= LC.Alternative_Contact_Email__c;
    			lead.Alternative_Contact_Name__c 			= LC.Alternative_Contact_Name__c;
    			lead.Alternative_Contact_Phone_Number__c 	= LC.Alternative_Contact_Phone_Number__c;
    			lead.Alternative_Contact_Type__c 			= LC.Alternative_Contact_Type__c;
    			lead.Alternative_Email_1__c 				= LC.Alternative_Email_1__c;
    			lead.Alternative_Email_2__c 				= LC.Alternative_Email_2__c;
    			lead.Alternative_Email_3__c 				= LC.Alternative_Email_3__c;
    			lead.Alternative_Phone_Number_1__c 			= LC.Alternative_Phone_Number_1__c;
    			lead.Alternative_Phone_Number_2__c 			= LC.Alternative_Phone_Number_2__c;
    			lead.Alternative_Phone_Number_3__c 			= LC.Alternative_Phone_Number_3__c;
    			//lead.Channel_Partner__c 					= LC.Channel_Partner__c;
    			lead.Contact_Preference__c 					= LC.Contact_Preference__c;
    			lead.Email 									= LC.Email;
    			lead.FirstName 								= LC.FirstName;
    			lead.LastName 								= LC.LastName;
    			//lead.LeadSource 							= LC.LeadSource;
    			lead.Lead_City__c 							= LC.Lead_City__c;
    			lead.Lead_Country__c 						= LC.Lead_Country__c;
    			lead.Lead_Street__c 						= LC.Lead_Street__c;
    			lead.Lead_Zip_Postal_Code__c 				= LC.Lead_Zip_Postal_Code__c;
    			lead.MobilePhone 							= LC.Primary_Phone_Number_1__c;
    			lead.Mobile_Country_Code__c 				= LC.Primary_Phone_Number_Country_Code_1__c;
    			lead.Other_Position__c 						= LC.Other_Position__c;
    			lead.Phone 									= LC.Phone;
    			lead.Primary_Contact_Type__c 				= LC.Primary_Contact_Type__c;
    			lead.Primary_Email_1__c 					= LC.Primary_Email_1__c;
    			lead.Primary_Email_2__c 					= LC.Primary_Email_2__c;
    			lead.Primary_Email_3__c 					= LC.Primary_Email_3__c;
    			lead.Primary_Lead_Contact__c 				= LC.id;
    			lead.Primary_Phone_Number_1__c 				= LC.MobilePhone;
    			lead.Primary_Phone_Number_2__c 				= LC.Primary_Phone_Number_2__c;
    			lead.Primary_Phone_Number_3__c 				= LC.Primary_Phone_Number_3__c;
    			lead.Received_Consent_Date__c 				= LC.Received_Consent_Date__c;
    			lead.Received_Consent__c	 				= LC.Received_Consent__c;
    			lead.Role__c 								= LC.Role__c;
    			lead.Salutation 							= LC.Salutation;
    			lead.State_Province__c 						= LC.State_Province__c;
    			
    			leadEntitylist.add(lead);
    		}
    		if(!leadEntitylist.isEmpty()){
    			update leadEntitylist;
    			unselectprimaryCheckonLeadContact(primaryLeadContacts);
    		}
    	}
    }
    
    
  //@future
  public static void unselectprimaryCheckonLeadContact(set<id> leadIds)
  {
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
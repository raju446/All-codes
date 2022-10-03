/*
    Author      : Rajil Ravindran
    Date        : 28-Nov-2017
    Description : Page Controller to display the Case types and the url from the custom setting based from the recordtype
    --------------------------------------------------------------------------------------
*/
public without sharing class CaseSelectionController{
    public list<CaseType> lstCaseRecordTypes{get;set;}//Case Type List used in page
    public boolean isPortal;
    public CaseSelectionController(ApexPages.StandardController controller) {
        lstCaseRecordTypes = new list<CaseType>();
        list<String> names = new list<String>(Case_Types__c.getAll().keySet()); //list to sort based on name.
        names.sort();
        isPortal = false;
        for(User usr:[select id,contactid from user where Id=:userinfo.getuserid() and ContactId!=null]){
            isPortal = true;
        }
        list<Case_Types__c> lstCaseTypes = new  list<Case_Types__c>(); //Holds the sorted case types.
        for (String name : names) {
            lstCaseTypes.add(Case_Types__c.getAll().get(name));
        }
        map<string,string> MapCaseRecordTypes = new map<string,string>();
        for(RecordType rt:[select id,developername,name from recordtype where sobjecttype='Case' and IsActive=true]){
            MapCaseRecordTypes.put(rt.Developername.tolowercase(),rt.Id);
        }
        List<User> lstUser = [Select Contact.AccountId, Contact.Account.Name from User where id =: Userinfo.getUserid() limit 1];
        for(Case_Types__c caseType : lstCaseTypes){
        
            CaseType ct = new CaseType();
            ct.IconName = caseType.Icon_Name__c;
            ct.Title = caseType.Case_Title__c;
            ct.Description = caseType.Case_Description__c;
            
            if(String.isNotEmpty(caseType.Record_Type_API_Name__c) && MapCaseRecordTypes.get(caseType.Record_Type_API_Name__c.tolowercase())!=null){
                string recordTypeId = MapCaseRecordTypes.get(caseType.Record_Type_API_Name__c.tolowercase());
                if(recordTypeId != null){
                    //ct.CaseUrl = '/500/e?nooverride=1&retURL=/adgm/NewPortalCase&RecordType='+recordTypeId+'&ent=Case';
                    if(isPortal){
                        if(String.IsNotEmpty(ct.Title) && ct.Title.tolowercase() == 'payment')
                            ct.CaseUrl = '/500/e?nooverride=1&retURL=/NewPortalCase&RecordType='+recordTypeId+'&ent=Case'+'&cas4='+lstUser[0].Contact.Account.Name+'&cas4_lkid='+lstUser[0].Contact.AccountId+'&cas11=ACCESSADGM Portal Case&'+Label.SubTypeFieldId+'=Pricing';
                        else {
                           ct.CaseUrl = '/500/e?nooverride=1&retURL=/NewPortalCase&RecordType='+recordTypeId+'&ent=Case'+'&cas4='+lstUser[0].Contact.Account.Name+'&cas4_lkid='+lstUser[0].Contact.AccountId+'&cas11=ACCESSADGM Portal Case';
                        }
                    }
                    else
                        ct.CaseUrl = '/500/e?nooverride=1&retURL=/apex/NewInternalCase&RecordType='+recordTypeId+'&ent=Case';
                }
            }
            lstCaseRecordTypes.add(ct);
        }
    }
    public class CaseType{
        public string IconName{get;set;}
        public string Title{get;set;}
        public string Description{get;set;}
        public string CaseUrl{get;set;}
    }
}
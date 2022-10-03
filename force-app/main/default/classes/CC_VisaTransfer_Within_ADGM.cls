/*******************
Author : Azmath
Description : Reparent the parentids upon approval of Visa Transfer Request.

******************* */

global without sharing class CC_VisaTransfer_Within_ADGM implements HexaBPM.iCustomCodeExecutable 
{
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) 
    {
        string strResult = 'Success';
        Id previousAccId;
        Id contactid;
        string newEntity = '';
        boolean empExists = false;
        if(step.HexaBPM__SR__c != null && step.HexaBPM__SR__r.Free_Zone_Transferring_From__c == 'ADGM' && (step.HexaBPM__SR__r.Previous_Visa_Number__c != null || step.HexaBPM__SR__r.Unified_ID_No__c != null))
        {
            string uid = (step.HexaBPM__SR__r.Unified_ID_No__c != null) ? step.HexaBPM__SR__r.Unified_ID_No__c : step.HexaBPM__SR__r.Previous_Visa_Number__c;
            newEntity = [Select HexaBPM__SR__r.HexaBPM__Customer__r.Name from HexaBPM__Step__c where id=:step.id].HexaBPM__SR__r.HexaBPM__Customer__r.Name;
            system.debug('===UID==='+uid+'====pre uid==='+step.HexaBPM__SR__r.Previous_Visa_Number__c+'===='+step.HexaBPM__SR__r.Unified_ID_No__c);
            Savepoint sp = Database.setSavepoint();
            try
            {
                list<Document_Details__c> employeesDocumentDetails = new list<Document_Details__c>();
            
                //1. Query contact and its document details..
                for(Contact cont : [Select id,Name,Accountid,Account.Name,Unified_ID_No__c,Residence_Visa_Number__c,Passport_No__c,Nationality__c,
                    
                    Gender__c,Religion__c,Birthdate,Birth_Place__c,Marital_Status__c,Faith__c,Country_of_Birth__c,First_Name_Arabic__c,Last_Name_Arabic__c,
                    
                    Mother_Name_Arabic__c,Nationality_Arabic__c,Middle_Name_Arabic__c,Job_Title_Arabic__c,Passport_Type__c,Passport_Issue_Date__c,
                    
                    Passport_Place_of_Issue__c,Passport_Expiry_Date__c,Passport_Country_of_Issue__c,Residence_Visa_Date_of_Expiry__c,Job_Title__c,
                    
                    Languages_Spoken__c,Employee_Email_ID__c,Educational_Qualification__c,Gross_Monthly_Salary__c,Employee_Mobile_Number__c,Person_In_UAE__c,
                    
                    Work_Permit_Card_Number__c,Work_Permit_Issue_Date__c,Work_Permit_Expiry_Date__c,Residence_Visa_Date_of_Issue__c,Residence_Visa_Place_of_Issue__c,
                    (Select id,Account__c,Contact__c,Document_Type__c from Document_Details__r) From Contact where Unified_ID_No__c =:uid and 
                        Employment_Status__c = 'Active' and Accountid != :step.HexaBPM__SR__r.HexaBPM__Customer__c  LIMIT 1])
                {
                    contactid       = cont.id;
                    previousAccId   = cont.Accountid;
                    empExists       = true;
                     //1. Create transferred employee record in old entity.
                    Transferred_Employees__c te     = new Transferred_Employees__c();
                    te.Name                         = cont.Name;
                    te.UID__c                       = cont.Unified_ID_No__c;
                    te.Transferred_to__c            = newEntity;
                    te.Residence_Visa_Number__c     = cont.Residence_Visa_Number__c;
                    te.Passport_Number__c           = cont.Passport_No__c;
                    te.Nationality__c               = cont.Nationality__c;
                    te.Birthdate__c                 = cont.Birthdate;
                    te.Country_of_Birth__c          = cont.Country_of_Birth__c;
                    te.Educational_Qualification__c = cont.Educational_Qualification__c;
                    te.Employee_Email_ID__c         = cont.Employee_Email_ID__c;
                    te.Employee_Mobile_Number__c    = cont.Employee_Mobile_Number__c;
                    te.Faith__c                     = cont.Faith__c;
                    te.First_Name_Arabic__c         = cont.First_Name_Arabic__c;
                    te.Gender__c                    = cont.Gender__c;
                    te.Gross_Monthly_Salary__c      = string.valueof(cont.Gross_Monthly_Salary__c);
                    te.Job_Title__c                 = cont.Job_Title__c;
                    //te.Job_Title_Arabic__c          = cont.Accountid;
                    te.Account__c                   = cont.Accountid;
                    te.Languages_Spoken__c          = cont.Languages_Spoken__c;
                    te.Last_Name_Arabic__c          = cont.Last_Name_Arabic__c;
                    te.Marital_Status__c            = cont.Marital_Status__c;
                    te.Middle_Name_Arabic__c        = cont.Middle_Name_Arabic__c;
                    te.Mother_Name_Arabic__c        = cont.Mother_Name_Arabic__c;
                    te.Nationality_Arabic__c        = cont.Nationality_Arabic__c;
                    te.Passport_Country_of_Issue__c = cont.Passport_Country_of_Issue__c;
                    te.Passport_Expiry_Date__c      = cont.Passport_Expiry_Date__c;
                    te.Passport_Issue_Date__c       = cont.Passport_Issue_Date__c;
                    te.Passport_Place_of_Issue__c   = cont.Passport_Place_of_Issue__c;
                    te.Passport_Type__c             = cont.Passport_Type__c;
                    te.Person_In_UAE__c             = cont.Person_In_UAE__c;
                    te.Place_of_Birth__c            = cont.Birth_Place__c;
                    te.Religion__c                  = cont.Religion__c;
                    te.Residence_Visa_Date_of_Expiry__c = cont.Residence_Visa_Date_of_Expiry__c;
                    te.Residence_Visa_Date_of_Issue__c  = cont.Residence_Visa_Date_of_Issue__c;
                    te.Residence_Visa_Place_of_Issue__c = cont.Residence_Visa_Place_of_Issue__c;
                    te.Work_Permit_Card_Number__c       = cont.Work_Permit_Card_Number__c;
                    te.Work_Permit_Issue_Date__c        = cont.Work_Permit_Issue_Date__c;
                    te.Work_Permit_Expiry_Date__c       = cont.Work_Permit_Expiry_Date__c;
                    insert te;
                    
                    //2. Update contact details..
                    cont.Accountid = step.HexaBPM__SR__r.HexaBPM__Customer__c;
                    for(Contact_SR_Field_Mapping__c cs : Contact_SR_Field_Mapping__c.getAll().values())
                    {
                        if(cs.Active__c)
                        {
                            cont.put(cs.Contact_Field_API_Name__c,step.HexaBPM__SR__r.get(cs.SR_Field_API_Name__c));
                        }
                    }
                    update cont;
                    
                    //3. Update Employees document details..
                    map<string,map<string,string>> mapOfVisitTypes = new map<string,map<string,string>>();
                    for(Document_Detail_SR_Field_Mapping__c docDetailSRFieldMap : Document_Detail_SR_Field_Mapping__c.getAll().values())
                    {
                        if(step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == docDetailSRFieldMap.Service_Request_Recordtype_API__c && docDetailSRFieldMap.Active__c == true)
                        {
                            if(mapOfVisitTypes.containsKey(docDetailSRFieldMap.Document_Type__c))
                            {
                                mapOfVisitTypes.get(docDetailSRFieldMap.Document_Type__c).put(docDetailSRFieldMap.SR_Field_API_Name__c,docDetailSRFieldMap.Document_Detail_Field_API_Name__c);
                            }
                            else
                            {
                                mapOfVisitTypes.put(docDetailSRFieldMap.Document_Type__c,new map<string,string>{docDetailSRFieldMap.SR_Field_API_Name__c=>docDetailSRFieldMap.Document_Detail_Field_API_Name__c});
                            }
                        }
                    }
                    
                    for(Document_Details__c detail : cont.Document_Details__r)
                    {
                        if(detail.Document_Type__c == 'Entry Permit' && !mapOfVisitTypes.containsKey(detail.Document_Type__c))
                        {
                            detail.Document_Status__c   = 'Inactive';
                        }
                        if(mapOfVisitTypes.containsKey(detail.Document_Type__c))
                        {
                            map<string,string> temp = mapOfVisitTypes.get(detail.Document_Type__c);
                            for(string keyStr: temp.keyset())
                            {
                                detail.put(temp.get(keyStr),step.HexaBPM__SR__r.get(keyStr));
                            }
                            detail.Document_Status__c   = 'Active';
                        }
                        detail.Account__c   = step.HexaBPM__SR__r.HexaBPM__Customer__c;
                        employeesDocumentDetails.add(detail);
                    }
                }
                
                //2. Reparent Independents and its document details..
                for(Contact ind : [Select id,Name,(Select id,Account__c,Contact__c,Document_Type__c from Document_Details__r) from Contact where Sponsor__c =:contactid and Sponsor__c != null])
                {
                    ind.Accountid = step.HexaBPM__SR__r.HexaBPM__Customer__c;
                    update ind;
                    
                    for(Document_Details__c detail : ind.Document_Details__r)
                    {
                        detail.Account__c   = step.HexaBPM__SR__r.HexaBPM__Customer__c;
                        employeesDocumentDetails.add(detail);
                    }
                }
                
                if(!employeesDocumentDetails.isEmpty()){
                        update employeesDocumentDetails;
                    }
                
                if(previousAccId != null )
                {
                    for(Account acc : [Select id,Total_Visas_Used__c FROM Account WHERE ID=:previousAccId ])
                    {
                        if(acc.Total_Visas_Used__c != null)
                        acc.Total_Visas_Used__c = acc.Total_Visas_Used__c-1;
                        update acc;
                    }
                
                }
                
                
                //If employee does not exist then create the contact..
                if(empExists == false)
                {
                    CC_CreateContactCls con = new CC_CreateContactCls();
                    con.EvaluateCustomCode(SR,step);
                }
            }
            catch(Exception ex)
            {
                Database.rollback(sp);
                strResult = ex.getMessage();
                system.debug('===error=='+ex.getMessage());
            }
            
        }
        return strResult;
    }
}
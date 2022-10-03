/*
@Author : Azmath.
@Description : The webservice class for public api.
*/

@RestResource(urlMapping='/GetRegEntityDetails/*')
global without sharing class GetAccountDetails
{
    @HttpGet
    global static string getAccountDetails()
    {
        String eStatus = RestContext.request.params.get('Status');
        string etype = 'Restricted Scope Company';
        system.debug('=====status==='+eStatus);
        list<EntityResponse> accounts = new list<EntityResponse>();
        EntityResponse.Address Eaddress = new EntityResponse.Address();
        list<Account> acclist = new List<Account>();
        Set<String> allowedEntityStatuses = new Set<String>{'Deregistered','Registered','Enters Administration','In administration','Registration Inactive','In Liquidation','Deregistered by Registrar','Dissolved','Continued outside ADGM'};
            
        
		string query = 'Select Name, Entity_Id__c, Account_Name_Arabic__c, Registration_Date__c, License_Expiry_Date__c, Entity_Status__c, Entity_Type__c, Entity_Sub_Type__c , Category__c, TotalAuthorisedSignatories__c,';
        query += '(select Type__c, County__c, Office_Number__c, Floor__c, Building_Name__c,Street_Name_of_Cluster_on_the_Island__c,State__c,Emirates__c from Addresses__r where Type__c=\'Physical\' limit 1),';
        query += '(Select id, Type__c, Actual_Activity_code__c, Status__c, Activity_Name_Arabic__c, Activity_Name__c,Section__c from Business_Activities__r), ';
        query += '(select id,Name_in_English__c, Name_in_Arabic__c, Status__c, Primary__c from Trade_Names__r), ';
        query += '(select id, Forenames__c, Title__c, Forenames_in_Arabic__c,Surname__c, Surname_in_Arabic__c, Country_of_Residence__c, Nationality__c,Status__c,Role_Name__c,Capacity__c from Relationships__r) ';
        query +=  'From Account where Recordtype.DeveloperName = \'ADGM_Registered_Company\' and Entity_Id__c != null and Entity_Type__c != :etype and Legacy_Data__c=false and Registration_Date__c != null ';
        
        if(eStatus != null && eStatus != '' && allowedEntityStatuses.contains(eStatus)){
            query += ' and Entity_Status__c =:eStatus';                       
            system.debug('===acclist==='+acclist.size());
            acclist = Database.query(query);
            
        } else if(eStatus == null || eStatus == ''){            
            query += ' and Entity_Status__c =\'Registered\'';
            system.debug('===query ==='+query );
            acclist = Database.query(query);
        }
        // query += ' LIMIT 5 ';

        if(acclist.size()>0){
            for(Account acc : acclist)
            {
            
                //Address mapping..
                if(!acc.Addresses__r.isEmpty())
                {
                    Address__c add= acc.Addresses__r[0];
                    Eaddress = new EntityResponse.Address();
                    //Eaddress.Type             = add.Type__c;
                    Eaddress.BuildingName     = add.Building_Name__c;
                    //Eaddress.Country          = add.County__c;
                    Eaddress.Emirates        = add.Emirates__c ;
                    Eaddress.Floor            = add.Floor__c;
                    Eaddress.OfficeNumber        = add.Office_Number__c;
                    Eaddress.Area     = add.State__c;
                    Eaddress.StreetNameofClusterontheIsland = add.Street_Name_of_Cluster_on_the_Island__c;
                }
                
                //Business activity mapping..
                list<EntityResponse.Activity> lstactivities;
                if(!acc.Business_Activities__r.isEmpty())
                {
                   lstactivities = new list<EntityResponse.Activity>();
                   for(Business_Activity__c avt : acc.Business_Activities__r)
                   {
                        EntityResponse.Activity act = new EntityResponse.Activity();
                        act.ActivityName = avt.Activity_Name__c;
                        act.ActivityNameAr = avt.Activity_Name_Arabic__c;
                        act.ActivityCode = avt.Actual_Activity_code__c;
                        //act.Type = avt.Type__c;
                        lstactivities.add(act);
                   }
                }
                
                //Roles mapping..
                /*list<EntityResponse.Signatory> signatories;
                if(!acc.Relationships__r.isEmpty())
                {
                   signatories = new list<EntityResponse.Signatory>();
                   for(Role__c role : acc.Relationships__r)
                   {
                        EntityResponse.Signatory sig = new EntityResponse.Signatory();
                        sig.Forename    = role.Forenames__c;
                        //sig.Type        = role.Type__c;
                        sig.Title       = role.Title__c;
                        sig.ForenamesAr = role.Forenames_in_Arabic__c;
                        sig.Surname     = role.Surname__c;
                        sig.SurnameAr   = role.Surname_in_Arabic__c;
                        sig.CountryofResidence = role.Country_of_Residence__c;
                        sig.Nationality = role.Nationality__c;
                        sig.Status      = role.Status__c;
                        sig.Role        = role.Role_Name__c;
                        sig.Capacity    = role.Capacity__c;
                        signatories.add(sig);
                   }
                }*/
                
                //Trade Names mapping..
                /*list<EntityResponse.TradeName> TradeNames;
                if(!acc.Trade_Names__r.isEmpty())
                {
                   TradeNames = new list<EntityResponse.TradeName>();
                   for(Trade_Name__c tname : acc.Trade_Names__r)
                   {
                        EntityResponse.TradeName trd = new EntityResponse.TradeName();
                        trd.TradeNameEn     = tname.Name_in_English__c;
                        trd.TradeNameAr     = tname.Name_in_Arabic__c;
                        trd.Status          = tname.Status__c;
                        trd.Primary         = tname.Primary__c;
                        TradeNames.add(trd);
                   }
                }*/
                 
                EntityResponse wrp = new EntityResponse();
                wrp.LicensNumber  = acc.Entity_Id__c;
                wrp.EntityName = acc.Name;
                wrp.EntityNameAr = acc.Account_Name_Arabic__c;
                wrp.LicenseIssueDate = acc.Registration_Date__c;
                wrp.LicenseExpiryDate = acc.License_Expiry_Date__c;
                wrp.EntityStatus = acc.Entity_Status__c;
                wrp.EntityType = acc.Entity_Type__c;
                wrp.EntitySubType = acc.Entity_Sub_Type__c ;
                wrp.Category = acc.Category__c;
                //wrp.TotalAuthorisedSignatories = acc.TotalAuthorisedSignatories__c;
                
                if(Eaddress!=null)
                    wrp.Address = Eaddress;
                
                if(lstactivities != null)     
                    wrp.Activities = lstactivities;
                
                //if(signatories != null)
                    //wrp.Roles = signatories;
                    
                //if(TradeNames != null)
                    //wrp.TradeNames = TradeNames;
                accounts.add(wrp);        
            }
        }
        responsewrap resp = new responsewrap(accounts);
        //resp.Entities = accounts;
        return JSON.serialize(resp);
    }
    
    global class responsewrap
    {
        public list<EntityResponse> Entities;
        public responsewrap(list<EntityResponse> temp){
            this.Entities= temp;
        }
    }
}
public with sharing class ICA_ViewInternalAuthsigCntlr 
{
    public list<Authsignatory> authsig {get;set;}
    public ICA_ViewInternalAuthsigCntlr(ApexPages.standardController SC)
    {
        string id= sc.getId();
        list<HexaBPM__Service_Request__c> sr = [Select id,HexaBPM__Customer__c, Recordtype.developername from HexaBPM__Service_Request__c where id=:id];
        authsig = new list<Authsignatory>();
        if(!sr.isEmpty() && sr[0].Recordtype.developername == 'Establishment_Card_New')
        {
            for(Internal_Auth_Signatories__c sig : [SELECT Name, Employee_Type__c,  Full_Name__c, Full_Name_Arabic__c, Mobile_Number__c, Nationality__c 
                                    FROM Internal_Auth_Signatories__c ])
            {
                Authsignatory sign = new Authsignatory(sig.Full_Name__c, sig.Full_Name_Arabic__c, sig.Employee_Type__c, sig.Name, sig.Mobile_Number__c, sig.Nationality__c, 'Internal', null,null);
                authsig.add(sign);
            }
        }
        for(Role__c role : [SELECT id,Unified_ID__c, Role_Full_Name__c, Role_Full_Name_Arabic__c, Nationality__c,Status__c FROM Role__c WHERE Subject_Account__c=:sr[0].HexaBPM__Customer__c  
                        Order by LastModifiedDate DESC])
        {
            Authsignatory sign = new Authsignatory(role.Role_Full_Name__c, role.Role_Full_Name_Arabic__c, 'Manager', role.Unified_ID__c, system.label.ICA_PhoneNumber, 
                role.Nationality__c, 'External',role.id, role.Status__c);
            authsig.add(sign);
        }
        
    }
    public class Authsignatory
    {
        public string fullName_En {get;set;}
        public string fullName_Ar {get;set;}
        public string employeeType {get;set;}
        public string unifiedId {get;set;}
        public string mobNo {get;set;}
        public string nationality {get;set;}
        public string Authtype {get;set;}
        public string recid {get;set;}
        public string status {get;set;}
        public Authsignatory(string fnEn, string fnAr, string et, string uid, string mob, string nt,string tp, string rid,string sts)
        {
            this.fullName_En    = fnEn;
            this.fullName_Ar    = fnAr;
            this.employeeType   = et;
            this.unifiedId      = uid;
            this.mobNo          = mob;
            this.nationality    = nt;
            this.Authtype       = tp;
            this.recid          = rid;
            this.status         = sts;
        }
    }
}
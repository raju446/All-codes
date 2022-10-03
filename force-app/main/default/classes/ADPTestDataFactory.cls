/*
*Author : Azmath
Description : This class provides test data to ADP related test classes.
*/
@isTest
public class ADPTestDataFactory
{
    public static list<HexaBPM__Service_Request__c> createcustomerandSR(string srname,integer count)
    {
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '2000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        newAccounts[0].Registration_Date__c = Date.today();
        newAccounts[0].License_Expiry_Date__c = Date.today().addDays(360);
        insert newAccounts;
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(count,srname);//'Permit_Alcohol'
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].Government_Authority_picklist__c = 'National Media Council';
        createdSRList[0].End_Date__c = Date.today().addDays(1);
        insert createdSRList;
        system.assertEquals(createdSRList.isEmpty(),false);
        return createdSRList;
    }
    public static HexaBPM__Status__c createStatus(string stsname, string code)
    {
        HexaBPM__Status__c status = new HexaBPM__Status__c(Name=stsname, HexaBPM__Code__c=code);//'APPLICATION_SUBMITTED'
        insert status;
        system.assertEquals(string.isEmpty(status.id),false);
        return status;
    }
    public static HexaBPM__Step_Template__c  createstepTemplate(string code, string recapiname)
    {
        HexaBPM__Step_Template__c temp = new HexaBPM__Step_Template__c(HexaBPM__Code__c=code,HexaBPM__Step_RecordType_API_Name__c=recapiname);//HexaBPM__Code__c='TYPING',HexaBPM__Step_RecordType_API_Name__c='Test'
        insert temp;
        system.assertEquals(string.isEmpty(temp.id),false);
        return temp;
    }
    public static HexaBPM__Step__c createactionitem(string summary, Id steptemplate, Id srid, Id statusid)
    {
        HexaBPM__Step__c step = new HexaBPM__Step__c(HexaBPM__Summary__c=summary, HexaBPM__Step_Template__c=steptemplate, HexaBPM__SR__c=srid, HexaBPM__Status__c=statusid);
        insert step;
        system.assertEquals(string.isEmpty(step.id),false);
        return step;
    }
    public static ADP_AttributesMapping__c createADPcustomset(string nm,string permitname,string section,boolean isdef,string attribute,string fld)
    {
        
        ADP_AttributesMapping__c custset = new ADP_AttributesMapping__c(Name=nm,Permit_Name__c=permitname,Section__c=section,
            Is_Default__c=isdef,ADP_Attribute__c=attribute,Field__c=fld);
        insert custset;
        system.assertEquals(string.isEmpty(custset.id),false);
        return custset;
    }
    public static Amendment__c createParticipant(string fname, string arname, string pp,Id srid,string nationality)
    {
        Amendment__c objAmm = new Amendment__c();
        objAmm.Full_Name__c = fname;
        objAmm.Full_Name_Arabic__c = arname;
        objAmm.Passport_No__c = pp;
        objAmm.Service_Request__c = srid;
        objAmm.Nationality_New__c = nationality;
        insert objAmm;
        system.assertEquals(string.isEmpty(objAmm.id),false);
        return objAmm;
    }
    public static Business_Activity__c createBusinessActivity(string des,string descar, string code,Id accid)
    {
        Business_Activity__c ba = new Business_Activity__c(Description__c=des,Description_Arabic__c=descar,Activity_Code__c=code,Entity__c=accid);
        insert ba;
        system.assertEquals(string.isEmpty(ba.id),false);
        return ba;
    }
    public static Trade_Name__c createdTradename(Id accid, string en, string ar)
    {
        Trade_Name__c tr = new Trade_Name__c(Entity__c=accid,Name_in_Arabic__c=ar,Name_in_English__c=en,Primary__c=true,Status__c='Active');
        insert tr;
        system.assertEquals(string.isEmpty(tr.id),false);
        return tr;
    }
    public static HexaBPM__SR_Doc__c createSRDoc(Id srid,string docname)
    {
        HexaBPM__SR_Doc__c srdoc = new HexaBPM__SR_Doc__c(HexaBPM__Service_Request__c=srid,Name=docname,Available_to_ADP__c=true);
        insert srdoc;
        system.assertEquals(string.isEmpty(srdoc.id),false);
        return srdoc;
    }
    public static Address__c createAddress(Id accid)
    {
        Address__c a = new Address__c(Entity__c=accid,Type__c='Physical',Status__c='Active',Floor__c='24',Emirates__c='AE');
        insert a;
        system.assertEquals(string.isEmpty(a.id),false);
        return a;
    }
    public static HexaBPM__Service_Request__c createamendment(Id accid,Id pid)
    {
        Id srRecordTypeId = Schema.SObjectType.HexaBPM__Service_Request__c.getRecordTypeInfosByName().get('ADGM Permit Amendment Service Request').getRecordTypeId();
        HexaBPM__Service_Request__c am = new HexaBPM__Service_Request__c(Recordtypeid=srRecordTypeId,HexaBPM__Customer__c=accid,HexaBPM__Parent_SR__c=pid,
                                                        Reason_of_Cancellation__c='test');
        insert am;
        system.assertEquals(string.isEmpty(am.id),false);
        return am;
        
    }
    public static HexaBPM__SR_Status__c createSRstatus(string code,string nm,string typ)
    {
        HexaBPM__SR_Status__c srstatus = new HexaBPM__SR_Status__c(HexaBPM__Code__c=code,HexaBPM__Type__c=typ,name=nm);
        insert srstatus;
        system.assertEquals(string.isEmpty(srstatus.id),false);
        return srstatus;
    }
    
    public static Attachment createAttachment(Id parentid)
    {
        Attachment objAttachment = new Attachment();
        objAttachment.Name = 'commercial license';
        objAttachment.ContentType = 'application/pdf';
        objAttachment.Body = blob.valueOf('test');
        objAttachment.ParentId = parentid;
        insert objAttachment;
        system.assertEquals(string.isEmpty(objAttachment.id),false);
        return objAttachment;
    }

}
/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class TestUtility {
    
    static Map<String, Id> srRecordTypes = new Map<String, Id>();

    //create a map for SR recordtypes
    public static void srRecordtypesMap(){
        for(Recordtype rt : [Select Id, DeveloperName FROM RecordType 
                            WHERE SObjectType = 'HexaBPM__Service_Request__c']){
            srRecordTypes.put(rt.DeveloperName, rt.Id);
        }
    }
    
    //create Service Request records
    public static List<HexaBPM__Service_Request__c> createSR(Integer ctr, String recordtypeName){
        srRecordtypesMap();
        User objUser = [select id,IsPortalEnabled from user where id =: UserInfo.getUserId()];
        Account acc = new Account();
        if(!objUser.IsPortalEnabled) {
            acc = new Account(Name = 'Test Company Name'+system.now(),Oracle_Party_Id__c='123124'+system.now());
            insert acc;
        }
        
        List<HexaBPM__Service_Request__c> insertNewSRs = new List<HexaBPM__Service_Request__c>();
        for(Integer i=0;i < ctr;i++){
            HexaBPM__Service_Request__c newSR = new HexaBPM__Service_Request__c();
            newSR.RecordtypeId = srRecordTypes.get(recordtypeName);
            newSR.Last_Name__c = 'LastName'+i;
            if(!objUser.IsPortalEnabled) {
                newSR.HexaBPM__Customer__c = acc.Id;
            }
            insertNewSRs.add(newSR);
        }
        
        return insertNewSRs;
    }
    //create Service Request records
    public static List<HexaBPM__Service_Request__c> createSR1(Integer ctr, String recordtypeName,string opId){
        srRecordtypesMap();
        User objUser = [select id,IsPortalEnabled from user where id =: UserInfo.getUserId()];
        Account acc = new Account();
        if(!objUser.IsPortalEnabled) {
            acc = new Account(Name = 'Test Company Name'+system.now(),Oracle_Party_Id__c=opId);
            insert acc;
        }
        
        List<HexaBPM__Service_Request__c> insertNewSRs = new List<HexaBPM__Service_Request__c>();
        for(Integer i=0;i < ctr;i++){
            HexaBPM__Service_Request__c newSR = new HexaBPM__Service_Request__c();
            newSR.RecordtypeId = srRecordTypes.get(recordtypeName);
            newSR.Last_Name__c = 'LastName'+i;
            if(!objUser.IsPortalEnabled) {
                newSR.HexaBPM__Customer__c = acc.Id;
            }
            insertNewSRs.add(newSR);
        }
        
        return insertNewSRs;
    }
    
    //create Step records
    public static List<HexaBPM__Step__c> createSteps(Integer ctr, Id serviceRequestId, Id srStepId){
        List<HexaBPM__Step__c> insertNewSteps = new List<HexaBPM__Step__c>();
        for(Integer i=1;i<=ctr;i++){
            HexaBPM__Step__c newStep = new HexaBPM__Step__c();
            newStep.HexaBPM__SR__c = serviceRequestId;
            newStep.HexaBPM__Due_Date__c = System.Now().addDays(2);
            newStep.HexaBPM__Step_No__c = i * 10;
            newStep.HexaBPM__SR_Step__c = srStepId;
            
            insertNewSteps.add(newStep);
        }
        
        return insertNewSteps;
    }
    
    //create Document Master records
    public static List<HexaBPM__Document_Master__c> createDocMasters(Integer ctr){
        List<HexaBPM__Document_Master__c> insertNewDocMasters = new List<HexaBPM__Document_Master__c>();
        for(Integer i=1;i<=ctr;i++){
            HexaBPM__Document_Master__c newDocMaster = new HexaBPM__Document_Master__c();
            newDocMaster.Name = 'DocumentMaster'+i;
            newDocMaster.HexaBPM__Code__c = 'DocumentMaster'+i; 
            
            insertNewDocMasters.add(newDocMaster);
        }
        
        return insertNewDocMasters;
    }
    
    //create SR Doc records
    public static List<HexaBPM__SR_Doc__c> createDocMasters(Integer ctr, Id docMasterId, Id serviceRequestId){
        List<HexaBPM__SR_Doc__c> insertNewSRDocs = new List<HexaBPM__SR_Doc__c>();
        for(Integer i=1;i<=ctr;i++){
            HexaBPM__SR_Doc__c newSRDoc = new HexaBPM__SR_Doc__c();
            newSRDoc.HexaBPM__Document_Master__c = docMasterId;
            newSRDoc.HexaBPM__Service_Request__c = serviceRequestId;
            
            insertNewSRDocs.add(newSRDoc);
        }
        
        return insertNewSRDocs;
    }
    
    //create Appointment Master records
    public static List<Appointment_Master__c> createAppointmentMasters(Date startDate, Date endDate, String timeStr, Integer numSeats){
        List<Appointment_Master__c> insertNewAppointmentMasters = new List<Appointment_Master__c>();
        Id bussHoursId = [SELECT Id FROM BusinessHours LIMIT 1].Id;
        do{
            Datetime availDate = datetime.newInstance(startDate.year(), startDate.month(),startDate.day()).addHours(10);
            if(BusinessHours.isWithin(bussHoursId,availDate) == TRUE){
                Appointment_Master__c aMaster = new Appointment_Master__c();
                aMaster.Date__c = startDate;
                aMaster.No_of_Seats__c = numSeats;
                aMaster.Time__c = timeStr;
                
                insertNewAppointmentMasters.add(aMaster);
            }
            
            startDate = startDate.addDays(1);
        } while(startDate <= endDate);
        
        return insertNewAppointmentMasters;
    }
    
    public static  List<HexaBPM__Page_Flow__c>  createPageFlow(String RTApiName, Integer countVal) {
        List<HexaBPM__Page_Flow__c> PF_List = new List<HexaBPM__Page_Flow__c>();

        HexaBPM__Page_Flow__c pf;
        for (Integer i = 0; i < countVal; i++) {
            pf = new HexaBPM__Page_Flow__c();
            pf.Name = 'New Page Flow :' + i;
            pf.HexaBPM__Flow_Description__c   = pf.Name + '_Description';
            pf.HexaBPM__Master_Object__c  = 'HexaBPM__Service_Request__c';
            pf.HexaBPM__Record_Type_API_Name__c   = RTApiName;
            PF_List.add(pf);
        }
        insert PF_List;
        return PF_List;

    }
    public static List<HexaBPM__Page__c> createPageRecords(List<HexaBPM__Page_Flow__c> pageFlow_List) {
        List<HexaBPM__Page__c> Page_List = new List<HexaBPM__Page__c>();
        //For every flow
        for (Integer i = 0 ; i < pageFlow_List.Size(); i++) {
            HexaBPM__Page__c page;
            //Create 5 Pages
            for (Integer j = 0; j < 5; j++) {
                page = new HexaBPM__Page__c();
                page.HexaBPM__No_Quick_navigation__c = true;
                page.HexaBPM__Is_Custom_Component__c = false;
                page.HexaBPM__Page_Description__c = 'Test Page Description';
                page.HexaBPM__Page_Flow__c = pageFlow_List[i].id;
                page.HexaBPM__Page_Order__c = j++;
                page.HexaBPM__Render_By_Default__c = true;
                page.HexaBPM__VF_Page_API_Name__c = 'PageFlow';
                page.HexaBPM__What_Id__c = '';
                Page_List.add(page);
            }
        }
        insert Page_List;

        return Page_List;
    }
}
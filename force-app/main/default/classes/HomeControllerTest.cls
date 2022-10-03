@isTest
public with sharing class HomeControllerTest {
    
    private static  List<Appointment_Master__c> createdAppointmentMasterList; 
    private static  Appointment__c createdAppointment; 
    private static List<Appointment__c> ls;
    private static List<HexaBPM__Service_Request__c> createdSRList;
    
   /* public static void init(){
       
        createdSRList = TestUtility.createSR(1,'CID_Approval');
        createdSRList[0].First_Name__c = 'test'; 
        insert createdSRList;
        
        createdAppointmentMasterList = TestUtility.createAppointmentMasters(system.today(),system.today(),'9:00 am',5);
        insert createdAppointmentMasterList;    
     
        createdAppointment = new Appointment__c();
        createdAppointment.Appointment_Master__c = createdAppointmentMasterList[0].Id;
        createdAppointment.Appointment_Type__c = 'Medical Test';
        createdAppointment.Appointment_Date__c = system.today();
        createdAppointment.Customer__c = newAccounts[0].Id;
        insert createdAppointment;
        
    }*/
    public static testmethod void TestHomeController(){
        
        //init();
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts; 
        
        List<Notice__c> noticeList = TestClassUtility.createNotice(new List<Notice__c>{new Notice__c (Entity__c = newAccounts[0].Id,Type__c = 'Company Alert')});  
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        
        newContacts[0].Community_Username__c = 'test13mg@adgm.portal';
        newContacts[0].Types_of_Services_Accessible__c = 'Company Services; Payment - Account Services; Permits Services; Visa & Letter Services';
        insert newContacts;  
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        
        
        system.runAs(portalUser){
            
            createdSRList = TestUtility.createSR(1,'Initial_Approval');
            createdSRList[0].First_Name__c = 'test'; 
            insert createdSRList;
            
            createdAppointmentMasterList = TestUtility.createAppointmentMasters(system.today(),system.today(),'9:00 am',5);
            insert createdAppointmentMasterList;    
         
            createdAppointment = new Appointment__c();
            /*if(createdAppointmentMasterList != null && createdAppointmentMasterList.size() > 0)
                createdAppointment.Appointment_Master__c = createdAppointmentMasterList[0].Id;
            createdAppointment.Appointment_Type__c = 'Medical Test';
            createdAppointment.Appointment_Date__c = system.today();
            createdAppointment.Customer__c = newAccounts[0].Id;
            insert createdAppointment;*/
            
            HomeController hc = new HomeController();
        
        }
    }
    
    public static testmethod void TestHomeController2(){
        
        //init();
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts; 
        
        List<Attachment> att  = TestClassUtility.createAttachment(new List<Attachment>{new Attachment(ParentId = newAccounts[0].Id)});
        String id = att[0].Id;
        
        List<Notice__c> noticeList = TestClassUtility.createNotice(new List<Notice__c>{new Notice__c (Entity__c = newAccounts[0].Id, Notification_Picture_Id__c = id)});  
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        
        newContacts[0].Community_Username__c = 'test14mg@adgm.portal';
        insert newContacts;  
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        
        
        system.runAs(portalUser){
            
            createdSRList = TestUtility.createSR(1,'Initial_Approval');
            createdSRList[0].First_Name__c = 'test'; 
            insert createdSRList;
            
            createdAppointmentMasterList = TestUtility.createAppointmentMasters(system.today(),system.today(),'9:00 am',5);
            insert createdAppointmentMasterList;    
         
            /*createdAppointment = new Appointment__c();
            if(createdAppointmentMasterList != null && createdAppointmentMasterList.size() > 0)
                createdAppointment.Appointment_Master__c = createdAppointmentMasterList[0].Id;
            createdAppointment.Appointment_Type__c = 'Medical Test';
            createdAppointment.Appointment_Date__c = system.today();
            createdAppointment.Customer__c = newAccounts[0].Id;
            insert createdAppointment;*/
            
            HomeController hc = new HomeController();
        
        }
    }
    
}
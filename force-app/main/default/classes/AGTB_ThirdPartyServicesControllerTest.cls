@isTest
public with sharing class AGTB_ThirdPartyServicesControllerTest 
{
     public static testmethod void TestThirdPartyServicesController()
     {
     	List<Account> newAccounts = TestClassUtility.createAccounts(1);
     	newAccounts[0].Category__c = 'Non-Financial (Category B)';
        insert newAccounts;
        
        Business_Activity__c act = new Business_Activity__c(Activity_Code__c='000786-6210',Entity__c=newAccounts[0].id);
        insert act; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Profile_Picture_Id__c = '12345';
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Is_Guest_User__c = false;
        newContacts[0].Community_Username__c = 'agtbtest1@adgm.portal';
        insert newContacts;
        
        HexaBPM__SR_Template__c srtemp = new HexaBPM__SR_Template__c();
        srtemp.HexaBPM__Menu__c = 'test123';
        srtemp.HexaBPM__Sub_menu_section__c = 'Bank Account';
        srtemp.HexaBPM__Sub_menu__c = 'tester';
        srtemp.HexaBPM__Menutext__c = 'adgm';
        srtemp.HexaBPM__SR_RecordType_API_Name__c = 'Expression_Of_Intereset_Basic_Info';
        srtemp.HexaBPM__Template_Sequence_No__c = 12;
        srtemp.HexaBPM__Portal_Service_Request_Name__c = 'test';
        srtemp.HexaBPM__Is_Through_Flow__c = true;
        srtemp.HexaBPM__SR_Instruction_URL__c = 'www.google.com';
        srtemp.Icon_Name__c = '134';
        srtemp.HexaBPM__Active__c = true;
        srtemp.HexaBPM__Available_for_menu__c = true;
        srtemp.Visible_To__c = 'Company User';  
        srtemp.Required_Access__c = '3rd Party Services';  
        insert srtemp;
        
        AGTB_Activity_Codes__c cset = new AGTB_Activity_Codes__c(Name='6210');
        insert cset;
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        test.startTest();
        system.runAs(portalUser){
            
            AGTB_ThirdPartyServicesController sc = new AGTB_ThirdPartyServicesController();
            sc.LoadServices();
            ServicesController.InnerMenu emp = new ServicesController.InnerMenu(1,'test','test','xxx','srtitle');
            ServicesController.InnerMenu emp2 = new ServicesController.InnerMenu(1,'test','test','xxx','srtitle');
            list<ServicesController.InnerMenu> lstInnerMenu = new list<ServicesController.InnerMenu>();
            lstInnerMenu.add(emp);
            lstInnerMenu.add(emp2);

            emp2.compareTo(emp); 
            ServicesController.Submenu im1 = new ServicesController.Submenu(1,'test',lstInnerMenu);
            ServicesController.Submenu im2 = new ServicesController.Submenu(1,'test',lstInnerMenu);
            im2.compareTo(im1);  
            
            
            AGTB_ThirdPartyServicesController sc1 = new AGTB_ThirdPartyServicesController();
        } 
        
        test.stopTest();
     }
}
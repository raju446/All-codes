/*
    Author      : Rajil
    Date        : 19-Nov-2018
    Description : Test Class for SRListViewController
    -------------------------------------------------------------------------------------------
*/
@isTest
private class SRListViewControllerTest{
    static testMethod void SRListViewControllerTest1(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 

        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        newContacts[0].Types_of_Services_Accessible__c = 'Company Services; Payment - Account Services; Permits Services; Visa & Letter Services';
        newContacts[0].RecordTypeId = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('Contact - Portal User').getRecordTypeId();
        insert newContacts; 
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        system.runAs(portalUser)
        {
            test.startTest();
                HexaBPM__SR_Template__c srtemp = new HexaBPM__SR_Template__c();
                srtemp.HexaBPM__Menu__c = 'test123';
                srtemp.HexaBPM__Sub_menu_section__c = 'Company Services';
                srtemp.HexaBPM__Sub_menu__c = 'tester';
                srtemp.HexaBPM__Menutext__c = 'adgm';
                srtemp.HexaBPM__SR_RecordType_API_Name__c = 'Employment_Visa_New';
                srtemp.HexaBPM__Template_Sequence_No__c = 12;
                srtemp.HexaBPM__Portal_Service_Request_Name__c = 'test';
                srtemp.HexaBPM__Is_Through_Flow__c = true;
                srtemp.HexaBPM__SR_Instruction_URL__c = 'www.google.com';
                srtemp.Icon_Name__c = '134';
                srtemp.HexaBPM__Active__c = true;
                srtemp.HexaBPM__Available_for_menu__c = true;
                srtemp.Visible_To__c = 'Company User';    
                insert srtemp;
                List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Employment_Visa_New');
                createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
                createdSRList[0].HexaBPM__SR_Template__c = srtemp.id; 
                createdSRList[0].I_Agree__c = true;
                insert createdSRList;
                SRListViewController srListViewObj = new SRListViewController();
                srListViewObj.requestObjView = 'servicerequest';
                srListViewObj.selectedView = 'savedrequests';
                srListViewObj.refresh();
                srListViewObj.getTotalPages();
                srListViewObj.getselectValues();
                srListViewObj.reloadView();
                srListViewObj.requestObjView = 'servicerequest';
                srListViewObj.selectedView = 'currentrequests';
                srListViewObj.refresh();
                srListViewObj.requestObjView = 'servicerequest';
                srListViewObj.selectedView = 'rejectedrequests';
                srListViewObj.refresh();
                srListViewObj.requestObjView = 'servicerequest';
                srListViewObj.selectedView = 'approvedrequests';
                srListViewObj.refresh();

                /*Action Items */
                srListViewObj.requestObjView = 'actionitem';
                srListViewObj.selectedView = 'pendingactions';
                srListViewObj.refresh();
                srListViewObj.getTotalPages();
                srListViewObj.getselectValues();
                srListViewObj.reloadView();
                srListViewObj.requestObjView = 'actionitem';
                srListViewObj.selectedView = 'cancellationrequests';
                srListViewObj.refresh();
                srListViewObj.requestObjView = 'actionitem';
                srListViewObj.selectedView = 'couriersteps';
                srListViewObj.refresh();
            test.stopTest();
        }

    }
}
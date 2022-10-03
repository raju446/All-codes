@isTest
private class CheckOpenSRTest{
    public static list<HexaBPM__SR_Status__c> lstSRStatus = new list<HexaBPM__SR_Status__c>();

    public static void init(){
        lstSRStatus = new list<HexaBPM__SR_Status__c>();
        HexaBPM__SR_Status__c objSRStatus;
        objSRStatus = new HexaBPM__SR_Status__c();
        objSRStatus.Name = 'Submitted';
        objSRStatus.HexaBPM__Code__c = 'SUBMITTED';
        lstSRStatus.add(objSRStatus);
        
        /*objSRStatus = new HexaBPM__SR_Status__c();
        objSRStatus.Name = 'Draft';
        objSRStatus.HexaBPM__Code__c = 'DRAFT';
        lstSRStatus.add(objSRStatus);*/
        
        insert lstSRStatus;
        
        system.debug('SR_STATUS: '+lstSRStatus);
    }
    
    static testmethod void checkOpenPermitAlcoholtest(){
    
        init();
        
        HexaBPM__SR_Template__c srtemp = new HexaBPM__SR_Template__c();
        srtemp.HexaBPM__Sub_menu__c = 'Permits';
        srtemp.HexaBPM__SR_RecordType_API_Name__c = 'Permit_Alcohol';
        insert srtemp;
    
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        insert newAccounts; 
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Permit_Alcohol');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].HexaBPM__Internal_SR_Status__c = lstSRStatus[0].Id;
        createdSRList[0].HexaBPM__External_SR_Status__c = lstSRStatus[0].Id;
        createdSRList[0].HexaBPM__SR_Template__c = srtemp.Id; 
        insert createdSRList;
        
        test.startTest();
            List<HexaBPM__Service_Request__c> createdSRList2 = TestUtility.createSR(1,'Permit_Alcohol');
            createdSRList2[0].HexaBPM__Customer__c = newAccounts[0].Id;
            createdSRList2[0].HexaBPM__Internal_SR_Status__c = lstSRStatus[0].Id;
            createdSRList2[0].HexaBPM__External_SR_Status__c = lstSRStatus[0].Id;
            createdSRList2[0].HexaBPM__SR_Template__c = srtemp.Id; 
            insert createdSRList2;
            
            HexaBPM__Service_Request__c objSR = [SELECT Id, RecordtypeId, HexaBPM__Customer__c, HexaBPM__SR_Template__r.HexaBPM__Sub_menu__c, HexaBPM__Contact__c, Dependent__c, 
                                                    Passport_Issue_Date__c, Passport_Expiry_Date__c, Country_of_Issue__c, Place_of_Issue__c, First_Name__c, Title__c, 
                                                    Middle_Name__c, HexaBPM__Record_Type_Name__c,HexaBPM__IsClosedStatus__c,HexaBPM__IsCancelled__c, HexaBPM__Is_Rejected__c, 
                                                    HexaBPM__Internal_SR_Status__r.Name, P_O_Box_Type__c 
                                                    FROM HexaBPM__Service_Request__c 
                                                    WHERE Id = :createdSRList2[0].Id LIMIT 1];
            
            CheckOpenSR.CheckOpenSRExists(objSR);
        test.stopTest();
    }
    
    static testmethod void checkOpenVisaServicestest(){
    
        init();
        
        HexaBPM__SR_Template__c srtemp = new HexaBPM__SR_Template__c();
        srtemp.HexaBPM__Sub_menu__c = 'Visa Services';
        srtemp.HexaBPM__SR_RecordType_API_Name__c = 'Employment_Visa_New';
        insert srtemp;
    
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        insert newAccounts; 
        
        List<Recordtype> employeeRectypeId = [SELECT Id FROM Recordtype WHERE SObjectType = 'Contact' AND DeveloperName = 'Contact_Employee' LIMIT 1];
        List<Recordtype> dependentRectypeId = [SELECT Id FROM Recordtype WHERE SObjectType = 'Contact' AND DeveloperName = 'Contact_Dependent' LIMIT 1];
        List<Contact> employeeContact = TestClassUtility.createContacts(2, newAccounts[0].Id);
        employeeContact[0].RecordtypeId = employeeRectypeId[0].Id;
        employeeContact[0].Gross_Monthly_Salary__c = 20000;
        employeeContact[0].Employment_Status__c = 'Active';
        employeeContact[0].UAE_Residence_Visa_Expiry_Date__c = System.Today().addYears(1);
        employeeContact[0].Passport_No__c = 'PASS-8326418735';
        employeeContact[0].Passport_Expiry_Date__c = System.Today().addYears(3);
        employeeContact[0].Work_Permit_Expiry_Date__c = System.Today().addYears(1);
        
        
        employeeContact[1].RecordtypeId = dependentRectypeId[0].Id;
        employeeContact[1].Sponsor__c = employeeContact[0].Id;
        employeeContact[1].Dependent_Status__c = 'Active';
        insert employeeContact;
        employeeContact[1].Sponsor__c = employeeContact[0].Id;
        update employeeContact[1];
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Employment_Visa_New');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].HexaBPM__Internal_SR_Status__c = lstSRStatus[0].Id;
        createdSRList[0].HexaBPM__External_SR_Status__c = lstSRStatus[0].Id;
        createdSRList[0].HexaBPM__SR_Template__c = srtemp.Id; 
        createdSRList[0].HexaBPM__Contact__c = employeeContact[0].Id; 
        createdSRList[0].Dependent__c = employeeContact[1].Id; 
        insert createdSRList;
        
        test.startTest();
        
            HexaBPM__Service_Request__c objSRStr = [SELECT Id, RecordtypeId, HexaBPM__Customer__c, HexaBPM__SR_Template__r.HexaBPM__Sub_menu__c, HexaBPM__Contact__c, Dependent__c, 
                                                    Passport_Issue_Date__c, Passport_Expiry_Date__c, Country_of_Issue__c, Place_of_Issue__c, First_Name__c, Title__c, 
                                                    Middle_Name__c, HexaBPM__Record_Type_Name__c,HexaBPM__IsClosedStatus__c,HexaBPM__IsCancelled__c, HexaBPM__Is_Rejected__c, 
                                                    HexaBPM__Internal_SR_Status__r.Name, P_O_Box_Type__c 
                                                    FROM HexaBPM__Service_Request__c 
                                                    WHERE Id = :createdSRList[0].Id LIMIT 1];
                                                    
            System.debug('@@OBJSTR: '+objSRStr);
        
            List<HexaBPM__Service_Request__c> createdSRList2 = TestUtility.createSR(1,'Employment_Visa_New');
            
            createdSRList2[0].HexaBPM__Customer__c = newAccounts[0].Id;
            createdSRList2[0].HexaBPM__Internal_SR_Status__c = lstSRStatus[0].Id;
            createdSRList2[0].HexaBPM__External_SR_Status__c = lstSRStatus[0].Id;
            createdSRList2[0].HexaBPM__SR_Template__c = srtemp.Id; 
            createdSRList2[0].Dependent__c = employeeContact[1].Id; 
            createdSRList2[0].HexaBPM__Contact__c = employeeContact[0].Id;
            insert createdSRList2;
            
            HexaBPM__Service_Request__c objSR = [SELECT Id, RecordtypeId, HexaBPM__Customer__c, HexaBPM__SR_Template__r.HexaBPM__Sub_menu__c, HexaBPM__Contact__c, Dependent__c, 
                                                    Passport_Issue_Date__c, Passport_Expiry_Date__c, Country_of_Issue__c, Place_of_Issue__c, First_Name__c, Title__c, 
                                                    Middle_Name__c, HexaBPM__Record_Type_Name__c,HexaBPM__IsClosedStatus__c,HexaBPM__IsCancelled__c, HexaBPM__Is_Rejected__c, 
                                                    HexaBPM__Internal_SR_Status__r.Name, P_O_Box_Type__c 
                                                    FROM HexaBPM__Service_Request__c 
                                                    WHERE Id = :createdSRList2[0].Id LIMIT 1];
            System.debug('@@OBJSTR2: '+objSR);
            CheckOpenSR.CheckOpenSRExists(objSR);
        test.stopTest();
    }
    
    static testmethod void checkOpenVisaServicestest2(){
    
        init();
        
        HexaBPM__SR_Template__c srtemp = new HexaBPM__SR_Template__c();
        srtemp.HexaBPM__Sub_menu__c = 'Visa Services';
        srtemp.HexaBPM__SR_RecordType_API_Name__c = 'Employment_Visa_New';
        insert srtemp;
    
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        insert newAccounts; 
        
        List<Recordtype> employeeRectypeId = [SELECT Id FROM Recordtype WHERE SObjectType = 'Contact' AND DeveloperName = 'Contact_Employee' LIMIT 1];
        List<Recordtype> dependentRectypeId = [SELECT Id FROM Recordtype WHERE SObjectType = 'Contact' AND DeveloperName = 'Contact_Dependent' LIMIT 1];
        List<Contact> employeeContact = TestClassUtility.createContacts(2, newAccounts[0].Id);
        employeeContact[0].RecordtypeId = employeeRectypeId[0].Id;
        employeeContact[0].Gross_Monthly_Salary__c = 20000;
        employeeContact[0].Employment_Status__c = 'Active';
        employeeContact[0].UAE_Residence_Visa_Expiry_Date__c = System.Today().addYears(1);
        employeeContact[0].Passport_No__c = 'PASS-8326418735';
        employeeContact[0].Passport_Expiry_Date__c = System.Today().addYears(3);
        employeeContact[0].Work_Permit_Expiry_Date__c = System.Today().addYears(1);
        
        
        employeeContact[1].RecordtypeId = dependentRectypeId[0].Id;
        //employeeContact[1].Sponsor__c = employeeContact[0].Id;
        employeeContact[1].Dependent_Status__c = 'Active';
        
        insert employeeContact;
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Employment_Visa_New');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].HexaBPM__Internal_SR_Status__c = lstSRStatus[0].Id;
        createdSRList[0].HexaBPM__External_SR_Status__c = lstSRStatus[0].Id;
        createdSRList[0].HexaBPM__SR_Template__c = srtemp.Id; 
        createdSRList[0].HexaBPM__Contact__c = employeeContact[0].Id; 
        insert createdSRList;
        
        test.startTest();
            List<HexaBPM__Service_Request__c> createdSRList2 = TestUtility.createSR(1,'Employment_Visa_New');
            
            createdSRList2[0].HexaBPM__Customer__c = newAccounts[0].Id;
            createdSRList2[0].HexaBPM__Internal_SR_Status__c = lstSRStatus[0].Id;
            createdSRList2[0].HexaBPM__External_SR_Status__c = lstSRStatus[0].Id;
            createdSRList2[0].HexaBPM__SR_Template__c = srtemp.Id; 
            createdSRList2[0].HexaBPM__Contact__c = employeeContact[0].Id;
            insert createdSRList2;
            
            HexaBPM__Service_Request__c objSR = [SELECT Id, RecordtypeId, HexaBPM__Customer__c, HexaBPM__SR_Template__r.HexaBPM__Sub_menu__c, HexaBPM__Contact__c, Dependent__c, 
                                                    Passport_Issue_Date__c, Passport_Expiry_Date__c, Country_of_Issue__c, Place_of_Issue__c, First_Name__c, Title__c, 
                                                    Middle_Name__c, HexaBPM__Record_Type_Name__c,HexaBPM__IsClosedStatus__c,HexaBPM__IsCancelled__c, HexaBPM__Is_Rejected__c, 
                                                    HexaBPM__Internal_SR_Status__r.Name, P_O_Box_Type__c 
                                                    FROM HexaBPM__Service_Request__c 
                                                    WHERE Id = :createdSRList2[0].Id LIMIT 1];
            
            CheckOpenSR.CheckOpenSRExists(objSR);
        test.stopTest();
    }
    static testmethod void checkOpenPoBoxtest(){
    
        init();
        
        HexaBPM__SR_Template__c srtemp = new HexaBPM__SR_Template__c();
        srtemp.HexaBPM__Sub_menu__c = 'Visa Services';
        srtemp.HexaBPM__SR_RecordType_API_Name__c = 'Employment_Visa_New';
        insert srtemp;
    
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        insert newAccounts; 
        
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Employment_Visa_New');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].HexaBPM__Internal_SR_Status__c = lstSRStatus[0].Id;
        createdSRList[0].HexaBPM__External_SR_Status__c = lstSRStatus[0].Id;
        createdSRList[0].HexaBPM__SR_Template__c = srtemp.Id; 
        createdSRList[0].P_O_Box_Type__c = 'EziMAIL Gold';
        insert createdSRList;
        
        test.startTest();
            List<HexaBPM__Service_Request__c> createdSRList2 = TestUtility.createSR(1,'Employment_Visa_New');
            
            createdSRList2[0].HexaBPM__Customer__c = newAccounts[0].Id;
            createdSRList2[0].HexaBPM__Internal_SR_Status__c = lstSRStatus[0].Id;
            createdSRList2[0].HexaBPM__External_SR_Status__c = lstSRStatus[0].Id;
            createdSRList2[0].HexaBPM__SR_Template__c = srtemp.Id; 
            createdSRList2[0].P_O_Box_Type__c = 'EziMAIL Gold';
            insert createdSRList2;
            
            HexaBPM__Service_Request__c objSR = [SELECT Id, RecordtypeId, HexaBPM__Customer__c, HexaBPM__SR_Template__r.HexaBPM__Sub_menu__c, HexaBPM__Contact__c, Dependent__c, 
                                                    Passport_Issue_Date__c, Passport_Expiry_Date__c, Country_of_Issue__c, Place_of_Issue__c, First_Name__c, Title__c, 
                                                    Middle_Name__c, HexaBPM__Record_Type_Name__c,HexaBPM__IsClosedStatus__c,HexaBPM__IsCancelled__c, HexaBPM__Is_Rejected__c, 
                                                    HexaBPM__Internal_SR_Status__r.Name, P_O_Box_Type__c
                                                    FROM HexaBPM__Service_Request__c 
                                                    WHERE Id = :createdSRList2[0].Id LIMIT 1];
            
            CheckOpenSR.CheckOpenSRExists(objSR);
        test.stopTest();
    }
    
    static testmethod void checkOpenOthertest(){
    
        init();
        
        HexaBPM__SR_Template__c srtemp = new HexaBPM__SR_Template__c();
        srtemp.HexaBPM__Sub_menu__c = 'Visa Services';
        srtemp.HexaBPM__SR_RecordType_API_Name__c = 'Employment_Visa_New';
        insert srtemp;
    
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        insert newAccounts; 
        
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Employment_Visa_New');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].HexaBPM__Internal_SR_Status__c = lstSRStatus[0].Id;
        createdSRList[0].HexaBPM__External_SR_Status__c = lstSRStatus[0].Id;
        createdSRList[0].HexaBPM__SR_Template__c = srtemp.Id; 
        insert createdSRList;
        
        test.startTest();
            List<HexaBPM__Service_Request__c> createdSRList2 = TestUtility.createSR(1,'Employment_Visa_New');
            
            createdSRList2[0].HexaBPM__Customer__c = newAccounts[0].Id;
            createdSRList2[0].HexaBPM__Internal_SR_Status__c = lstSRStatus[0].Id;
            createdSRList2[0].HexaBPM__External_SR_Status__c = lstSRStatus[0].Id;
            createdSRList2[0].HexaBPM__SR_Template__c = srtemp.Id; 
            insert createdSRList2;
            
            HexaBPM__Service_Request__c objSR = [SELECT Id, RecordtypeId, HexaBPM__Customer__c, HexaBPM__SR_Template__r.HexaBPM__Sub_menu__c, HexaBPM__Contact__c, Dependent__c, 
                                                    Passport_Issue_Date__c, Passport_Expiry_Date__c, Country_of_Issue__c, Place_of_Issue__c, First_Name__c, Title__c, 
                                                    Middle_Name__c, HexaBPM__Record_Type_Name__c,HexaBPM__IsClosedStatus__c,HexaBPM__IsCancelled__c, HexaBPM__Is_Rejected__c, 
                                                    HexaBPM__Internal_SR_Status__r.Name, P_O_Box_Type__c
                                                    FROM HexaBPM__Service_Request__c 
                                                    WHERE Id = :createdSRList2[0].Id LIMIT 1];
            
            CheckOpenSR.CheckOpenSRExists(objSR);
        test.stopTest();
    }
}
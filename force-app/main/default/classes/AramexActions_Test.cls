@isTest
private class AramexActions_Test {
    
    public static List<HexaBPM__Status__c> createStepStatus() {
        Map<String, String> statusMap = new Map<String, String> {
            'Submitted' => 'SUBMITTED',
            'Awaiting Approval' => 'AWAITING_APPROVAl',
            'Awaiting Review' => 'AWAITING_REVIEW',
            'Collected' => 'COLLECTED',
            'Closed' => 'CLOSED',
            'Completed' => 'COMPLETED',
            'Rejected' => 'REJECTED'
        };
        Map<String, String> typeMap = new Map<String, String> {
            'Submitted' => 'End',
            'Awaiting Approval' => 'Start',
            'Awaiting Review' => 'Start',
            'Collected' => 'End',
            'Closed' => 'End',
            'Completed' => 'End',
            'Rejected' => 'End'
        };
        HexaBPM__Status__c  status ;
        List<HexaBPM__Status__c> statusList =  new List<HexaBPM__Status__c>();
        for (String s :  statusMap.keySet()) {
            status = new HexaBPM__Status__c();
            status.HexaBPM__Type__c = typeMap.get(s);
            status.HexaBPM__Code__c  = statusMap.get(s);
            status.Name = s;
            statusList.add(status);
        }
        Database.Insert(statusList,false);
        return statusList;
    }


    public static List<HexaBPM__SR_Status__c> createSRStatus() {
        Map<String, String> statusMap = new Map<String, String> {
            'Draft' => 'DRAFT',
            'Submitted' => 'SUBMITTED',
            'Duplicate' => 'DUPLICATE',
            'Delivered' => 'DELIVERED',
            'Request Approved' => 'REQUEST_APPROVED',
            'Contact Client' => 'CONTACT_CLIENT',
            'Closed' => 'CLOSED',
            'Cancelled' => 'CANCELLED'
        };
        List<HexaBPM__SR_Status__c>  statusList = new List<HexaBPM__SR_Status__c>();
        HexaBPM__SR_Status__c status ;
        for (String s :  statusMap.keySet()) {
            status =  new HexaBPM__SR_Status__c();
            status.HexaBPM__Code__c = statusMap.get(s);
            status.Name = s;
            statusList.add(status);
        }
        Database.Insert(statusList,false);
        return statusList;
    }
    
    
    @testSetup static void setupData() {
     
      
      createStepStatus();
      createSRStatus();
      
      
      
      List<HexaBPM__Status__c> statusList = [Select Id, HexaBPM__Code__c, Name from HexaBPM__Status__c];
      
      Account accObj = new Account();
      accObj.Name = 'Test Account';
      insert accObj;
      
      Contact c = new Contact();
      c.FirstName = 'FName';
      c.LastName = 'LName';
      c.AccountId = accObj.Id;
      insert c;
      
      HexaBPM__SR_Template__c SRTemplate = new HexaBPM__SR_Template__c();
      SRTemplate.Name = 'New Registration';
      SRTemplate.HexaBPM__Active__c = true;
      SRTemplate.HexaBPM__SR_RecordType_API_Name__c = 'New_Registration' ;
      SRTEmplate.HexaBPM__Menutext__c = 'Menu Text';
      SRTEmplate.HexaBPM__Sub_menu__c = 'Sub Menu';
      SRTemplate.HexaBPM__Sub_menu_section__c = 'Sub Menu Section';
      insert SRTemplate;
      
      HexaBPM__SR_Steps__c SRStep = new HexaBPM__SR_Steps__c();
      SRStep.HexaBPM__SR_Template__c = SRTemplate.Id;
      Insert SRStep;
      
      
      Id generalRTId = Schema.SObjectType.HexaBPM__Service_Request__c.getRecordTypeInfosByName().get('Initial Approval').getRecordTypeId();
      HexaBPM__Service_Request__c SR = new HexaBPM__Service_Request__c();
      SR.RecordTypeId = generalRTId;
      SR.HexaBPM__Email__c = 'hexabpm@hexabpm.com';
      SR.HexaBPM__Customer__c = accObj.Id;
      insert SR;
      
      
      HexaBPM__Step_Template__c courierTemplate = new HexaBPM__Step_Template__c();
      courierTemplate.HexaBPM__Code__c = 'COURIER';
      courierTemplate.HexaBPM__Step_RecordType_API_Name__c = 'General';
      courierTemplate.Name = 'Courier';
      insert courierTemplate;
      
      
      Id stepRTId = Schema.SObjectType.HexaBPM__Step__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
      HexaBPM__Step__c stp  = new HexaBPM__Step__c();
      stp.HexaBPM__Step_No__c = 1;
      stp.HexaBPM__SR__c  = SR.Id;
      stp.HexaBPM__Status__c =  statusList[0].Id;
      stp.HexaBPM__Step_Template__c = courierTemplate.id;
      stp.RecordTypeId = stepRTId; 
      insert stp;
      
   }
    
    
    
    
    @isTest static void test_method_one() {
        // Implement test code
        
        
        HexaBPM__Step__c stp = [SELECT id from HexaBPM__Step__c LIMIT 1];
        Test.setMock(WebServiceMock.class, new AramexShippingServicesMockTest('CANCELPICKUP'));
        AramexActions obj = new AramexActions();
        Test.startTest();
        
           AramexActions.cancelPickupRequest(stp.Id,'CANCELPICKUP');
        Test.stopTest();
        
        
        
    }
    
    @isTest static void test_ShipmentLabelAndPickupRequest() {
        HexaBPM__Step__c stp = [SELECT id from HexaBPM__Step__c LIMIT 1];
        Test.setMock(WebServiceMock.class, new AramexShippingServicesMockTest('SHIPPINGREQUEST'));
        AramexActions obj = new AramexActions();
        Test.startTest();
           
           AramexActions.createShipmentLabelAndPickupRequest(stp.Id);
        Test.stopTest();
    }
    @isTest static void test_ShipmentLabelAndPickupRequestNullNotification() {
        HexaBPM__Step__c stp = [SELECT id from HexaBPM__Step__c LIMIT 1];
        Test.setMock(WebServiceMock.class, new AramexShippingServicesMockTest('SHIPPINGREQUESTNULLNOTIFICATION'));
        AramexActions obj = new AramexActions();
        Test.startTest();
        
           AramexActions.ShipmentLabelAndPickupRequest(stp.Id);
        Test.stopTest();
    }
    
    @isTest static void test_ShipmentLabelAndPickupRequestCreateLabel() {
        HexaBPM__Step__c stp = [SELECT id from HexaBPM__Step__c LIMIT 1];
        stp.Aramex_Shipping_ID__c = '123456';
        update stp;
        Test.setMock(WebServiceMock.class, new AramexShippingServicesMockTest('PRINTLABEL'));
        AramexActions obj = new AramexActions();
        Test.startTest();
        
           AramexActions.ShipmentLabelAndPickupRequest(stp.Id);
        Test.stopTest();
    }
    @isTest static void test_UpdateAramexShipmentLabel() {
        HexaBPM__Step__c stp = [SELECT id from HexaBPM__Step__c LIMIT 1];
        stp.Aramex_Shipping_ID__c = '123456';
        update stp;
        Test.setMock(WebServiceMock.class, new AramexShippingServicesMockTest('PRINTLABEL'));
        AramexActions obj = new AramexActions();
        Test.startTest();
        
           AramexActions.updateAramexShipmentLabel(stp.Id,stp.Aramex_Shipping_ID__c);
        Test.stopTest();
    }
    
    @isTest static void test_ShipmentLabelAndPickupRequest_PickupRequest() {
        HexaBPM__Step__c stp = [SELECT id from HexaBPM__Step__c LIMIT 1];
        stp.Aramex_Shipping_ID__c = '123456';
        stp.Aramex_Shipment_Label_URL__c = 'http://www.test.com';
        update stp;
        Test.setMock(WebServiceMock.class, new AramexShippingServicesMockTest('PICKUPREQUEST'));
        AramexActions obj = new AramexActions();
        Test.startTest();
           AramexActions.ShipmentLabelAndPickupRequest(stp.Id);
        Test.stopTest();
    }
    
        @isTest static void test_getPickupInformation() {
        HexaBPM__Step__c stp = [SELECT id from HexaBPM__Step__c LIMIT 1];
        stp.Aramex_Pickup_Request_Date__c = System.Today();
        update stp;
        AramexActions obj = new AramexActions();
        AramexWebserviceUtil serviceObj  = new AramexWebserviceUtil(stp.Id);
        Test.startTest();
             
            AramexActions.getPickupInformation(true,false,System.Now());
            stp.Aramex_Pickup_Request_Date__c = System.Today().addDays(1);
            update stp;
            AramexActions.getPickupInformation(false,true,System.Now());
        Test.stopTest();
    }
    
    
    @isTest static void test_getAllFields() {
        HexaBPM__Step__c stp = [SELECT id from HexaBPM__Step__c LIMIT 1];
    
        Test.startTest();
           AramexActions.getAllFields(HexaBPM__Step__c.getSObjectType().getDescribe());
        Test.stopTest();
    }
    
    @isTest static void test_hasPickupRequestCreated() {
        HexaBPM__Step__c stp = [SELECT id from HexaBPM__Step__c LIMIT 1];
        stp.Aramex_Pickup_Request_Date__c = System.Today();
        Test.startTest();
           AramexActions.hasPickupRequestCreated(System.Today());
        Test.stopTest();
    }
    
    
}
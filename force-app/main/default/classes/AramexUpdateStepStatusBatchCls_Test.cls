@isTest
private class AramexUpdateStepStatusBatchCls_Test {
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
     
      
       List<HexaBPM__Status__c> stepStatusList = createStepStatus();
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
      
      HexaBPM__Status__c stepStatusFrom  = new HexaBPM__Status__c();
      HexaBPM__Status__c stepStatusTo  = new HexaBPM__Status__c();
      for(HexaBPM__Status__c status : [SELECT Id,HexaBPM__Code__c from HexaBPM__Status__c  ]){
          
          if(status.HexaBPM__Code__c == 'AWAITING_APPROVAl'){
              stepStatusFrom = status;
              
          }else if(status.HexaBPM__Code__c == 'COMPLETED'){
              stepStatusTo = status;
          }
      }
      
      HexaBPM__Transition__c transition = new HexaBPM__Transition__c();
      transition.HexaBPM__From__c  = stepStatusFrom.Id;
      transition.HexaBPM__To__c  = stepStatusTo.Id;
      transition.HexaBPM__Transition_Code__c = 'NEW_TRANSITION';
      insert transition;

      HexaBPM__Step_Transition__c  stepTransition  =  new HexaBPM__Step_Transition__c();
      stepTransition.HexaBPM__SR_Step__c =  SRStep.Id;
      stepTransition.HexaBPM__SR_Template__c = SRTemplate.Id;
      stepTransition.HexaBPM__Transition__c = transition.Id;
      insert stepTransition;

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
      stp.HexaBPM__Status__c =  stepStatusFrom.Id;
      stp.HexaBPM__Step_Template__c = courierTemplate.id;
      stp.HexaBPM__SR_Step__c = SRStep.Id;
      stp.RecordTypeId = stepRTId; 
      insert stp;
      
   }
    @isTest static void test_method_one() {
        
        HexaBPM__Step__c stp = [SELECT id from HexaBPM__Step__c LIMIT 1];
        stp.Aramex_Shipping_ID__c = '123456';
        stp.Aramex_Shipment_Status__c = 'Record created.';
        update stp;
       
        Test.setMock(WebServiceMock.class, new AramexTrackingServicesMockTest('TRACKSHIPMENTS'));
        AramexWebserviceUtil utilobj = new AramexWebserviceUtil(stp.id);

        Test.startTest();
        
           AramexUpdateStepStatusBatchCls obj = new AramexUpdateStepStatusBatchCls();
           obj.shipmentStatus = 'Record created.';
           Database.executeBatch(obj,10);
            obj.RecurringScheduleJob();


        Test.stopTest();

    }
    
    @isTest static void test_method_two() {
        // Implement test code
    }
    
}
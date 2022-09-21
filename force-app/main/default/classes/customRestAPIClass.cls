@RestResource(urlMapping='/api/students__c/true')
     global class customRestAPIClass { 
 @HttpGet 
     global static students__c doGet()
 {
     RestRequest req = RestContext.request; 
     students__c student = [SELECT Id, Name, class_no__c, mobile_number__c, Email_id__c FROM students__c WHERE Aadhar_mandatory_del__c =: True]; 
     return student ; 
  }
@HttpPost 
     global static String DoPost()
 {
     students__c acc = new students__c(); 
     acc.name = ''; 
     acc.class_no__c = '';
     acc.mobile_number__c = '';
     acc.Email_id__c = '';
     insert acc; 
     return acc.id; 
  } 
}
@RestResource(urlMapping='/api/Account/*')
     global class MyFirstRestAPIClass { 
 @HttpGet 
     global static Account doGet()
 {
     RestRequest req = RestContext.request; 
     String AccNumber = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1); 
     Account result = [SELECT Id, Name, Phone, Website FROM Account WHERE AccountNumber = '12345']; 
     return result; 
  }
 
 @HttpDelete 
     global static void doDelete() 
 { 
     RestRequest req = RestContext.request; 
     RestResponse res = RestContext.response; 
     String AccNumber = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1); 
     List<Account> result = new List<Account>();
   result = [SELECT Id, Name, Phone, Website FROM Account WHERE name='Blackbeards Coconut Milk Emporium']; 
     delete result; 
  } 
  
 @HttpPost 
     global static String doPost(String name,String phone,String AccountNumber )
 {
     Account acc = new Account(); 
     acc.name= name; 
     acc.AccountNumber =AccountNumber ;
     insert acc; 
     return acc.id; 
  } 
}
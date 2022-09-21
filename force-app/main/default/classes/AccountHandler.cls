public class AccountHandler {
    
    public static Account insertNewAccount(string name){
        account a = new account();
        a.Name = Name;
  
   try{
         insert a;
           } catch (DmlException e) {
                return null;
        }
            return a;
    }
    }
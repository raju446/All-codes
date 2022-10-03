public without sharing class WelcomeTextHelper 
{
    public string UId {get;set;}
    //public string welcomeText;
    public WelcomeTextHelper () 
    {
        
    }
     public string getwelcomeText() 
     {
         list<User> usr = [Select Profile.Name FROM User where Id=:UId];
         if(!usr.isEmpty())
         {
             string profName = usr[0].Profile.Name;
             if(profName == 'ADGM Guest User')
             {
                return 'event and exhibition permits and ADGM letter requests.';
             }else{
                return 'company’s government related services.';
             }
         }
         return '';
       
     }
    
}
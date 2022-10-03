public class EntityResponse
{
    public string LicensNumber;
    public string EntityName;
    public string EntityNameAr;
    public Date LicenseIssueDate;
    public Date LicenseExpiryDate;
    public string EntityStatus;
    public string EntityType;
    public string EntitySubType;
    public string Category;
    //public Decimal TotalAuthorisedSignatories;
    
    
    public Address Address;
    
    //public string FSPNumber;
    //public string Website;
    //public string Email;
    //public string Telephone;
    public list<Activity> Activities;
    //public list<Signatory> Roles;
    //public list<TradeName> TradeNames;

    public class Address
    {
       // public string Type;
        public string BuildingName;
        //public string Country;
        public string Emirates;
        public string Floor;
        public string OfficeNumber;
        public string Area;  
        public string StreetNameofClusterontheIsland;       
    }
    
    public class Activity
    {
        public string ActivityName;
        public string ActivityNameAr;
        public string ActivityCode;
        //public string Type;
             
    }
    
    /*public class Signatory
    {
        public string Forename;
        //public string Type;
        public string Title;
        public string ForenamesAr;
        public string Surname;
        public string SurnameAr;
        public string CountryofResidence;
        public string Nationality;
        public string Status;
        public string Role;
        public string Capacity;     
    }*/
    
    /*
    public class TradeName
    {
        public string TradeNameEn;
        public string TradeNameAr;
        public string Status;
        public boolean Primary;
    }*/
}
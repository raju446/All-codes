/*
    Author      : Rajil Ravindran
    Date        : 16-Nov-2017
    Description : Controller class to display the Authorised Signatories and Employees.
    
    Modified Date : 3/3/2019
    Description : Added Cancelled Employees section and Transferred employees section.

	Modified Date : 25-Aug-2019
    Description : Added download employee detail function
    --------------------------------------------------------------------------------------
*/
public without sharing class CompanyProfileController{

    //public Account acc {get;set;}
    
    public String accId {get;set;}
    //public List<Contact> authorisedSignatoriesList {get;set;}
    public Integer noOfEmpRecords{get; set;}
    public Integer empSize{get;set;}
    public Integer noOfSignatoryRecords{get; set;}
    public Integer signatorySize{get;set;}
    public Integer noPOBoxRecords{get; set;}
    public Integer POBoxSize{get;set;}
    public string searchValue {get;set;}
    private string queryString {get;set;}
    public boolean isVisaServiceIncluded {get;set;}
    public ApexPages.StandardSetController setEmployeesCon {get;set;}
    //
    public Integer cancelledEmpSize {get;set;}
    public Integer trEmployeessize {get;set;}
    public Integer noCERecords {get; set;}
    public Integer noTeRecords {get;set;}
    
    public CompanyProfileController(ApexPages.StandardController stdController){
        string loggedInUserAccountId;
        isVisaServiceIncluded = false;
        list<User> lstUser = [Select contact.accountid from User where id =: Userinfo.getUserid() limit 1];
        if(!lstUser.IsEmpty()){
            loggedInUserAccountId = lstUser[0].contact.accountid;
            accId = loggedInUserAccountId;
            ApexPages.currentPage().getParameters().put('id',loggedInUserAccountId);
        }
        Set<string> accessibleMenuSet = new Set<string>();
        list<HexaBPM__SR_Template__c> menuServicesList = new list<HexaBPM__SR_Template__c>();
        menuServicesList = HelperUtil.getAccessibleMenu();
        if(menuServicesList.size() > 0){
            for(HexaBPM__SR_Template__c srTemplate : menuServicesList){
                if(String.isNotBlank(srTemplate.HexaBPM__Sub_menu_section__c))
                    accessibleMenuSet.add(srTemplate.HexaBPM__Sub_menu_section__c.toLowerCase());
            }
        }
        //Show the employee section if there is "visa services" added to the contact.
        if(accessibleMenuSet.contains('visa services')){
            isVisaServiceIncluded = true;
            searchEmployees();
        }
    }
    public ApexPages.StandardSetController setPOBoxCon {
        get{
            if(setPOBoxCon == null){
                POBoxSize= 10;
                string queryString = 'SELECT Id, name, PO_Box_Number__c,status__c, P_O_Box_Selected_Bundle__c, Sys_Type__c, Start_Date__c, Expiry_Date__c FROM PO_Box__c WHERE Account__c = :accId AND (Status__c = \'Allocated\' OR Status__c = \'Cancelled\') limit 3000';
                System.debug('queryString '+queryString );
                setPOBoxCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setPOBoxCon.setPageSize(POBoxSize);
                noPOBoxRecords= setPOBoxCon.getResultSize();
            }
            return setPOBoxCon;
        }set;
    }
    public List<PO_Box__c> getPOBoxes(){
        List<PO_Box__c> poBoxList= new List<PO_Box__c>();
        for(PO_Box__c objPOBox : (List<PO_Box__c>)setPOBoxCon.getRecords()){
            poBoxList.add(objPOBox);
        }
        return poBoxList;
    }
    
    
    //Cancelled Employees section..
    public ApexPages.StandardSetController setCancelledEmployeesCon {
        get{
            if(setCancelledEmployeesCon == null){
                cancelledEmpSize= 10;
                string status = 'Cancelled';
                string queryString = 'SELECT Id, FirstName, LastName, Email, Job_Title__c, Passport_No__c, Nationality__c , Employment_Status__c,Sponsor__r.Name FROM Contact WHERE  Employment_Status__c = :status and Accountid=:accId LIMIT 2000';
                System.debug('queryString '+queryString );
                setCancelledEmployeesCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setCancelledEmployeesCon.setPageSize(cancelledEmpSize);
                noCERecords= setCancelledEmployeesCon.getResultSize();
            }
            return setCancelledEmployeesCon;
        }set;
    }
    public List<Contact> getCancelledEmployees(){
        List<Contact> conlist = new List<Contact>();
        for(Contact con : (List<Contact>)setCancelledEmployeesCon.getRecords()){
            conlist.add(con);
        }
        return conlist;
    }
    
    //Transferred employees section..
    
    public ApexPages.StandardSetController setTrEmployeesCon {
        get{
            if(setTrEmployeesCon == null){
                trEmployeessize = 10;
                string queryString = 'SELECT Id, Name, Employee_Email_ID__c,Job_Title__c, Passport_Number__c,Residence_Visa_Number__c, Nationality__c  FROM Transferred_Employees__c WHERE  Account__c = :accId LIMIT 2000';
                
                setTrEmployeesCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setTrEmployeesCon.setPageSize(trEmployeessize);
                noTeRecords= setTrEmployeesCon.getResultSize();
            }
            return setTrEmployeesCon;
        }set;
    }
    public List<Transferred_Employees__c> getTeEmployees(){
        List<Transferred_Employees__c> trlist = new List<Transferred_Employees__c>();
        for(Transferred_Employees__c tr : (List<Transferred_Employees__c>)setTrEmployeesCon.getRecords()){
            trlist.add(tr);
        }
        return trlist;
    }
    
    
    public List<Contact> getEmployees(){
        System.debug('getting employees');
        List<Contact> employeesList = new List<Contact>();
        //Set<Id> contactIds = new Set<Id>();
        for(Contact objCon : (List<Contact>)setEmployeesCon.getRecords()){
            employeesList.add(objCon);
        }
        return employeesList;
    }
    public Integer getEmpTotalPages() {
        return Integer.valueof(Math.ceil((Double) noOfEmpRecords / empSize));
    }
    /*public Integer getSignatoryTotalPages() {
        return Integer.valueof(Math.ceil((Double) noOfSignatoryRecords/ signatorySize));
    }*/
    public Integer getPOBoxTotalPages() {
        return Integer.valueof(Math.ceil((Double) noPOBoxRecords/ POBoxSize));
    }
    public Integer getCETotalPages() {
        return Integer.valueof(Math.ceil((Double) noCERecords/ cancelledEmpSize));
    }
    public Integer getTeTotalPages() {
        return Integer.valueof(Math.ceil((Double) noTeRecords/ trEmployeessize));
    } 
    
    public void searchEmployees(){
        empSize = 10;
        string status = 'Active';
        queryString = 'SELECT Id, FirstName, LastName, Email, Job_Title__c, Passport_No__c, Nationality__c , Employment_Status__c,Sponsor__r.Name FROM Contact WHERE AccountId = :accId AND Employment_Status__c <> null and Employment_Status__c=:status limit 3000';
        System.debug('searchValue'+searchValue);
        List<List<SObject>>searchList;
        List<Contact> lContacts = new List<Contact>();
        if(String.isNotEmpty(searchValue))
        {
            for(Contact contact : [SELECT Id, FirstName, LastName, Email, Job_Title__c, Passport_No__c, Nationality__c , Employment_Status__c,Sponsor__r.Name FROM Contact 
                                    WHERE AccountId = :accId AND Employment_Status__c <> null and Employment_Status__c=:status limit 10000]){
                if((String.isNotBlank(contact.FirstName) && contact.FirstName.indexOfIgnoreCase(searchValue) > -1) || (String.isNotBlank(contact.LastName) && contact.LastName.indexOfIgnoreCase(searchValue) > -1)){
                    lContacts.add(contact);
                }
            }
            setEmployeesCon = new ApexPages.StandardSetController(lContacts);
        }
        else
            setEmployeesCon = new ApexPages.StandardSetController(Database.query(queryString));
        setEmployeesCon.setPageSize(empSize);
        noOfEmpRecords= setEmployeesCon.getResultSize();
    }
    /*
    Name : exportEmpData
    Description : Used to download employee detail
    */
    public PageReference exportEmpData () {
        PageReference pageRef = new PageReference('/apex/EmployeeDetails?id='+accId);
		pageRef.setRedirect(true);
		return pageRef;
    }
}
public without sharing class ChartController{

    string loggedInUserAccountId;
    string ContactId;
    public string monthDataJSON {get;set;}
    public string caseDataJSON {get;set;}
    public string serviceRequestStatusJSON {get;set;}
    public string expiringVisaJSON {get;set;}
    public boolean IsGuestUser{get;set;}
    public list<string> lstAccessibleSRTemplateId;
    public ChartController(){
        for(User usr:[Select ContactId,contact.accountid,contact.Is_Guest_User__c from User where id =: Userinfo.getUserid()]){
            if(usr.ContactId!=null){
                ContactId = usr.ContactId;
                IsGuestUser = usr.contact.Is_Guest_User__c;
                loggedInUserAccountId = usr.contact.accountid;
            }
        }
        lstAccessibleSRTemplateId = new list<string>();
        list<HexaBPM__SR_Template__c> menuServicesList = new list<HexaBPM__SR_Template__c>();
        menuServicesList = HelperUtil.getAccessibleMenu();
        if(menuServicesList.size() > 0){
            for(HexaBPM__SR_Template__c srTemplate : menuServicesList){
                lstAccessibleSRTemplateId.add(srTemplate.id);
            }
        }
    }
    //Visa Status Chart Data - Gets the open and closed service request data
    public void prepareVisaChart(){ 
        map<integer,MonthData> mapMonthData = new map<integer,MonthData>();
        list<HexaBPM__Service_Request__c> lstServiceRequest = new list<HexaBPM__Service_Request__c>();
        lstServiceRequest = [select HexaBPM__IsClosedStatus__c,HexaBPM__Is_Rejected__c,HexaBPM__IsCancelled__c,CreatedDate from HexaBPM__Service_Request__c where HexaBPM__Parent_SR__c = '' and HexaBPM__SR_Template__c in :lstAccessibleSRTemplateId and HexaBPM__Customer__c =:loggedInUserAccountId and CreatedDate=LAST_N_DAYS:60 limit 10000];
        for(HexaBPM__Service_Request__c sr : lstServiceRequest){
            MonthData monthData = new MonthData();
            if(sr.HexaBPM__IsClosedStatus__c == false && sr.HexaBPM__Is_Rejected__c == false && sr.HexaBPM__IsCancelled__c == false){ //these are open service request
                if(!mapMonthData.containsKey(sr.CreatedDate.Month())){
                    mapMonthData.put(sr.CreatedDate.Month(), new MonthData());
                }
                monthData = mapMonthData.get(sr.CreatedDate.Month());
                monthData.iOpen += 1;
                mapMonthData.put(sr.CreatedDate.Month(), monthData);
                
            }
            else{ //Closed SR request
                if(!mapMonthData.containsKey(sr.CreatedDate.Month())){
                    mapMonthData.put(sr.CreatedDate.Month(), new MonthData());
                }
                monthData = mapMonthData.get(sr.CreatedDate.Month());
                monthData.iClose += 1;
                mapMonthData.put(sr.CreatedDate.Month(), monthData);

            }
        }
        monthDataJSON = JSON.serialize(mapMonthData);
    }
    //Case Statistics Data
    public void prepareCaseChartData(){
        map<integer,MonthData> mapMonthData = new map<integer,MonthData>();
        list<Case> lstCases = [select IsClosed, CreatedDate from Case where CreatedDate = LAST_N_DAYS:60 and ContactId=:ContactId  limit 50000];
        for(Case caseObj: lstCases){
            MonthData monthData = new MonthData();
            if(caseObj.IsClosed == false){ //Open Cases
                if(!mapMonthData.containsKey(caseObj.CreatedDate.Month())){
                    mapMonthData.put(caseObj.CreatedDate.Month(), new MonthData());
                }
                monthData = mapMonthData.get(caseObj.CreatedDate.Month());
                monthData.iOpen += 1;
                mapMonthData.put(caseObj.CreatedDate.Month(), monthData);
            }
            else{ //Closed Cases
                if(!mapMonthData.containsKey(caseObj.CreatedDate.Month())){
                    mapMonthData.put(caseObj.CreatedDate.Month(), new MonthData());
                }
                monthData = mapMonthData.get(caseObj.CreatedDate.Month());
                monthData.iClose += 1;
                mapMonthData.put(caseObj.CreatedDate.Month(), monthData);
            }
        }
        caseDataJSON = JSON.serialize(mapMonthData);
    }
    //Service Request Pie chart 
    public void prepareSRPieChart(){
        Integer cnt = 0;
        string serviceType;
        map<string,integer> mapSRStatusCount = new map<string,integer>();
        AggregateResult[] groupedServiceRequest = [select count(id) cntId,HexaBPM__SR_Template__r.HexaBPM__Sub_menu_section__c serviceType, HexaBPM__Internal_SR_Status__r.Name srstatus,HexaBPM__IsCancelled__c cancelled,HexaBPM__IsClosedStatus__c closed,HexaBPM__Is_Rejected__c rejected from HexaBPM__Service_Request__c where CreatedDate = LAST_N_DAYS:60 
                                     and HexaBPM__Customer__c=:loggedInUserAccountId and HexaBPM__SR_Template__c in :lstAccessibleSRTemplateId and HexaBPM__Parent_SR__c = '' and HexaBPM__SR_Template__r.HexaBPM__Sub_menu_section__c in ('Letters & Permits','Company Services','Visa Services') and ( HexaBPM__IsClosedStatus__c=false and HexaBPM__IsCancelled__c=false and HexaBPM__Is_Rejected__c=false) group by HexaBPM__SR_Template__r.HexaBPM__Sub_menu_section__c,HexaBPM__Internal_SR_Status__r.Name,HexaBPM__IsCancelled__c,HexaBPM__IsClosedStatus__c,HexaBPM__Is_Rejected__c];
        for(AggregateResult  ar : groupedServiceRequest){
            if(string.isNotEmpty(String.valueOf(ar.get('serviceType')))){
                serviceType = String.valueOf(ar.get('serviceType'));
                cnt = ar.get('cntId') != null ? Integer.valueOf(ar.get('cntId')) : 0;
                mapSRStatusCount.put(serviceType,cnt);
            }
        }
        serviceRequestStatusJSON = JSON.serialize(mapSRStatusCount);
    }
    //Preparing visas expiring and due for renewals in the next 60 days //expiring in 10, 20, 30, 50 ,60
    public void prepareVisaExpiring_Due_Chart(){
        Integer cnt = 0;
        string strDays;
        integer diffDays = 0;
        map<string,integer> mapVisaExpiringCount = new map<string,integer>();
        mapVisaExpiringCount.put('60 days',0);
        mapVisaExpiringCount.put('50 days',0);
        mapVisaExpiringCount.put('40 days',0);
        mapVisaExpiringCount.put('30 days',0);
        mapVisaExpiringCount.put('20 days',0);
        mapVisaExpiringCount.put('10 days',0);
        Date todaysDate = System.today();
        Date limitDate = System.today().addDays(60);
        list<Document_Details__c> lstDocDetails = new list<Document_Details__c>();
        lstDocDetails = [select Document_Type__c,Document_Expiry_Date__c from Document_Details__c where Account__c = :loggedInUserAccountId 
                            and Document_Type__c = 'Residence Visa' and Document_Status__c = 'Active' and Document_Expiry_Date__c > :todaysDate and  Document_Expiry_Date__c < :limitDate ]; //covers 60 days data
        System.debug('lstDocDetails>>>>>>>>>>>>>>>');
        System.debug(lstDocDetails);
        for(Document_Details__c docDetail : lstDocDetails){
            cnt = 0;
            diffDays = todaysDate.daysBetween(docDetail.Document_Expiry_Date__c);
            if(docDetail.Document_Expiry_Date__c != null && diffDays <= 10){
                cnt = mapVisaExpiringCount.get('10 days');
                mapVisaExpiringCount.put('10 days',cnt + 1);
            }
            else if(docDetail.Document_Expiry_Date__c != null && diffDays <= 20){
                cnt = mapVisaExpiringCount.get('20 days');
                mapVisaExpiringCount.put('20 days',cnt + 1);
            }
            else if(docDetail.Document_Expiry_Date__c != null && diffDays <= 30){
                cnt = mapVisaExpiringCount.get('30 days');
                mapVisaExpiringCount.put('30 days',cnt + 1);
            }
            else if(docDetail.Document_Expiry_Date__c != null && diffDays <= 40){
                cnt = mapVisaExpiringCount.get('40 days');
                mapVisaExpiringCount.put('40 days',cnt + 1);
            }
            else if(docDetail.Document_Expiry_Date__c != null && diffDays <= 50){
                cnt = mapVisaExpiringCount.get('50 days');
                mapVisaExpiringCount.put('50 days',cnt + 1);
            }
            else if(docDetail.Document_Expiry_Date__c != null && diffDays <= 60){
                cnt = mapVisaExpiringCount.get('60 days');
                mapVisaExpiringCount.put('60 days',cnt + 1);
            }
        }
        expiringVisaJSON = JSON.serialize(mapVisaExpiringCount);
    }
    public class MonthData{
        public integer iOpen {get;set;}
        public integer iClose {get;set;}
        public MonthData()
        {
            iOpen = 0;
            iClose = 0;
        }
    }
}
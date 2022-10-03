public without sharing class ServicesController {
    public map<string,string> mapServiceFlows;
    public map<string,map<string,list<InnerMenu>>> EmployeeServiceRequestsMenu{set; get;} //Holds the entire services menu in the map and this map is used to populate the lstMainMenu[sorted]
    private map<string,InnerMenu> serviceRecordTypes;
    public map<string,string> mapServiceIcon{get;set;} //Holds the Services menu and the icon class name to show in VF Page.
    
    //Updated Code here..
    public list<InnerMenu> lstInnerMenu {set;get;}
    public list<Submenu> lstSubMenu {set;get;}
    public list<MainMenu> lstMainMenu {set;get;}
    public boolean preventSrCreation {get;set;}
    public string accountstatus {get;set;}

    public ServicesController(){
        mapServiceIcon = new map<string,string>();
        mapServiceFlows = new map<string,string>();
        for(HexaBPM__Page_Flow__c objFlow:[select id,HexaBPM__Record_Type_API_Name__c from HexaBPM__Page_Flow__c where HexaBPM__Record_Type_API_Name__c!=null]){
            mapServiceFlows.put(objFlow.HexaBPM__Record_Type_API_Name__c,objFlow.Id);
        }
        EmployeeServiceRequestsMenu = new map<string, map<string, list<InnerMenu>>>();
        preventSrCreation = false;
        
        for(User usr : [Select Contact.Accountid, Contact.Account.IsEntityChanged__c, contact.Account.Entity_Status__c from User where id=:Userinfo.getUserId() limit 1])
        {
            preventSrCreation = usr.Contact.Account.IsEntityChanged__c;
            accountstatus = usr.contact.Account.Entity_Status__c;
        }
        
    }
    public void LoadServices(){
        LoadRecordTypes();     
        System.debug('serviceRecordTypes'+serviceRecordTypes);
        list<HexaBPM__SR_Template__c> menuServicesList = HelperUtil.getAccessibleMenu(); 
        map<string, list<InnerMenu>> subSectionMap;
        integer seqNumber;
        
        set<string> srs = new set<string>{'Employment_Visa_New','Employment_Visa_Renewal','Employee_Change_of_Name','Employee_Change_of_Job_Title','Visa_Re_Stamping_on_Lost_Passport_Employee','Visa_Restamping_On_New_Damaged_Passport_Employee','Visa_Transfer'};
        
        set<string> activeSRs = new set<string>{'EChannel_Cancellation','Establishment_Card_Cancellation','P_O_Box_Cancellation','Employment_Visa_Cancellation','Report_Absconding_Employee','Withdraw_Absconding_Status_Employee','Temporary_Work_Permit_Cancellation','Dependent_Visa_Cancellation','Cancel_Full_Time_Non_Sponsored_Employee'};
        
        boolean isCancellationAllowed = false;
        if(accountstatus == 'Registration Inactive' || accountstatus == 'In Liquidation' || accountstatus == 'In receivership' || 
        accountstatus == 'Deregistered by Registrar' || accountstatus == 'Inactive')
        {
            isCancellationAllowed = true;
        }
        //
        set<string> deactivatedSRs = new set<string>();
        deactivatedSRs = InActiveServiceRequests__c.getAll().keyset();
        //
        for(HexaBPM__SR_Template__c a: menuServicesList){
            if(a.HexaBPM__SR_RecordType_API_Name__c!=null && serviceRecordTypes.get(a.HexaBPM__SR_RecordType_API_Name__c)!=null){
                seqNumber = 0;
                if(mapServiceIcon.containsKey(a.HexaBPM__Sub_menu_section__c)){
                    if(!string.isEmpty(a.Icon_Name__c))
                        mapServiceIcon.put(a.HexaBPM__Sub_menu_section__c,a.Icon_Name__c);
                }else{
                    mapServiceIcon.put(a.HexaBPM__Sub_menu_section__c,string.isEmpty(a.Icon_Name__c) ? 'no-icon' : a.Icon_Name__c);
                }
                if(a.HexaBPM__Template_Sequence_No__c != null)
                    seqNumber = Integer.valueOf(a.HexaBPM__Template_Sequence_No__c);
                
                System.debug('a.HexaBPM__SR_RecordType_API_Name__c->'+a.HexaBPM__SR_RecordType_API_Name__c);  
                System.debug('a.HexaBPM__Menutext__c->'+a.HexaBPM__Menutext__c); 
                System.debug('a.HexaBPM__Portal_Service_Request_Name__c->'+a.HexaBPM__Portal_Service_Request_Name__c);
                System.debug('serviceRecordTypes'+serviceRecordTypes);
                InnerMenu innerMenu = new InnerMenu(seqNumber,a.HexaBPM__SR_RecordType_API_Name__c, a.HexaBPM__Menutext__c,serviceRecordTypes.get(a.HexaBPM__SR_RecordType_API_Name__c).RecordId, a.HexaBPM__Portal_Service_Request_Name__c ); 
                System.debug('innerMenu '+innerMenu );
                if(a.HexaBPM__Is_Through_Flow__c==true && mapServiceFlows.get(a.HexaBPM__SR_RecordType_API_Name__c)!=null){
                    innerMenu.isFlow = true;
                    innerMenu.strFlowId = mapServiceFlows.get(a.HexaBPM__SR_RecordType_API_Name__c);
                }else{
                    innerMenu.isFlow = false;
                    innerMenu.strFlowId = null;
                }
                system.debug('==preventSrCreation=='+preventSrCreation+'====record type=='+a.HexaBPM__SR_RecordType_API_Name__c);
                innerMenu.MenuURL = Site.getPathPrefix()+'/'+Label.Service_Request_Object_Prefix+'/e?retURL=/apex/CommunityServices&RecordType='+innerMenu.RecordId+'&type='+innerMenu.API_NAME+'&service_request_title='+innerMenu.MenuTitle;
                
                
                if( (preventSrCreation == true && srs.contains(a.HexaBPM__SR_RecordType_API_Name__c)) ||
                    (isCancellationAllowed == true && !activeSRs.contains(a.HexaBPM__SR_RecordType_API_Name__c)) ||
                    (accountstatus == 'Deregistered' || accountstatus == 'Dissolved' || accountstatus == 'Continued outside ADGM') || 
                    (deactivatedSRs.contains(a.HexaBPM__SR_RecordType_API_Name__c))
                )
                {
                    innerMenu.preventSRCreation = true;
                    innerMenu.MenuURL = '';
                }
                
                
                //Constructing the EmployeeServiceRequestsMenu Map here - Services tree structure.
                if(!EmployeeServiceRequestsMenu.containsKey(a.HexaBPM__Sub_menu_section__c)) { //If new section, initialize the map with the first set of [subsection] values.
                    subSectionMap = new map<string, list<InnerMenu>>();
                    lstInnerMenu = new list<InnerMenu>();
                    lstInnerMenu.add(innerMenu);
                    subSectionMap.put(a.HexaBPM__Sub_menu__c,lstInnerMenu);
                    EmployeeServiceRequestsMenu.put(a.HexaBPM__Sub_menu_section__c,subSectionMap);
                }else{ //If main section exists in EmployeeServiceRequestsMenu
                    //If subsection doesn't exist, create new subsection with inner menu values.
                    if(!(EmployeeServiceRequestsMenu.get(a.HexaBPM__Sub_menu_section__c).containsKey(a.HexaBPM__Sub_menu__c))){
                        lstInnerMenu = new list<InnerMenu>();
                        lstInnerMenu.add(innerMenu);
                        EmployeeServiceRequestsMenu.get(a.HexaBPM__Sub_menu_section__c).put(a.HexaBPM__Sub_menu__c,lstInnerMenu);
                    }else{ //If section and subSection key exists in EmployeeServiceRequestsMenu, get the subSectionMap to add the new set of values [inner menus]
                        subSectionMap = new map<string, list<InnerMenu>>();
                        subSectionMap = EmployeeServiceRequestsMenu.get(a.HexaBPM__Sub_menu_section__c);
                        subSectionMap.get(a.HexaBPM__Sub_menu__c).add(innerMenu);
                    }
                }
            
            }
        }
        lstSubMenu = new list<Submenu>();
        lstMainMenu = new list<MainMenu>();
        
        list<InnerMenu> lstInnerMenuItem;
        map<string,list<InnerMenu>> mapInnerMenu;
        integer sequenceNumber ;
        string lowerCaseInnerMenu = '';
        for (String mainMenuName : EmployeeServiceRequestsMenu.keySet()){ 
            lstSubMenu = new list<Submenu>();
            mapInnerMenu = new map<string,list<InnerMenu>>();
            mapInnerMenu = EmployeeServiceRequestsMenu.get(mainMenuName);
            for(String innerMenu : mapInnerMenu.keySet()){
                lowerCaseInnerMenu = innerMenu.toLowerCase();
                sequenceNumber = 0;
                lstInnerMenuItem = new list<InnerMenu>();
                lstInnerMenuItem = mapInnerMenu.get(innerMenu);
                if(lstInnerMenuItem.size() > 0)
                    lstInnerMenuItem.sort();
                sequenceNumber = lstInnerMenuItem[0].SequenceNumber;
                Submenu subMenu = new Submenu(sequenceNumber,innerMenu,lstInnerMenuItem);
                lstSubMenu.add(subMenu);
            }
            if(lstSubMenu.size() > 0)
                lstSubMenu.sort();
            MainMenu mainMenu = new MainMenu(sequenceNumber,mainMenuName,lstSubMenu);
            lstMainMenu.add(mainMenu);
            if(lstMainMenu.size() > 0)
                lstMainMenu.sort();
        }
    }
    public void loadRecordTypes(){
        serviceRecordTypes = new map<string, InnerMenu>();
        integer i = 1;
        for(RecordType recordType: [Select id, Name, DeveloperName from RecordType WHERE sObjectType='HexaBPM__Service_Request__c' and IsActive=true]){
            serviceRecordTypes.put(recordType.DeveloperName,new InnerMenu(i,recordType.DeveloperName, recordType.Name, recordType.Id, recordType.Name));
            i++;
        }        
    }
    /* Main Menu Wrapper Class */
    public class MainMenu implements Comparable{
        public integer SeqNo {get;set;}
        public string mainMenuName {get;set;}
        public list<Submenu> lstSubmenu{get;set;}
        public MainMenu(integer pSeqNo, string pMainMenuName, list<Submenu> pLstSubmenu){
            SeqNo = pSeqNo;
            mainMenuName = pMainMenuName;
            lstSubmenu = pLstSubmenu;
        }
        
        public Integer compareTo(Object CompareToObj){
            MainMenu currentObj = (MainMenu)CompareToObj;
            if (this.SeqNo> currentObj.SeqNo) {
                return 1;
            }
            
            if (this.SeqNo== currentObj.SeqNo) {
                return 0;
            }
            
            return -1;
        }
        
    }
    /* Submenu Wrapper Class */
    public class Submenu implements Comparable{
        public integer SeqNo {get;set;}
        public string subMenuName {get;set;}
        public list<InnerMenu> lstInnerMenu{get;set;}
        public Submenu(integer pSeqNo, string psubMenuName, list<InnerMenu> pLstInnerMenu){
            SeqNo = pSeqNo;
            subMenuName = psubMenuName;
            lstInnerMenu = pLstInnerMenu;
        }
        
        public Integer compareTo(Object CompareToObj){
            Submenu currentObj = (Submenu)CompareToObj;
            if (this.SeqNo> currentObj.SeqNo) {
                return 1;
            }
            
            if (this.SeqNo== currentObj.SeqNo) {
                return 0;
            }
            
            return -1;
        }
        
    }
    
    /* Inner Menu Wrapper Class */
    public class InnerMenu implements Comparable {
        public string MenuTitle {set; get;}
        public string RecordId {set; get;}
        public string PortalServiceTitle {set;get;}
        public string MenuURL {set; get;}
        public string API_NAME {set; get;}
        public boolean preventSRCreation {get;set;}
        public integer SequenceNumber{get;set;}
        // properties for process flow
        public boolean isFlow{get;set;}
        public string strFlowId{get;set;}
        public InnerMenu(integer Seq,string APIName, string title, string id, string portalSRTitle){
            SequenceNumber = Seq;
            API_NAME = APIName;
            MenuTitle = title;
            RecordId = id;
            PortalServiceTitle = portalSRTitle;
            isFlow = false;
            preventSRCreation = false;
        }
        public Integer compareTo(Object CompareToObj){
            InnerMenu currentObj = (InnerMenu)CompareToObj;
            if (this.SequenceNumber> currentObj.SequenceNumber) {
                return 1;
            }
            
            if (this.SequenceNumber== currentObj.SequenceNumber) {
                return 0;
            }
            
            return -1;
        }
    }
}
/*
@Author			: Azmath
@Description	: To load the available services of AGTB.
@Version		: v1
*/
public without sharing class AGTB_ThirdPartyServicesController 
{
    public map<string,map<string,list<InnerMenu>>> EmployeeServiceRequestsMenu{set; get;} 
    private map<string,InnerMenu> serviceRecordTypes;
    public map<string,string> mapServiceIcon{get;set;} 
    
    public list<InnerMenu> lstInnerMenu {set;get;}
    public list<Submenu> lstSubMenu {set;get;}
    public list<MainMenu> lstMainMenu {set;get;}
    public string accountstatus {get;set;}
    public boolean prevSrCreation;
    public AGTB_ThirdPartyServicesController()
    {
        string accountid='';
        prevSrCreation = false;
        mapServiceIcon = new map<string,string>();
        set<string> categories = new set<string>{'Non-Financial (Category B)', 'Financial (Category A)'};
        EmployeeServiceRequestsMenu = new map<string, map<string, list<InnerMenu>>>();
        for(User usr : [Select Contact.Accountid, Contact.Account.IsEntityChanged__c, contact.Account.Entity_Status__c, contact.Account.Category__c from User where id=:Userinfo.getUserId() limit 1])
        {
            accountstatus = usr.contact.Account.Entity_Status__c;
            accountid = usr.contact.Accountid;
           if(usr.contact.Account.Category__c == null || (!categories.contains(usr.contact.Account.Category__c))){
                prevSrCreation = true;
           }
        }
        if(accountid != '' && prevSrCreation == false)
        {
            set<string> allowedActivities = AGTB_Activity_Codes__c.getAll().keyset();
            boolean isValidActivity = false;
            for(Business_Activity__c ba : [Select id, Activity_Code__c  FROM Business_Activity__c WHERE Entity__c=:accountid ])
            {
                if(ba.Activity_Code__c != null)
                {
                    string actCode = ba.Activity_Code__c.substringAfter('-');
                    if(allowedActivities.contains(actCode)){
                        isValidActivity = true;
                        break;
                    }
                }
            }
            prevSrCreation = !isValidActivity;
        }
    }
    public void LoadServices()
    {
        LoadRecordTypes();     
        System.debug('serviceRecordTypes'+serviceRecordTypes);
        list<HexaBPM__SR_Template__c> menuServicesList = [SELECT id,HexaBPM__Template_Sequence_No__c,HexaBPM__Portal_Service_Request_Name__c,HexaBPM__SR_RecordType_API_Name__c,HexaBPM__Menu__c,HexaBPM__Sub_menu_section__c,HexaBPM__Sub_menu__c, HexaBPM__Menutext__c,HexaBPM__Is_Through_Flow__c,
                                HexaBPM__SR_Instruction_URL__c,Icon_Name__c from HexaBPM__SR_Template__c where HexaBPM__Active__c=true and HexaBPM__Available_for_menu__c=true  and Required_Access__c='3rd Party Services' order by HexaBPM__Template_Sequence_No__c];
        map<string, list<InnerMenu>> subSectionMap;
        integer seqNumber;
        
        for(HexaBPM__SR_Template__c a: menuServicesList)
        {
            if(a.HexaBPM__SR_RecordType_API_Name__c!=null && serviceRecordTypes.get(a.HexaBPM__SR_RecordType_API_Name__c)!=null)
            {
                seqNumber = 0;
                if(mapServiceIcon.containsKey(a.HexaBPM__Sub_menu_section__c)){
                    if(!string.isEmpty(a.Icon_Name__c))
                        mapServiceIcon.put(a.HexaBPM__Sub_menu_section__c,a.Icon_Name__c);
                }else{
                    mapServiceIcon.put(a.HexaBPM__Sub_menu_section__c,string.isEmpty(a.Icon_Name__c) ? 'no-icon' : a.Icon_Name__c);
                }
                if(a.HexaBPM__Template_Sequence_No__c != null)
                    seqNumber = Integer.valueOf(a.HexaBPM__Template_Sequence_No__c);
                
                
                InnerMenu innerMenu = new InnerMenu(seqNumber,a.HexaBPM__SR_RecordType_API_Name__c, a.HexaBPM__Menutext__c,serviceRecordTypes.get(a.HexaBPM__SR_RecordType_API_Name__c).RecordId, a.HexaBPM__Portal_Service_Request_Name__c ); 
                System.debug('innerMenu '+innerMenu );
                innerMenu.isFlow = false;
                innerMenu.strFlowId = null;
                
                if(a.HexaBPM__SR_RecordType_API_Name__c == 'Expression_Of_Intereset_Basic_Info'){
                    innerMenu.MenuURL = Site.getPathPrefix()+'/apex/AGTB_AboutProduct';
                }
                
                if(!EmployeeServiceRequestsMenu.containsKey(a.HexaBPM__Sub_menu_section__c)) {
                    subSectionMap = new map<string, list<InnerMenu>>();
                    lstInnerMenu = new list<InnerMenu>();
                    lstInnerMenu.add(innerMenu);
                    subSectionMap.put(a.HexaBPM__Sub_menu__c,lstInnerMenu);
                    EmployeeServiceRequestsMenu.put(a.HexaBPM__Sub_menu_section__c,subSectionMap);
                }
                else{ 
                    if(!(EmployeeServiceRequestsMenu.get(a.HexaBPM__Sub_menu_section__c).containsKey(a.HexaBPM__Sub_menu__c))){
                        lstInnerMenu = new list<InnerMenu>();
                        lstInnerMenu.add(innerMenu);
                        EmployeeServiceRequestsMenu.get(a.HexaBPM__Sub_menu_section__c).put(a.HexaBPM__Sub_menu__c,lstInnerMenu);
                    }else{ 
                        subSectionMap = new map<string, list<InnerMenu>>();
                        subSectionMap = EmployeeServiceRequestsMenu.get(a.HexaBPM__Sub_menu_section__c);
                        subSectionMap.get(a.HexaBPM__Sub_menu__c).add(innerMenu);
                    }
                }
                innerMenu.preventSRCreation = prevSrCreation;
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
        for(RecordType recordType: [Select id, Name, DeveloperName from RecordType WHERE sObjectType='AGTB_Client_On_Board__c' and IsActive=true and (Name='Expression_Of_Intereset_Basic_Info' OR Name ='On_Board_Form_Full_Data')]){
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
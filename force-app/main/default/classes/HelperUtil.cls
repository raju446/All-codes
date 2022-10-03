public without sharing class HelperUtil{
    public static list<HexaBPM__SR_Template__c> getAccessibleMenu(){
        boolean isGuestUser;
        boolean isLicenseExpired;
        list<string> lstAccessibleMenu = new list<string>();
        string userServiceType;
        boolean isLeadAdmin;
        userServiceType = '';
        list<string> lstAccessibleService = new list<string>();
        isGuestUser = false;
        isLicenseExpired = false;
        isLeadAdmin = false;
        Id accountid;
        for(User usr:[select Contact.Is_Guest_User__c,Contact.Types_of_Services_Accessible__c,Role__c,Contact.Accountid from User where Id=:userinfo.getUserId() and ContactId!=null]){
            isGuestUser = usr.Contact.Is_Guest_User__c;
            accountid = usr.Contact.Accountid;
            userServiceType = usr.Contact.Types_of_Services_Accessible__c;
            if(String.isNotBlank(userServiceType)){
                lstAccessibleService.addAll(userServiceType.split(';'));
                userServiceType = usr.Contact.Types_of_Services_Accessible__c.toLowerCase();
            }
            if(String.isNotBlank(usr.Role__c) && usr.Role__c.toLowerCase() == 'lead admin')
                isLeadAdmin = true;
            if(lstAccessibleService != null && lstAccessibleService.size() > 0)
                lstAccessibleMenu = getAccessibleServicesMenu(lstAccessibleService);
        }
        list<HexaBPM__SR_Template__c> menuServicesList = new list<HexaBPM__SR_Template__c>();
        System.debug('isLeadAdmin>>>>>'+isLeadAdmin);
        System.debug(lstAccessibleMenu);
        if(isGuestUser)
        {
            /*if(isLicenseExpired)
                menuServicesList = [SELECT id,HexaBPM__Template_Sequence_No__c,HexaBPM__Portal_Service_Request_Name__c,HexaBPM__SR_RecordType_API_Name__c,HexaBPM__Menu__c,HexaBPM__Sub_menu_section__c,HexaBPM__Sub_menu__c, HexaBPM__Menutext__c,HexaBPM__Is_Through_Flow__c,
                            HexaBPM__SR_Instruction_URL__c,Icon_Name__c from HexaBPM__SR_Template__c where HexaBPM__Active__c=true and HexaBPM__Available_for_menu__c=true and (Visible_To__c INCLUDES ('Guest User') or Category__c='Cancellation') order by HexaBPM__Template_Sequence_No__c]; 
            else
                menuServicesList = [SELECT id,HexaBPM__Template_Sequence_No__c,HexaBPM__Portal_Service_Request_Name__c,HexaBPM__SR_RecordType_API_Name__c,HexaBPM__Menu__c,HexaBPM__Sub_menu_section__c,HexaBPM__Sub_menu__c, HexaBPM__Menutext__c,HexaBPM__Is_Through_Flow__c,
                            HexaBPM__SR_Instruction_URL__c,Icon_Name__c from HexaBPM__SR_Template__c where HexaBPM__Active__c=true and HexaBPM__Available_for_menu__c=true and (Visible_To__c INCLUDES ('Guest User') ) order by HexaBPM__Template_Sequence_No__c];*/
            
            for(HexaBPM__SR_Template__c temp : [SELECT id, HexaBPM__Template_Sequence_No__c, HexaBPM__Portal_Service_Request_Name__c, HexaBPM__SR_RecordType_API_Name__c,            HexaBPM__Menu__c, HexaBPM__Sub_menu_section__c, HexaBPM__Sub_menu__c, HexaBPM__Menutext__c, HexaBPM__Is_Through_Flow__c,
                            HexaBPM__SR_Instruction_URL__c, Icon_Name__c,Provide_Additional_Access__c,  (select id,Entity__c from Additional_Access__r) from HexaBPM__SR_Template__c where HexaBPM__Active__c=true and HexaBPM__Available_for_menu__c=true and (Visible_To__c INCLUDES ('Guest User') or Provide_Additional_Access__c = true) order by HexaBPM__Template_Sequence_No__c])
            {
                if(temp.Provide_Additional_Access__c == true && temp.Additional_Access__r != null && temp.Additional_Access__r.size()>0)
                {
                    for(Additional_Access__c add : temp.Additional_Access__r){
                        if(add.Entity__c == accountid){
                            menuServicesList.add(temp);
                        }
                    }
                }else
                    menuServicesList.add(temp);
            }
        }else{
                if(isLeadAdmin)
                    menuServicesList = [SELECT id,HexaBPM__Template_Sequence_No__c,HexaBPM__Portal_Service_Request_Name__c,HexaBPM__SR_RecordType_API_Name__c,HexaBPM__Menu__c,HexaBPM__Sub_menu_section__c,HexaBPM__Sub_menu__c, HexaBPM__Menutext__c,HexaBPM__Is_Through_Flow__c,
                                HexaBPM__SR_Instruction_URL__c,Icon_Name__c from HexaBPM__SR_Template__c where HexaBPM__Active__c=true and HexaBPM__Available_for_menu__c=true and Visible_To__c INCLUDES ('Company User') order by HexaBPM__Template_Sequence_No__c];
                else{                
                    for(HexaBPM__SR_Template__c srTemplate : [SELECT id,HexaBPM__Template_Sequence_No__c,HexaBPM__Portal_Service_Request_Name__c,HexaBPM__SR_RecordType_API_Name__c,HexaBPM__Menu__c,HexaBPM__Sub_menu_section__c,HexaBPM__Sub_menu__c, HexaBPM__Menutext__c,HexaBPM__Is_Through_Flow__c,
                                    HexaBPM__SR_Instruction_URL__c,Icon_Name__c,Required_Access__c from HexaBPM__SR_Template__c where HexaBPM__Active__c=true and HexaBPM__Available_for_menu__c=true and Required_Access__c in:lstAccessibleMenu and Visible_To__c INCLUDES ('Company User') order by HexaBPM__Template_Sequence_No__c])
                    {
                        system.debug('===='+userServiceType+'==='+srTemplate.Required_Access__c);
                        if(userServiceType.indexOf(srTemplate.Required_Access__c.toLowerCase()) < 0 || test.isRunningTest()){ //Not found
                            if(userServiceType.indexOf('permits services') > -1 && srTemplate.HexaBPM__Sub_menu__c == 'Permits' )
                                menuServicesList.add(srTemplate);
                            if(userServiceType.indexOf('visa & letter services') > -1 && 
                                (srTemplate.HexaBPM__Sub_menu__c == 'letters' || srTemplate.Required_Access__c == 'Visa Services' ))
                                menuServicesList.add(srTemplate);
                        }
                        else {
                            menuServicesList.add(srTemplate);
                        }
                    }
                }
            
        }
        return menuServicesList;
    }
    public static list<string> getAccessibleServicesMenu(list<string> lstAccessibleService){
        list<string> showMenu = new list<string>();
        for(AccessADGM_Portal_Setting__mdt menuSetting : [select Services_Menu__c from AccessADGM_Portal_Setting__mdt 
                                                    where Type_Of_Service__c in :lstAccessibleService]){
        showMenu.addAll(menuSetting.Services_Menu__c.split(';'));
        }
        return showMenu;
    }
}
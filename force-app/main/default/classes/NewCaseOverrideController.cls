/*
    Author      : Durga Prasad
    Company     : PwC
    Date        : 19-Dec-2017
    Description : New Case Override controller to open custom vf page for portal
    -------------------------------------------------------------------------
*/
public without sharing class NewCaseOverrideController{
    public boolean isPortal;
    public NewCaseOverrideController(ApexPages.StandardController controller) {
        isPortal = false;
        for(User usr:[select id,contactid from user where Id=:userinfo.getuserid() and ContactId!=null]){
            isPortal = true;
        }
    }
    public pagereference RedirectToCasePage(){
        pagereference pg;
        if(isPortal)
            pg = new pagereference('/apex/NewPortalCase?retURL=/500/');
       else
           pg = new pagereference('/apex/NewInternalCase?retURL=/500/');//have to show the recordtype selection custom screen
        /*
        else
            pg = new pagereference('/setup/ui/recordtypeselect.jsp?ent=Case&retURL=/500/o&save_new_url=/500/e?retURL=/500/');
        pg.setredirect(true);
        }*/
        //pg = new pagereference('/500/e?nooverride=1');
        pg.setredirect(true);
        return pg;
    }
}
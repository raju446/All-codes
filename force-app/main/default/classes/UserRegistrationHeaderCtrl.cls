/**************************************************************************************************
* Name               : PageFlowCSS Controller                                               
* Description        : A controller to configure the branding on the Page Flows.                                            
* Created By         : PwC - Lakshay                                                                        
* Created Date       : 02/May/2017                                                                                                                                           
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR                    DATE             Description                                                       
* 1.0         PwC - Lakshay           02/May/2017    
* 1.1         Yogesh Mahajan         06/June/2018        Added Logo URL Label                                             
**************************************************************************************************/
global with sharing class UserRegistrationHeaderCtrl{
    
    /**************************************************************************************************
     Variables used in the class
    **************************************************************************************************/
    global string NavigationPrimaryColor{get;set;} //Used to define the primary color used in the navbar header, buttons and left side navigation
    global string NavigationFontColor{get;set;} //Used to define the font color used in the header, buttons and left side navigation
    global string SectionHeaderColor{get;set;} //Used to define the color in page section headers.
    global string SectionHeaderFontColor{get;set;} ////Used to define the font color in page section headers.
    global string PrimaryLogoURL{get;set;} //Used to define the URL of the primary logo.
    global string SecondaryLogoURL{get;set;} // //Used to define the URL of the secondary logo.
    global UserRegistrationHeaderCtrl(){
        //5px solid #ac975e
        boolean hasRecord = false;
        SectionHeaderColor = '#ac975e';
        NavigationPrimaryColor = '#e0301e';
        NavigationFontColor = '#ffffff';
        SectionHeaderFontColor = '#ffffff';
        PrimaryLogoURL = Label.ADGM_Logo_URL;//'https://adgm-oss-dev--ADGMDev--c.cs81.content.force.com/servlet/servlet.ImageServer?id=01526000000Lrue&oid=00D2600000096ir&lastMod=1502350862000';
    }
}
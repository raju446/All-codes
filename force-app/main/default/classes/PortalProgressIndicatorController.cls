/*
 * Created on 01-04-2018
 * Author: Rajil Ravindran
 * Gets the Step Processes and the Time specs of the Service Requests 
 */
public without sharing class PortalProgressIndicatorController {
    public string strSRID;
    public list<StatusGroupWrap> lstStatusGroupWrap{get;set;}
    public string GroupWidth{get;set;}
    public decimal fineAmount {get;set;}
    public PortalProgressIndicatorController(ApexPages.StandardController stdController) {
        strSRID = String.escapeSingleQuotes(apexpages.currentPage().getParameters().get('Id'));
        fineAmount = 0;
        if(strSRID!= null){
            PrepareStatusGroups();
        }
    }
    public void PrepareStatusGroups(){
        lstStatusGroupWrap = new list<StatusGroupWrap>();
        list<string> lstStatusVals = new list<string>{'Draft','Upload Documents','Review & Submit','Under Process','Closed'};
        integer i=1;
        for(string statusval:lstStatusVals){
            StatusGroupWrap objwrap = new StatusGroupWrap();
            objwrap.GroupLabel = statusval;
            objwrap.GroupShortLabel = i+'';
            lstStatusGroupWrap.add(objwrap);
            i++;
        }
        for(HexaBPM__Service_Request__c objSR:[select Id,HexaBPM__Required_Docs_not_Uploaded__c,Fine_Amount__c,HexaBPM__External_SR_Status__r.Name,HexaBPM__IsClosedStatus__c,HexaBPM__Is_Rejected__c,HexaBPM__IsCancelled__c,
        (Select Id,HexaBPM__Status__c from HexaBPM__SR_Price_Items1__r where HexaBPM__Status__c='Added'),
        (Select Id,HexaBPM__Is_Not_Required__c,HexaBPM__Status__c from HexaBPM__SR_Docs__r) from HexaBPM__Service_Request__c where Id =: strSRID]){
            if(objSR.HexaBPM__IsClosedStatus__c==true || objSR.HexaBPM__Is_Rejected__c || objSR.HexaBPM__IsCancelled__c){
                lstStatusGroupWrap[0].PassedGroup = true;
                lstStatusGroupWrap[1].PassedGroup = true;
                lstStatusGroupWrap[2].PassedGroup = true;
                lstStatusGroupWrap[3].PassedGroup = true;
                lstStatusGroupWrap[4].PassedGroup = true;
                break;
            }else{
                if(objSR.HexaBPM__External_SR_Status__r.Name!='Draft'){
                    lstStatusGroupWrap[0].PassedGroup = true;
                    lstStatusGroupWrap[1].PassedGroup = true;
                    lstStatusGroupWrap[2].PassedGroup = true;
                    lstStatusGroupWrap[3].CurrentGroup = true;
                }else{
                    if(objSR.HexaBPM__Required_Docs_not_Uploaded__c){
                        lstStatusGroupWrap[0].PassedGroup = true;
                        lstStatusGroupWrap[1].CurrentGroup = true;
                    }else{
                        if(objSR.HexaBPM__SR_Price_Items1__r!=null && objSR.HexaBPM__SR_Price_Items1__r.size()>0){
                            lstStatusGroupWrap[0].PassedGroup = true;
                            lstStatusGroupWrap[1].PassedGroup = true;
                            lstStatusGroupWrap[2].CurrentGroup = true;
                        }
                    }
                }
            }
            if(objSR.Fine_Amount__c != null)
                fineAmount = objSR.Fine_Amount__c;
        }
        if(lstStatusGroupWrap != null && lstStatusGroupWrap.size()> 0) {
            Decimal dLstGroupSize = lstStatusGroupWrap.size();
            Decimal dGroupWidth = 100 / dLstGroupSize;
            GroupWidth = String.valueOf(dGroupWidth.setScale(3)) + '%';
        }
        system.debug('GroupWidth===>' + GroupWidth);
    }
    public class StatusGroupWrap{
        public string GroupLabel{get;set;}
        public string GroupShortLabel{get;set;}
        public boolean CurrentGroup{get;set;}
        public boolean PassedGroup{get;set;}
        public StatusGroupWrap() {
            CurrentGroup = false;
            PassedGroup = false;
        }
    }
}
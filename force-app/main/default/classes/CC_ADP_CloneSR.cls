/*
@Author : Azmath
@Version : v1.
*/
global without sharing class CC_ADP_CloneSR implements HexaBPM.iCustomCodeExecutable 
{
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SRi, HexaBPM__Step__c step) 
    {
        if(step.Id!=null && step.HexaBPM__SR__c!=null)
        {
            string fetchdatafrom='';
            HexaBPM__Service_Request__c amendmentSR = [Select id, Start_Date__c, End_Date__c,Recordtypeid, Location__c, Location_Arabic__c, HexaBPM__Parent_SR__c,ADP_Record_Type__c,
                                                        Reason_of_Cancellation__c FROM HexaBPM__Service_Request__c where id=:step.HexaBPM__SR__c limit 1];
            
            if(amendmentSR.Reason_of_Cancellation__c == null || amendmentSR.Reason_of_Cancellation__c == '')
            {
                list<HexaBPM__Service_Request__c> lastestAmendSR = [Select id from HexaBPM__Service_Request__c where 
                                                    HexaBPM__Parent_SR__c=:amendmentSR.HexaBPM__Parent_SR__c and ID !=:amendmentSR.id order by CreatedDate DESC limit 1];
                
                if(!lastestAmendSR.isEmpty()){
                    fetchdatafrom = lastestAmendSR[0].id;
                }else{
                    fetchdatafrom = amendmentSR.HexaBPM__Parent_SR__c;
                }
                string parentrectype = amendmentSR.ADP_Record_Type__c;
                /*string doctoCancel;
                
                if(parentrectype == 'Temporary_Fit_Out_Security_Clearance'){
                    doctoCancel = 'Temporary Fit Out Security Clearance Permit';
                }else if(parentrectype == 'Permit_Alcohol' || parentrectype == 'Renew_Alcohol_Permit'){
                    doctoCancel = 'Alcohol Permit';
                }else if(parentrectype == 'Permit_Entertainment'){
                    doctoCancel = 'Entertainment Permit';
                }else if(parentrectype == 'Extended_Operating_Hours'){
                    doctoCancel = 'Extended Business Hours Permit';
                }
                
                //Cancel permit of parent sr.
                for(HexaBPM__SR_Doc__c srdoc : [Select id from HexaBPM__SR_Doc__c where Name=:doctoCancel and HexaBPM__Service_Request__c=:fetchdatafrom  limit 1])
                {
                    srdoc.HexaBPM__Status__c='Cancelled';
                    update srdoc;
                }*/
                
                HexaBPM__Service_Request__c sr = [Select id, HexaBPM__Customer__c, Contact_Person_for_Inspection_Name__c, Contact_Person_for_Inspection_Phone__c, 
                                                HexaBPM__Email__c, Email_Second_Correspondence__c, Contact_Number_Second_Correspondence__c, HexaBPM__Send_SMS_to_Mobile__c, 
                                                Type_of_Entertainment__c, Organizer__c, Event_Name__c, Type_of_Entertainment_Arabic__c, Location__c, Location_Arabic__c, 
                                                Event_Time__c, Other_Reasons__c, Please_select_if_catering_is_provided__c, Event_Brief__c, Entity_Physical_Address__c, 
                                                Reason_for_Requested_Permit__c, Reason_for_Requested_Permit_Arabic__c, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c , Alarm_System_Account_Number__c 
                                                FROM HexaBPM__Service_Request__c where id=:fetchdatafrom];
                                                
                HexaBPM__Service_Request__c srclonecopy = sr;
                srclonecopy.id                          = amendmentSR.id;//Update amendmentSR with previous SR values.
                srclonecopy.HexaBPM__Required_Docs_not_Uploaded__c  = false;
                srclonecopy.recordtypeid = amendmentSR.Recordtypeid;
                
                if(amendmentSR.Start_Date__c != null)
                    srclonecopy.Start_Date__c = amendmentSR.Start_Date__c;
                if(amendmentSR.End_Date__c != null)
                    srclonecopy.End_Date__c = amendmentSR.End_Date__c;
                if(amendmentSR.Location__c != null){
                    srclonecopy.Location__c = amendmentSR.Location__c;
                    srclonecopy.Location_Arabic__c = amendmentSR.Location_Arabic__c;
                }
                update srclonecopy;
                system.debug('----srclonecopy--'+srclonecopy.id);
                
                list<Amendment__c> amlist = new list<Amendment__c>();
                if(srclonecopy.id != null)
                {
                    set<id> parentSrParticipantsIds = new set<id>();
                    for(Amendment__c am : [Select id, UAE_Resident__c, Unified_Number__c, Full_Name__c, Place_of_Birth__c, Nationality_New__c, Gender__c, Passport_No__c,
                                            Passport_Place_Of_Issue__c, Passport_Issue_Date__c, Passport_Expiry_Date__c, Passport_Type__c, Full_Name_Arabic__c, Service_Request__c 
                                            FROM Amendment__c where Service_Request__c=:fetchdatafrom and Is_Participant_Approved__c != 'No'])
                    {
                        parentSrParticipantsIds.add(am.id);
                        Amendment__c amNew = am.clone(false,false,false,false);
                        amNew.Do_not_trigger_email_notification__c = true;
                        amNew.Service_Request__c = srclonecopy.id ;
                        amlist.add(amNew);
                    }
                    
                    map<string,id> participantmap = new map<string,id>();
                    if(!amlist.isEmpty())
                    {
                        insert amlist;
                        for(Amendment__c am : amlist){
                            participantmap.put(am.Passport_No__c,am.id);
                        }
                    }
                    
                    list<HexaBPM__SR_Doc__c> newSRDocs  = new list<HexaBPM__SR_Doc__c>();
                    for(HexaBPM__SR_Doc__c srDoc : [SELECT id, Name, Contractor__c, Available_to_ADP__c, HexaBPM__Status__c, Name__c, Participant_Name__c, HexaBPM__Doc_ID__c,
                                                    HexaBPM__Customer_Comments__c, HexaBPM__SR_Template_Doc__c, Available_to_Community__c,HexaBPM__Document_Name__c ,
                                                    Introductory_Statement__r.Passport_No__c, HexaBPM__Document_Description_External__c
                                                    FROM HexaBPM__SR_Doc__c where HexaBPM__Service_Request__c=:fetchdatafrom and HexaBPM__Status__c!='Generated'
                                                    and HexaBPM__Document_Name__c != 'CID Letter - Approval/Rejection' and HexaBPM__Status__c != 'Cancelled'
                                                    and (Introductory_Statement__c IN:parentSrParticipantsIds or Available_to_ADP__c=true)])
                    {
                        system.debug('---sr docs section---'+srdoc.HexaBPM__Doc_ID__c+'===='+srdoc.Available_to_ADP__c);
                        Id parId;
                        if(participantmap.containsKey(srDoc.Introductory_Statement__r.Passport_No__c)){
                            parId = participantmap.get(srDoc.Introductory_Statement__r.Passport_No__c);
                        }
                        HexaBPM__SR_Doc__c sdoc             = srDoc.clone(false,false,false,false);
                        sdoc.Introductory_Statement__c      = parId;
                        sdoc.HexaBPM__Service_Request__c    = srclonecopy.id;
                        newSRDocs.add(sdoc);
                    }
                    if(!newSRDocs.isEmpty())
                        insert newSRDocs;
                    
                    map<string,id> AttachmentToSrDocmap = new map<string,id>();
                    for(HexaBPM__SR_Doc__c doc : newSRDocs)
                    {
                        system.debug('----amendments section----');
                        AttachmentToSrDocmap.put(doc.HexaBPM__Doc_ID__c,doc.id);//attachmentid,documentid
                    }
                    
                    list<Attachment> atlist = new list<Attachment>();
                    system.debug('---IN:AttachmentToSrDocmap---'+AttachmentToSrDocmap);
                    for(Attachment at : [Select id, Parentid, Name, Body, BodyLength, ContentType, Description from Attachment where ID IN:AttachmentToSrDocmap.keyset()])
                    {
                        system.debug('----attachments section----');
                        if(AttachmentToSrDocmap.get(at.id) != null)
                        {
                            system.debug('--parentid from map-'+AttachmentToSrDocmap.get(at.id));
                            Id pid = AttachmentToSrDocmap.get(at.id);
                            Attachment att = new Attachment(Name=at.Name,Parentid=pid,Body=at.Body,ContentType=at.ContentType,Description=at.Description);
                            system.debug('---att.Parentid---'+att.Parentid);
                            atlist.add(att);
                        }
                    }
                    if(!atlist.isEmpty())
                        insert atlist;
                }
            }
        }
        return null;
    }
}
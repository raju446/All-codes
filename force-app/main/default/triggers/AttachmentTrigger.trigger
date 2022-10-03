/*******************************
Author : Azmath.
Description : To update the roles with respective attachment ids.
******************************* */
trigger AttachmentTrigger on Attachment (after insert) 
{
  string Rolepref = Role__c.SObjectType.getDescribe().getkeyPrefix();
    map<id,Role__c> rolesToUpdate = new map<id,Role__c>();//Taking map to remove duplicate entries of role while update.
  
    for(Attachment att : trigger.new)
    {
        string attId = att.parentid;
        if(attId.substring(0,3) == Rolepref)
        {
            system.debug('-----'+att.Name);
      Role__c role = new Role__c(id=att.parentid);
            if(att.Name.contains('Passport_Evidence') || att.Name.contains('Passport Evidence'))
      {
        role.Passport_Evidence_Attachment_Id__c = att.id;
        rolesToUpdate.put(att.parentid,role);
      }
      else if(att.Name.contains('Evidence_of_Appointment') || att.Name.contains('Evidence of Appointment'))
      {
        role.Evidence_Of_Appointment_Attachment_Id__c = att.id;
        rolesToUpdate.put(att.parentid,role);
      }
      else if(att.Name.contains('UAE_Visa_or_Entry_Stamp') || att.Name.contains('UAE Visa or Entry Stamp'))
      {
        role.Visa_or_Entry_Stamp_Attachment_Id__c = att.id;
        rolesToUpdate.put(att.parentid,role);
      }
      else if(att.Name.contains('UAE_NationalID') || att.Name.contains('UAE NationalID'))
      {
        role.UAE_National_Attachment_Id__c = att.id;
        rolesToUpdate.put(att.parentid,role);
      }
            system.debug('-----'+role);
        }
    }
  if(!rolesToUpdate.isEmpty())
  {
    try{
        update rolesToUpdate.values();
    }
    catch(Exception ex){
        system.debug('=========='+ex.getMessage());
    }
  }
}
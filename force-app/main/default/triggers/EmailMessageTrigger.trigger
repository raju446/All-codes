trigger EmailMessageTrigger on EmailMessage (after insert, before delete) {
    
    List<Profile> currentUsersProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
    String profileName = currentUsersProfile[0].Name;
    list<String> preventProfileNames = new List<String>();
    String preventProfilesLabel =  Label.EmailMessageValidationProfiles;
    if(String.isNotEmpty(preventProfilesLabel)){
        preventProfileNames = preventProfilesLabel.split(';');
    }
    System.debug(profileName+ ' preventProfileNames--'+preventProfileNames);
    
    System.debug('EmailMessageTrigger--');
    if(preventProfileNames.contains(profileName)) {
        if(trigger.isinsert){
            String currentUsersEmail = UserInfo.getUserEmail();
            for(EmailMessage em : trigger.new){
                System.debug('em.fromAddress--'+em.fromAddress);
                                System.debug('em--'+em);

                System.debug('currentUsersEmail--'+currentUsersEmail);
                if(em.fromAddress != currentUsersEmail && em.FromName != 'ORS Support'){
                   em.addError(Label.Email_Validation_Error);
                }
            }
        }
        if(trigger.isdelete){
            for(EmailMessage em : trigger.old){
                System.debug('for loop--');
                        System.debug('true--');
                        em.addError(Label.Email_Delete_Validation);
                    }   
        }
    }
}
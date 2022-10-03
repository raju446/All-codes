trigger RestrictFileOnContentVersionTrigger on ContentVersion (before insert) {
    //Restricts the file uploads for few file extensions like exe,json etc
    Trigger_Settings__c TS = Trigger_Settings__c.getValues('RestrictFileOnContentVersionTrigger');
    if(TS != null && TS.is_Active__c == TRUE){
        Set<String> fileTypes = new Set<String>();
        for(FileExtensions__c fileExtension : FileExtensions__c.getAll().values()) {
            fileTypes.add(fileExtension.Name);// allowed extensions
        }
        list<Id> contentDocIds = new list<Id>();
        for ( ContentVersion cv : Trigger.new ) {
            // have to use PathOnClient, since FileExtension field doesn't seem to be populated in this context
            if (fileTypes != null && !fileTypes.contains(Utils.getFileExtension(cv.PathOnClient)) ) {
                cv.addError('You cannot upload the '+Utils.getFileExtension(cv.PathOnClient)+' File.');
                break;
            }
            
        }
    }
}
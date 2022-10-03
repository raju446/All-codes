trigger ICADocumentTrigger on ICA_Document__c (before insert) 
{
    ICADocumentTriggeHandler.before_Insert(trigger.new);
}
trigger CaseCommentTrigger on CaseComment (after insert) {

if(trigger.isAfter){
     if(trigger.isInsert)
         CaseCommentTriggerHandler.Execute_AI(Trigger.New);

}
}
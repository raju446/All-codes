trigger SubscribeICAstatusUpdate on ICAStatusUpdate__e (after insert) 
{
   ICAStatusUpdateTriggerHandler.Execute_AI(trigger.new);
}
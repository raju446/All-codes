/*  Author      : Keerthan Tantry
    Date        : 25-Feb-2018
    Description : Custom Code for creating shipment/pickup request


    ------------------------------------------------------------------------------------------------------
*/
global without sharing class CC_InvokeAramexService implements HexaBPM.iCustomCodeExecutable {
  global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c stp) {
    string strResult = 'Success';
    if (stp != null) {

      inVokeAramexServicesinFuture(stp.Id);

    }

    return  strResult;
  }

  @Future(callout = true)
  public static void inVokeAramexServicesinFuture(Id StepID) {
      
     String result =  AramexActions.ShipmentLabelAndPickupRequest(StepID);
     System.debug('***inVokeAramexServicesinFuture**');
     System.debug('result =>'+result);
   }

}
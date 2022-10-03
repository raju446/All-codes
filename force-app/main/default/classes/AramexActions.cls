/*  Author      : Keerthan Tantry
    Date        : 25-Feb-2018
    Name        : AramexActions
    Description : Class used for performing all the button level actions on Step
                 1) Create Shipment/Pickup Request
                 2) Cancel Pickup Request


    ------------------------------------------------------------------------------------------------------
*/
global without sharing class AramexActions {

  /**
   * [cancelPickupRequest - Method cancels pickup request created ]
   * @param  stepId     [Step Record ID]
   * @param  pickupGUID [PickupGUID to cancel the pickup request]
   * @return            [Message String - Success/Failure]
   */
  webService static String cancelPickupRequest(String stepId, String pickupGUID ) {
    String retStr;
    try {
      AramexWebserviceUtil serviceObj  = new AramexWebserviceUtil(stepId);
      retStr = AramexWebserviceUtil.cancelPickupRequest(pickupGUID, 'Cancelling Request');
      HexaBPM__Step__c step =  new HexaBPM__Step__c(id = stepId);
      if (retStr.equals('Success')) {
        step.Aramex_Shipping_ID__c = '';
        step.Aramex_Shipment_Label_URL__c = '';
        step.Aramex_PickupID__c = '';
        step.Aramex_PickupGUID__c = '';
        step.Aramex_Pickup_Request_Date__c = NULL;
        step.Aramex_Error__c = 'Pickup Cancelled';
      } else {
        step.Aramex_Error__c = retStr;
      }

      update step;
    } catch (Exception e) {
      retStr = e.getMessage();
    }
    return retStr;
  }

  /**
   * [Print Label - Method updates the label on the Action ]
   * @param  stepId     [Step Record ID]
   * @param  shipmentNumber [shipmentNumber]
   * @return            [Label url]
   */
  webService static String updateAramexShipmentLabel(String stepId, String shipmentNumber ) {
    String strLabel;
    try {
      AramexWebserviceUtil serviceObj  = new AramexWebserviceUtil(stepId);
      strLabel = AramexWebserviceUtil.printLabel(shipmentNumber);
      HexaBPM__Step__c step =  new HexaBPM__Step__c(id = stepId);
      if (String.isNotEmpty(strLabel)) {
        step.Aramex_Shipment_Label_URL__c = strLabel;
      } else {
        step.Aramex_Error__c = strLabel;
      }

      update step;
    } catch (Exception e) {
      strLabel = e.getMessage();
    }
    return strLabel;
  }
 
  /**
   * [createShipmentLabelAndPickupRequest - Method used for creating Shipment Label and Pickup Request]
   * @param  stepId [Step record ID]
   * @return        [Success/Error message]
   */
  Webservice static String createShipmentLabelAndPickupRequest(String stepId) {

    return (ShipmentLabelAndPickupRequest(stepId));


  }
  
  /**
   * [ShipmentLabelAndPickupRequest -Helper Method used for creating shipment and pickup request]
   * @param  StepID [Step record ID]
   * @return        [Success/Error message]
   */
  public static String ShipmentLabelAndPickupRequest(Id StepID) {
    System.debug('**AramexActions ShipmentLabelAndPickupRequest **');

    String retStr = 'Operation was successful.';
    //Check if there is pickup request for today
    Boolean hasPickupRequest = hasPickupRequestCreated(System.Today());
   //Check if there is a pickup request for tomorrow
    
    DateTime tomo = (System.Now().addDays(1).format('EEEE') == 'Friday') ? System.Now().addDays(3) : System.Now().addDays(1) ;
    Boolean hasPickupRequestTomorrow = hasPickupRequestCreated(Date.valueOf(tomo));
   //calculate cutoff time value - 1 hour less than the confogured value
   //Reduction by hour is done as last pickup time can be only be 1 hr befre cutoff
    DateTime cutOff  = DateTime.newInstance(System.Today().Year(), System.Today().Month(), System.Today().Day(), Integer.valueOf(System.Label.ARAMEX_CUTOFF_TIME)-1, 00, 00);

    System.debug('hasPickupRequest ==>' + hasPickupRequest);
    System.debug('hasPickupRequestTomorrow ==>' + hasPickupRequestTomorrow);
    if (!String.isBlank(StepID)) {
      try {
     
        String shipmentID;
        String labelURL;
        Map<String, String> pikupIdMap = new Map<String, String>();
        //Instantiate util object
        AramexWebserviceUtil serviceObj  = new AramexWebserviceUtil(stepID);
        if (String.isNotBlank(AramexWebserviceUtil.objStp.Aramex_Shipping_ID__c) && String.isNotBlank(AramexWebserviceUtil.objStp.Aramex_PickupID__c)) {
          retStr = 'Shipment & Pickup request already raised.';
          return retStr;
        }
        //If there is no shipment then create one
        shipmentID = (String.isBlank(AramexWebserviceUtil.objStp.Aramex_Shipping_ID__c)) ?   AramexWebserviceUtil.createShippingRequest() : AramexWebserviceUtil.objStp.Aramex_Shipping_ID__c;
        if (shipmentID != NULL && shipmentID.isNumeric()) {
          AramexWebserviceUtil.objStp.Aramex_Shipping_ID__c = shipmentID;
          //If there is no label for the shipment create a new label for the shipment
          labelURL = (String.isBlank(AramexWebserviceUtil.objStp.Aramex_Shipment_Label_URL__c)) ?   AramexWebserviceUtil.printLabel(shipmentID) : AramexWebserviceUtil.objStp.Aramex_Shipment_Label_URL__c;

          if (!String.isBlank(labelURL)) {
            AramexWebserviceUtil.objStp.Aramex_Shipment_Label_URL__c = labelURL;
            //If there is no pickup created for today and current time <  cutoff ( one hour less than configuration label)
            //If there is no pickup for tomorrow and current time is ahead of cutOff 
            if ((!hasPickupRequest && System.Now() <= cutOff ) || (!hasPickupRequestTomorrow && System.Now() >= cutOff)) {
              System.debug('Creating new pickup!');
              pikupIdMap = AramexWebserviceUtil.createPickupRequest(shipmentID);
              //Any error from ARAMEX capture it
              if (pikupIdMap.get('ID') == NULL) {
                retStr = AramexWebserviceUtil.errorStr;
              } else {
                //Proceed with  updating step with ARAMEX response  
                AramexWebserviceUtil.objStp.Aramex_Pickup_Request_Date__c = Date.valueOf(pikupIdMap.get('PICKUPDATE'));
                AramexWebserviceUtil.objStp.Aramex_PickupID__c = pikupIdMap.get('ID');
                AramexWebserviceUtil.objStp.Aramex_PickupGUID__c = pikupIdMap.get('GUID');
                AramexWebserviceUtil.objStp.Aramex_Shipment_Status__c = 'Record created.';
              }


            } else {
              //Get the appropriate pickup details already created for today/tomorrow    
              System.debug('Getting existing pickup!');
              getPickupInformation(hasPickupRequest, hasPickupRequestTomorrow, cutOff);
            }

          } else {
            //label generation failed
            retStr = AramexWebserviceUtil.errorStr;
          }

        } else {
          //Shipment creation failed
          retStr = AramexWebserviceUtil.errorStr;
        }

      } catch (Exception e) {
        System.debug('**inVokeAramexServices  Exception Occured ** ');
        System.debug('Exception Message:' + e.getMessage());
        System.debug('Exception Line:' + e.getLineNumber());
        retStr = e.getMessage();
        AramexWebserviceUtil.LogException(e);
      } finally {
        try {
          AramexWebserviceUtil.objStp.Aramex_Error__c = AramexWebserviceUtil.errorStr;
          AramexWebserviceUtil.objStp.Aramex_Error__c += ((hasPickupRequest && System.Now() <= cutOff) || hasPickupRequestTomorrow ) ? '[Pickup Request is already raised]' : '';
          update AramexWebserviceUtil.objStp;

        } catch (DMLException e) {
          System.debug('=>' + e.getDMLMessage(0));
          retStr = e.getMessage();
        }

      }
    }
    return retStr;
  }
  /**
   * [getPickupInformation - Method used for loading pickup details that is already created for  today/tomorrow]
   * @param hasPickupRequest         [Boolean indicator indicating there is a pickup request raised already for today]
   * @param hasPickupRequestTomorrow [Boolean indicator indicating there is a pickup request raised already for tomorrow]
   * @param cutOff                   [Cutoff time indicator to decide whether to create pickup request for today/tomorrow]
   */
  public static void getPickupInformation(Boolean hasPickupRequest, Boolean hasPickupRequestTomorrow, dateTime cutOff) {
    if (hasPickupRequest && System.Now() <= cutOff ) {
      System.debug('Load todays pickup details.');
      for (HexaBPM__Step__c stpObj  :  [Select Aramex_Pickup_Request_Date__c, Aramex_PickupID__c, Aramex_PickupGUID__c from HexaBPM__Step__c  WHERE Aramex_Pickup_Request_Date__c = :System.Today()  ] ) {
        AramexWebserviceUtil.objStp.Aramex_Pickup_Request_Date__c = stpObj.Aramex_Pickup_Request_Date__c;
        AramexWebserviceUtil.objStp.Aramex_PickupID__c = stpObj.Aramex_PickupID__c;
        AramexWebserviceUtil.objStp.Aramex_PickupGUID__c = stpObj.Aramex_PickupGUID__c;
        AramexWebserviceUtil.objStp.Aramex_Shipment_Status__c = 'Record created.';
      }

    } else if (hasPickupRequestTomorrow) {
      System.debug('Load tomorrows pickup details.');
      for (HexaBPM__Step__c stpObj  :  [Select Aramex_Pickup_Request_Date__c, Aramex_PickupID__c, Aramex_PickupGUID__c from HexaBPM__Step__c  WHERE Aramex_Pickup_Request_Date__c = :System.Today().addDays(1)  ] ) {
        AramexWebserviceUtil.objStp.Aramex_Pickup_Request_Date__c = stpObj.Aramex_Pickup_Request_Date__c;
        AramexWebserviceUtil.objStp.Aramex_PickupID__c = stpObj.Aramex_PickupID__c;
        AramexWebserviceUtil.objStp.Aramex_PickupGUID__c = stpObj.Aramex_PickupGUID__c;
        AramexWebserviceUtil.objStp.Aramex_Shipment_Status__c = 'Record created.';
      }
    }
  }

 /**
  * [hasPickupRequestCreated - Method to check if pickup request is created for the given date]
  * @param  d [Date value]
  * @return   [Boolean indicator true/false]
  */
  public static Boolean hasPickupRequestCreated(Date d) {
    Boolean hasPickupRequest = false;
    for (HexaBPM__Step__c stepObj : [Select Aramex_Pickup_Request_Date__c from HexaBPM__Step__c WHERE Aramex_Pickup_Request_Date__c  = : d]) {
      hasPickupRequest = true;
    }
    return hasPickupRequest;
  }

  /**
   * [getAllFields - Method to get all field string for a given object for dynamic SOQL]
   * @param  describeResult [Object describeresult information]
   * @return                [String with all fields]
   */
  public  static String getAllFields(DescribeSObjectResult describeResult) {
    String sObjectName = describeResult.getName();
    String query = ' SELECT ';
    List<String> fieldNames = new List<String> ( describeResult.fields.getMap().keySet() );
    List<RecordType> rts = [select Id from RecordType where SObjectType = :sObjectName];
    if (rts.size() > 0) {}
    query += (rts.size() > 0) ? 'RecordType.DeveloperName ,RecordType.Name , ' : '';
    query +=  String.join( fieldNames, ',' ) + ' FROM ' + describeResult.getName();
    return query;
  }

}
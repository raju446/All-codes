/*  Author      : Keerthan Tantry
    Date        : 25-Feb-2018
    Description : Aramex Integration Utility Class


    ------------------------------------------------------------------------------------------------------
*/
public without sharing class AramexWebserviceUtil {

    //Getting Config Details from Custom Metadat Type : Aramex_Service_Setting__mdt
    public static Aramex_Service_Setting__mdt aramexConfigDetails = getAramexConfigDetails('Aramex');
    public static String errorStr = '';
    public static HexaBPM__Step__c objStp;
    public static Contact objContact;
    public static User SROwner;
    public static DateTime pickupDateTime;

    //Constructor
    public AramexWebserviceUtil(String stepId) {
        String ContactID;
        String srOwnerId;
        objContact = new Contact();
        SROwner = new User();
        String query = '';
        for (HexaBPM__Step__c stepObj : [Select  Name,
                                         Id,
                                         Customer__c,
                                         HexaBPM__SR__r.U_A_E_Address__c,
                                         HexaBPM__SR__r.U_A_E_Address_2__c,
                                         //HexaBPM__SR__r.U_A_E_Address_City__c,
                                         HexaBPM__SR__r.U_A_E_Address_PO_Box__c,
                                         HexaBPM__SR__r.HexaBPM__Customer__c,
                                         HexaBPM__SR__r.U_A_E_Address_Emirate__c,
                                         HexaBPM__SR__r.HexaBPM__Contact__c,
                                         HexaBPM__SR__r.RecordType.Name,
                                         HexaBPM__SR__r.Name,
                                         HexaBPM__SR__r.createdById,
                                         Aramex_PickupGUID__c,
                                         Aramex_PickupID__c,
                                         Aramex_Shipment_Label_URL__c,
                                         Aramex_Shipping_ID__c

                                         FROM HexaBPM__Step__c where Id = : StepID   ]) {
            objStp  = stepObj;
            srOwnerId = stepObj.HexaBPM__SR__r.createdById;
        }
        for(User userObj : [Select ID,ContactId FROM User WHERE Id = :srOwnerId ]){
            ContactId = userObj.ContactId;
        }

        query = getAllFields(Contact.getsObjectType().getDescribe());
        query = query.replace('FROM Contact', ',Account.Name FROM Contact ');
        query += (!Test.isRunningTest()) ? ' WHERE Id = : ContactId  ' : ' LIMIT 1 ';
        for (Contact conObj  : Database.query(query)) {
            objContact = conObj;
        }
        errorStr = (String.isBlank(objContact.Id)) ? 'Error  : Service request owner has no contact information.' : '';
        System.debug('**AramexWebserviceUtil AramexWebserviceUtil(Constructor) **');
        System.debug('**AramexWebserviceUtil Consignee :' + objContact);
    }

    /**
     * [getAllFields - Method gets all the fields from a given object]
     * @param  describeResult [Object Describeresult ]
     * @return                [String with all fields delemeted with ,]
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


    /**
     * [createShippingRequest - method creates Shipment Request ]
     * @return [Return shipmentID ]
     */
    public static String createShippingRequest() {
        
        if(String.isNotBlank(errorStr)){
            LogException(errorStr);
            return errorStr;
        }
        
        String shipmentID = '';
        AramexShippingServices.BasicHttpBinding_Service_1_0  serviceObj = new AramexShippingServices.BasicHttpBinding_Service_1_0 ();
        AramexShippingServices.ClientInfo clientInfoobj = getShippingClientInfo();
        system.debug('======shipping address=='+clientInfoobj);
        AramexShippingServices.Transaction_x TransactionObj = getShippingTransaction();
        AramexShippingServices.ArrayOfShipment Shipments =  getArrayOfShipment();
        AramexShippingServices.LabelInfo LabelInfoObj = getLabelInfo();
        //system.debug('==>'+serviceObj.CreateShipments(clientInfoobj,TransactionObj,Shipments,LabelInfoObj));
        system.debug('==>clientInfoobj'+clientInfoobj);
        system.debug('==>TransactionObj'+TransactionObj);
        system.debug('==>Shipments'+Shipments);
        system.debug('==>LabelInfoObj'+LabelInfoObj);
        
        AramexShippingServices.ShipmentCreationResponse_element responseElement = serviceObj.CreateShipments(clientInfoobj, TransactionObj, Shipments, LabelInfoObj);
        System.debug(responseElement);
        if (responseElement.Notifications.Notification == NULL) {
            for (AramexShippingServices.ProcessedShipment ps : responseElement.Shipments.ProcessedShipment) {
                if (ps.ID == NULL) {
                    showErrors(ps.Notifications.Notification);

                } else {
                    System.debug('Shipment ID : ' + ps.ID);
                    shipmentID = ps.ID;
                }
            }
        } else {
            showErrors(responseElement.Notifications.Notification);

        }
        return shipmentID;
    }
    //AramexWebservice.printLabel('30754298304','EXP','AUH');
    /**
     * [printLabel - Method created Label for a given shipment request]
     * @param  ShipmentNumber [Shipment Number]
     * @return                [Label URL ]
     */
    public static String printLabel(String ShipmentNumber) {
        String labelURL;
        AramexShippingServices.BasicHttpBinding_Service_1_0  serviceObj = new AramexShippingServices.BasicHttpBinding_Service_1_0 ();
        AramexShippingServices.ClientInfo clientInfoobj = getShippingClientInfo();
        AramexShippingServices.Transaction_x TransactionObj = getShippingTransaction();
        AramexShippingServices.LabelInfo LabelInfoObj = getLabelInfo();
        AramexShippingServices.LabelPrintingResponse_element responseElement = serviceObj.PrintLabel(
                    clientInfoobj,
                    TransactionObj,
                    ShipmentNumber,
                    aramexConfigDetails.ProductGroup__c,
                    aramexConfigDetails.OriginEntity__c,
                    LabelInfoObj);

        if (responseElement.Notifications.Notification == NULL) {
            System.debug('Label : ' + responseElement.ShipmentLabel.LabelURL);
            labelURL = responseElement.ShipmentLabel.LabelURL;
        } else {
            showErrors(responseElement.Notifications.Notification);
        }

        return labelURL;
    }
    /**
     * [createPickupRequest - Method creates Pickup Request]
     * @param  shipmentNumber [Shipment Number]
     * @return                [Map containing pickup ID, pickup GUID , pickup DATE ]
     */
    public static Map<String, String> createPickupRequest(String shipmentNumber) {


        Map<String, String> retIds = new Map<String, String>();

        AramexShippingServices.BasicHttpBinding_Service_1_0  serviceObj = new AramexShippingServices.BasicHttpBinding_Service_1_0 ();
        AramexShippingServices.ClientInfo clientInfoobj = getShippingClientInfo();
        AramexShippingServices.Transaction_x TransactionObj = getShippingTransaction();
        AramexShippingServices.LabelInfo LabelInfoObj = getLabelInfo();
        AramexShippingServices.Pickup pickupObj = getPickup(shipmentNumber);
        AramexShippingServices.PickupCreationResponse_element responseElement  = serviceObj.createPickup(
                    clientInfoobj,
                    TransactionObj,
                    pickupObj,
                    LabelInfoObj);
        System.debug('responseElement:' + responseElement);
        if (responseElement.Notifications.Notification == NULL) {
            //hasErrors = false
            AramexShippingServices.processedPickup pp = responseElement.ProcessedPickup;
            if (pp.ID != NULL) {
                System.debug('Pickup ID ==>' + pp.ID);
                System.debug('GUID ID ==>' + pp.GUID);
                retIds.put('ID', pp.ID);
                retIds.put('GUID', pp.GUID);
                retIds.put('PICKUPDATE', String.valueOf(pickupObj.PickupDate));
                for (AramexShippingServices.ProcessedShipment ps : pp.ProcessedShipments.ProcessedShipment ) {
                    if (ps.ID == NULL) {
                        showErrors(ps.Notifications.Notification);

                    }
                }
            }

        } else {
            //If any error display the log 
            showErrors(responseElement.Notifications.Notification);
        }
        return retIds;
    }
   

    /**
     * [cancelPickupRequest - Method cancels pickup request already raised]
     * @param  pickupGUID [Pickup GUID]
     * @param  Comments   [Cancellation comment.]
     * @return            ['Success'/ Error details]
     */
    public static String  cancelPickupRequest(String pickupGUID, String Comments) {
        String retStr = '';
        AramexShippingServices.BasicHttpBinding_Service_1_0  serviceObj = new AramexShippingServices.BasicHttpBinding_Service_1_0 ();
        AramexShippingServices.ClientInfo clientInfoobj = getShippingClientInfo();
        AramexShippingServices.Transaction_x TransactionObj = getShippingTransaction();
        AramexShippingServices.LabelInfo LabelInfoObj = getLabelInfo();
        AramexShippingServices.PickupCancelationResponse_element responseElement  = serviceObj.CancelPickup(clientInfoobj, TransactionObj, pickupGUID, Comments);
        if (!responseElement.hasErrors) {
            retStr = 'Success';
            System.debug('==>' + responseElement.Message);
        } else {

            showErrors(responseElement.Notifications.Notification);
            retStr = errorStr;
        }
        return retStr;
    }
    

    /**
     * [trackShipments - Method used for tracking shipment request]
     * @param  shipmentIdList [List<Id> shipment ID list]
     * @return                [List<AramexTrackingServices.TrackingResult> for every shipment ]
     */
    public static List<AramexTrackingServices.TrackingResult> trackShipments(List<String> shipmentIdList) {

        list<AramexTrackingServices.TrackingResult> TrackingResults = new list<AramexTrackingServices.TrackingResult>();
        AramexTrackingServices.BasicHttpBinding_Service_1_0  serviceObj = new AramexTrackingServices.BasicHttpBinding_Service_1_0 ();
        AramexTrackingServices.ClientInfo clientInfoobj = getTrackingClientInfo();
        AramexTrackingServices.Transaction_x TransactionObj = getTrackingTransaction();
        AramexTrackingServicesArr.ArrayOfstring shipments = getTrackingServicesArray(shipmentIdList);

        AramexTrackingServices.ShipmentTrackingResponse_element responseElement = serviceObj.TrackShipments(clientInfoobj,
                TransactionObj,
                shipments, true);

        System.debug('==>' + responseElement);
        if (!responseElement.hasErrors) {

            AramexTrackingServicesArr.KeyValueOfstringArrayOfTrackingResultmFAkxlpY_element[] objList = responseElement.TrackingResults.KeyValueOfstringArrayOfTrackingResultmFAkxlpY;
            if (objList != NULL) {
                for (AramexTrackingServicesArr.KeyValueOfstringArrayOfTrackingResultmFAkxlpY_element obj : objList ) {
                    
                    for (AramexTrackingServices.TrackingResult TrackingResult : obj.value.TrackingResult) {
                        TrackingResults.add(TrackingResult);
                        System.debug('=====================');
                        System.debug('WaybillNumber :' + TrackingResult.WaybillNumber);
                        System.debug('UpdateCode :' + TrackingResult.UpdateCode);
                        System.debug('UpdateDescription :' + TrackingResult.UpdateDescription);
                        System.debug('UpdateDateTime :' + TrackingResult.UpdateDateTime);
                        System.debug('UpdateLocation :' + TrackingResult.UpdateLocation);
                        System.debug('Comments :' + TrackingResult.Comments);
                        System.debug('ProblemCode :' + TrackingResult.ProblemCode);
                        System.debug('GrossWeight :' + TrackingResult.GrossWeight);
                        System.debug('ChargeableWeight :' + TrackingResult.ChargeableWeight);
                        System.debug('WeightUnit :' + TrackingResult.WeightUnit);
                        System.debug('=====================');
                    }


                }
            }


        } else {
            showErrors(responseElement.Notifications.Notification);
        }
        
        return TrackingResults;
    }


    /**
     * [trackPickups - Method used for tracking pickup request]
     * @param pickupRefId [Pickup reference ID]
     */
    /** 
    public static void trackPickups(String pickupRefId) {
        AramexTrackingServices.BasicHttpBinding_Service_1_0  serviceObj = new AramexTrackingServices.BasicHttpBinding_Service_1_0 ();
        AramexTrackingServices.ClientInfo clientInfoobj = getTrackingClientInfo();
        AramexTrackingServices.Transaction_x TransactionObj = getTrackingTransaction();

        AramexTrackingServices.PickupTrackingResponse_element responseElement = serviceObj.TrackPickup(clientInfoobj,
                TransactionObj,
                pickupRefId);

        if (!responseElement.hasErrors) {
            System.debug('=====================');
            System.debug('Entity : ' + responseElement.Entity );
            System.debug('Reference : ' + responseElement.Reference );
            System.debug('CollectionDate : ' + responseElement.CollectionDate );
            System.debug('PickupDate : ' + responseElement.PickupDate );
            System.debug('LastStatus : ' + responseElement.LastStatus );

            System.debug('=====================');

        } else {
            showErrors(responseElement.Notifications.Notification);
        }

    }
    **/
    
    /**
     * [fetchCountries - method used for fetching all the country List from Aramex]
     */
    public static void fetchCountries() {

        AramexLocationServices.BasicHttpBinding_Service_1_0  serviceObj = new AramexLocationServices.BasicHttpBinding_Service_1_0 ();
        AramexLocationServices.ClientInfo clientInfoobj = getLocationClientInfo();
        AramexLocationServices.Transaction_x TransactionObj = getLoctaionTransaction();

        AramexLocationServices.CountriesFetchingResponse_element responseElement  = serviceObj.FetchCountries(clientInfoobj, TransactionObj);
        System.debug('**responseElement:'+responseElement);
        if (!responseElement.hasErrors) {
            for (AramexLocationServices.Country Country : responseElement.Countries.country) {
                System.debug('******');
                System.debug('Code ==>' + Country.Code);
                System.debug('Name ==>' + Country.Name);
                System.debug('IsoCode ==>' + Country.IsoCode);
                System.debug('StateRequired ==>' + Country.StateRequired);
                System.debug('PostCodeRequired ==>' + Country.PostCodeRequired);
                System.debug('InternationalCallingNumber ==>' + Country.InternationalCallingNumber);
                System.debug('******');
            }


        } else {
            showErrors(responseElement.Notifications.Notification);

        }
    }
    /**
     * [FetchCities - Method used for fetching all the cities for a Country and State]
     * @param CountryCode    [Country Code value]
     * @param State          [State Value]
     * @param NameStartsWith [Name starts with value]
     */
    public static void FetchCities(String CountryCode, String State, String NameStartsWith) {
        AramexLocationServices.BasicHttpBinding_Service_1_0  serviceObj = new AramexLocationServices.BasicHttpBinding_Service_1_0 ();
        AramexLocationServices.ClientInfo clientInfoobj = getLocationClientInfo();
        AramexLocationServices.Transaction_x TransactionObj = getLoctaionTransaction();

        AramexLocationServices.CitiesFetchingResponse_element responseElement = serviceObj.FetchCities(clientInfoobj, TransactionObj, CountryCode, State, NameStartsWith);
        if (!responseElement.hasErrors) {
            for (String city : responseElement.Cities.string_x ) {
                System.debug('******');
                System.debug('==>' + city);
                System.debug('******');
            }

        } else {
            showErrors(responseElement.Notifications.Notification);
        }

    }
    /**
     * [fetchOffices -Method used for fetaching all the Offices in a given country ]
     * @param CountryCode [Country code value]
     */
    public static void fetchOffices(String CountryCode) {
        AramexLocationServices.BasicHttpBinding_Service_1_0  serviceObj = new AramexLocationServices.BasicHttpBinding_Service_1_0 ();
        AramexLocationServices.ClientInfo clientInfoobj = getLocationClientInfo();
        AramexLocationServices.Transaction_x TransactionObj = getLoctaionTransaction();


        AramexLocationServices.OfficesFetchingResponse_element responseElement = serviceObj.FetchOffices(clientInfoobj, TransactionObj, CountryCode);
        System.debug('responseElement:'+responseElement);
        if (!responseElement.hasErrors) {
            for (AramexLocationServices.Office office : responseElement.Offices.Office ) {
                System.debug('******');
                System.debug('Entity ==>' + office.entity);
                System.debug('EntityDescription ==>' + office.EntityDescription);
                System.debug('OfficeType ==>' + office.OfficeType);
                System.debug('Telephone ==>' + office.Telephone);
                System.debug('WorkingDays ==>' + office.WorkingDays);
                System.debug('WorkingHours ==>' + office.WorkingHours);
                System.debug('Longtitude ==>' + office.Longtitude);
                System.debug('Latitude ==>' + office.Latitude);

                System.debug('Line 1==>' + office.Address.Line1);
                System.debug('Line 2==>' + office.Address.Line2);
                System.debug('Line 3==>' + office.Address.Line3);
                System.debug('City==>' + office.Address.City);
                System.debug('StateOrProvinceCode==>' + office.Address.StateOrProvinceCode);
                System.debug('CountryCode==>' + office.Address.CountryCode);





                System.debug('******');
            }

        } else {
            showErrors(responseElement.Notifications.Notification);
        }


    }


    /**
     * [getTrackingServicesArray - Tracking request helper method]
     * @param  itemIdList [List  of Ids for tracking request]
     * @return            [AramexTrackingServicesArr.ArrayOfstring]
     */
    public static AramexTrackingServicesArr.ArrayOfstring  getTrackingServicesArray(List<String> itemIdList) {
        AramexTrackingServicesArr.ArrayOfstring AramexTrackingServicesArrObj = new AramexTrackingServicesArr.ArrayOfstring();
        AramexTrackingServicesArrObj.string_x =  itemIdList;
        return AramexTrackingServicesArrObj;
    }
    public static AramexShippingServices.ArrayOfExistingShipment getArrayOfExistingShipment(String shipmentNumber) {
        AramexShippingServices.ArrayOfExistingShipment ArrayOfExistingShipmentObj =  new AramexShippingServices.ArrayOfExistingShipment();
        List<AramexShippingServices.ExistingShipment> ExistingShipments = new List<AramexShippingServices.ExistingShipment>();
        AramexShippingServices.ExistingShipment  ExistingShipment = new AramexShippingServices.ExistingShipment();
        ExistingShipment.Number_x = shipmentNumber;
        ExistingShipment.OriginEntity = Constants.ORIGINENTITY;
        ExistingShipment.ProductGroup = aramexConfigDetails.ProductGroup__c;
        ExistingShipments.add(ExistingShipment);
        ArrayOfExistingShipmentObj.ExistingShipment = ExistingShipments;
        return ArrayOfExistingShipmentObj;


    }
    public static AramexShippingServices.Pickup getPickup(String shipmentNumber) {
        AramexShippingServices.Pickup pickupObj = new AramexShippingServices.Pickup();
        pickupObj.PickupAddress = getAddress('Consignor');
        pickupObj.PickupContact = getContact('Consignor');
        pickupObj.PickupLocation  = Constants.PICKUPLOCATION;
        system.debug('====='+pickupObj.PickupAddress);
        system.debug('====='+pickupObj.PickupContact );
        system.debug('====='+pickupObj.PickupLocation);
        /*pickupObj.PickupDate = DateTime.newInstance(2017,11,9,13,00,00);
        pickupObj.ReadyTime = DateTime.newInstance(2017,11,9,13,00,00);
        pickupObj.LastPickupTime = DateTime.newInstance(2017,11,9,1,00,00);
        pickupObj.ClosingTime = DateTime.newInstance(2017,11,9,1,00,00); */

        pickupObj.PickupDate = getPickupTime();
        pickupObj.ReadyTime = getReadyTime();
        pickupObj.LastPickupTime = getLastPickupTime();
        pickupObj.ClosingTime = pickupObj.LastPickupTime.addMinutes(30);

        //pickupObj.Comments = 'TEST=='+ objStp.HexaBPM__SR__r.RecordType.Name + '==' + objStp.HexaBPM__SR__r.Name;
        pickupObj.Comments = objStp.HexaBPM__SR__r.RecordType.Name + '==' + objStp.HexaBPM__SR__r.Name;
        pickupObj.Reference1 = objStp.Name;
        pickupObj.Reference2 = objStp.Id;
        pickupObj.Vehicle = Constants.VEHICLE;
        pickupObj.Status = Constants.PICKUP_STATUS;
        pickupObj.Shipments = getArrayOfShipment();
        pickupObj.PickupItems = getArrayOfPickupItemDetail();
        pickupObj.ExistingShipments = getArrayOfExistingShipment(shipmentNumber);

        System.debug('Pickup Date==>' + pickupObj.PickupDate);
        System.debug('ReadyTime==>' + pickupObj.ReadyTime);
        System.debug('LastPickupTime==>' + pickupObj.LastPickupTime);
        System.debug('ClosingTime==>' + pickupObj.ClosingTime);

        pickupDateTime = pickupObj.PickupDate;
        return pickupObj;

    }
    public static AramexShippingServices.ArrayOfPickupItemDetail getArrayOfPickupItemDetail() {

        AramexShippingServices.ArrayOfPickupItemDetail  ArrayOfPickupItemDetailObj = new  AramexShippingServices.ArrayOfPickupItemDetail();
        ArrayOfPickupItemDetailObj.PickupItemDetail = getPickupItemDetail();
        return ArrayOfPickupItemDetailObj;
    }

    public static List<AramexShippingServices.PickupItemDetail> getPickupItemDetail() {
        List<AramexShippingServices.PickupItemDetail> pickupItemDetailsList = new List<AramexShippingServices.PickupItemDetail>();
        AramexShippingServices.PickupItemDetail pickupItemDetailObj = new  AramexShippingServices.PickupItemDetail();
        pickupItemDetailObj.ProductGroup = aramexConfigDetails.ProductGroup__c;
        pickupItemDetailObj.ProductType = aramexConfigDetails.ProductType__c;
        pickupItemDetailObj.NumberOfShipments = Constants.NO_OF_SHIPMENTS;
        pickupItemDetailObj.PackageType = Constants.PACKAGE_TYPE;
        pickupItemDetailObj.Payment = Constants.PAYMENT_TYPE;
        pickupItemDetailObj.ShipmentWeight = getWeight();
        pickupItemDetailObj.ShipmentVolume = getVolume();
        pickupItemDetailObj.NumberOfPieces = 1;
        pickupItemDetailObj.CashAmount = getMoney(Constants.ARAMEX_CURRENCY, 0);
        pickupItemDetailObj.ExtraCharges = getMoney(Constants.ARAMEX_CURRENCY, 0);
        pickupItemDetailObj.ShipmentDimensions = getDimensions();
        //PickupItemDetailObj.Comments = 'TEST=='+ objStp.HexaBPM__SR__r.RecordType.Name + '==' + objStp.HexaBPM__SR__r.Name;
        PickupItemDetailObj.Comments = objStp.HexaBPM__SR__r.RecordType.Name + '==' + objStp.HexaBPM__SR__r.Name;
        pickupItemDetailsList.add(pickupItemDetailObj);
        return pickupItemDetailsList;

    }
    public static void showErrors(AramexShippingServices.Notification[] Notification) {

        for (AramexShippingServices.Notification n : Notification) {
            System.debug('*********************');
            System.debug('==>' + n.Code);
            System.debug('==>' + n.Message);
            errorStr += ' [' +  n.Code  + ' : ' + n.Message + '] ';
            System.debug('*********************');
        }
        if (String.isNotBlank(errorStr)) {
            LogException(errorStr);
        }

    }
    //Method overloaded
    public static void showErrors(AramexTrackingServices.Notification[] Notification) {
        for (AramexTrackingServices.Notification n : Notification) {
            System.debug('*********************');
            System.debug('==>' + n.Code);
            System.debug('==>' + n.Message);
            errorStr += ' [' +  n.Code  + ' : ' + n.Message + '] ';
            System.debug('*********************');
        }
        if (String.isNotBlank(errorStr)) {
            LogException(errorStr);
        }
    }
    //Method overloaded
    public static void showErrors(AramexLocationServices.Notification[] Notification) {
        for (AramexLocationServices.Notification n : Notification) {
            System.debug('*********************');
            System.debug('==>' + n.Code);
            System.debug('==>' + n.Message);
            errorStr += ' [' +  n.Code  + ' : ' + n.Message + '] ';
            System.debug('*********************');
        }
        if (String.isNotBlank(errorStr)) {
            LogException(errorStr);
        }
    }


    public static AramexTrackingServices.clientInfo getTrackingClientInfo() {

        AramexTrackingServices.clientInfo clientInfoobj = new AramexTrackingServices.clientInfo();


        clientInfoobj.UserName  = AramexWebserviceUtil.decryptPhrase(aramexConfigDetails.UserName__c);
        clientInfoobj.Password = AramexWebserviceUtil.decryptPhrase(aramexConfigDetails.Password__c);
        clientInfoobj.Version = aramexConfigDetails.Version__c;
        clientInfoobj.AccountNumber = aramexConfigDetails.AccountNumber__c;
        clientInfoobj.AccountPin = aramexConfigDetails.AccountPin__c;
        clientInfoobj.AccountEntity = aramexConfigDetails.AccountEntity__c;
        clientInfoobj.AccountCountryCode = aramexConfigDetails.AccountCountryCode__c;
        return clientInfoobj;
    }

    public static AramexTrackingServices.Transaction_x getTrackingTransaction() {
        AramexTrackingServices.Transaction_x  TransactionObj = new AramexTrackingServices.Transaction_x();
        TransactionObj.Reference1 = '';
        TransactionObj.Reference2 = '';
        TransactionObj.Reference3 = '';
        TransactionObj.Reference4 = '';
        TransactionObj.Reference5 = '';
        return TransactionObj;
    }
    public static AramexShippingServices.clientInfo getShippingClientInfo() {
        AramexShippingServices.clientInfo clientInfoobj = new AramexShippingServices.clientInfo();

        clientInfoobj.UserName  = AramexWebserviceUtil.decryptPhrase(aramexConfigDetails.UserName__c);
        clientInfoobj.Password = AramexWebserviceUtil.decryptPhrase(aramexConfigDetails.Password__c);
        clientInfoobj.Version = aramexConfigDetails.Version__c;
        clientInfoobj.AccountNumber = aramexConfigDetails.AccountNumber__c;
        clientInfoobj.AccountPin = aramexConfigDetails.AccountPin__c;
        clientInfoobj.AccountEntity = aramexConfigDetails.AccountEntity__c;
        clientInfoobj.AccountCountryCode = aramexConfigDetails.AccountCountryCode__c;
        return clientInfoobj;
    }
    public static AramexShippingServices.Transaction_x getShippingTransaction() {
        AramexShippingServices.Transaction_x  TransactionObj = new AramexShippingServices.Transaction_x();
        TransactionObj.Reference1 = '';
        TransactionObj.Reference2 = '';
        TransactionObj.Reference3 = '';
        TransactionObj.Reference4 = '';
        TransactionObj.Reference5 = '';
        return TransactionObj;
    }
    public static AramexLocationServices.clientInfo getLocationClientInfo() {
        AramexLocationServices.clientInfo clientInfoobj = new AramexLocationServices.clientInfo();

        clientInfoobj.UserName  = AramexWebserviceUtil.decryptPhrase(aramexConfigDetails.UserName__c);
        clientInfoobj.Password = AramexWebserviceUtil.decryptPhrase(aramexConfigDetails.Password__c);
        clientInfoobj.Version = aramexConfigDetails.Version__c;
        clientInfoobj.AccountNumber = aramexConfigDetails.AccountNumber__c;
        clientInfoobj.AccountPin = aramexConfigDetails.AccountPin__c;
        clientInfoobj.AccountEntity = aramexConfigDetails.AccountEntity__c;
        clientInfoobj.AccountCountryCode = aramexConfigDetails.AccountCountryCode__c;
        return clientInfoobj;
    }
    public static AramexLocationServices.Transaction_x getLoctaionTransaction() {
        AramexLocationServices.Transaction_x  TransactionObj = new AramexLocationServices.Transaction_x();
        TransactionObj.Reference1 = '';
        TransactionObj.Reference2 = '';
        TransactionObj.Reference3 = '';
        TransactionObj.Reference4 = '';
        TransactionObj.Reference5 = '';
        return TransactionObj;
    }

    public static AramexShippingServices.Address getAddress(String addressType) {
        System.debug('addressType***' + addressType);
        AramexShippingServices.Address address = new AramexShippingServices.Address();

        address.Line1 = (addressType.equals('Consignor')) ? aramexConfigDetails.ADGM_Address_Line1__c : objStp.HexaBPM__SR__r.U_A_E_Address__c ;
        address.Line2 = (addressType.equals('Consignor')) ? aramexConfigDetails.ADGM_Address_Line2__c : objStp.HexaBPM__SR__r.U_A_E_Address__c;
        address.Line3 = (addressType.equals('Consignor')) ? aramexConfigDetails.ADGM_Address_Line3__c : objStp.HexaBPM__SR__r.U_A_E_Address__c;
        address.City = (addressType.equals('Consignor')) ? aramexConfigDetails.ADGM_Address_City__c : objStp.HexaBPM__SR__r.U_A_E_Address_Emirate__c;
        address.stateOrProvinceCode = (addressType.equals('Consignor')) ? aramexConfigDetails.AGDM_Address_stateOrProvinceCode__c : objStp.HexaBPM__SR__r.U_A_E_Address_PO_Box__c;
        // address.postCode = (addressType.equals('Consignor')) ? '' : objStp.HexaBPM__SR__r.U_A_E_Address_PO_Box__c;
        address.CountryCode = Constants.CONSIGNER_COUNTRY_CODE;
        system.debug('=========address====='+address);
        return address;

    }

    public static AramexShippingServices.Contact getContact(String contactType) {
        System.debug('contactType***' + contactType);
        AramexShippingServices.Contact contact = new AramexShippingServices.Contact();
        contact.department = '';
        contact.PersonName = (contactType.equals('Consignor')) ? aramexConfigDetails.ADGM_Contact_PersonName__c :  objContact.Name;
        contact.title = (contactType.equals('Consignor')) ? aramexConfigDetails.ADGM_Contact_Title__c :  objContact.Title;
        contact.CompanyName = (contactType.equals('Consignor')) ? aramexConfigDetails.ADGM_Contact_CompanyName__c :  objContact.Account.Name;
        contact.PhoneNumber1 = (contactType.equals('Consignor')) ? aramexConfigDetails.ADGM_Contact_PhoneNumber1__c :  objContact.MobilePhone;
        contact.PhoneNumber1Ext = (contactType.equals('Consignor')) ? aramexConfigDetails.ADGm_Contact_PhoneNumber1Ext__c :  '';
        contact.PhoneNumber2 = (contactType.equals('Consignor')) ? aramexConfigDetails.ADGM_Contact_PhoneNumber2__c :  objContact.MobilePhone;
        contact.PhoneNumber2Ext = (contactType.equals('Consignor')) ? aramexConfigDetails.ADGm_Contact_PhoneNumber2Ext__c :  '';
        contact.FaxNumber = (contactType.equals('Consignor')) ? aramexConfigDetails.ADGM_COntact_FaxNumber__c :  '';
        contact.CellPhone = (contactType.equals('Consignor')) ? aramexConfigDetails.ADGM_Contact_CellPhone__c :  objContact.MobilePhone;
        contact.EmailAddress = (contactType.equals('Consignor')) ? aramexConfigDetails.ADGM_Contact_EmailAddress__c :  objContact.Email;
        contact.Type_x = '';
        return contact;

    }


    public static AramexShippingServices.Party getParty(String partyType) {
        AramexShippingServices.Party  party = new AramexShippingServices.Party();
        Party.Reference1 = '';
        party.Reference2 = '';
        party.AccountNumber = aramexConfigDetails.AccountNumber__c;
        party.PartyAddress =  getAddress(partyType);
        party.Contact = getContact(partyType);


        return party;
    }
    /**
     * [getShipper Method to get Shipper Details]
     * @return [returns Consignor details (ADGM)]
     */
    public static AramexShippingServices.Party getShipper() {
        return getParty('Consignor');

    }

    /**
     * [getConsignee - Method Consignee Details]
     * @return [Returns Consignee Details]
     */
    public static AramexShippingServices.Party getConsignee() {
        return getParty('Consignee');
    }

    /**
     * [getThirdParty - Method to get Tird Party Details]
     * @return [Return Consigor Details]
     */
    public static AramexShippingServices.Party getThirdParty() {
        return getParty('Consignor');
    }

    /**
     * [getShipment - Method to get shipment]
     * @return [List of AramexShippingServices.shipment]
     */
    public static List<AramexShippingServices.shipment> getShipment() {

        List<AramexShippingServices.shipment> shipments = new List<AramexShippingServices.shipment>();
        AramexShippingServices.shipment shipment = new AramexShippingServices.shipment();
        shipment.Reference1 = objStp.HexaBPM__SR__r.Name;
        shipment.Reference2 = objStp.Name;
        shipment.Reference3 = objStp.Id;
        shipment.Shipper = getShipper();
        shipment.Consignee = getConsignee();
        shipment.ThirdParty = getThirdParty();
        shipment.ShippingDateTime = System.Now();
        shipment.DueDate = System.now();
        //shipment.Comments = 'TEST=='+ objStp.HexaBPM__SR__r.RecordType.Name + '=='  + objStp.HexaBPM__SR__r.Name;
        shipment.Comments = objStp.HexaBPM__SR__r.RecordType.Name + '=='  + objStp.HexaBPM__SR__r.Name;
        shipment.PickupLocation = aramexConfigDetails.ShipmentPickupLocation__c;
        shipment.OperationsInstructions = '';
        shipment.AccountingInstrcutions = '';
        shipment.Details = getShipmentDetails();
        shipment.Attachments = NULL;
        shipment.ForeignHAWB =   generateRefNumber();
        //
        shipment.TransportType_x0020_x = 0;
        shipment.PickupGUID = '';
        shipments.add(shipment);
        return shipments;

    }
   /**
    * [getShipmentDetails - method to get shipment details]
    * @return [returns AramexShippingServices.ShipmentDetails]
    */
    public static AramexShippingServices.ShipmentDetails getShipmentDetails() {
        AramexShippingServices.ShipmentDetails shipmentDetail = new AramexShippingServices.ShipmentDetails();
        shipmentDetail.Dimensions = getDimensions();
        shipmentDetail.ActualWeight = getWeight();
        shipmentDetail.ChargeableWeight = getWeight();
        //shipmentDetail.DescriptionOfGoods = 'TEST=='+ objStp.HexaBPM__SR__r.RecordType.Name + '==' + objStp.HexaBPM__SR__r.Name;
        shipmentDetail.DescriptionOfGoods = objStp.HexaBPM__SR__r.RecordType.Name + '==' + objStp.HexaBPM__SR__r.Name;
        shipmentDetail.GoodsOriginCountry = Constants.GOODSORIGINCOUNTRY;
        shipmentDetail.NumberOfPieces = Constants.NO_OF_PIECES;
        shipmentDetail.ProductGroup = aramexConfigDetails.ProductGroup__c;
        shipmentDetail.ProductType = aramexConfigDetails.ProductType__c ;
        shipmentDetail.PaymentType = Constants.PAYMENT_TYPE;

        shipmentDetail.PaymentOptions = '';
        shipmentDetail.CustomsValueAmount  = getMoney('', 0);
        shipmentDetail.CashOnDeliveryAmount  = getMoney('', 0);
        shipmentDetail.InsuranceAmount  = getMoney('', 0);
        shipmentDetail.CashAdditionalAmount  = getMoney('', 0);
        shipmentDetail.CollectAmount  = getMoney('', 0);
        shipmentDetail.Services = '';

        shipmentDetail.CashAdditionalAmountDescription = '';
        shipmentDetail.Items = getArrayOfShipmentItem();
        return shipmentDetail;

    }
    

    /**
     * [getDimensions Method to get Dimension information of Shipment]
     * @return [Returns shipment dimensions]
     */
    public static  AramexShippingServices.Dimensions getDimensions() {
        AramexShippingServices.Dimensions dimension = new AramexShippingServices.Dimensions();
        dimension.Length = aramexConfigDetails.ShipmentLength__c;
        dimension.Width = aramexConfigDetails.ShipmentWidth__c;
        dimension.Height = aramexConfigDetails.ShipmentHeight__c;
        dimension.unit = aramexConfigDetails.ShipmentDimensionUnit__c;
        return dimension;
    }
    
    /**
     * [getWeight -Method builds weight property of shipmentr]
     * @return [Returns weight instance]
     */
    public static AramexShippingServices.Weight getWeight() {
        AramexShippingServices.Weight weight  = new AramexShippingServices.Weight();
        weight.unit = aramexConfigDetails.ShipmentWeightUnit__c;
        weight.value = Constants.WEIGHT_VALUE;
        return weight;
    }

    /**
     * [getMoney Method to get money details ]
     * @param  currencyCode [Currency Information]
     * @param  value        [money Value]
     * @return              [Returns AramexShippingServices.Money ]
     */
    public static AramexShippingServices.Money getMoney(String currencyCode , Double value) {
        AramexShippingServices.Money money = new AramexShippingServices.Money();
        money.CurrencyCode = aramexConfigDetails.currencyCode__c;
        money.Value = value;
        return money;

    }

    /**
     * [getVolume  - Method to evaluate volume details]
     * @return [Returns  AramexShippingServices.Volume]
     */
    public static AramexShippingServices.Volume getVolume() {
        AramexShippingServices.Volume volume  = new AramexShippingServices.Volume();
        volume.unit = aramexConfigDetails.ShipmentVolumeUnit__c;
        volume.value = Constants.VOLUME_VALUE;
        return volume;
    }

    /**
     * [getArrayOfShipment -  Method to get array of shipments]
     * @return [Returns array of Shipments]
     */
    public  static AramexShippingServices.ArrayOfShipment getArrayOfShipment() {
        AramexShippingServices.ArrayOfShipment ArrayOfShipmentObj = new AramexShippingServices.ArrayOfShipment();
        ArrayOfShipmentObj.Shipment = getShipment();
        return ArrayOfShipmentObj;

    }

    /**
     * [getArrayOfShipmentItem - Method for getting array of Shipment Item]
     * @return [AramexShippingServices.ArrayOfShipmentItem ]
     */
    public static AramexShippingServices.ArrayOfShipmentItem  getArrayOfShipmentItem() {
        AramexShippingServices.ArrayOfShipmentItem ArrayOfShipmentItemObj = new AramexShippingServices.ArrayOfShipmentItem();
        AramexShippingServices.ShipmentItem ShipmentItemObj;
        List<AramexShippingServices.ShipmentItem> shipmentItemList = new List<AramexShippingServices.ShipmentItem>();
        for (Integer i = 0; i < 2; i++) {
            ShipmentItemObj = new AramexShippingServices.ShipmentItem();
            ShipmentItemObj.PackageType = Constants.PACKAGE_TYPE;
            ShipmentItemObj.Quantity = Constants.SHIPMENT_QUANTITY;
            ShipmentItemObj.weight = getWeight();
            //ShipmentItemObj.Comments = 'TEST=='+ objStp.HexaBPM__SR__r.RecordType.Name + '==' + objStp.HexaBPM__SR__r.Name ;
            ShipmentItemObj.Comments = objStp.HexaBPM__SR__r.RecordType.Name + '==' + objStp.HexaBPM__SR__r.Name ;
            ShipmentItemObj.Reference = objStp.Name;
            shipmentItemList.add(ShipmentItemObj);
        }
        ArrayOfShipmentItemObj.ShipmentItem = shipmentItemList;
        return ArrayOfShipmentItemObj;
    }
    

    /**
     * [getLabelInfo -Method used for getting label info details]
     * @return [Label Information]
     */
    public static AramexShippingServices.LabelInfo getLabelInfo() {
        AramexShippingServices.LabelInfo LabelInfoObj = new AramexShippingServices.LabelInfo();
        LabelInfoObj.ReportID = Integer.valueOf(aramexConfigDetails.LabelReportId__c);
        LabelInfoObj.ReportType = aramexConfigDetails.LabelReportType__c;
        return LabelInfoObj;
    }


    /**
    * [generateRefNumber Generates Random Number]
    * @return [Unique  number]
    */
    public static String generateRefNumber() {
        Integer len = 5;
        String str = string.valueof(Math.abs(Crypto.getRandomLong()));
        String randomNumber = str.substring(0, len);
        system.debug('Random Number-' + randomNumber);

        String hashString = randomNumber + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        String hexDigest = EncodingUtil.convertToHex(hash);
        System.debug('hexDigest==>' + hexDigest);
        return hexDigest;

    }

    /**
     * [getAramexConfigDetails - Method to get the Aramex Config Details from Custom Metadata Type]
     * @param  Name [Name of the Custom Metadata Type]
     * @return      [Config details from custom metadata type]
     */
    public static Aramex_Service_Setting__mdt getAramexConfigDetails(String Name) {
        Aramex_Service_Setting__mdt aramexConfigDetails = new Aramex_Service_Setting__mdt();
        String query = getAllFields(Aramex_Service_Setting__mdt.getsObjectType().getDescribe());
        query += ' WHERE DeveloperName = : Name ';
        for (Aramex_Service_Setting__mdt setting : Database.query(query)) {
            aramexConfigDetails = setting;
        }
        //AramexServices__c aramexConfigDetails = AramexServices__c.getInstance(Name);
        return aramexConfigDetails;
    }

    /**
     * [LogException - Log exception during execution]
     * @param e [Exception Object]
     */
    public static void LogException(Exception e) {
        System.debug('==>' + e.getLineNumber());
        Log__c EL =  new Log__c();
        EL.Cause__c = String.valueOf(e.getCause());
        EL.Line_Number__c = e.getLineNumber();
        EL.Message__c = e.getMessage();
        EL.Stack_Trace__c = e.getStackTraceString();
        EL.Type_Name__c = e.getTypeName();
        EL.User_Name__c = UserInfo.getName();
        EL.step__c = objStp.Id;
        EL.User_Email__c = UserInfo.getUserEmail();
        insert EL;
    }
    /**
     * [LogException Method to log any Aramex Errors ]
     * @param Message [Message value]
     */
    public static void LogException(String Message) {
        Log__c EL =  new Log__c();
        EL.Message__c = Message ;
        EL.step__c = objStp.Id;
        EL.User_Email__c = UserInfo.getUserEmail();
        insert EL;
    }
    

    /**
     * [getLocalDateTime -  Method used to get Date time in local correction]
     * @param  z [Date time value to corrcet]
     * @return   [Date time corrected]
     */
    public Static Datetime getLocalDateTime(Datetime z) {
        Datetime l = z.Date();
        l = l.addHours(z.hour());
        l = l.addMinutes(z.minute());
        l = l.addSeconds(z.second());

        return l;
    }
    

    /**
     * [getCutOffTime - Method to calculate cut off time]
     * @return [CutOff date time value]
     */
    public static Datetime getCutOffTime() {
        DateTime cutOff  = DateTime.newInstance(System.Today().Year(), System.Today().Month(), System.Today().Day(), Integer.valueOf(System.Label.ARAMEX_CUTOFF_TIME)-1, 00, 00);
        return getLocalDateTime(cutOff);
    }
    
    /**
     * [getPickupTime Method to return pickup time]
     * @return [Pickup Date time value]
     */
    public static DateTime getPickupTime() {
        System.debug('**getPickupTime**');
        DateTime retDateTime;
        DateTime CutOffTime = getCutOffTime();
        DateTime currentTime  = getLocalDateTime(System.Now());
        System.debug('Current Time :' + currentTime);
        System.debug('CutOffTime Time :' + CutOffTime);

        if (currentTime <= CutOffTime) {
            retDateTime = CutOffTime;
            
        } else {
            retDateTime = (CutOffTime.addDays(1).format('EEEE') == 'Friday') ? CutOffTime.addDays(3) : CutOffTime.addDays(1) ;
            
        }


        return retDateTime;
    }
    
    /**
     * [getPickupTime Method to return pickup time]
     * @return [Pickup Date time value]
     */
    public static DateTime getReadyTime() {
        System.debug('**getReadyTime**');
        DateTime retDateTime;
        DateTime CutOffTime = getCutOffTime();
        //DateTime currentTime  = getLocalDateTime(System.Now().addHours(1));
        DateTime currentTime  = getLocalDateTime(System.Now());
        System.debug('Current Time :' + currentTime);
        System.debug('CutOffTime Time :' + CutOffTime);

        if (currentTime <= CutOffTime) {
            retDateTime = CutOffTime; //End of the day
            
            
        } else {
            retDateTime = (CutOffTime.addDays(1).format('EEEE') == 'Friday') ? CutOffTime.addDays(3) : CutOffTime.addDays(1) ;// pickup next days cut off time
            
        }


        return retDateTime;
    }

    
    /**
     * [getLastPickupTime - Method to get last pickup time]
     * @return [Last pickup date time value]
     */
    public static DateTime getLastPickupTime() {
        System.debug('**getLastPickupTime**');
        DateTime retDateTime;
        DateTime CutOffTime = getCutOffTime();
        DateTime currentTime  = getLocalDateTime(System.Now().addMinutes(30));

        System.debug('Current Time :' + currentTime);
        System.debug('CutOffTime Time :' + CutOffTime);

        if (currentTime <= CutOffTime) {
            retDateTime = CutOffTime;
        } else {
            retDateTime = (CutOffTime.addDays(1).format('EEEE') == 'Friday') ? CutOffTime.addDays(3) : CutOffTime.addDays(1) ;// pickup next days cut off time
        }

        return retDateTime;

    }

    /**
     * [encryptPhrase Encrypts phrase using crypto key defined in the contants]
     * @param  phraseToEncrypt [Value to encrypt]
     * @return                 [Encrypted value]
     */
    public  static String encryptPhrase(String phraseToEncrypt) {
        Blob keyblobval = Blob.valueOf(Constants.CRYPTOKEY);
        Blob phraseBlob = Blob.valueOf(phraseToEncrypt);
        Blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', keyblobval, phraseBlob);
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        return encryptedString;
    }


    /**
     * [decryptPhrase Decrypts phrase using key defined in constants]
     * @param  phraseToDecrypt [Value to decrypt]
     * @return                 [Decdrypted value]
     */
    public  static String decryptPhrase(String phraseToDecrypt) {
        Blob keyblobval = Blob.valueOf(Constants.CRYPTOKEY);
        Blob encodedEncryptedBlob = EncodingUtil.base64Decode(phraseToDecrypt);
        Blob decryptedBlob = Crypto.decryptWithManagedIV('AES256', keyblobval, encodedEncryptedBlob);
        String decryptedPasswordText = decryptedBlob.toString();
        return decryptedPasswordText;
    }


}
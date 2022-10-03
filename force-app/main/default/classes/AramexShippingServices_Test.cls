@isTest
private class AramexShippingServices_Test{
    static testmethod void holdCreation(){
        Test.setMock(WebServiceMock.class, new AramexShippingServicesMockTest('HOLDCREATION'));
        AramexShippingServices.BasicHttpBinding_Service_1_0  serviceObj = new AramexShippingServices.BasicHttpBinding_Service_1_0 ();
        AramexShippingServices.ClientInfo clientInfoobj = null;
        AramexShippingServices.Transaction_x TransactionObj = null;
        AramexShippingServices.ArrayOfShipmentHoldDetails Shipments =  null;
        AramexShippingServices.HoldCreationResponse_element testHold= serviceObj.HoldShipments(clientInfoobj, TransactionObj, Shipments);
    }
    static testmethod void reserveShipmentNumber(){
        Test.setMock(WebServiceMock.class, new AramexShippingServicesMockTest('RESERVESHIPMNETNUMBERRANGE'));
        AramexShippingServices.BasicHttpBinding_Service_1_0  serviceObj = new AramexShippingServices.BasicHttpBinding_Service_1_0 ();
        AramexShippingServices.ClientInfo clientInfoobj = null;
        AramexShippingServices.Transaction_x TransactionObj = null;
        AramexShippingServices.ReserveRangeResponse_element testReserve= serviceObj.ReserveShipmentNumberRange(clientInfoobj, TransactionObj, 'TestEntity','TestGrp',1);
    }
    static testmethod void lastShipmentNumber(){
        Test.setMock(WebServiceMock.class, new AramexShippingServicesMockTest('GETSHIPMNETNUMBERRANGE'));
        AramexShippingServices.BasicHttpBinding_Service_1_0  serviceObj = new AramexShippingServices.BasicHttpBinding_Service_1_0 ();
        AramexShippingServices.ClientInfo clientInfoobj = null;
        AramexShippingServices.Transaction_x TransactionObj = null;
        AramexShippingServices.LastReservedShipmentNumberRangeResponse_element testlastNumber= serviceObj.GetLastShipmentsNumbersRange(clientInfoobj, TransactionObj, 'TestEntity','TestGrp');
    }
}
/*  Author      : Keerthan Tantry
    Date        : 25-Feb-2018
    Description : Class storing all constant variables


    ------------------------------------------------------------------------------------------------------
*/
public without sharing class Constants {
    

    /** Aramex Constants - Start*/
    public static final string CRYPTOKEY = '12341544566467678798791237868947';
    public static final string ORIGINENTITY = 'AUH';
    public static final string PICKUPLOCATION = 'Reception';
    public static final string VEHICLE = 'Small';
    public static final string PICKUP_STATUS = 'Ready';
    public static final Integer NO_OF_SHIPMENTS = 1;
    public static final string PACKAGE_TYPE = 'Box';
    public static final string PAYMENT_TYPE = 'P';
    public static final string ARAMEX_CURRENCY = 'AED';
    public static final string CONSIGNER_COUNTRY_CODE = 'AE';
    public static final string GOODSORIGINCOUNTRY = 'AUH';
    public static final Integer NO_OF_PIECES = 1;
    public static final Integer WEIGHT_VALUE = 1;
    public static final Integer VOLUME_VALUE = 1;
    public static final Integer SHIPMENT_QUANTITY = 1;
    /** Aramex Constants - End*/
    
    public static final string STR_Under_Review = 'Under Review';
    public static final string STR_Approved = 'Approved';

    public static final set<string> SET_TAX_VALUES = new set<string>{
        '5%','ADJUSTMENT 5%'
    };
    public static final string TaxCode = '5%';
    public static final Integer TAX_PERCENT = 5;
    
}
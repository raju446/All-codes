trigger Accountupdate on Account (before insert,before update) {
    if((trigger.isInsert || trigger.isUpdate)&&trigger.isBefore){
        for(Account acc:trigger.new){
        if(acc.ShippingAddress==null){
        acc.ShippingCity = acc.BillingCity;
        acc.ShippingCountry = acc.BillingCountry;
        acc.ShippingLatitude= acc.BillingLatitude;
        acc.ShippingLongitude = acc.BillingLongitude;
        acc.ShippingPostalCode =acc.BillingPostalCode;
        acc.ShippingState=acc.BillingState;
        acc.ShippingStreet = acc.BillingStreet;
        }   
    } 
    } 
}
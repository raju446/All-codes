Public class ServiceRequestViewController{
    public String isSRAccessible {get;set;}
    HexaBPM__Service_Request__c srObj;
    
    public ServiceRequestViewController(){
        isSRAccessible = '';
    }
    
    public void checkAccessibility(){
        String srId = ApexPages.currentPage().getParameters().get('Id');
        HexaBPM__Service_Request__c srObject = [SELECT Id, Service_Type__c FROM HexaBPM__Service_Request__c WHERE Id = :srId];
        String userId = UserInfo.getUserId();
        User usObj = [SELECT Id, Name, Is_Community_User__c,Types_of_Services_Accessible__c FROM User WHERE Id = :userId];
        if(usObj.Is_Community_User__c){
            if(String.isNotBlank(usObj.Types_of_Services_Accessible__c) && String.isNotBlank(srObject.Service_Type__c) && (usObj.Types_of_Services_Accessible__c).contains(srObject.Service_Type__c)){
                isSRAccessible = 'true';
            }else{
                isSRAccessible = 'false';
            }
        }else{
            isSRAccessible =  'true';
        } 
        isSRAccessible = JSON.serialize(isSRAccessible.trim());
    }
}
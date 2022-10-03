public class ReceiptViewController{
    
    public String isReceiptAccessible {get;set;}
    
    public void checkAccessibility(){
        String recId = ApexPages.currentPage().getParameters().get('Id');
        Receipt__c rcObject = [SELECT Id, CreatedById FROM Receipt__c WHERE Id = :recId LIMIT 1];
        String userId = UserInfo.getUserId();
        User usObj = [SELECT Id, Name, Is_Community_User__c FROM User WHERE Id = :userId];
        if(usObj.Is_Community_User__c){
            if(rcObject.CreatedById == userId){
                isReceiptAccessible = 'true';
            }else{
                isReceiptAccessible = 'false';
            }
        }else{
            isReceiptAccessible = 'true';
        } 
        isReceiptAccessible = JSON.serialize(isReceiptAccessible.trim());
    }
}
public class whatsappapex {
    @AuraEnabled 
    public static Contact fetchContact(String conId){
        return [Select Id, Name,Phone, MobilePhone FROM Contact where Id=:conId ];
    }
    
    @AuraEnabled
    public static String saveChat(String conId, String chat){
        WhatsApp__c wa = new WhatsApp__c();
        wa.WhatsAppText__c = chat;
        wa.ContactId__c = conId;
        wa.WhatsAppDate__c = System.Datetime.now();
        insert wa;
        return wa.Id;
    }
}
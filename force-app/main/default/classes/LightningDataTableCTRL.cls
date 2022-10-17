public class LightningDataTableCTRL {
    @AuraEnabled
    public static list<WhatsApp__c> getChatsList(String pageSize, String pageNumber, String conId){
        String soql = 'Select Name, FORMAT(WhatsAppDate__c), WhatsAppText__c FROM WhatsApp__c where ContactId__c=\''+conId+'\' Order By WhatsAppDate__c';
        system.debug('###SOQL : '+soql);
        if(pageSize==null){
            pageSize='10';
        }
        if(pageNumber==null){
            pageNumber='1';
        }
        Integer ps = Integer.valueOf(pageSize);
        Integer pn = Integer.valueOf(pageNumber)-1;
        soql += ' limit '+ps+' OFFSET '+(ps*pn);
         system.debug('### Complete SOQL : '+soql);
        List<WhatsApp__c> accList= Database.Query(soql);
        if(accList != null && accList.size()>0){
		return accList;
        }
        else{return null;}
    }
     @AuraEnabled
    public static Integer getChatsCount(){
        String soqlStr = 'Select COUNT() From WhatsApp__c';
        Integer recCount= database.countQuery(soqlStr);
        return recCount;
    }
}
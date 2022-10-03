/**
 * @File Name          : LookupSearchComponentController.cls
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 5/6/2020, 2:49:30 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/25/2020   Jayanta Karmakar     Initial Version
**/
public class LookupSearchComponentController {
    
    @AuraEnabled
    public static List<SObJectResult> getResults(String ObjectName, String fieldName, String value, String filtertxt) {
        system.debug('----->'+ ObjectName +'----'+fieldName+'----'+value);
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
        String qst = 'Select Id,Invoice_Balance__c,GL_Date__c'+fieldName+' FROM '+ObjectName+' WHERE '+fieldName+' LIKE \'%' + value + '%\''+filtertxt+' LIMIT 10';
        System.debug(qst);
        for(sObject so : Database.Query('Select Id,Invoice_Balance__c,In_Progress_Amount__c,GL_Date__c,Total_Taxable_Amount__c,'+fieldName+' FROM '+ObjectName+' WHERE '+fieldName+' LIKE \'%' + value + '%\''+filtertxt+' LIMIT 10')) {
            DateTime dt = (DateTime)so.get('GL_Date__c');
            String inDt = dt == null? Date.today().Year()+'-'+Date.today().Month()+'-'+Date.today().Day() : dt.Year()+'-'+dt.Month()+'-'+dt.Day();
            String fieldvalue = (String)so.get(fieldName);
            system.debug('fieldvalue==>>' + fieldvalue);
            system.debug('so.Id==>>' + so.Id);
            system.debug('3==>>' +((Decimal)so.get('Invoice_Balance__c') - (decimal)so.get('In_Progress_Amount__c') ) );
            system.debug('4==>>' + inDt);
            system.debug('5==>>' + ((Decimal)so.get('Total_Taxable_Amount__c')));
            SObjectResult objSObjectResult = new SObjectResult(fieldvalue, so.Id, ((Decimal)so.get('Invoice_Balance__c') - (decimal)so.get('In_Progress_Amount__c') ),inDt, ((Decimal)so.get('Total_Taxable_Amount__c')));
            if(objSObjectResult.invAmt != 0)
                sObjectResultList.add( objSObjectResult );
        }
        system.debug(sObjectResultList.size());
        return sObjectResultList;
    }
    
    public class SObJectResult {
        @AuraEnabled
        public String recName;
        @AuraEnabled
        public Id recId;
        @AuraEnabled
        public Decimal invAmt;
        @AuraEnabled
        public String invoiceDate;
        @AuraEnabled
        public decimal invTaxAmount;

        public SObJectResult(String recNameTemp, Id recIdTemp, Decimal inAmt, String invDate, decimal dTax) {
            recName = recNameTemp;
            recId = recIdTemp;
            invAmt = inAmt;
            invoiceDate = invDate;
            if(dTax != null && dTax != 0){
                invTaxAmount = dTax;//(invAmt*(Decimal)5/100);
            }else{
                invTaxAmount = dTax;
            }
            
        }
    }
}
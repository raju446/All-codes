/*****
* Name              : CSPApplicationCmpController
* Author            : prateek.b.bansal@pwc.com
* Date              : 
* Description       : Controller for LEX_CSPApplicationCmp
*****/
public class CSPApplicationCmpController {
    
    /****
    * Name          :   getReceiptDetails
    * Author        :   prateek.b.bansal@pwc.com
    * Description   :   method to fetch receipt details for selected entity
    ****/
    @AuraEnabled
    public static List<Receipt__c> getReceiptDetails(String entityId){
        return [SELECT Id, Entity__r.Name, Entity__r.Oracle_Site_Id__c, Entity__r.Operating_Unit_Name__c, Remaning_Amount__c, GL_Date__c, Amount__c, Name, Operating_Unit__c, Payment_Currency__c 
                    FROM Receipt__c 
                    WHERE Entity__c =: entityId AND Remaning_Amount__c > 0 AND Journal_Created__c = TRUE 
                          AND Is_Reversed__c = false ORDER BY Remaning_Amount__c DESC];
    } 
    
    
    /****
    * Name          :   getInvoiceDetails
    * Author        :   prateek.b.bansal@pwc.com
    * Description   :   fetch invoices related to selected entity and prepare application with selected receipt.
    ****/
    @AuraEnabled
    public static List<ApplicationWrapper> getInvoiceDetails(String selectedReceiptId, String entityId, String paymentCurrency){
        List<ApplicationWrapper> applWrapLst = new List<ApplicationWrapper>();
        List<Invoice__c> invLst = [SELECT Id, Entity__r.Name, Entity__r.Oracle_Site_Id__c, Entity__r.Operating_Unit_Name__c, Invoice_Balance__c, GL_Date__c, Total_Invoice_Amount_OC__c, Name, Operating_Unit__c, Payment_Currency__c 
                    FROM Invoice__c 
                    WHERE Entity__c =: entityId AND Invoice_Balance__c > 0 AND Journal_Created__c = TRUE AND Payment_Currency__c = :paymentCurrency
                          AND Status__c != 'Cancelled' AND Service_Request__c = '' ORDER BY Invoice_Balance__c DESC];
        
        for(Invoice__c invObj : invLst){
            ApplicationWrapper appObj = new ApplicationWrapper();
            appObj.invoiceName = invObj.Name;
            appObj.invoiceId = invObj.Id;
            appObj.receiptId = selectedReceiptId;
            appObj.glDate = System.today();
            appObj.appliedDate = System.today();
            appObj.appliedAmnt = invObj.Invoice_Balance__c;
            appObj.invAmnt = invObj.Total_Invoice_Amount_OC__c;
            appObj.invBalance = invObj.Invoice_Balance__c;
            appObj.isSelected = false;
            applWrapLst.add(appObj);
        }
        return applWrapLst;
    } 
    
    public class ApplicationWrapper{
        @AuraEnabled
        public String invoiceName;
        @AuraEnabled
        public String receiptId;
        @AuraEnabled
        public String invoiceId;
        @AuraEnabled
        public Date glDate;
        @AuraEnabled
        public Date appliedDate;
        @AuraEnabled
        public Decimal appliedAmnt;
        @AuraEnabled
        public Decimal invAmnt;
        @AuraEnabled
        public Decimal invBalance;
        @AuraEnabled
        public Boolean isSelected;
    }
    
    public class ResponseWrapper{
        @AuraEnabled
        public string message;
        @AuraEnabled
        public boolean success;
    }
    
    /****
    * Name          :   createApplicationRecords
    * Author        :   prateek.b.bansal@pwc.com
    * Description   :   Create application using the details from the component
    ****/
    @AuraEnabled
    public static ResponseWrapper createApplicationRecords(String appLst){
        system.debug(appLst);
        List<ApplicationWrapper> applWrapLst = (List<ApplicationWrapper>) System.JSON.deserialize(appLst, List<ApplicationWrapper>.class);
        List<Related_Invoice_Receipt__c> newAppliLst = new List<Related_Invoice_Receipt__c>();
        List<Invoice__c> invLst = new List<Invoice__c>();
        for(ApplicationWrapper appWrapObj : applWrapLst){
            Related_Invoice_Receipt__c appObj = new Related_Invoice_Receipt__c();
            appObj.Invoice__c = appWrapObj.invoiceId;
            appObj.Receipt__c = appWrapObj.receiptId;
            appObj.Applied_Date__c = appWrapObj.appliedDate;
            appObj.GL_Date__c = appWrapObj.appliedDate;
            appObj.Amount_Applied__c = appWrapObj.appliedAmnt;
            appObj.Oracle_Applied_Amount__c = appWrapObj.appliedAmnt;
            appObj.Journal_Created__c = true;
            appObj.Applied__c = true;
            newAppliLst.add(appObj);
            Invoice__c invObj = new Invoice__c(Id = appWrapObj.invoiceId, Invoice_Balance__c = appWrapObj.appliedAmnt - appWrapObj.invBalance);
            invLst.add(invObj);
        }
        try{
            system.debug('==>>' + invLst);
            system.debug('==>>' + newAppliLst);
            UPDATE invLst; 
            INSERT newAppliLst;
            List<Id> appObjLst = new List<Id>();
            for(Related_Invoice_Receipt__c appObj : newAppliLst){
                appObjLst.add(appObj.Id);
            }
            BM_JournalEntryEngine.receiptApplicationJournalLines(appObjLst);
            ResponseWrapper respObj = new ResponseWrapper();
            respObj.success = true;
            respObj.message = 'Applications Created';
            return respObj;
        }catch(Exception exObj){
            ResponseWrapper respObj = new ResponseWrapper();
            respObj.success = false;
            respObj.message = exObj.getMessage();
            return respObj;
        }
    }
}
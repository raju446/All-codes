/*
* Author : Rajil Ravindran
* Date : 03/05/2018
* Purpose : Generates Account Statement for both Portal and Backend(Admin) Users.
*/
public without sharing class StatementAccountController{
    public list<StatementAccount> lstStatementAcct {get;set;}
    public string accountName {get;set;}
    public string licenseNumber {get;set;}
    public list<StatementAccount> lstBlockedTransactions {get;set;}
    public decimal transactionTotalDebitAmt {get;set;}
    public decimal transactionTotalCreditAmt {get;set;}
    public decimal blockedTransactionTotalDebitAmt {get;set;}
    public decimal blockedTransactionTotalCreditAmt {get;set;}
    public decimal portalBalance {get;set;}
    public sObject sObj{get;set;}
    public boolean isPortalUser {get;set;}
    public StatementAccountController(){
        isPortalUser = false;
        list<User> lstUser = [Select contactId from User where id =: Userinfo.getUserid() limit 1];
        if(lstUser!=null && lstUser.size() > 0){
            if(String.isNotBlank(lstUser[0].contactId))
                isPortalUser = true;
        }
        //This below IsPortalUser check is done since the same account lookup and date fields cannot be used
        //for both Portal and Backend users due to the object permission rights.
        if(isPortalUser){ //If logged in user is portal user, use HexaBPM__Service_Request__c to get the Account lookup and the date fields on the VF Page
            sObj =  Schema.getGlobalDescribe().get('HexaBPM__Service_Request__c').newSObject();
        }else{ //If logged in user is backend user, use Receipt__c to get the Account lookup and the date fields on the VF Page
            sObj = Schema.getGlobalDescribe().get('Receipt__c').newSObject();
        }
    }
    public void fetchStatementAccount(){
        portalBalance = 0;
        Datetime dtFrmDate = system.now();
        Datetime dtToDate = system.now();
        string fromDate = ApexPages.currentPage().getParameters().get('fromDate') + ' 00:00:00';
        string toDate = ApexPages.currentPage().getParameters().get('toDate') + ' 23:59:59';
        if(string.isNotEmpty(fromDate) && string.isNotEmpty(toDate)){
            dtFrmDate = DateTime.valueOf(fromDate);
            dtToDate = DateTime.valueOf(toDate);
        }
        System.debug('dtFrmDate' +dtFrmDate);
        System.debug('dtToDate' +dtToDate);
        transactionTotalDebitAmt = 0;
        transactionTotalCreditAmt = 0;
        blockedTransactionTotalDebitAmt = 0;
        blockedTransactionTotalCreditAmt = 0;
        string accountId,oraclePartyId;
        lstStatementAcct = new list<StatementAccount>();
        lstBlockedTransactions = new list<StatementAccount>();
        list<User> lstUser = [Select contact.accountid,contact.Account.Name,contact.Account.Oracle_Party_Id__c, contact.account.Establishment_Card_No__c from User where id =: Userinfo.getUserid() limit 1];
        if(isPortalUser){
            accountId = lstUser[0].contact.accountid;
            oraclePartyId = lstUser[0].contact.Account.Oracle_Party_Id__c;
            accountName = lstUser[0].contact.Account.Name;
            licenseNumber = lstUser[0].contact.account.Establishment_Card_No__c;
        }else{
            accountId = ApexPages.currentPage().getParameters().get('accId');
            list<Account> lstAcct = [select Oracle_Party_Id__c,Name,Establishment_Card_No__c from Account where id = :accountId ];
            if(lstAcct != null && lstAcct.size() > 0){
                oraclePartyId = lstAcct[0].Oracle_Party_Id__c;
                accountName = lstAcct[0].Name;
                licenseNumber = lstAcct[0].Establishment_Card_No__c;
            }
        }
        if(String.isNotBlank(accountId)){
            /* Portal Balance Calculation */
            /*decimal ReceiptsAmount = ApexCodeUtility.getOpenReceiptsAmount(accountId);
            decimal BlockedSRsAmount = ApexCodeUtility.getBlockedAmount(accountId);
            decimal BalancefromOracle;
            try{
                BalancefromOracle = WS_BalanceCheck.GetOracleBalance(oraclePartyId);
            }catch(Exception e){
                portalBalance = 0;   
            }
            if(BalancefromOracle!=null)
                portalBalance = BalancefromOracle;
            
            if(ReceiptsAmount!=null)
                portalBalance = portalBalance + ReceiptsAmount;
            
            if(BlockedSRsAmount!=null)
                portalBalance = portalBalance - BlockedSRsAmount;*/
            //portalBalance = portalBalance.setScale(2);
            portalBalance = PortalBalanceCalculator.finalbalance(accountId).setScale(2);
            datetime dttest = System.now();
            
            decimal receiptTotalDebitAmount = 0;
            decimal receiptTotalCreditAmount = 0;
            //Adding the receipts to the list
            for(Receipt__c receipt : [select Receipt_Created_Date__c,Payment_Purpose__c,Amount__c,Payment_Method__c, Description__c,Service_Request__r.RecordType.Name,Receipt_Reference__c,Service_Request__r.Name 
                                        from Receipt__c where Entity__c = :accountId and Legacy_Data__c=false and CreatedDate>=:dtFrmDate and CreatedDate<=:dtToDate 
                                            and Status__c in ('Success','Approved') and Payment_Currency__c != 'USD' ]){
                StatementAccount stAcct = new StatementAccount();
                if(receipt.Service_Request__r.Name != null)
                {
                    stAcct.SrNumber = receipt.Service_Request__r.Name;
                }
                stAcct.receiptDate = receipt.Receipt_Created_Date__c;
                stAcct.description = receipt.Payment_Purpose__c;
                stAcct.paymentMethod = receipt.Payment_Method__c;
                stAcct.fees = receipt.Amount__c;
                stAcct.qty = 1;
                stAcct.refNumber = receipt.Receipt_Reference__c;
                if(receipt.Amount__c != null && receipt.Amount__c < 0) {
                    stAcct.debitAmt = receipt.Amount__c * -1;
                }else{
                    stAcct.creditAmt = receipt.Amount__c;
                }
                lstStatementAcct.add(stAcct);
                
            }
            
            /*//Adding CMs to the list
            for(Invoice__c invObj : [SELECT Id, Name, Total_Invoice_Amount_Rollup__c, CreatedDate 
                                        FROM Invoice__c 
                                        WHERE RecordType.Name = 'Credit Memo' AND Entity__c = :accountId AND Payment_Currency__c = 'AED'
                                        AND Status__c IN ('Approved', 'Success')]){
                StatementAccount stAcct = new StatementAccount();
                stAcct.receiptDate = Date.valueOf(invObj.CreatedDate);
                stAcct.refNumber = invObj.Name;
                stAcct.description = 'Credit Memo';
                stAcct.qty = 1;
                stAcct.creditAmt = invObj.Total_Invoice_Amount_Rollup__c * -1; 
                lstStatementAcct.add(stAcct);
            }
            
            
            //Adding FTs to the list
            for(Fund_Transfer__c ftObj : [SELECT Id, Name, Reference_Receipt__r.Receipt_Reference__c, CreatedDate, Amount__c, From_Currency__c, To_Currency__c 
                                            FROM Fund_Transfer__c 
                                            WHERE Status__c IN ( 'Approved', 'Success') AND To_Receipt__r.Oracle_Receipt_Id__c != '' 
                                            AND From_Currency__c = 'AED' AND Reference_Receipt__r.Entity__c = :accountId]){
                                            
                StatementAccount stAcct = new StatementAccount();
                stAcct.receiptDate = ftObj.CreatedDate.Date();
                stAcct.fees = ftObj.Amount__c;
                stAcct.qty = 1;
                stAcct.description = 'Fund Transfer from ' + ftObj.Reference_Receipt__r.Receipt_Reference__c;
                stAcct.refNumber = ftObj.Name;
                stAcct.debitAmt = ftObj.Amount__c;
                lstStatementAcct.add(stAcct);
            }*/
            
            //Adding the SR Price Items to the list
            for(HexaBPM__SR_Price_Item__c srPriceItem : [select Name,HexaBPM__Product__r.Name,Applicant_Name__c,CreatedDate,HexaBPM__Status__c, HexaBPM__ServiceRequest__r.RecordType.Name,HexaBPM__Price__c,Total_Amount__c, HexaBPM__ServiceRequest__r.Name 
                                                from HexaBPM__SR_Price_Item__c
                                                where Entity__c = :accountId and HexaBPM__Status__c in ('Consumed','Invoiced','Blocked') 
                                                and CreatedDate >= :dtFrmDate and CreatedDate <= :dtToDate 
                                                        AND HexaBPM__Product__r.Name != :System.Label.Invoice_Refund_In_Statement]){
                StatementAccount stAcct = new StatementAccount();
                //if(srPriceItem.HexaBPM__ServiceRequest__r.Name != null)
                //{
                //  stAcct.SrNumber = srPriceItem.HexaBPM__ServiceRequest__r.Name;
                //}
                stAcct.receiptDate = Date.valueOf(srPriceItem.CreatedDate);
                //stAcct.refNumber = srPriceItem.Name;
                stAcct.refNumber = srPriceItem.HexaBPM__ServiceRequest__r.Name;
                stAcct.description = srPriceItem.HexaBPM__Product__r.Name;
                if(srPriceItem.Applicant_Name__c!=null)
                    stAcct.serviceType = srPriceItem.HexaBPM__ServiceRequest__r.RecordType.Name +' for '+srPriceItem.Applicant_Name__c;
                else
                    stAcct.serviceType = srPriceItem.HexaBPM__ServiceRequest__r.RecordType.Name;
                stAcct.qty = 1;
                if(srPriceItem.Total_Amount__c != null && srPriceItem.Total_Amount__c < 0 )
                    stAcct.fees = srPriceItem.Total_Amount__c * -1;
                else
                    stAcct.fees = srPriceItem.Total_Amount__c;
                    
                if(srPriceItem.Total_Amount__c!= null && srPriceItem.Total_Amount__c > 0) { //If +ve, then add it to debit attribute.
                    stAcct.debitAmt = srPriceItem.Total_Amount__c;
                }else if(srPriceItem.Total_Amount__c!= null){
                    stAcct.creditAmt = srPriceItem.Total_Amount__c * -1.00; //If -ve, then add it to credit attribute.
                }
                if(srPriceItem.HexaBPM__Status__c == 'Blocked')
                    lstBlockedTransactions.add(stAcct);
                else
                    lstStatementAcct.add(stAcct);
            }
            
            //Calculating the Totals for the Transactions
            for(StatementAccount stObj : lstStatementAcct){
                if(stObj.debitAmt != null)
                    transactionTotalDebitAmt = transactionTotalDebitAmt + stObj.debitAmt;
                if(stObj.creditAmt!= null)
                    transactionTotalCreditAmt += stObj.creditAmt;
            }
            //Calculating the Totals for the Blocked Transactions
            for(StatementAccount stObj : lstBlockedTransactions){
                if(stObj.debitAmt != null)
                    blockedTransactionTotalDebitAmt += stObj.debitAmt;
                if(stObj.creditAmt!= null)
                    blockedTransactionTotalCreditAmt += stObj.creditAmt;
            }
            //Sorts by date asc for the transaction list
            lstStatementAcct.sort();
            lstBlockedTransactions.sort();
        }
    }
   
    public class StatementAccount implements Comparable{
        public date receiptDate {get;set;}
        public string description {get;set;}
        public string serviceType {get;set;}
        public string additionalInfo {get;set;}
        public string paymentMethod {get;set;}
        public decimal fees {get;set;}
        public integer qty {get;set;}
        public string refNumber {get;set;}
        public decimal debitAmt {get;set;}
        public decimal creditAmt {get;set;}
        public string SrNumber  {get;set;}
        public Integer compareTo(Object compareTo){
            StatementAccount compareToRec = (StatementAccount)compareTo;
            if(receiptDate == compareToRec.receiptDate) 
                return 0;
            if(receiptDate > compareToRec.receiptDate) 
                return 1;
            return -1;         
        }
    }
}
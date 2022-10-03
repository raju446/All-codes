/*
    Author      : Durga Prasad
    Date        : 04-May-2020
    Description : Batch class to push the Invoices to ERP which where created from csv file.
    ------------------------------------------------------------------------------------------
*/
public without sharing class Batch_RAFinancialTransactionExt2 implements Database.batchable<sObject>, Database.AllowsCallouts {
    public Database.QueryLocator start(Database.BatchableContext BC){
        map<String, Schema.SObjectType>  m = Schema.getGlobalDescribe();
        SObjectType objtype;
        DescribeSObjectResult objDef1;
        map<String, SObjectField> fieldmap;
        if(m.get('RA_Receipt_Invoice__c')!= null){
            objtype = m.get('RA_Receipt_Invoice__c');
            objDef1 =  objtype.getDescribe();
            fieldmap =  objDef1.fields.getmap();
        }
        set<string> setFields = new set<string>();
        if(fieldmap!=null){
            for(Schema.SObjectField strFld:fieldmap.values()){
                Schema.DescribeFieldResult fd = strFld.getDescribe();
                if(fd.isCustom())
                    setFields.add(string.valueOf(strFld).toLowerCase());
            }
        }
        setFields.add('id');
        string strqry =  'Select name';
        if(setFields.size()>0){
            for(string srField : setFields){
                strqry += ','+srField;
            }
        }
        strqry += ' From RA_Receipt_Invoice__c where Invoice__c!=null and Invoice__r.Journal_Created__c=false';
        return database.getQueryLocator(strqry);
    }
    /*
        Execute method to push Invoice to ERP with batch size as 1
    */
    public void execute(Database.BatchableContext BC,list<RA_Receipt_Invoice__c> lstRA){
        
        try{
            for(RA_Receipt_Invoice__c RARI:lstRA){
                InvoiceUtil.pushToOracleInvoice(new list<string>{RARI.Invoice__c});
            }
        }catch(Exception e){string sMessage = e.getMessage()+'';Log__c objLog = new Log__c(Line_Number__c = e.getLineNumber(),Additional_Information__c = sMessage,Stack_Trace__c =  e.getStackTraceString(),Type_Name__c = e.getTypeName());
                            if(sMessage .length() > 240){objLog.Message__c = sMessage.subString(0,240);} 
                            else {objLog.Message__c = sMessage;}
            insert objLog;
        }   
    }
    public void finish(Database.BatchableContext BC){
    	if(label.RA_Receipt_Push=='True'){Batch_RAFinancialTransactionExt3 objBatchExt3 = new Batch_RAFinancialTransactionExt3();Database.executeBatch(objBatchExt3,1);}
    }
}
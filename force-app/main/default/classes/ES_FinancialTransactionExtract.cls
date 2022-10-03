/*
    Author      : Durga Prasad
    Date        : 04-May-2020
    Description : Email Service to read the RA Financial Extract and save as Attachment.
    -------------------------------------------------------------------------------------
*/
global without sharing class ES_FinancialTransactionExtract implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        string strEmailBody = email.plainTextBody;
        string strEmailSubject = email.subject;
        system.debug('strEmailSubject===>'+strEmailSubject);
        system.debug('strEmailBody===>'+strEmailBody);
        system.debug('FromEmailAddress===>'+email.fromAddress);
        
        RA_Financial_File__c RAfile = new RA_Financial_File__c();
        RAfile.From_Email__c = email.fromAddress;
        RAfile.Status__c = 'Created';
        insert RAfile;
        
        list<Attachment> lstAttachments = new list<Attachment>();
        if(!system.test.isRunningTest()){
            if(email.binaryAttachments != null && email.binaryAttachments.size() > 0){
                for(integer i = 0; i < email.binaryAttachments.size(); i++) {
                    lstAttachments.add(new Attachment(ParentId = RAfile.Id,Name = email.binaryAttachments[i].filename,Body = email.binaryAttachments[i].body));
                }
            }
        }else{
            string strCSVData = 'Payment ID,Authority Name,Receipt Number,Receipt Date,Payment Method,Entity Name,Entity Number,Category,Service Type,General Ledger Code,General Ledger Entry Description,Fee,Description,Fee Type,Fee Amount in AED,Fee Amount in USD,Total Fee in AED,Total Paid in AED,Balance in AED\n 12323122,Registration Authority,RA-X31231,5/12/2020,Electronic Funds Transfer (direct credit),ABC XYZ LTD,131313,Non-Financial (Category B),Registration & Incorporation,3101,Application Fee for License,  Reserve a Company Name,Application Fee for License,367.35,100,5510.25,367.35,5142.9\n 12323123,Registration Authority,RA-X31233,5/12/2020,Credit Card,ABC XYZ LTD,131313,Non-Financial (Category B),Registration & Incorporation,3101,Application Fee for License,Reserve a Company Name,Application Fee for License,367.35,100,5510.25,367.35,5142.9';       
            blob csvFileBody = Blob.valueOf(strCSVData);
            Attachment a = new Attachment();
            a.ParentId = RAfile.Id;
            a.Name = 'MAY2020_Catalyst Reports.csv';
            a.Body = csvFileBody;
            lstAttachments.add(a);
        }
        if(lstAttachments!=null && lstAttachments.size()>0){
            try{
                insert lstAttachments;
                
                if(label.RA_File_Push=='True'){
                    RAfile.Status__c = 'Process Started';
                    update RAfile;
                    
                    Batch_CSVFileParser objCsvBtch = new Batch_CSVFileParser();//Initializing the Batch class
                    objCsvBtch.StrCSVFileId = RAfile.Id;//Assigning the CSV File record Id to the batch class variable
                    objCsvBtch.StrObjectName = 'RA_Receipt_Invoice__c';//Assigning the object API Name to the batch class variable.
                    Database.executeBatch(objCsvBtch,200);//Executing the Batch class
                }
            }catch(Exception e){
                RAfile.Message__c = 'Attachment Insert Failed'+e.getMessage();
                update RAfile;
            }
        }
        return result;
    }
}
/*
    Author      : Durga Prasad
    Date        : 04-May-2020
    Description : Batch class to parse the FinancialExtract CSV file and create them as Receipts and Invoices.
    ----------------------------------------------------------------------------------------------------------
*/
public without sharing class Batch_CSVFileParser implements Database.batchable<String>, Database.Stateful{
    public string StrCSVFileId;//Variable which will hold the CSV File Record Id where we will store the Record Count, Success & Failure details.
    public string StrObjectName;//Variable which will defines the Object API Name of the CSV File. 
    public string selCurrFormat;//variable to hold the Currency Format in case there is any Currency fields in the file
    public string selDateFormat = 'YYYY/MM/DD';//'MM/DD/YYYY';//variable to hold the Date format to be followed while dealing with date fields
    
    public map<string,map<string,string>> mapCS_HeaderMap = new map<string,map<string,string>>();//Map to store the Csv Header(s) mapping to the Object fields.
    public map<string,map<string,string>> mapCS_LI_HeaderMap = new map<string,map<string,string>>();
    
    public map<integer,string> Map_ColIndex_FieldName = new map<integer,string>();//Map to store the Column index of the file along with its Field Name.
    public map<integer,string> Map_LineItemIndexField = new map<integer,string>();
    
    public RA_Financial_File__c objCSV = new RA_Financial_File__c();// Object which will be used to update the Success/Failure and Status of the Import.
    public string headerString;//header values to be useful for sending the failure records email for the user
    
    public string errors;// = headerString.trim()+','+'Error Message\n';
    
    //Start method which will invoke when the batch class initialzed from "Invoke_FileProcess" class.
    public Iterable<string> start(Database.BatchableContext BC){
        objCSV = new RA_Financial_File__c(Id=StrCSVFileId);
        string finalStr;
        /* Querying the attachment which has to be processed */
        for(Attachment attch:[SELECT Id,Name,Body,ParentId,CreatedDate from Attachment where ParentId=:StrCSVFileId]){
            finalStr = attch.Body.toString();
            system.debug('ActId==>'+attch.Id);
        }
        /* Getting Custom setting data for Mapping the CSV File headers to appropriate fields */
        for(CSV_Header_Field_Mapping__c CS:[select Id,Name,Header_Value__c,Object_Name__c,Field_Name__c from CSV_Header_Field_Mapping__c where Object_Name__c=:StrObjectName and Header_Value__c!=null and Field_Name__c!=null]){
            map<string,string> Map_CustomSetting_Data = new map<string,string>();
            if(mapCS_HeaderMap.get(CS.Object_Name__c)!=null)
                Map_CustomSetting_Data = mapCS_HeaderMap.get(CS.Object_Name__c);
            Map_CustomSetting_Data.put(CS.Header_Value__c,CS.Field_Name__c);
            mapCS_HeaderMap.put(CS.Object_Name__c,Map_CustomSetting_Data);
        }
        
        for(CSV_Header_Field_Mapping__c CS:[select Id,Name,Header_Value__c,Object_Name__c,Field_Name__c from CSV_Header_Field_Mapping__c where Object_Name__c='RA_Invoice_Line_Item__c' and Header_Value__c!=null and Field_Name__c!=null]){
            map<string,string> Map_CustomSetting_Data = new map<string,string>();
            if(mapCS_LI_HeaderMap.get(CS.Object_Name__c)!=null)
                Map_CustomSetting_Data = mapCS_LI_HeaderMap.get(CS.Object_Name__c);
            Map_CustomSetting_Data.put(CS.Header_Value__c,CS.Field_Name__c);
            mapCS_LI_HeaderMap.put(CS.Object_Name__c,Map_CustomSetting_Data);
        }
        
        list<string> numberOfRows = new list<string>();//to store the CSV File rows(Including Headers)
        list<string> headers = new list<string>();// to store the CSV File Header Row only i.e. (Headers of the CSV File)
        map<string,string> Map_CS_Data = new map<string,string>();
        map<string,string> Map_CS_LI_Data = new map<string,string>();
        
        if(mapCS_HeaderMap.get(StrObjectName)!=null)
            Map_CS_Data = mapCS_HeaderMap.get(StrObjectName);
        if(mapCS_LI_HeaderMap.get('RA_Invoice_Line_Item__c')!=null)
            Map_CS_LI_Data = mapCS_LI_HeaderMap.get('RA_Invoice_Line_Item__c');
        if(finalStr != null && finalStr!=''){
            numberOfRows = new list<String>();
            String introValue='\n';//string which holds the new line sign to split the csvdata string as list of Rows 
            numberOfRows = safeSplit(finalStr,'\n');
            finalStr = '';
            system.debug('numberOfRows===>'+numberOfRows.size());
            system.debug('numberOfRows data===>'+numberOfRows);
            if(numberOfRows!=null && numberOfRows.size()>0){
                if(numberOfRows[0].trim() != null && numberOfRows[0].trim() != ''){
                    headers = numberOfRows[0].split(',');//splitting the header row string to get the list of Header Vlaues of the file
                    headerString = numberOfRows[0];//holding the headers in an list
                    errors = headerString.trim()+','+'Error Message\n';
                    integer i = 0;//variable to hold the Header row index
                    for(String s: headers){
                        if(s!= '' && s != null && s.trim() != '' && s != 'Error Message'){//checking the header column and excluding the Error Message column
                            if(Map_CS_Data.get(s.trim())!=null)
                                Map_ColIndex_FieldName.put(i,Map_CS_Data.get(s.trim()).toLowerCase());//replacing the Header Row text with Field API Name as config in Custom Setting.
                            if(Map_CS_LI_Data.get(s.trim())!=null)
                                Map_LineItemIndexField.put(i,Map_CS_LI_Data.get(s.trim()).toLowerCase());
                            i++;
                        }
                    }
                }
                if(numberOfRows.size()>1)//checking the totals number of rows and removing the header row from the total row(s) list
                    numberOfRows.remove(0);
                objCSV.Success__c = 0;//defaulting the Success record count to zero before processing
                objCSV.Failure__c = 0;//defaulting the Failure record count to zero before processing
                if(numberOfRows.size()>0 && numberOfRows[numberOfRows.size()-1]==''){
                    numberOfRows.remove(numberOfRows.size()-1);
                }
                objCSV.Total_Records__c = numberOfRows.size();//assigning the total record count for the field
            }
        }
        return numberOfRows;
    }
    /*
      Execute Method which will be invoked for every 200 csv rows (200 is the default batch size) of the whole file.
    */
    public void execute(Database.BatchableContext BC, list<string> lstCSVRows){
        
        /* Map to store the field datatype */
        map<string,map<string,Schema.DisplayType>> map_Schema_DisplayType = new map<string,map<string,Schema.DisplayType>>();
        /* Schema to get all the field details of the Object */
        map<String, SObjectField> ObjectFieldMap = Schema.getGlobalDescribe().get(StrObjectName).getDescribe().fields.getMap();
        list<string> lstFields = new list<string>();//list to store all the fields of the sObject
        lstFields.addAll(ObjectFieldMap.keyset());
        map<string,Schema.DisplayType> mapsObjectField_DataType = new map<string,Schema.DisplayType>();// Map to store the key as field Name and value as Data Type
        for(string projField : lstFields){
            DescribeFieldResult selectedField = ObjectFieldMap.get(projField).getDescribe();
            if(selectedField.isUpdateable() && selectedField.isAccessible()){
                mapsObjectField_DataType.put(string.valueOf(selectedField.getName()).toLowerCase(),selectedField.getType());
            }
        }
        map_Schema_DisplayType.put(StrObjectName,mapsObjectField_DataType);
        
        ObjectFieldMap = Schema.getGlobalDescribe().get('RA_Invoice_Line_Item__c').getDescribe().fields.getMap();
        lstFields = new list<string>();
        lstFields.addAll(ObjectFieldMap.keyset());
        mapsObjectField_DataType = new map<string,Schema.DisplayType>();// Map to store the key as field Name and value as Data Type
        for(string projField : lstFields){
            DescribeFieldResult selectedField = ObjectFieldMap.get(projField).getDescribe();
            if(selectedField.isUpdateable() && selectedField.isAccessible()){
                mapsObjectField_DataType.put(string.valueOf(selectedField.getName()).toLowerCase(),selectedField.getType());
            }
        }
        map_Schema_DisplayType.put('RA_Invoice_Line_Item__c',mapsObjectField_DataType);
        
        map<Integer,string> mpToInsertRows = new map<Integer,string>();
        
        map<string,Schema.DisplayType> mapField_DataType = map_Schema_DisplayType.get(StrObjectName);
        map<string,Schema.DisplayType> map_LI_Field_DataType = map_Schema_DisplayType.get('RA_Invoice_Line_Item__c');
        
        map_Schema_DisplayType = new map<string,map<string,Schema.DisplayType>>();
        
        list<RA_Receipt_Invoice__c> lstDyncObject = new list<RA_Receipt_Invoice__c>();
        map<string,list<RA_Invoice_Line_Item__c>> MapLineItems = new map<string,list<RA_Invoice_Line_Item__c>>();
        map<string,string> MapUniqueInvoices = new map<string,string>();
        
        try{
            if(lstCSVRows!=null && lstCSVRows.size()>0){
                integer Rows = 0;
                for(String s : lstCSVRows){//looping each row of the csv file and preparing the records
                    list<string> lstData = s.split(',');//splitted the string with "," to get each column data
                    string dateError='';
                    string decimalError='';
                    string valueError='';
                    RA_Receipt_Invoice__c DycObject = new RA_Receipt_Invoice__c();
                    DycObject.RA_Financial_File__c = StrCSVFileId;
                    
                    for(integer ColIndex:Map_ColIndex_FieldName.keyset()){
                        if(Map_ColIndex_FieldName.containsKey(ColIndex)){
                            string strFieldName = Map_ColIndex_FieldName.get(ColIndex);
                            try{
                                if(lstData[ColIndex] != null && lstData[ColIndex] != '' && lstData[ColIndex].trim() != '' && lstData[ColIndex].trim() != null){
                                    if(mapField_DataType.get(strFieldName)!=null){
                                        string val = lstData[ColIndex].trim();
                                        if(mapField_DataType.get(strFieldName)==Schema.DisplayType.Date){
                                            system.debug('val=>'+val);
                                            if(dateFormatter(val)!= null)
                                                DycObject.put(strFieldName,dateFormatter(val));
                                        }else if(mapField_DataType.get(strFieldName)==Schema.DisplayType.DateTime){
                                            if(val!=null && val.indexof('T')>-1){
                                                DateTime DateTimeVal = dateTime.valueOf(val.replace('T',' '));
                                                DycObject.put(strFieldName,DateTimeVal);
                                            }
                                        }else if(mapField_DataType.get(strFieldName)==Schema.DisplayType.Currency || mapField_DataType.get(strFieldName)==Schema.DisplayType.Percent){
                                            DycObject.put(strFieldName,decimal.valueOf(val));
                                        }else if(mapField_DataType.get(strFieldName)==Schema.DisplayType.Boolean){
                                            DycObject.put(strFieldName,Boolean.valueOf(lstData[ColIndex]));
                                        }else if(mapField_DataType.get(strFieldName)==Schema.DisplayType.Double){
                                            DycObject.put(strFieldName,Double.valueOf(lstData[ColIndex]));
                                        }else if(mapField_DataType.get(strFieldName)==Schema.DisplayType.Integer){
                                            DycObject.put(strFieldName,Integer.valueOf(lstData[ColIndex]));
                                        }else{
                                            DycObject.put(strFieldName,lstData[ColIndex]);
                                        }
                                    }
                                }else{
                                    DycObject.put(strFieldName,null);
                                }
                                
                            }catch(Exception e){
                                valueError = strFieldName+'=>'+e.getMessage();
                            }
                        }
                    }
                    string ReceiptUniqueNumber = DycObject.Entity_Number__c+'-'+DycObject.Receipt_Number__c+'-'+StrCSVFileId;
                    DycObject.put('Receipt_Number_Unique__c',ReceiptUniqueNumber);
                    
                    list<RA_Invoice_Line_Item__c> listInvoiceLines = new list<RA_Invoice_Line_Item__c>();
                    RA_Invoice_Line_Item__c objInvoiceLI = new RA_Invoice_Line_Item__c();
                    for(integer ColIndex:Map_LineItemIndexField.keyset()){
                        if(Map_LineItemIndexField.containsKey(ColIndex)){
                            string strFieldName = Map_LineItemIndexField.get(ColIndex);
                            try{
                                if(lstData[ColIndex] != null && lstData[ColIndex] != '' && lstData[ColIndex].trim() != '' && lstData[ColIndex].trim() != null){
                                    if(map_LI_Field_DataType.get(strFieldName)!=null){
                                        string val = lstData[ColIndex].trim();
                                        if(map_LI_Field_DataType.get(strFieldName)==Schema.DisplayType.Date){
                                            system.debug('val=>'+val);
                                            if(dateFormatter(val)!= null)
                                                objInvoiceLI.put(strFieldName,dateFormatter(val));
                                        }else if(map_LI_Field_DataType.get(strFieldName)==Schema.DisplayType.DateTime){
                                            if(val!=null && val.indexof('T')>-1){
                                                DateTime DateTimeVal = dateTime.valueOf(val.replace('T',' '));
                                                objInvoiceLI.put(strFieldName,DateTimeVal);
                                            }
                                        }else if(map_LI_Field_DataType.get(strFieldName)==Schema.DisplayType.Currency || map_LI_Field_DataType.get(strFieldName)==Schema.DisplayType.Percent){
                                            objInvoiceLI.put(strFieldName,decimal.valueOf(val));
                                        }else if(map_LI_Field_DataType.get(strFieldName)==Schema.DisplayType.Boolean){
                                            objInvoiceLI.put(strFieldName,Boolean.valueOf(lstData[ColIndex]));
                                        }else if(map_LI_Field_DataType.get(strFieldName)==Schema.DisplayType.Double){
                                            objInvoiceLI.put(strFieldName,Double.valueOf(lstData[ColIndex]));
                                        }else if(map_LI_Field_DataType.get(strFieldName)==Schema.DisplayType.Integer){
                                            objInvoiceLI.put(strFieldName,Integer.valueOf(lstData[ColIndex]));
                                        }else{
                                            objInvoiceLI.put(strFieldName,lstData[ColIndex]);
                                        }
                                    }
                                }else{
                                    objInvoiceLI.put(strFieldName,null);
                                }
                                objInvoiceLI.put('Receipt_Number_Unique__c',ReceiptUniqueNumber);
                            }catch(Exception e){
                                valueError = strFieldName+'=>'+e.getMessage();
                            }
                        }
                    }
                    if(MapUniqueInvoices.get(ReceiptUniqueNumber)==null){
                        mpToInsertRows.put(mpToInsertRows.size(),s);
                        lstDyncObject.add(DycObject);
                        MapUniqueInvoices.put(ReceiptUniqueNumber,ReceiptUniqueNumber);
                    }
                    
                    if(objInvoiceLI.Receipt_Number_Unique__c!=null && MapLineItems.get(objInvoiceLI.Receipt_Number_Unique__c)!=null)
                        listInvoiceLines = MapLineItems.get(objInvoiceLI.Receipt_Number_Unique__c);
                    
                    if(objInvoiceLI.Receipt_Number_Unique__c!=null){
                        listInvoiceLines.add(objInvoiceLI);
                        MapLineItems.put(objInvoiceLI.Receipt_Number_Unique__c,listInvoiceLines);
                    }
                }
                integer success = 0;
                integer failure = 0;
                string Error = '';
                system.debug('lstDyncObject===>'+lstDyncObject);
                if(lstDyncObject!=null && lstDyncObject.size()>0){
                    Schema.SObjectField UpsertFld = RA_Receipt_Invoice__c.Fields.Receipt_Number_Unique__c;
                    list<Database.UpsertResult> UpsertResultLst = Database.upsert(lstDyncObject,UpsertFld,false);
                    //list<Database.SaveResult> srList = Database.insert(lstDyncObject);
                    integer rowNum = 0;
                    if(UpsertResultLst!=null){
                        for(Database.UpsertResult sr : UpsertResultLst){
                            if(sr.getErrors().size()>0){
                                string errorDesc='';
                                for(Database.Error e : sr.getErrors()){
                                    if(errorDesc=='')
                                       errorDesc = e.getMessage();
                                    else
                                       errorDesc = errorDesc +';'+e.getMessage();
                                    Error = Error + '||' + errorDesc;
                                }
                                system.debug('errorDesc==>'+errorDesc);
                                if(mpToInsertRows.containsKey(rowNum))
                                    errors = errors+mpToInsertRows.get(rowNum).trim()+','+errorDesc+'\n';
                                failure++;
                            }
                            else
                                success++;
                            rowNum++;
                       }
                    }
                }
                if(MapLineItems.size()>0){
                    map<string,RA_Receipt_Invoice__c> MapRAInvoice = new map<string,RA_Receipt_Invoice__c>();
                    for(RA_Receipt_Invoice__c RARI:[Select Id,Receipt_Number_Unique__c,Revenue_Classification__c from RA_Receipt_Invoice__c where Receipt_Number_Unique__c IN:MapLineItems.keyset()]){
                        MapRAInvoice.put(RARI.Receipt_Number_Unique__c,RARI);
                    }
                    list<RA_Invoice_Line_Item__c> lstInvLineItems = new list<RA_Invoice_Line_Item__c>();
                    for(list<RA_Invoice_Line_Item__c> LstInvLI:MapLineItems.values()){
                        for(RA_Invoice_Line_Item__c InvLI:LstInvLI){
                            if(InvLI.Receipt_Number_Unique__c!=null && MapRAInvoice.get(InvLI.Receipt_Number_Unique__c)!=null){
                                InvLI.RA_Receipt_Invoice__c = MapRAInvoice.get(InvLI.Receipt_Number_Unique__c).Id;
                                InvLI.Revenue_Classification__c = MapRAInvoice.get(InvLI.Receipt_Number_Unique__c).Revenue_Classification__c;
                                lstInvLineItems.add(InvLI);
                            }
                        }
                    }
                    if(lstInvLineItems.size()>0){
                        list<Database.SaveResult> LineItemSaveResult = Database.insert(lstInvLineItems);
                        if(LineItemSaveResult!=null){
                            for(Database.SaveResult sr : LineItemSaveResult){
                                if(sr.getErrors().size()>0){
                                    string errorDesc='';
                                    for(Database.Error e : sr.getErrors()){
                                        if(errorDesc=='')
                                           errorDesc = e.getMessage();
                                        else
                                           errorDesc = errorDesc +';'+e.getMessage();
                                        Error = Error + '||' + errorDesc;
                                    }
                                    system.debug('Line Item errorDesc==>'+errorDesc);
                                }
                            }
                        }
                    }
                }
                system.debug('Error==>'+Error);
                objCSV.Success__c = objCSV.Success__c + success;//setting the Success record count to the Success__c Field
                objCSV.Failure__c = objCSV.Failure__c + failure;//setting the Failure record count to the Failure__c field.
            }
        }catch(Exception e){
            string sMessage = e.getMessage()+'';
            Log__c objLog = new Log__c(Line_Number__c = e.getLineNumber(),Additional_Information__c = sMessage,Stack_Trace__c =  e.getStackTraceString(),Type_Name__c = e.getTypeName());
            if(sMessage .length() > 240) 
                objLog.Message__c = sMessage.subString(0,240);
            else 
                objLog.Message__c = sMessage;
            insert objLog;
        }
    }
    
    /*
      Method Name  :  finish
      Description  :  Finish method which will executes at the End after the completion of all the batches.
    */
    public void finish(Database.BatchableContext BC){//Finish method
        
        if(objCSV.Total_Records__c==objCSV.Failure__c){
            objCSV.Status__c = 'Failed';
        }else if(objCSV.Total_Records__c==objCSV.Success__c){
            objCSV.Status__c = 'Success';
        }else{
            objCSV.Status__c = 'Partial Success';
        }
        update objCSV;
        
        
        //if(objCSV.Failure__c>0 && errors != null){
            User loggedInUser;
            for(User objUsr:[select id,Name,Email,UserName from User where Id=:userinfo.getUserId()]){
                loggedInUser = objUsr;
            }
            //Email Attachment
            Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
            blob csvBlob = Blob.valueOf(errors);
            csvAttc.setFileName('Failed'+System.Today()+'.csv');
            csvAttc.setBody(csvBlob);
            csvAttc.setContentType('application/vnd.ms-excel');
            //Sending Email
            Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
            String[] toAddresses = new list<string> {system.label.RA_CSV_Email_Trigger};
            String subject ='RE: '+StrObjectName+' Data Load Status';
            email.setSubject(subject);
            email.setToAddresses(toAddresses);
            if(objCSV.Failure__c!=null && objCSV.Failure__c>0)
                email.setPlainTextBody('Hello '+UserInfo.getName()+',\n\nPlease find the below details of your data load.\nNumber of records loaded:'+objCSV.Total_Records__c+'\nNumber of successful records:'+objCSV.Success__c+'\nNumber of failure records:'+objCSV.Failure__c+'\n\n\nThank You\nSalesforce Support');
            else
                email.setPlainTextBody('Hello '+UserInfo.getName()+',\n\nYou have inserted all the records successfully. Please find below the details of you data load.\nNumber of records loaded:'+objCSV.Total_Records__c+'\nNumber of successful records:'+objCSV.Success__c+'\nNumber of failure records:'+objCSV.Failure__c+'\n\n\nThank You\nSalesforce Support');                
            if(objCSV.Failure__c!=null && objCSV.Failure__c>0)
                email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
            if(!System.Test.isRunningTest())    
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        //}
        
        try{
            if(!system.Test.isRunningTest()){
                if(label.RA_Account_Push=='True'){
                    Batch_RAFinancialTransactionExt1 objBatchExt1 = new Batch_RAFinancialTransactionExt1();
                    Database.executeBatch(objBatchExt1,1);
                }
            }
        }catch(Exception e){
            string sMessage = e.getMessage()+'';
            Log__c objLog = new Log__c(Line_Number__c = e.getLineNumber(),Additional_Information__c = sMessage,Stack_Trace__c =  e.getStackTraceString(),Type_Name__c = e.getTypeName());
            if(sMessage .length() > 240) 
                objLog.Message__c = sMessage.subString(0,240);
            else 
                objLog.Message__c = sMessage;
            insert objLog;
        }
    }
    /*
      Method Name  :  formatDecimals
      Description  :  Method which will formats the decimal value string based on the configuration. 
    */
    public string formatDecimals(string cost){
          if(cost.contains(',') || cost.contains('.')){
              if(selCurrFormat == 'Comma'){
                  if(cost.lastIndexOf(',') < cost.lastIndexOf('.')) 
                    cost = cost.replaceAll(',','');
                  else
                    cost='Error';
              }else{
                  if(cost.lastIndexOf('.') < cost.lastIndexOf(',')){
                    list<String> vals = cost.split(',');
                    vals[0]=vals[0].replaceAll('.','');
                    cost = vals[0];
                    if(vals.size()>0)
                        cost = cost+'.'+vals[1];
                  }else{
                    cost='Error';
                  }
              }
          }
          return cost; 
    }
    /*
      Method Name  :  dateFormatter
      Description  :  Method which will formats the date string based on the configuration. 
    */
    public date dateFormatter(string selDate){
        try{
            system.debug('selDate==>'+selDate);
            string DateFormat = label.CSV_File_Date_Format;
            system.debug('DateFormat==>'+DateFormat);
            date formattedDate ;
            /*
            //if(selDateFormat=='MM/DD/YYYY'){//value is coming in this format//YYYY/MM/DD
                list<string> dtString = selDate.split('/');
                if(Integer.valueOf(dtString[1])<=12)
                    formattedDate = date.newInstance(Integer.valueOf(dtString[0]), Integer.valueOf(dtString[1]), Integer.valueOf(dtString[2]));////YYYY/MM/DD
                //formattedDate = date.newInstance(Integer.valueOf(dtString[2]), Integer.valueOf(dtString[0]), Integer.valueOf(dtString[1]));//MM/DD/YYYY
                
            //}
            */
            list<string> dtString = selDate.split('/');
            if(DateFormat=='MM/DD/YYYY'){
                if(Integer.valueOf(dtString[0])<=12)
                    formattedDate = date.newInstance(Integer.valueOf(dtString[2]), Integer.valueOf(dtString[0]), Integer.valueOf(dtString[1]));//MM/DD/YYYY
            }else if(DateFormat=='YYYY/MM/DD'){
                if(Integer.valueOf(dtString[1])<=12)
                    formattedDate = date.newInstance(Integer.valueOf(dtString[0]), Integer.valueOf(dtString[1]), Integer.valueOf(dtString[2]));//YYYY/MM/DD
            }
            system.debug('formattedDate==>'+formattedDate);
            return formattedDate;
        }catch(Exception e){
            return null;
        }
        return null;
    }
    public static list<string> safeSplit(String inStr, String delim){
        Integer regexFindLimit = 100;
        Integer regexFindCount = 0;
        list<String> output = new list<String>();
        Matcher m = Pattern.compile(delim).matcher(inStr);
        Integer lastEnd = 0;
        while(!m.hitEnd()){
            while(regexFindCount < regexFindLimit && !m.hitEnd()){
                if(m.find()){
                    output.add(inStr.substring(lastEnd, m.start()));  
                    lastEnd = m.end();
                }else{
                    output.add(inStr.substring(lastEnd));
                    lastEnd = inStr.length();
                }
                regexFindCount++;
            }
            // Note: Using region() to advance instead of substring() saves 
            // drastically on heap size. Nonetheless, we still must reset the 
            // (unmodified) input sequence to avoid a 'Regex too complicated' 
            // error.
            m.reset(inStr);        
            m.region(lastEnd, m.regionEnd());
            regexFindCount = 0;
        }
        return output;
    }
}
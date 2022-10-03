/*
    Author      : Jayanta Karmakar
    Date        : 16-Mar-2020
    Description : Credit Memo Utility Class to push the Invoices to Oracle
    ------------------------------------------------------------------
*/
public class CreditMemoUtil {

    public static Boolean isFromCreditMemoUpdate = false;
    
    //@future(callout = true)
    //public static void pushToOracleCreditMemoFuture(List<String> invIDs){pushToOracleCreditMemo(invIDs);} 

    public static void pushToOracleCreditMemo(List<String> invIDs){
        /*if(invIDs <> null && invIDs.size() > 0){
            try{
                List<Invoice__c> listCreditMemo = new List<Invoice__c>();
                list<Invoice_Line_Item__c> listILT = new List<Invoice_Line_Item__c>();
                for(Invoice__c inv : [SELECT Id,Name,Entity__r.Oracle_Site_Id__c,Description__c,Invoice_Type__c,Invoice_Date__c,Entity__r.Oracle_Party_Id__c,Converted_Invoice_Balance__c,
                                        Oracle_Invoice_Type__c, Oracle_Invoice_Id__c,Oracle_GL_Date__c,Is_Refundable__c,Total_Invoice_Amount__c,GL_Date__c,
                                        Payment_Currency__c, Credit_Memo_Type__c,Source_System__c,Source_Invoice_Id__c,
                                        (SELECT Id,Name,Item_Reference__c,Amount__c, Invoice__c, Invoice_Line_Item__r.Invoice__r.Oracle_Invoice_Id__c,Invoice__r.Oracle_Invoice_Id__c,Line_No__c,
                                                Tax_Amount__c,Item_Description__c,Tax__c,Invoice_Line_Item__r.Tax__c,Department__c,Service_Type__c,Course_Type__c,Schools__c,Quantity__c,Revenue_Type__c,Line_Description__c 
                                         FROM Invoice_Line_Items__r WHERE RECORDTYPE.Name = 'Invoice Line Item') 
                                    FROM Invoice__c WHERE Id IN: invIDs AND From_Data_Migration__c = false]){
                                                                                         
            
            		String jsonBody = ConstructInvoicePayload(inv);
                    system.debug('Request Body--->'+jsonBody);
                    // get endpoint details
                    List<ERP_Endpoint_Details__mdt> listERPEndpointDetails = new List<ERP_Endpoint_Details__mdt>();
                    listERPEndpointDetails = [SELECT ID,Endpoint_URL__c, Password__c, Username__c,HTTP_Method__c  FROM ERP_Endpoint_Details__mdt WHERE Is_Active__c = true AND DeveloperName =: 'Credit_Memo_Creation' LIMIT 1];                                                                    
                    if(listERPEndpointDetails <> null && listERPEndpointDetails.size() > 0 ) {                  
						HTTPResponse response = HTTPRestUtil.callWebservice(listERPEndpointDetails[0].Endpoint_URL__c,listERPEndpointDetails[0].HTTP_Method__c,jsonBody);              
						 system.debug('Response Body---->'+response.getBody());    
                        //save Payload on fail for reference purpose
                        ApexCodeUtility.savePayload(listERPEndpointDetails[0].Endpoint_URL__c,jsonBody,invIDs[0],response.getBody());
                        
						OutputParameters respObj = (OutputParameters)JSON.deserialize(response.getBody() , OutputParameters.class);
						system.debug(respObj);
						List<Invoice__c> listInvoice = new List<Invoice__c>();                                                                      
						if(respObj.P_OP_RETURN_STS == 'S' && string.isNotBlank(respObj.P_OP_CM_NUM) ){
							inv.Status__c = 'Invoiced';
							inv.Oracle_Invoice_Id__c = respObj.P_OP_CM_NUM;
							inv.CM_Applied_Amount__c = respObj.P_OP_AMT_APPLIED;
							inv.Converted_CM_Applied_Amount__c = respObj.P_CONV_AMT_APPLIED;
							inv.CM_Applied_Invoice_No__c = respObj.P_OP_APPL_INV_NO;
							if(respObj.P_OP_GL_DATE != null){
								List<String> glDateStrings = respObj.P_OP_GL_DATE.split('-');
								inv.Oracle_GL_Date__c = date.newinstance(Integer.valueOf(glDateStrings[2]), Integer.valueOf(glDateStrings[1]), Integer.valueOf(glDateStrings[0]));
							}
							if(respObj.P_AMT_INV_BAL != null && respObj.P_AMT_INV_BAL != '') {
								List<String> listOracleInvoicIds = new List<String>();
								List<String> balAmnts = new List<String>();
								List<String> conBalAmnts = new List<String>();
								if(respObj.P_OP_APPL_INV_NO <> null && respObj.P_OP_APPL_INV_NO <> '')
									listOracleInvoicIds = respObj.P_OP_APPL_INV_NO.split(',');
								if(respObj.P_AMT_INV_BAL <> null && respObj.P_AMT_INV_BAL <> '')
									balAmnts = respObj.P_AMT_INV_BAL.split(',');
								if(respObj.P_CONV_AMT_INV_BAL <> null && respObj.P_CONV_AMT_INV_BAL <> '')
									conBalAmnts = respObj.P_CONV_AMT_INV_BAL.split(',');
								listInvoice = [SELECT Id, Invoice_Balance__c, Oracle_Invoice_Id__c, Converted_Invoice_Balance__c FROM Invoice__c WHERE Oracle_Invoice_Id__c IN: listOracleInvoicIds];
								for(Integer i =0; i < listOracleInvoicIds.size(); i++){
									for(Invoice__c obj : listInvoice){
										if(listOracleInvoicIds[i] == obj.Oracle_Invoice_Id__c){ obj.Invoice_Balance__c = (balAmnts.size()-1) >= i ? Decimal.valueOf(balAmnts[i]) : 0; obj.Converted_Invoice_Balance__c = (conBalAmnts.size()-1) >= i ? Decimal.valueOf(conBalAmnts[i]) : 0;
										}
									}
								}                            
							}
							if(!inv.Is_Refundable__c) {
								inv.Invoice_Balance__c = respObj.P_AMT_CM_INV_BAL != null && respObj.P_AMT_CM_INV_BAL != '' ? Decimal.valueof(respObj.P_AMT_CM_INV_BAL) : 0.0; inv.Converted_Invoice_Balance__c = respObj.P_CONV_AMT_CM_INV_BAL != null && respObj.P_CONV_AMT_CM_INV_BAL != '' ? Decimal.valueof(respObj.P_CONV_AMT_CM_INV_BAL) : 0.0;
								//inv.Invoice_Balance__c = respObj.P_CONV_AMT_CM_INV_BAL != null && respObj.P_CONV_AMT_CM_INV_BAL != '' ? Decimal.valueof(respObj.P_CONV_AMT_CM_INV_BAL) : 0.0;
								//inv.Converted_Invoice_Balance__c = respObj.P_CONV_INV_AMOUNT != null && respObj.P_CONV_INV_AMOUNT != '' ? Decimal.valueof(respObj.P_CONV_INV_AMOUNT) : 0.0;
							} else {
								//inv.Invoice_Balance__c = inv.Total_Invoice_Amount__c;  
								inv.Invoice_Balance__c = respObj.P_AMT_CM_INV_BAL != null && respObj.P_AMT_CM_INV_BAL != '' ? Decimal.valueof(respObj.P_AMT_CM_INV_BAL) : -inv.Total_Invoice_Amount__c; inv.Converted_Invoice_Balance__c = respObj.P_CONV_AMT_CM_INV_BAL != null && respObj.P_CONV_AMT_CM_INV_BAL != '' ? Decimal.valueof(respObj.P_CONV_AMT_CM_INV_BAL) : 0.0;
							}
								 
							inv.Oracle_Response_Message__c = respObj.P_OP_RETURN_MSG;
                            system.debug('inv.Invoice_Line_Items__r==>>' + inv.Invoice_Line_Items__r);
							if(respObj.P_OP_LINE_TBL.size() > 0){
								for(LINE_DETAILS lines : respObj.P_OP_LINE_TBL){
									for(Invoice_Line_Item__c eachLine : inv.Invoice_Line_Items__r){
										if(eachLine.id == lines.X8_ITEM_SFID){eachLine.Line_No__c = Decimal.valueof(lines.X12_LINE_NO);
										}
									}
								}
							}
							if(inv <> null )
                                listCreditMemo.add(inv);
							if(inv.Invoice_Line_Items__r <> null && inv.Invoice_Line_Items__r.size() > 0)
                                listILT.addAll(inv.Invoice_Line_Items__r);
								//update inv.Invoice_Line_Items__r;
                            if(listInvoice <> null && listInvoice.size() > 0){listCreditMemo.addAll(listInvoice);}
						} 
                        else {inv.Oracle_Response_Message__c = respObj.P_OP_RETURN_MSG;update inv;return respObj.P_OP_RETURN_MSG;}

						//return 'SUCCESS';
					}
            	}
                
                if(listCreditMemo <> null && listCreditMemo.size() > 0)
                    update listCreditMemo;
                if(listILT <> null && listILT.size() > 0)
                    update listILT;
            } catch(Exception ex){ String sMessage = ex.getMessage();Log__c objLog = new Log__c(); if(sMessage .length() > 240) { objLog.Message__c = sMessage.subString(0,240);} else {objLog.Message__c = sMessage;} objLog.Line_Number__c = ex.getLineNumber();objLog.Stack_Trace__c =  ex.getStackTraceString();objLog.Type_Name__c = ex.getTypeName(); insert objLog;return ex.getMessage();
            }
        }
        return 'SUCCESS';*/
    }
    /*
    public static string ConstructInvoicePayload(Invoice__c objInv){
        list<LINE_REC_TYPE_CLASS> lstInvoiceLines = new list<LINE_REC_TYPE_CLASS>();
        Map<String, Decimal> mapInvoiceWithAmount = new Map<String, Decimal>();
        map<string, decimal> mapInvAmounts = new map<string, decimal>();
        
        List<Invoice_Line_Item__c> lstInvoiceLineItems = isFromCreditMemoUpdate ? objInv.Invoice_Line_Items1__r : objInv.Invoice_Line_Items__r;
        
        if(lstInvoiceLineItems != null && !lstInvoiceLineItems.isEmpty()){
            for(Invoice_Line_Item__c InvLI : lstInvoiceLineItems){//objInv.Invoice_Line_Items__r
                
                InvLI.Amount__c = InvLI.Amount__c != null ? InvLI.Amount__c : 0; 
                InvLI.Tax_Amount__c = InvLI.Tax_Amount__c != null ? InvLI.Tax_Amount__c : 0; 
                if(objInv.Credit_Memo_Type__c == 'Debit'){ InvLI.Amount__c = InvLI.Amount__c > 0 ? InvLI.Amount__c : InvLI.Amount__c*-1; InvLI.Tax_Amount__c = InvLI.Tax_Amount__c > 0 ? InvLI.Tax_Amount__c : InvLI.Tax_Amount__c*-1;
                }else{
                    InvLI.Amount__c = InvLI.Amount__c > 0 ? InvLI.Amount__c*-1 : InvLI.Amount__c;
                    InvLI.Tax_Amount__c = InvLI.Tax_Amount__c > 0 ? InvLI.Tax_Amount__c*-1 : InvLI.Tax_Amount__c;
                }

                String amount = InvLI.Amount__c != null ? String.valueof(InvLI.Amount__c) : '0.0';
                //String taxAmount = InvLI.Tax_Amount__c != null ? String.valueOf(InvLI.Tax_Amount__c) : '0.0';

                Decimal amountVal = 0;
                if( mapInvoiceWithAmount.get(InvLI.Invoice_Line_Item__r.Invoice__r.Oracle_Invoice_Id__c) <> null){ amountVal +=  mapInvoiceWithAmount.get(InvLI.Invoice_Line_Item__r.Invoice__r.Oracle_Invoice_Id__c); }
                	
                 
                amountVal += (InvLI.Amount__c);//+InvLI.Tax_Amount__c);
                
                mapInvoiceWithAmount.put(InvLI.Invoice_Line_Item__r.Invoice__r.Oracle_Invoice_Id__c,amountVal);
                if(String.isBlank(InvLI.Tax__c) ){
                    //InvLI.Tax__c =  (InvLI.Invoice_Line_Item__r.Tax__c != null ) ? InvLI.Invoice_Line_Item__r.Tax__c : '0%';
                    InvLI.Tax__c = '0%';
                }
                String descr = InvLI.Item_Description__c != null ? InvLI.Item_Description__c : InvLI.Line_Description__c;
                LINE_REC_TYPE_CLASS objLineItem = new LINE_REC_TYPE_CLASS(InvLI.Item_Reference__c,InvLI.Id,amount,InvLI.Tax__c,descr,InvLI.Line_Description__c,
                                                        InvLI.Service_Type__c,InvLI.Department__c,InvLI.Course_Type__c,'Default',InvLI.Schools__c,'Default', InvLI.Revenue_Type__c);
                
                lstInvoiceLines.add(objLineItem);
                //lstInvoiceLines.add(new LINE_REC_TYPE_CLASS(InvLI.Item_Reference__c,InvLI.Id,amount,taxAmount,'FSRA Credit Memo'));
                system.debug('isFromCreditMemoUpdate is : '+isFromCreditMemoUpdate);
                system.debug('InvLI is : '+InvLI);
                system.debug('InvLI is : '+InvLI.Invoice__r.Oracle_Invoice_Id__c);
                if(isFromCreditMemoUpdate){mapInvAmounts.put(InvLI.Invoice__r.Oracle_Invoice_Id__c, InvLI.Amount__c);}

            }   
        }
        system.debug('mapInvAmounts is '+mapInvAmounts);
        String appliedINV = '', appliedInvAmt = '';
        Integer counter=0;

        if(!isFromCreditMemoUpdate){
            for(String objId : mapInvoiceWithAmount.keyset()) {
                if(counter !=0){ appliedINV = appliedINV + ','; appliedInvAmt = appliedInvAmt + ',';
                }
                appliedINV = appliedINV + objId;
                appliedInvAmt = appliedInvAmt + String.valueOf(-mapInvoiceWithAmount.get(objId));
                counter++;
            }
        }else{
            for(string InvNo : mapInvAmounts.keySet()){ appliedINV += (appliedINV != '' ? ','+InvNo : InvNo); appliedInvAmt += (appliedInvAmt != '' ? ','+mapInvAmounts.get(InvNo) : mapInvAmounts.get(InvNo)+'');
            }
        }

        system.debug('appliedINV is '+appliedINV);
        system.debug('appliedInvAmt is '+appliedInvAmt);

        String DateVal = '';
        if(appliedINV == null || appliedINV == 'null')
            appliedINV = '';
        //DateVal = Date.Today().DAY()+'-'+Date.Today().Month()+'-'+Date.Today().Year();
        
        if(objInv.GL_Date__c != null){DateVal = objInv.GL_Date__c.DAY()+'-'+objInv.GL_Date__c.Month()+'-'+objInv.GL_Date__c.Year();
        } else if(objInv.Invoice_Date__c != null){DateVal = objInv.Invoice_Date__c.DAY()+'-'+objInv.Invoice_Date__c.Month()+'-'+objInv.Invoice_Date__c.Year();
        } else {DateVal = Date.Today().DAY()+'-'+Date.Today().Month()+'-'+Date.Today().Year();
        } 
        
        String invoiceNo = '';
        InputParameters_Class invObj = new InputParameters_Class(objInv.Source_Invoice_Id__c, objInv.Id, objInv.Entity__r.Oracle_Party_Id__c,objInv.Source_System__c,
                                                                     objInv.Oracle_Invoice_Type__c, DateVal, objInv.Entity__r.Oracle_Site_Id__c,
                                                                     objInv.Payment_Currency__c, appliedINV, appliedInvAmt); //objInv.Status__c
        
        if(isFromCreditMemoUpdate){ invObj.P_CM_INV_NO = objInv.Oracle_Invoice_Id__c;invObj.P_REC_TYPE_UPDATE = 'Yes';
        }
                                                                     
        P_LINE_TBL_CLASS lineTblClass = new P_LINE_TBL_CLASS();
        lineTblClass.LINE_REC_TYPE.addAll(lstInvoiceLines);
        invObj.P_LINE_TBL = lineTblClass;
        CreateCreditMemo_Class obj = new CreateCreditMemo_Class();
        obj.InputParameters = invObj;
        CreateCreditMemo_Wrapper wrapperObj = new CreateCreditMemo_Wrapper();
        wrapperObj.CreateCMInvoice = obj;
        String s = JSON.serialize(wrapperObj);
        reqPara objClass = new reqPara();
        objClass.P_IN_CreditMemoDetail = s;
        //invObj = constructFinalWrapper(invObj,lineItemList);
        system.debug(objClass);
        return JSON.serialize(objClass);
    }

    /*public static string pushCreditMemoUpdateToOracle(list<String> lstLineIds){
        try{
            map<Id, Invoice_Line_Item__c> mapInvoiceItems = new map<Id, Invoice_Line_Item__c>();
            for(Invoice__c inv : [SELECT Id,Name,Entity__r.Oracle_Site_Id__c,Description__c,Invoice_Type__c,Invoice_Date__c,Entity__r.Oracle_Party_Id__c,Converted_Invoice_Balance__c,Oracle_Invoice_Type__c, Oracle_Invoice_Id__c,Oracle_GL_Date__c,Is_Refundable__c,Total_Invoice_Amount__c,Source_Invoice_Id__c,Payment_Currency__c, Credit_Memo_Type__c,Source_System__c,GL_Date__c,(SELECT Id,Name,Item_Reference__c,Amount__c, Invoice__c, Invoice_Line_Item__r.Invoice__r.Oracle_Invoice_Id__c, Invoice__r.Oracle_Invoice_Id__c,Department__c,Service_Type__c,Course_Type__c,Schools__c,Quantity__c,Revenue_Type__c ,Line_Description__c,Tax_Amount__c,Item_Description__c,Tax__c,Invoice_Line_Item__r.Tax__c FROM Invoice_Line_Items1__r WHERE Id IN : lstLineIds) FROM Invoice__c WHERE Id IN (select Related_Credit_Memo__c from Invoice_Line_Item__c where Id IN :lstLineIds )]){
                isFromCreditMemoUpdate = true; String jsonBody = ConstructInvoicePayload(inv);system.debug('Request Body--->'+jsonBody);
				// get endpoint details
				List<ERP_Endpoint_Details__mdt> listERPEndpointDetails = new List<ERP_Endpoint_Details__mdt>(); listERPEndpointDetails = [SELECT ID,Endpoint_URL__c, Password__c, Username__c,HTTP_Method__c  FROM ERP_Endpoint_Details__mdt WHERE Is_Active__c = true AND DeveloperName =: 'Credit_Memo_Update' LIMIT 1];                                                                    
				 if(listERPEndpointDetails <> null && listERPEndpointDetails.size() > 0 ) {  HTTPResponse response = HTTPRestUtil.callWebservice(listERPEndpointDetails[0].Endpoint_URL__c,listERPEndpointDetails[0].HTTP_Method__c,jsonBody);              
					system.debug('Response Body---->'+response.getBody());    
                    //save Payload on fail for reference purpose
                    ApexCodeUtility.savePayload(listERPEndpointDetails[0].Endpoint_URL__c,jsonBody,inv.Id,response.getBody()); OutputParameters respObj = (OutputParameters)JSON.deserialize(response.getBody() , OutputParameters.class);
					system.debug(respObj); List<Invoice__c> listInvoice = new List<Invoice__c>();                                                                      
					if(respObj.P_OP_RETURN_STS == 'S' && string.isNotBlank(respObj.P_OP_CM_NUM) ){ inv.CM_Applied_Amount__c = respObj.P_OP_AMT_APPLIED; inv.Converted_CM_Applied_Amount__c = respObj.P_CONV_AMT_APPLIED; inv.CM_Applied_Invoice_No__c = respObj.P_OP_APPL_INV_NO;
						
						if(respObj.P_AMT_INV_BAL != null && respObj.P_AMT_INV_BAL != '') {
							List<String> listOracleInvoicIds = new List<String>();List<String> balAmnts = new List<String>();List<String> conBalAmnts = new List<String>();
                            if(respObj.P_OP_APPL_INV_NO <> null && respObj.P_OP_APPL_INV_NO <> ''){listOracleInvoicIds = respObj.P_OP_APPL_INV_NO.split(',');}
                            if(respObj.P_AMT_INV_BAL <> null && respObj.P_AMT_INV_BAL <> ''){balAmnts = respObj.P_AMT_INV_BAL.split(',');}
                            if(respObj.P_CONV_AMT_INV_BAL <> null && respObj.P_CONV_AMT_INV_BAL <> ''){conBalAmnts = respObj.P_CONV_AMT_INV_BAL.split(',');}
							listInvoice = [SELECT Id, Invoice_Balance__c, Oracle_Invoice_Id__c, Converted_Invoice_Balance__c FROM Invoice__c WHERE Oracle_Invoice_Id__c IN: listOracleInvoicIds];

							for(Integer i =0; i < listOracleInvoicIds.size(); i++){
								for(Invoice__c obj : listInvoice){
									if(listOracleInvoicIds[i] == obj.Oracle_Invoice_Id__c){ obj.Invoice_Balance__c = (balAmnts.size()-1) >= i ? Decimal.valueOf(balAmnts[i]) : 0; obj.Converted_Invoice_Balance__c = (conBalAmnts.size()-1) >= i ? Decimal.valueOf(conBalAmnts[i]) : 0;
									}
								}
                            }
                            
                            inv.Invoice_Balance__c = respObj.P_AMT_CM_INV_BAL != null && respObj.P_AMT_CM_INV_BAL != '' ? Decimal.valueof(respObj.P_AMT_CM_INV_BAL) : 0.0; inv.Converted_Invoice_Balance__c = respObj.P_CONV_AMT_CM_INV_BAL != null && respObj.P_CONV_AMT_CM_INV_BAL != '' ? Decimal.valueof(respObj.P_CONV_AMT_CM_INV_BAL) : 0.0;
                            listInvoice.add(inv);
                            for(string lineId : lstLineIds){mapInvoiceItems.put(lineId, new Invoice_Line_Item__c(Id=lineId, Status__c = 'Invoiced'));
                            }
						}
                    }                    
					if(!listInvoice.isEmpty()){update listInvoice;}
				}
            }
            if(!mapInvoiceItems.isEmpty()){update mapInvoiceItems.values();
            }
        }catch(Exception ex){system.debug('---->'+ex.getMessage()); return ex.getMessage();
        }
        return 'SUCCESS';
    }*/
    
    
    /*public class reqPara {
        public String P_IN_CreditMemoDetail;
    }

    public class CreateCreditMemo_Wrapper{
        public CreateCreditMemo_Class CreateCMInvoice;
    }
    
    public Class CreateCreditMemo_Class{
    	public InputParameters_Class InputParameters;    
    }
    
    public class InputParameters_Class{
        public string P_INV_SR_REF;
        public string P_SFID;
        public string P_ORA_CUST_ID;
        public string P_INV_BATCH_SOURCE;
        public string P_INV_TYPE;
        public string P_INV_DATE;
        public string P_ORG_ID;
        public string P_CURRENCY;
        public string P_APPL_INVOICE_NO;
        public string P_APPL_AMOUNT;
        public string P_CM_INV_NO;
        public string P_REC_TYPE_UPDATE;
        
        public P_LINE_TBL_CLASS P_LINE_TBL;

        public InputParameters_Class(String INV_SR_REF, String SFID, String ORA_CUST_ID,String sourceSys, String INV_TYPE, String INV_DATE, String ORG_ID, String INVCURRENCY, String APPL_INVOICE_NO, String APPL_AMOUNT){
            P_INV_SR_REF = INV_SR_REF;
            P_SFID = SFID;
            P_ORA_CUST_ID = ORA_CUST_ID;
            P_INV_BATCH_SOURCE = sourceSys;
            P_INV_TYPE = INV_TYPE;
            P_INV_DATE = INV_DATE;
            P_ORG_ID = ORG_ID;
            P_CURRENCY = INVCURRENCY;
            P_APPL_INVOICE_NO = APPL_INVOICE_NO;
            P_APPL_AMOUNT = APPL_AMOUNT;
            P_CM_INV_NO = '';
            P_REC_TYPE_UPDATE = 'No';
        }
    }
    
    public class P_LINE_TBL_CLASS{
        public List<LINE_REC_TYPE_CLASS> LINE_REC_TYPE;
        public P_LINE_TBL_CLASS(){
            LINE_REC_TYPE = new List<LINE_REC_TYPE_CLASS>();
        }
    }
    
    public class LINE_REC_TYPE_CLASS{
        
        public string X9_ITEM_REF;
        public string X8_ITEM_SFID;
        public string X7_AMOUNT;
        public string X6_TAX_CODE;
        public string X5_ITEM_DESC;
        public string X4_LINE_DESCRIPTION;
        public string Y1_ACCOUNTS;
        public string Y2_COST_CENTRE;
        public string Y3_PROJECT;
        public string Y4_INTERCOMPANY;
        public string Y5_PROGRAM;
        public string Y6_FUTURE2;
        public string Y7_REVENUE_TYPE;
        
        public LINE_REC_TYPE_CLASS( String ITEM_REF, String ITEM_SFID, String AMOUNT, String TAX_CODE, String ITEM_DESC, String LINE_DESC, String revenueType, String BRCSegment, String courses, String intCompany, String schools, String future2, String revType){
           
            X9_ITEM_REF = ITEM_REF;
            X8_ITEM_SFID = ITEM_SFID;
            X7_AMOUNT = AMOUNT;
            X6_TAX_CODE = TAX_CODE;
            X5_ITEM_DESC = ITEM_DESC;//'Registration-Entities';//ITEM_DESC;
            X4_LINE_DESCRIPTION = LINE_DESC;
            Y1_ACCOUNTS = revenueType;
            Y2_COST_CENTRE = BRCSegment;
            Y3_PROJECT = courses;
            Y4_INTERCOMPANY = intCompany;
            Y5_PROGRAM = schools;
            Y6_FUTURE2 = future2;
            Y7_REVENUE_TYPE = revType;
        }
    }
    
    public class OutputParameters{
        public string P_OP_RETURN_MSG;
        public string P_OP_RETURN_STS;
        public string P_OP_AMT_UNAPPLIED;
        public string P_OP_AMT_APPLIED;
        public string P_OP_APPL_INV_NO;
        public string P_OP_GL_DATE;
        public string P_OP_TAX_AMOUNT;
        public string P_OP_INV_AMOUNT;
        public string P_OP_ORG_ID;
        public string P_OP_CUST_ID;
        public string P_OP_CM_NUM;
        public string P_OP_SFID;             
        public string P_AMT_INV_BAL;
        
        public string P_AMT_CM_INV_BAL;
        public string P_CONV_AMT_APPLIED;
        public string P_CONV_AMT_CM_INV_BAL;
        public string P_CONV_AMT_INV_BAL;
        public string P_CONV_INV_AMOUNT;

        
        public List<LINE_DETAILS> P_OP_LINE_TBL;
    }

    public class LINE_DETAILS {
		public String X9_ITEM_REF;
		public String X6_TAX_CODE;
		public String X5_ITEM_DESC;
		public String X12_LINE_NO;
		public String X8_ITEM_SFID;
		public String X7_AMOUNT;
	}

    public class LineDetails{
        public list<LineDetailsWrapper> P_LINE_TBL;
        public LineDetails(){P_LINE_TBL = new list<LineDetailsWrapper>();}
    }

    public class LineDetailsWrapper{
        public String X9_ITEM_REF;
		public String X6_TAX_CODE;
		public String X5_ITEM_DESC;
		public String X12_LINE_NO;
		public String X8_ITEM_SFID;
		public String X7_AMOUNT;
        
    }*/
}
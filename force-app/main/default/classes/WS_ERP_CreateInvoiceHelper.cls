/*
    Author      : Durga Prasad
    Date        : 14-April-2017
    Description : Helper Class for the Invoice Payload Contruction
    --------------------------------------------------------------------------------------
*/
public class WS_ERP_CreateInvoiceHelper{
    public static void InvokeProcess(string ServiceRequestId){
        HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c(Id=ServiceRequestId);
        list<HexaBPM__SR_Price_Item__c> lstSRPS = new list<HexaBPM__SR_Price_Item__c>();
        for(HexaBPM__Service_Request__c SR:[Select Id,Name,HexaBPM__SR_Template__c,HexaBPM__SR_Template__r.Invoice_Transaction_Type__c,HexaBPM__Customer__c,HexaBPM__Customer__r.Oracle_Party_Id__c,RecordType.Name,
        (Select Id,Name,Credit_Amount__c,HexaBPM__Status__c,HexaBPM__Price__c,Tax_Amount__c,HexaBPM__Pricing_Line__c,HexaBPM__Product__c,HexaBPM__Product__r.Name,HexaBPM__Pricing_Line__r.Name,Is_Refund_Line__c,Oracle_Response__c,Cost__c,Markup_Amount__c,Cancellation_Fee__c from HexaBPM__SR_Price_Items1__r where HexaBPM__Status__c!='Invoiced' and HexaBPM__Status__c!='Cancelled') from HexaBPM__Service_Request__c where Id=:ServiceRequestId and HexaBPM__Customer__r.Is_ADGM_Company__c = false]){
            objSR = SR;
            if(SR.HexaBPM__SR_Price_Items1__r!=null){
                for(HexaBPM__SR_Price_Item__c line:SR.HexaBPM__SR_Price_Items1__r){
                    lstSRPS.add(line);
                }
            }
        }
        if(lstSRPS.size()>0){
            try{
                string RequestString = ConstructInvoicePayload(objSR);
                system.debug('RequestString===>'+RequestString);
                
                WS_ERP_CreateInvoice.CreateInvoice_ERP_Service objReqServ = new WS_ERP_CreateInvoice.CreateInvoice_ERP_Service();
                WS_ERP_CreateInvoice.CreateInvoice_ERPResponse_element objResp = new WS_ERP_CreateInvoice.CreateInvoice_ERPResponse_element();
                WS_ERP_CreateInvoice.CreateInvoice_ERPHeader_element objHeaderElement = new WS_ERP_CreateInvoice.CreateInvoice_ERPHeader_element();
                objReqServ.header = objHeaderElement;
                objReqServ.timeout_x = 120000;//30 seconds..
                objResp = objReqServ.CreateInvoice_ERP(RequestString);
                system.debug('SRId==>'+objResp.P_OP_SR_Id);
                system.debug('InvoiceId==>'+objResp.P_OP_Invoice_Id);
                system.debug('CNote Id==>'+objResp.P_OP_CNote_Id);
                system.debug('Status==>'+objResp.P_OP_RETURN_STS);
                system.debug('Message==>'+objResp.P_OP_RETURN_MSG);
                HexaBPM__Service_Request__c ServiceRequest = [select id, Service_Request_Name__c, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c from HexaBPM__service_request__c where Id=:ServiceRequestId];
                if(objResp.P_OP_RETURN_STS=='S' && (objResp.P_OP_Invoice_Id!=null || objResp.P_OP_CNote_Id!=null)){
                    if(objResp.P_OP_Invoice_Id!=null)
                        ServiceRequest.Oracle_Invoice_Number__c = objResp.P_OP_Invoice_Id;
                    if(objResp.P_OP_CNote_Id!=null)
                        ServiceRequest.Oracle_Credit_Number__c = objResp.P_OP_CNote_Id;
                    for(HexaBPM__SR_Price_Item__c SRP:lstSRPS){
                        SRP.HexaBPM__Status__c = 'Invoiced';
                        SRP.Oracle_Response__c = objResp.P_OP_RETURN_STS;
                    }
                }else if(objResp.P_OP_RETURN_STS!='S' && objResp.P_OP_RETURN_MSG!=null){
                    for(HexaBPM__SR_Price_Item__c SRP:lstSRPS){
                        SRP.Oracle_Response__c = objResp.P_OP_RETURN_MSG;
                    }
                }
                // Issue Fix- status change to submitted after service request is closed- shagufta 05/04/2021
                if(ServiceRequest.Service_Request_Name__c=='Sales and Promotion Permit'){
                    List<HexaBPM__Step__c> lstStep = [SELECT id, HexaBPM__SR_Step__c,HexaBPM__Status__c FROM HexaBPM__Step__c WHERE HexaBPM__SR__c=:ServiceRequest.Id AND HexaBPM__Summary__c='Generate Permit & Invoice' limit 1];
                    if(lstStep.size()>0){
                        system.debug('in step');
                        for(HexaBPM__Step_Transition__c stptran :[select HexaBPM__SR_Status_Internal__c, HexaBPM__SR_Status_External__c, HexaBPM__Transition__r.HexaBPM__To__c, HexaBPM__Transition__r.HexaBPM__From__c from HexaBPM__Step_Transition__c where HexaBPM__Transition__c!=null and HexaBPM__SR_Step__c=:lstStep[0].HexaBPM__SR_Step__c and HexaBPM__Transition__r.HexaBPM__To__r.HexaBPM__Type__c = 'End' AND HexaBPM__Transition__r.HexaBPM__To__r.HexaBPM__Rejection__c = false limit 1]){
                            system.debug('in steptrans');
                            if(stptran.HexaBPM__SR_Status_Internal__c!=null)
                                ServiceRequest.HexaBPM__Internal_SR_Status__c = stptran.HexaBPM__SR_Status_Internal__c;
                            if(stptran.HexaBPM__SR_Status_External__c!=null)
                                ServiceRequest.HexaBPM__External_SR_Status__c = stptran.HexaBPM__SR_Status_External__c;
                            break;
                        }
                    }
                }
                update ServiceRequest;
                update lstSRPS;
                
            }catch(Exception e){
                system.debug('Exception==>'+e.getMessage());
            }
        }
    }
    public static string ConstructInvoicePayload(HexaBPM__Service_Request__c objSR){
        /*
        string strJsonRequestString = '{"CreateInvoice" : {"InputParameters" : {';
        strJsonRequestString += '"P_SFID" : "a0s26000001PjFU","P_ORACLE_ID" : "278059","P_INV_TYPE" : "INV_TYPE","P_INV_SR_REF" : "SR-01435","P_INV_DESC" : "New Employment Visa Service Fee","P_LINE_TBL":{"LINE_REC_TYPE" : [';
        */
        string strJsonRequestString;
        Date TodaysDate = system.today();
        string InvoiceDate = TodaysDate.DAY()+'-'+TodaysDate.Month()+'-'+TodaysDate.Year();//'07-02-2018';//
        system.debug('InvoiceDate==>'+InvoiceDate);
        HexaBPM__Service_Request__c SR = new HexaBPM__Service_Request__c();
        list<HexaBPM__Service_Request__c> lstSR = new list<HexaBPM__Service_Request__c>();
        
        list<InvoiceLineWrapper> lstInvoiceLines = new list<InvoiceLineWrapper>();
        list<InvoiceLineWrapper> lstTaxableInvoiceLines = new list<InvoiceLineWrapper>();
        list<InvoiceLineWrapper> lstNonTaxableInvoiceLines = new list<InvoiceLineWrapper>();
        list<InvoiceLineWrapper> lstRefundTaxableLines = new list<InvoiceLineWrapper>();
        list<InvoiceLineWrapper> lstRefundNonTaxableLines = new list<InvoiceLineWrapper>();
        if(objSR!=null)
            lstSR.add(objSR);
        
        for(HexaBPM__Service_Request__c objServiceRequest:lstSR){
            if(objServiceRequest.HexaBPM__SR_Price_Items1__r!=null){
              system.debug('LineItemsSize==>'+objServiceRequest.HexaBPM__SR_Price_Items1__r.size());
                for(HexaBPM__SR_Price_Item__c line:objServiceRequest.HexaBPM__SR_Price_Items1__r){
                    if(line.Is_Refund_Line__c){
                        InvoiceLineWrapper objRefundLine = new InvoiceLineWrapper();
                        objRefundLine.Id = line.Id;
                        objRefundLine.Name = line.Name;
                        objRefundLine.Amount = line.Markup_Amount__c;
                        objRefundLine.TaxAmount = line.Tax_Amount__c;
                        if(objRefundLine.TaxAmount==null)
                            objRefundLine.TaxAmount = 0;
                        if(line.HexaBPM__Pricing_Line__c!=null)
                            objRefundLine.Description = line.HexaBPM__Pricing_Line__r.Name;
                        else if(line.HexaBPM__Product__c!=null)
                            objRefundLine.Description = line.HexaBPM__Product__r.Name;
                        objRefundLine.isRefundLine = true;
                        objRefundLine.X4_CM_TYPE = objServiceRequest.HexaBPM__SR_Template__r.Invoice_Transaction_Type__c;
                        objRefundLine.X3_ATTRIB_1 = line.Id;
                        objRefundLine.X2_ATTRIB_2 = line.Id;
                        objRefundLine.X1_ATTRIB_3 = line.Id;
                        if(objRefundLine.Amount!=null)
                            lstRefundTaxableLines.add(objRefundLine);
                        decimal NonTaxableAmount;
                        if(line.Cost__c!=null)
                            NonTaxableAmount = line.Cost__c;
                        if(line.Cancellation_Fee__c!=null)
                            NonTaxableAmount = NonTaxableAmount + line.Cancellation_Fee__c;
                        /*
                        if(line.Cancellation_Fee__c!=null){
                            if(NonTaxableAmount!=null)
                                NonTaxableAmount = NonTaxableAmount + line.Cancellation_Fee__c;
                            else
                                NonTaxableAmount = line.Cancellation_Fee__c;
                        }
                        */
                        if(NonTaxableAmount!=null && NonTaxableAmount!=0){
                            objRefundLine = new InvoiceLineWrapper();
                            objRefundLine.Id = line.Id;
                            objRefundLine.Name = line.Name;
                            objRefundLine.Amount = NonTaxableAmount;
                            objRefundLine.TaxAmount = 0;
                            objRefundLine.Description = line.HexaBPM__Pricing_Line__r.Name;
                            objRefundLine.isRefundLine = true;
                            objRefundLine.X4_CM_TYPE = objServiceRequest.HexaBPM__SR_Template__r.Invoice_Transaction_Type__c;
                            objRefundLine.X3_ATTRIB_1 = line.Id;
                            objRefundLine.X2_ATTRIB_2 = line.Id;
                            objRefundLine.X1_ATTRIB_3 = line.Id;
                            lstRefundNonTaxableLines.add(objRefundLine);
                        }
                    }else{
                        InvoiceLineWrapper objInvoiceLine = new InvoiceLineWrapper();
                        objInvoiceLine.Id = line.Id;
                        objInvoiceLine.Name = line.Name;
                        objInvoiceLine.Amount = line.Markup_Amount__c;
                        if(line.Markup_Amount__c==null && line.Cost__c==null && line.HexaBPM__Price__c!=null)
                            objInvoiceLine.Amount = line.HexaBPM__Price__c;
                        objInvoiceLine.TaxAmount = line.Tax_Amount__c;
                        if(objInvoiceLine.TaxAmount==null)
                            objInvoiceLine.TaxAmount = 0;
                        objInvoiceLine.Description = line.HexaBPM__Pricing_Line__r.Name;
                        objInvoiceLine.X4_CM_TYPE = objServiceRequest.HexaBPM__SR_Template__r.Invoice_Transaction_Type__c;
                        objInvoiceLine.X3_ATTRIB_1 = line.Id;
                        objInvoiceLine.X2_ATTRIB_2 = line.Id;
                        objInvoiceLine.X1_ATTRIB_3 = line.Id;
                        if(objInvoiceLine.Amount!=null && objInvoiceLine.Amount>0)
                            lstTaxableInvoiceLines.add(objInvoiceLine);
                        if(line.Cost__c!=null && line.Cost__c>0){
                            objInvoiceLine = new InvoiceLineWrapper();
                            objInvoiceLine.Id = line.Id;
                            objInvoiceLine.Name = line.Name;
                            objInvoiceLine.Amount = line.Cost__c;
                            objInvoiceLine.TaxAmount = 0;
                            objInvoiceLine.Description = line.HexaBPM__Pricing_Line__r.Name;
                            objInvoiceLine.X4_CM_TYPE = objServiceRequest.HexaBPM__SR_Template__r.Invoice_Transaction_Type__c;
                            objInvoiceLine.X3_ATTRIB_1 = line.Id;
                            objInvoiceLine.X2_ATTRIB_2 = line.Id;
                            objInvoiceLine.X1_ATTRIB_3 = line.Id;
                            lstNonTaxableInvoiceLines.add(objInvoiceLine);
                        }
                    }
                }
            }
            SR = objServiceRequest;
            strJsonRequestString = '{"CreateInvoice" : {"InputParameters" : {';
            strJsonRequestString += '"P_SFID" : "'+SR.Id+'","P_ORA_CUST_ID" : "'+SR.HexaBPM__Customer__r.Oracle_Party_Id__c+'","P_INV_DATE" : "'+InvoiceDate+'","P_ATTRIBUTE1" : "NULL","P_ATTRIBUTE2" : "NULL","P_ATTRIBUTE3" : "NULL","P_LINKED_INV" : "NULL","P_INV_TYPE" : "'+objServiceRequest.HexaBPM__SR_Template__r.Invoice_Transaction_Type__c+'","P_INV_SR_REF" : "'+SR.Name+'","P_INV_DESC" : "'+SR.RecordType.Name+'","P_LINE_TBL":{"LINE_REC_TYPE" : [';
        }
        system.debug('lstRefundTaxableLines==>'+lstRefundTaxableLines.size()+' == '+lstRefundTaxableLines);
        system.debug('lstTaxableInvoiceLines==>'+lstTaxableInvoiceLines.size()+' == '+lstTaxableInvoiceLines);
        system.debug('lstRefundNonTaxableLines==>'+lstRefundNonTaxableLines.size()+' == '+lstRefundNonTaxableLines);
        system.debug('lstNonTaxableInvoiceLines==>'+lstNonTaxableInvoiceLines.size()+' == '+lstNonTaxableInvoiceLines);
        
        if(lstRefundTaxableLines.size()>0 && lstTaxableInvoiceLines.size()>0){
            for(InvoiceLineWrapper RefundInvoice:lstRefundTaxableLines){
                for(InvoiceLineWrapper MainInvoice:lstTaxableInvoiceLines){
                    if((RefundInvoice.Amount*-1) <= MainInvoice.Amount && (RefundInvoice.TaxAmount*-1) <= MainInvoice.TaxAmount){
                        MainInvoice.Amount = MainInvoice.Amount + RefundInvoice.Amount;
                        MainInvoice.TaxAmount = MainInvoice.TaxAmount + RefundInvoice.TaxAmount;
                        break;
                    }
                }
            }
        }
        if(lstRefundNonTaxableLines.size()>0 && lstNonTaxableInvoiceLines.size()>0){
            for(InvoiceLineWrapper RefundInvoice:lstRefundNonTaxableLines){
                for(InvoiceLineWrapper MainInvoice:lstNonTaxableInvoiceLines){
                    if((RefundInvoice.Amount * -1) <= MainInvoice.Amount && (RefundInvoice.TaxAmount * -1) <= MainInvoice.TaxAmount){
                        MainInvoice.Amount = MainInvoice.Amount + RefundInvoice.Amount;
                        MainInvoice.TaxAmount = MainInvoice.TaxAmount + RefundInvoice.TaxAmount;
                        break;
                    }
                }
            }
        }
        
        if(lstTaxableInvoiceLines.size()>0)
            lstInvoiceLines.addAll(lstTaxableInvoiceLines);
        if(lstNonTaxableInvoiceLines.size()>0)
            lstInvoiceLines.addAll(lstNonTaxableInvoiceLines);
        integer i = 0;
        if(lstInvoiceLines.size()>0){
            for(InvoiceLineWrapper line:lstInvoiceLines){
                Decimal dAmount = line.Amount;
                decimal TaxAmount = 0;
                if(line.TaxAmount!=null && line.TaxAmount>0)
                    TaxAmount = line.TaxAmount;
                if(i==0)
                    strJsonRequestString += '{"X9_ITEM_REF":"'+line.Name+'","X8_ITEM_SFID":"'+line.Id+'","X7_AMOUNT":"'+dAmount+'","X6_TAX_AMOUNT":"'+TaxAmount+'","X5_ITEM_DESC":"'+line.Description+'","X4_CM_TYPE":"'+line.X4_CM_TYPE+'","X3_ATTRIB_1":"'+line.X3_ATTRIB_1+'","X2_ATTRIB_2":"'+line.X2_ATTRIB_2+'","X1_ATTRIB_3":"'+line.X1_ATTRIB_3+'"}';
                else
                    strJsonRequestString += ',{"X9_ITEM_REF":"'+line.Name+'","X8_ITEM_SFID":"'+line.Id+'","X7_AMOUNT":"'+dAmount+'","X6_TAX_AMOUNT":"'+TaxAmount+'","X5_ITEM_DESC":"'+line.Description+'","X4_CM_TYPE":"'+line.X4_CM_TYPE+'","X3_ATTRIB_1":"'+line.X3_ATTRIB_1+'","X2_ATTRIB_2":"'+line.X2_ATTRIB_2+'","X1_ATTRIB_3":"'+line.X1_ATTRIB_3+'"}';
                i++;
            }
        }
        strJsonRequestString += ']}}}}';
        system.debug('strJsonRequestString==>'+strJsonRequestString);
        return strJsonRequestString;
    }
    public class InvoiceLineWrapper{
        public string Id;
        public string Name;
        public decimal Amount;
        public boolean isRefundLine;
        public decimal TaxAmount;
        public string Description;
        public string X4_CM_TYPE;
        public string X3_ATTRIB_1;
        public string X2_ATTRIB_2;
        public string X1_ATTRIB_3;
        public InvoiceLineWrapper(){
            isRefundLine = false;
        }
    }
}
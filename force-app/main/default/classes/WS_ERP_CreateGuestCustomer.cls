//Generated by wsdl2apex

public class WS_ERP_CreateGuestCustomer {
    public class CreateGuestCustomer_ERPRequest_element {
        public String P_AccountId;
        public String P_AccountName;
        public String P_VAT_Reg_Number;
        private String[] P_AccountId_type_info = new String[]{'P_AccountId','http://services.informatica.com/rt/CreateGuestCustomer-ERP',null,'0','1','false'};
        private String[] P_AccountName_type_info = new String[]{'P_AccountName','http://services.informatica.com/rt/CreateGuestCustomer-ERP',null,'0','1','false'};
        private String[] P_VAT_Reg_Number_type_info = new String[]{'P_VAT_Reg_Number','http://services.informatica.com/rt/CreateGuestCustomer-ERP',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://services.informatica.com/rt/CreateGuestCustomer-ERP','false','false'};
        private String[] field_order_type_info = new String[]{'P_AccountId','P_AccountName','P_VAT_Reg_Number'};
    }
    public class GuestCustomerResponseType {
        public String XN_PARTY_ID;
        public String XC_STATUS;
        public String XC_SFID;
        public String XC_ERR_MSG;
        private String[] XN_PARTY_ID_type_info = new String[]{'XN_PARTY_ID','http://services.informatica.com/rt/CreateGuestCustomer-ERP',null,'0','1','false'};
        private String[] XC_STATUS_type_info = new String[]{'XC_STATUS','http://services.informatica.com/rt/CreateGuestCustomer-ERP',null,'0','1','false'};
        private String[] XC_SFID_type_info = new String[]{'XC_SFID','http://services.informatica.com/rt/CreateGuestCustomer-ERP',null,'0','1','false'};
        private String[] XC_ERR_MSG_type_info = new String[]{'XC_ERR_MSG','http://services.informatica.com/rt/CreateGuestCustomer-ERP',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://services.informatica.com/rt/CreateGuestCustomer-ERP','false','false'};
        private String[] field_order_type_info = new String[]{'XN_PARTY_ID','XC_STATUS','XC_SFID','XC_ERR_MSG'};
    }
    public class CreateGuestCustomer_ERPResponse_element {
        public String P_OP_AccountId;
        public String P_OP_PARTY_ID;
        public String P_OP_Status;
        public String P_OP_Message;
        private String[] P_OP_AccountId_type_info = new String[]{'P_OP_AccountId','http://services.informatica.com/rt/CreateGuestCustomer-ERP',null,'0','1','false'};
        private String[] P_OP_PARTY_ID_type_info = new String[]{'P_OP_PARTY_ID','http://services.informatica.com/rt/CreateGuestCustomer-ERP',null,'0','1','false'};
        private String[] P_OP_Status_type_info = new String[]{'P_OP_Status','http://services.informatica.com/rt/CreateGuestCustomer-ERP',null,'0','1','false'};
        private String[] P_OP_Message_type_info = new String[]{'P_OP_Message','http://services.informatica.com/rt/CreateGuestCustomer-ERP',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://services.informatica.com/rt/CreateGuestCustomer-ERP','false','false'};
        private String[] field_order_type_info = new String[]{'P_OP_AccountId','P_OP_PARTY_ID','P_OP_Status','P_OP_Message'};
    }
    public class CreateGuestCustomer_ERPHeader_element {
        public WS_ERP_CreateGuestCustomer.GuestCustomerResponseType ObjectId;
        private String[] ObjectId_type_info = new String[]{'ObjectId','http://services.informatica.com/rt/CreateGuestCustomer-ERP',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://services.informatica.com/rt/CreateGuestCustomer-ERP','false','false'};
        private String[] field_order_type_info = new String[]{'ObjectId'};
    }
    public class CreateGuestCustomer_ERP_Service {
        //public String endpoint_x = 'https://localhost:7443/process-engine/public/soap/CreateGuestCustomer-ERP';
        //public String endpoint_x = 'https://informaticaprod.adgm.com:443/process-engine/public/soap/CreateGuestCustomer-ERP';
        public string endpoint_x = label.ERPCreateGuestCustomerEndpointURL;
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        public WS_ERP_CreateGuestCustomer.CreateGuestCustomer_ERPHeader_element header;
        private String header_hns = 'CreateGuestCustomer-ERPHeader=http://services.informatica.com/rt/CreateGuestCustomer-ERP';
        private String[] ns_map_type_info = new String[]{'http://services.informatica.com/rt/CreateGuestCustomer-ERP', 'WS_ERP_CreateGuestCustomer'};
        public WS_ERP_CreateGuestCustomer.CreateGuestCustomer_ERPResponse_element CreateGuestCustomer_ERP(String P_AccountId,String P_AccountName,String P_VAT_Reg_Number) {
            WS_ERP_CreateGuestCustomer.CreateGuestCustomer_ERPRequest_element request_x = new WS_ERP_CreateGuestCustomer.CreateGuestCustomer_ERPRequest_element();
            request_x.P_AccountId = P_AccountId;
            request_x.P_AccountName = P_AccountName;
            request_x.P_VAT_Reg_Number = P_VAT_Reg_Number;
            WS_ERP_CreateGuestCustomer.CreateGuestCustomer_ERPResponse_element response_x;
            Map<String, WS_ERP_CreateGuestCustomer.CreateGuestCustomer_ERPResponse_element> response_map_x = new Map<String, WS_ERP_CreateGuestCustomer.CreateGuestCustomer_ERPResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'CreateGuestCustomer-ERP',
              'http://services.informatica.com/rt/CreateGuestCustomer-ERP',
              'CreateGuestCustomer-ERPRequest',
              'http://services.informatica.com/rt/CreateGuestCustomer-ERP',
              'CreateGuestCustomer-ERPResponse',
              'WS_ERP_CreateGuestCustomer.CreateGuestCustomer_ERPResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
}
/*
@Author : Azmath
@Description : This class is used to parse the response JSON.
@Version : v1.
*/
public without sharing class ICA_InitialApprovalRespParser 
{
    public class Errors 
    {
        //public String errorCode;
        //public string  errorDetail;
        public String errorMessage;
        //public string errorRefNumber;
    }

    public class Wallets {
        public String bankCode;
        //public String defaultAccount;
        public String accountCode;
        public String token;
        public Double balance;
    }

    /*public class Details {
        public Decimal amount;
        public String feeTypeCode;
        public Boolean optional;
        public Boolean isSelected;
        public String name;
        public string vatableAmount;
        public String vatOnCustomer;
        public Decimal vatAmount;
        public Boolean byDefaultSelected;
        public Boolean isRequired;
        public string feeGroupName;
        public String feeGroupCode;
        public Boolean exempted;
    }*/

    public UD_Output UD_Output;

    public class RequestFees_Z {
        //public Decimal totalCommissions;
        //public Double totalCommissionsVat;
        //public Decimal totalAmount;
        //public Double totalCommissionsWithVat;
        public string totalAmountWithCommissionsIncludingVat;
        public string totalWithVat;
        //public Decimal totalWithCommissions;
        //public Boolean containsVat;
        //public Boolean eligibleForSecondPayment;
        //public List<RequestFees> requestFees;
    }

    public class Data {
        public String requestNumber;
        //public string externalReferenceNumber;
        public List<RequiredAttachments> requiredAttachments;
        public RequestFees_Z requestFees;
        public List<Wallets> wallets;
    }

    /*public class RequestFees {
        public decimal feesAmount;
        public Double totalFeesWithVatAmount;
        public Double feesVat;
        public Decimal total;
        public Double totalWithVat;
        public Boolean containsVat;
        public string establishmentDepositErrorMessage;
        public Decimal refundableAmountForApproved;
        public Decimal refundableAmountForRejected;
        public String serviceName;
        public Boolean eligibleForSecondPayment;
        public Boolean isICARequestEligibleForExemption;
        public String draftNumber;
        public String adminRegion;
        public String parentDraftNumber;
        //public Boolean isSkipPayment;
        //public List<Details> details;
    }*/

    public class RequiredAttachments {
        public Decimal attachmentTypeId;
        public String attachmentTypeText;
        public Boolean isAttachmentTypeMandatory;
    }

    public class UD_Output {
        public Boolean isSuccess;
        public String responseDate;
        public List<Errors> errors;
        public Data data;
    }
}
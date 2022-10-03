public without sharing class ICA_PaymentRespJson 
{
    public List<PaymentRequestDetails> PaymentRequestDetails;
    public class PaymentRequestDetails {
        public String DraftNumber;
        public String TransactionRef;
        public String ServiceName;
        public String ReceiptNumber;
        public String paymentRef;
    }
}
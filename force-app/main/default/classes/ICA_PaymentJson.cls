/*
@Author : Azmath
@Description : This class is used to parse the response JSON.
@Version : v1.
*/
public without sharing class ICA_PaymentJson
{
    public ICA_PaymentJson(Double Amount)
    {
        this.totalUIAmount      = Amount;
        this.paymentType        = 'AmwalWallet';
        this.bankAccountToken   = '8769bfb5-7cc7-4f93-b903-2c5daf7ab8c9';
        this.bankCode           = 'CBD';
        this.BankAccountCode    = 'sd652tf4sd65f4 - الرصيد: 999390.9 درهم إماراتي';
    }
    public List<Drafts> drafts;
    public Double totalUIAmount;
    public String paymentType;
    public String bankAccountToken;
    public String bankCode;
    public String BankAccountCode;

    public class IncludeOptionallIds{
    }

    public class Drafts
    {
        public String draftNumber;
        public List<IncludeOptionallIds> includeOptionallIds;
        public Boolean eligibleForSecondPayment;
        public Drafts(string draftNo)
        {
            this.draftNumber = draftNo;
            this.eligibleForSecondPayment = false;
        }
    }
}
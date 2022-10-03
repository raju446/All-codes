/**
* Author: Azmath
* Desc  : Mock class for createupdate estb. service.
 */
@isTest
global class ICA_MockHttpRespCreateUpdateEstbService implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req)
    {
        string body='{"UD_Output":{"isSuccess":true,"responseDate":"2021-06-23T10:30:06Z","errors":[{}],"data":{"requestNumber":"0001035691072021300871132",';
        body+= '"externalReferenceNumber":null,"requiredAttachments":[{"attachmentTypeId":145.0,"attachmentTypeText":"COPY OF RESIDENCY","isAttachmentTypeMandatory":true},';
        body+= '{"attachmentTypeId":147.0,"attachmentTypeText":"COPY OF THE AUTHORIZATION FOR THE AUTHORIZED SIGNATORIES","isAttachmentTypeMandatory":true},';
        body+= '{"attachmentTypeId":153.0,"attachmentTypeText":"COPY OF THE AMIRI DECREE OR THE MINISTERIAL DECREES FOR ESTABLISHING THE ESTABLISHMENT","isAttachmentTypeMandatory":true},';
        body+= '{"attachmentTypeId":142.0,"attachmentTypeText":"A COPY OF THE MEMORANDUM OF ASSOCIATION FOR PARTNERS AND INVESTORS","isAttachmentTypeMandatory":false},';
        body+= '{"attachmentTypeId":143.0,"attachmentTypeText":"ORIGINAL COPY OF THE MEMORANDUM OF ASSOCIATION FOR PARTNERS AND INVESTORS","isAttachmentTypeMandatory":false},';
        body+= '{"attachmentTypeId":170.0,"attachmentTypeText":"A COPY OF THE INVESTOR OR PARTNER\'S PASSPORT","isAttachmentTypeMandatory":false},';
        body+= '{"attachmentTypeId":230.0,"attachmentTypeText":"EXCEPTIONAL ATTACHMENT NO 1","isAttachmentTypeMandatory":false},';
        body+= '{"attachmentTypeId":231.0,"attachmentTypeText":"EXCEPTIONAL ATTACHMENT NO 2","isAttachmentTypeMandatory":false},';
        body+= '{"attachmentTypeId":232.0,"attachmentTypeText":"EXCEPTIONAL ATTACHMENT NO 3","isAttachmentTypeMandatory":false},';
        body+= '{"attachmentTypeId":233.0,"attachmentTypeText":"EXCEPTIONAL ATTACHMENT NO 4","isAttachmentTypeMandatory":false},';
        body+= '{"attachmentTypeId":234.0,"attachmentTypeText":"EXCEPTIONAL ATTACHMENT NO 5","isAttachmentTypeMandatory":false},';
        body+= '{"attachmentTypeId":235.0,"attachmentTypeText":"COPY OF THE AUTHORIZATION FOR THE AUTHORIZED SIGNATORIES","isAttachmentTypeMandatory":false},';
        body+= '{"attachmentTypeId":236.0,"attachmentTypeText":"COPY OF THE AMIRI DECREE OR THE MINISTERIAL DECREES FOR ESTABLISHING THE ESTABLISHMENT","isAttachmentTypeMandatory":false},';
        body+= '{"attachmentTypeId":237.0,"attachmentTypeText":"A COPY OF THE MEMORANDUM OF ASSOCIATION FOR PARTNERS AND INVESTORS","isAttachmentTypeMandatory":false},';
        body+= '{"attachmentTypeId":238.0,"attachmentTypeText":"ORIGINAL COPY OF THE MEMORANDUM OF ASSOCIATION FOR PARTNERS AND INVESTORS","isAttachmentTypeMandatory":false},';
        body+= '{"attachmentTypeId":239.0,"attachmentTypeText":"ADDITIONAL ATTACHMENT NO 5","isAttachmentTypeMandatory":false},';
        body+= '{"attachmentTypeId":11.0,"attachmentTypeText":"ORIGINAL AUTHORIZATION FOR THE AUTHORIZED SIGNATORIES","isAttachmentTypeMandatory":false}],';
        body+= '"requestFees":{"totalCommissions":3.0,"totalCommissionsVat":0.15,"totalAmount":400.0,"totalCommissionsWithVat":3.15,"totalAmountWithCommissionsIncludingVat":404.55,';
        body+= '"totalWithVat":401.4,"totalWithCommissions":403.0,"containsVat":true,"eligibleForSecondPayment":false,';
        body+= '"requestFees":[{"feesAmount":3.0,"totalFeesWithVatAmount":3.15,"feesVat":0.15,"total":400.0,"totalWithVat":401.4,"containsVat":true,';
        body+= '"establishmentDepositErrorMessage":null,"refundableAmountForApproved":0.0,"refundableAmountForRejected":300.0,';
        body+= '"serviceName":"SPONSOR - ESTABLISHMENT CARD - PUBLIC SECTOR ESTABLISHMENT OR COMPANIES (3 YEARS) - ISSUE","eligibleForSecondPayment":false,';
        body+= '"isICARequestEligibleForExemption":false,"draftNumber":"0001035691072021300871132","adminRegion":"null","parentDraftNumber":"0001035691072021300871132","isSkipPayment":false,';
        body+= '"details":[{"amount":100.0,"feeTypeCode":"null","optional":true,"isSelected":false,"name":"URGENT SERVICE FEES","vatableAmount":null,';
        body+= '"vatOnCustomer":"false","vatAmount":0.0,"byDefaultSelected":false,"isRequired":false,"feeGroupName":null,"feeGroupCode":"null","exempted":false},';
        body+= '{"amount":50.0,"feeTypeCode":"null","optional":false,"isSelected":false,"name":"REQUEST FEES","vatableAmount":null,';
        body+= '"vatOnCustomer":"false","vatAmount":0.0,"byDefaultSelected":false,"isRequired":false,"feeGroupName":null,"feeGroupCode":"null","exempted":false},';
        body+= '{"amount":300.0,"feeTypeCode":"null","optional":false,"isSelected":false,"name":"ISSUE FEES","vatableAmount":null,';
        body+= '"vatOnCustomer":"false","vatAmount":0.0,"byDefaultSelected":false,"isRequired":false,"feeGroupName":null,"feeGroupCode":"null","exempted":false},';
        body+= '{"amount":28.0,"feeTypeCode":"null","optional":false,"isSelected":false,"name":"E-SERVICES FEES","vatableAmount":"28.0","vatOnCustomer":"true",';
        body+= '"vatAmount":1.4,"byDefaultSelected":false,"isRequired":false,"feeGroupName":null,"feeGroupCode":"null","exempted":false},';
        body+= '{"amount":22.0,"feeTypeCode":"null","optional":false,"isSelected":false,"name":"ICA FEES","vatableAmount":null,';
        body+= '"vatOnCustomer":"false","vatAmount":0.0,"byDefaultSelected":false,"isRequired":false,"feeGroupName":null,';
        body+= '"feeGroupCode":"null","exempted":false}]}]},"wallets":[{"bankCode":"CBD","defaultAccount":"true",';
        body+= '"accountCode":"sd652tf4sd65f4","token":"8769bfb5-7cc7-4f93-b903-2c5daf7ab8c9","balance":956658.75}]}}}';
        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type','application/json');
        resp.setBody(body);
        resp.setStatusCode(200);
        return resp;
    }
}
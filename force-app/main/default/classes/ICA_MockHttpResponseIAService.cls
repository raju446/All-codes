/**
* Author: Azmath
* Desc  : Mock class for Initial approval service.
 */
@isTest
global class ICA_MockHttpResponseIAService implements HttpCalloutMock
{
    global HttpResponse respond(HttpRequest req)
    {
    	string body = '{"UD_Output":{"isSuccess":true,"responseDate":"2021-06-27T12:38:01Z","errors":[{}],"data":{"requestNumber":"0001036911622021300871479","externalReferenceNumber":null,';
    	body+= '"requiredAttachments":[{"attachmentTypeId":230.0,"attachmentTypeText":"EXCEPTIONAL ATTACHMENT NO 1","isAttachmentTypeMandatory":false},';
    	body+= '{"attachmentTypeId":231.0,"attachmentTypeText":"EXCEPTIONAL ATTACHMENT NO 2","isAttachmentTypeMandatory":false},';
    	body+= '{"attachmentTypeId":232.0,"attachmentTypeText":"EXCEPTIONAL ATTACHMENT NO 3","isAttachmentTypeMandatory":false},';
    	body+= '{"attachmentTypeId":233.0,"attachmentTypeText":"EXCEPTIONAL ATTACHMENT NO 4","isAttachmentTypeMandatory":false},';
    	body+= '{"attachmentTypeId":234.0,"attachmentTypeText":"EXCEPTIONAL ATTACHMENT NO 5","isAttachmentTypeMandatory":false},';
    	body+= '{"attachmentTypeId":235.0,"attachmentTypeText":"ADDITIONAL ATTACHMENT NO 1","isAttachmentTypeMandatory":false},';
    	body+= '{"attachmentTypeId":236.0,"attachmentTypeText":"ADDITIONAL ATTACHMENT NO 2","isAttachmentTypeMandatory":false},';
    	body+= '{"attachmentTypeId":237.0,"attachmentTypeText":"ADDITIONAL ATTACHMENT NO 3","isAttachmentTypeMandatory":false},';
    	body+= '{"attachmentTypeId":238.0,"attachmentTypeText":"ADDITIONAL ATTACHMENT NO 4","isAttachmentTypeMandatory":false},';
    	body+= '{"attachmentTypeId":239.0,"attachmentTypeText":"ADDITIONAL ATTACHMENT NO 5","isAttachmentTypeMandatory":false}],';
    	body+= '"requestFees":{"totalCommissions":3.0,"totalCommissionsVat":0.15,"totalAmount":50.0,"totalCommissionsWithVat":3.15,';
    	body+= '"totalAmountWithCommissionsIncludingVat":54.55,"totalWithVat":51.4,"totalWithCommissions":53.0,"containsVat":true,';
    	body+= '"eligibleForSecondPayment":false,"requestFees":[{"feesAmount":3.0,"totalFeesWithVatAmount":3.15,"feesVat":0.15,';
    	body+= '"total":50.0,"totalWithVat":51.4,"containsVat":true,"establishmentDepositErrorMessage":null,';
    	body+= '"refundableAmountForApproved":0.0,"refundableAmountForRejected":0.0,';
    	body+= '"serviceName":"SPONSOR - INITIAL APPROVAL SERVICES - ALL ESTABLISHMENT LICENSE TYPES - REQUEST INITIAL APPROVAL","eligibleForSecondPayment":false,';
    	body+= '"isICARequestEligibleForExemption":false,';
    	body+= '"draftNumber":"0001036911622021300871479","adminRegion":"null","parentDraftNumber":"0001036911622021300871479","isSkipPayment":false,';
    	body+= '"details":[{"amount":100.0,"feeTypeCode":"null","optional":true,"isSelected":false,"name":"URGENT SERVICE FEES","vatableAmount":null,';
    	body+= '"vatOnCustomer":"false","vatAmount":0.0,"byDefaultSelected":false,"isRequired":false,"feeGroupName":null,"feeGroupCode":"null","exempted":false},';
    	body+= '{"amount":28.0,"feeTypeCode":"null","optional":false,"isSelected":false,"name":"E-SERVICES FEES",';
    	body+= '"vatableAmount":"28.0","vatOnCustomer":"true","vatAmount":1.4,"byDefaultSelected":false,"isRequired":false,"feeGroupName":null,';
    	body+= '"feeGroupCode":"null","exempted":false},{"amount":22.0,"feeTypeCode":"null","optional":false,"isSelected":false,"name":"ICA FEES","vatableAmount":null,';
    	body+= '"vatOnCustomer":"false","vatAmount":0.0,"byDefaultSelected":false,"isRequired":false,"feeGroupName":null,"feeGroupCode":"null","exempted":false}]}]}';
    	body+= ',"wallets":[{"bankCode":"CBD","defaultAccount":"true","accountCode":"sd652tf4sd65f4","token":"8769bfb5-7cc7-4f93-b903-2c5daf7ab8c9","balance":953504.15}]}}}';
        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type','application/json');
        resp.setBody(body);
        resp.setStatusCode(200);
        return resp;
    }
}
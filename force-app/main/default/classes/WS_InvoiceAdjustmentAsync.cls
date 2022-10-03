/*
    Author      : Prachi Sinha
    Date        : 10/8/2021
    Description : Queueable job to push the invoice adjustment to the corresponding source system after it is Invoiced
*/
public without sharing class WS_InvoiceAdjustmentAsync implements Queueable, Database.AllowsCallouts{

    private Id invLineItemId;

    public WS_InvoiceAdjustmentAsync(Id invoiceLineItemId)
    {
        this.invLineItemId = invoiceLineItemId;
    }
    
    public void execute(QueueableContext qc){
        InvoiceUtil.PushAdjToSourceSystem(invLineItemId);
    }

}
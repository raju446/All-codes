/*  Author      : Keerthan Tantry
    Date        : 25-Feb-2018
    Name        : AramexUpdateStepStatusScheduleCls
    Description : Schedule class that will be scheduled to run and close any step where the documents are delivered.

    ------------------------------------------------------------------------------------------------------
    * @Change History
    * Version   Author            Date            Description
       V1.1     Rajil Ravindran   19-Aug-2019     ISSUE-000615 : Changed the batch size to 1.
*/
global class AramexUpdateStepStatusScheduleCls implements Schedulable {
    global void execute(SchedulableContext sc) {
        AramexUpdateStepStatusBatchCls b = new AramexUpdateStepStatusBatchCls();
        b.shipmentStatus = label.ARAMEX_SHIPMENT_CREATION_STATUS;//'Record created.';
        database.executebatch(b,1); //V1.1
    }
}
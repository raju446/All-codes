/*  Author      : Keerthan Tantry
    Date        : 25-Feb-2018
    Name        : AramexUpdateStepStatusBatchCls
    Description : Batch class that will be scheduled to run and close any step where the documents are delivered.

    ------------------------------------------------------------------------------------------------------
    * @Change History
    * Version       Author            Date            Description
        V1.1        Rajil Ravindran   19-Aug-2019     ISSUE-000615 : If there is no invoice step created at the time of courrier step delivered status, 
                                                      update the SR Status to the courrier step transition step: Delivered.
*/


global class AramexUpdateStepStatusBatchCls implements Database.Batchable<sObject>,Database.AllowsCallouts {

    String query;
    //Label indictaing what status value to be used to close the step when Aramex returns the status
    public String statusStr = label.ARAMEX_SHIPMENT_STATUS_SUCCESS;
    public String shipmentStatus; //Filter to query steps with specific aramex status.
    global AramexUpdateStepStatusBatchCls() {
        shipmentStatus = label.ARAMEX_SHIPMENT_CREATION_STATUS;//label.ARAMEX_SHIPMENT_STATUS_SUCCESS
        
        query =  ' Select Id,Name,HexaBPM__Status__c,Aramex_Shipping_ID__c,Aramex_Error__c,HexaBPM__SR_Step__c,HexaBPM__SR__c from HexaBPM__Step__c ';
        // query += ' WHERE  Aramex_Shipment_Status__c =: shipmentStatus AND ';
        query += '  WHERE (NOT Aramex_Shipment_Status__c LIKE \'%Delivered%\') AND ';
        query += ' Aramex_Shipping_ID__c != NULL AND ';
        query += ' Aramex_Shipment_Status__c != NULL AND ';
        query += ' HexaBPM__Step_Template__r.HexaBPM__Code__c = \'COURIER\' ';

    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC, List<HexaBPM__Step__c> scope) {
        Map<String, HexaBPM__Step__c> shipmentStepMap = new Map<String, HexaBPM__Step__c>();
        List<String> shipmentsDelivered = new List<String>();
        List<HexaBPM__Step__c> stepsToUpdate  =  new List<HexaBPM__Step__c>();
        List<HexaBPM__Service_Request__c> srsToUpdate  =  new List<HexaBPM__Service_Request__c>();
        List<AramexTrackingServices.TrackingResult>  TrackingResults  = new List<AramexTrackingServices.TrackingResult>();
        
        //Declase a savepoint
        Savepoint sp;
        
        //V1.1:Find the list of service request having invoice generated step created.Address
        set<Id> setSRIDs = new set<Id>();

        //Get the transition associated with the shipment step
        HexaBPM__Step_Transition__c transitionObj = getTransition(scope);
        for (HexaBPM__Step__c  stpObj : scope) {
            shipmentStepMap.put(stpObj.Aramex_Shipping_ID__c, stpObj);
            setSRIDs.add(stpObj.HexaBPM__SR__c);
        }
        //V1.1: Finds the list which return the SR's having invoice step -status 'Generate Invoice.
        map<id,HexaBPM__Step__c> mapSRInvoiceStep = new map<id,HexaBPM__Step__c>();
        for(HexaBPM__Step__c invoiceStep : [select id,HexaBPM__SR__c,HexaBPM__SR_Step__c,HexaBPM__Step_Status__c,HexaBPM__Status__c from HexaBPM__Step__c where HexaBPM__SR__c IN :setSRIDs AND Step_Template_Code__c = 'Generate Invoice']){
            mapSRInvoiceStep.put(invoiceStep.HexaBPM__SR__c,invoiceStep);
        }
        try {

            if (!shipmentStepMap.isEmpty()) {
                List<String> shipmentIds = new List<String>(shipmentStepMap.keySet());
                HexaBPM__Step__c stpObj;
                TrackingResults = AramexWebserviceUtil.trackShipments(shipmentIds);
                if(transitionObj != null && transitionObj.id != null){
                    for (AramexTrackingServices.TrackingResult TrackingResult : TrackingResults ) {
                        stpObj = shipmentStepMap.get(TrackingResult.WaybillNumber);
                        stpObj.Aramex_Shipment_Status__c = TrackingResult.UpdateDescription;
                        System.debug('TrackingResult>>>'+TrackingResult);
                        if (TrackingResult.UpdateDescription.equals(statusStr)) {
                            stpObj.HexaBPM__Status__c  = transitionObj.HexaBPM__Transition__r.HexaBPM__To__c;
                            HexaBPM__Service_Request__c srObj = new HexaBPM__Service_Request__c(Id= stpObj.HexaBPM__SR__c);
                            if(mapSRInvoiceStep.get(stpObj.HexaBPM__SR__c) == null){//V1.1
                                srObj.HexaBPM__External_SR_Status__c = transitionObj.HexaBPM__SR_Status_External__c;
                                srObj.HexaBPM__Internal_SR_Status__c = transitionObj.HexaBPM__SR_Status_Internal__c;
                                srsToUpdate.add(srObj);
                            }
                        }
                        stepsToUpdate.add(stpObj);
                    }
                }
            }

            if (!stepsToUpdate.isEmpty()) {
               sp =  Database.setSavepoint();     
               update stepsToUpdate;
               if(srsToUpdate.size()>0)
                    update srsToUpdate;
            }



        }catch(Exception e){
            System.debug('Error Message: '+e.getMessage());
            System.debug('Error Line Number: '+e.getLineNumber());
            Database.rollback(sp);
        }




    }
 
    global void finish(Database.BatchableContext BC) {
        //RecurringScheduleJob();
    }

    /**
     * [RecurringScheduleJob - Schedules the job to run again after specific time configured in custom label.]
     */
    public void RecurringScheduleJob(){
        Integer addTime = (Test.isRunningTest()) ? 100 :Integer.valueOf(Label.ARAMEX_STEP_CLOSURE_SCHEDULER_TIME);
        DateTime now =  System.now().addMinutes(addTime);
        String day = string.valueOf(now.day());
        String month = string.valueOf(now.month());
        String hour = string.valueOf(now.hour());
        String minute = string.valueOf(now.minute());
        String second = string.valueOf(now.second());
        String year = string.valueOf(now.year());
        
        String strJobName = 'ARAMEX-STEP_CLOURE_JOB : ' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;
        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        if(!Test.isRunningTest())
            System.schedule(strJobName, strSchedule, new AramexUpdateStepStatusScheduleCls());
        for( CronTrigger c:[Select State,Id,EndTime,CronExpression,CronJobDetail.Name From CronTrigger WHERE   
                                        NextFireTime= null  AND State='DELETED' AND CronJobDetail.Name LIKE  'ARAMEX-STEP_CLOURE_JOB%' Limit 10]){
                    System.abortJob(c.id);
           }
    }

    /**
     * [getTransition - Get the transition record for the step]
     * @param  steps [description]
     * @return       [description]
     */
    public HexaBPM__Step_Transition__c getTransition(List<HexaBPM__Step__c> steps) {
    system.debug('====='+steps[0].HexaBPM__SR_Step__c+'===='+steps[0].HexaBPM__Status__c+'===='+steps[0].id);
        HexaBPM__Step_Transition__c transitionObj = new HexaBPM__Step_Transition__c();
        if (!steps.isEmpty()) {
        for (HexaBPM__Step_Transition__c transition : [SELECT Id,
                    HexaBPM__SR_Status_External__c,
                    HexaBPM__SR_Status_Internal__c,
                    HexaBPM__Transition__r.HexaBPM__To__c,
                    HexaBPM__SR_Step__c
                    FROM HexaBPM__Step_Transition__c
                    WHERE HexaBPM__SR_Step__c = :steps[0].HexaBPM__SR_Step__c AND
                    HexaBPM__Transition__r.HexaBPM__From__c =:steps[0].HexaBPM__Status__c]) {

                //System.debug('==>'+transition.HexaBPM__Transition__r.HexaBPM__To__c);
                transitionObj = transition;
                 
            }
        }
        return transitionObj;
    }
}
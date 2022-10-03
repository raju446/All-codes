/*
    Author      : Kim Noceda
    Date        : 13-Nov-2017
    Description : COntroller class to create PO Box records based on the range from the user.
    --------------------------------------------------------------------------------------
*/
public class CreatePOBoxController{

    public String startPOBoxNum {get;set;}
    public String endPOBoxNum {get;set;}
    public String AVAILABLE_STR = 'Available';
    public PO_Box__c newObjPOBox {get;set;}
    public String maxPOBoxNumber;
    public Integer OriginalStartNumber;
    public CreatePOBoxController(ApexPages.StandardController stdController){
        newObjPOBox = new PO_Box__c();
        maxPOBoxNumber = '00000';
        for(PO_Box__c objPO : [SELECT Id,PO_Box_Number__c FROM PO_Box__c where PO_Box_Number__c!=null ORDER BY PO_Box_Number__c DESC limit 1]){
            maxPOBoxNumber = (integer.valueOf(objPO.PO_Box_Number__c)+1)+'';
            OriginalStartNumber = integer.valueOf(objPO.PO_Box_Number__c)+1;
        }
        startPOBoxNum = maxPOBoxNumber;//String.valueOf(maxPOBoxNumber).leftpad(5).replace('0', '');
    }
    
    public PageReference savePOBoxes(){
        list<PO_Box__c> newPOBoxList = new List<PO_Box__c>();
        
        Integer startNumber;
        if(startPOBoxNum!=null && startPOBoxNum.isNumeric())
            startNumber = Integer.valueOf(startPOBoxNum);
        Integer endNumber;
        if(endPOBoxNum!=null && endPOBoxNum.isNumeric())
            endNumber = Integer.valueOf(endPOBoxNum);
        System.debug('##START: '+startNumber);
        system.debug('##START: '+startNumber);
        System.debug('OriginalStartNumber===>'+OriginalStartNumber);
        
        if(OriginalStartNumber!=null && startNumber!=null && startNumber<OriginalStartNumber){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Start Number should start with '+OriginalStartNumber));
            return null;
        }
        if(startNumber!=null && endNumber!=null && startNumber>endNumber){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Start Number should be less than End Number'));
            return null;
        }
        for(integer i=startNumber;i<=endNumber;i++){
            PO_Box__c newPOBox = new PO_Box__c();
            newPOBox.PO_Box_Number__c = String.valueOf(i).leftpad(5).replace(' ', '0');
            newPOBox.Status__c = AVAILABLE_STR;
            newPOBox.Type__c = newObjPOBox.Type__c;
            newPOBox.Size__c = newObjPOBox.Size__c;
            System.debug('##POBOX: '+newPOBox.PO_Box_Number__c);
            newPOBoxList.add(newPOBox);
        }
        
        if(!newPOBoxList.isEmpty()){
            try{
                insert newPOBoxList;
                //System.debug('##POBOXLIST: '+newPOBoxList);
                PageReference pageRef = new PageReference('/'+Label.PO_Box_Object_Prefix+'/o');
                pageRef.setRedirect(true);
                return pageRef;
            } catch(Exception e){
                System.debug('##ERROR: '+e.getmessage());
                return null;
            }
        }
        return null;
    }
    
    public PageReference cancelPOBox(){
        PageReference pageRef = new PageReference('/'+Label.PO_Box_Object_Prefix+'/o');
        pageRef.setRedirect(true);
        return pageRef;
    }
}
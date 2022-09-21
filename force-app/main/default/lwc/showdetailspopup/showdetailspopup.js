import { LightningElement, track, wire } from 'lwc';
import getDataFromContact from '@salesforce/apex/popupdetails.getDataFromContact';
const columns=[
    {
        label: 'View',
        type: 'button-icon',
        initialWidth: 75,
        typeAttributes: {
            iconName: 'action:preview',
            title: 'Preview',
            variant: 'border-filled',
            alternativeText: 'View'
        }
      },
      {
        label: 'Name',
        fieldName: 'Name'
       
    },
    {
        label: 'gender',
        fieldName: 'gender__c'
        

    },
    {
        label: 'fees',
        fieldName: 'fees__c'
        
    },
    {
        label: 'marks',
        fieldName: 'marks__c'
       

     
    },
    {
        label: 'results',
        fieldName: 'results__c'
    },
    {
        label: 'teacher',
        fieldName: 'teacher2__r.Name'   
        
    }
];

export default class popupdetails extends LightningElement {
  @track columns = columns;
  @track contactRow={};
  @track rowOffset = 0;  
  @track modalContainer = false;
   @wire(getDataFromContact) wireContact;
 
   handleRowAction(event){
       alert(" Can I Show Student Recoerds")
      const dataRow = event.detail.row;
      window.console.log('dataRow@@ ' + dataRow);
      this.contactRow=dataRow;
      window.console.log('contactRow## ' + dataRow);
      this.modalContainer=true;
   }

   closeModalAction(){
    this.modalContainer=false;
   }

}
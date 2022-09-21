import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class recordpage extends LightningElement {
   
    showToast() {
        const event = new ShowrRecordpage({
            title: 'Success',
            message:'Record created has been successfully',
                variant: 'success',
        });
        this.dispatchEvent(event);
    }

      
        handleButtonClick() {
            alert('Go To Record Page')
            const event = new ShowToastEvent({
                title: 'Success!',
                message: 'Record {0} created! See it {1}!',
                variant: 'success',
                messageData: [
                    'Record',
                    {
                        url: 'https://raju3-dev-ed.lightning.force.com/lightning/o/student2__c/list?filterName=Recent',
                        label: 'Tap Here',
                    },
                ],
            });
            this.dispatchEvent(event);
        }
        
}
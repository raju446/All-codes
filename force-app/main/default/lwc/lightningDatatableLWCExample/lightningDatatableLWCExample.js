import { LightningElement ,api, wire, track} from 'lwc';
import getstudent2List from '@salesforce/apex/studentrecords.getstudent2List';
export default class LightningDatatableLWCExample extends LightningElement {
    @track columns = [{
            label: 'Record name',
            fieldName: 'Name',
            type: 'text',
            sortable: true
        },
        {
            label: 'gender',
            fieldName: 'gender__c',
            type: 'text',
            sortable: true
        },
        {
            label: 'fees',
            fieldName: 'fees__c',
            type: 'Currency',
            sortable: true
        },
        {
            label: 'marks',
            fieldName: 'marks__c',
            type: 'numbers',
            sortable: true
        },
        {
            label: 'results',
            fieldName: 'results__c',
            type: 'text',
            sortable: true
        }
    ];
 
    @track error;
    @track accList ;
    @wire(getstudent2List)
    wiredstudent2({
        error,
        data
    }) {
        console.log(data);
        if (data) {
            this.accList = data;
        } else if (error) {
            this.error = error;
        }
    }
}
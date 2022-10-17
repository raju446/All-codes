import { LightningElement, wire } from 'lwc';
import getRelatedList from '@salesforce/apex/Contactapex.getRelatedList';

const columns = [
    { label: 'Contact', fieldName: 'Contact.Name', type: 'text' },
    { label: 'Role', fieldName: 'Role', type: 'Picklist' },
    { label: 'Title', fieldName: 'Contact.Title', type: 'text' }
];

export default class Contact extends LightningElement {

    records;
    wiredRecords;
    error;
    columns = columns;
    draftValues = [];

    @wire( getRelatedList )  
    wiredAccount( value ) {

        this.wiredRecords = value;
        const { data, error } = value;

    }  

}
import { LightningElement, wire } from 'lwc';
import First_Name from '@salesforce/schema/Contact.FirstName';
import Last_Name from '@salesforce/schema/Contact.LastName';
import Email from '@salesforce/schema/Contact.Email';
import getContacts from '@salesforce/apex/ContactController.getContacts';
import { reduceErrors } from 'c/ldsUtils';
const COLUMNS = [
    { label: 'FirstName', fieldName: First_Name.fieldApiName, type: 'text' },
    { label: 'LastName', fieldName: Last_Name.fieldApiName, type: 'text' },
    { label: 'Email', fieldName: Email.fieldApiName, type: 'text' }
];
export default class ContactList extends LightningElement {
    columns = COLUMNS;
    @wire(getContacts)
    Contacts;

    get errors() {
        return (this.Contacts.error) ?
            reduceErrors(this.Contacts.error) : [];
    }
}
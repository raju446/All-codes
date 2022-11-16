import { LightningElement, wire } from 'lwc';
import fetchBooks from '@salesforce/apex/Booksearch.fetchBooks';
import { NavigationMixin } from 'lightning/navigation';
 
const columns = [   
    { label: 'Id', fieldName: 'Id__c' },
    { label: 'Title', fieldName: 'Title__c' },
    { label: 'Author', fieldName: 'Author__c'},
    { label: 'ISBN', fieldName: 'ISBN__c', type: 'Text (Unique)' },
    { label: 'Category', fieldName: 'Category__c', type: 'picklist' },
    { label: 'Inventory', fieldName: 'Inventory__c', type: 'Number' },
    { label: 'notes', fieldName: 'notes__c', type: 'Long Text' },
];

export default class findbook extends NavigationMixin( LightningElement ) {
     
    availableAccounts;
    error;
    columns = columns;
    searchString;
    initialRecords;

    @wire( fetchBooks )  
    wiredBooks( { error, data } ) {

        if ( data ) {

            this.availableAccounts = data;
            this.initialRecords = data;
            this.error = undefined;

        } else if ( error ) {

            this.error = error;
            this.availableAccounts = undefined;

        }

    }

    handleSearchChange( event ) {

        this.searchString = event.detail.value;
    }

    handleSearch( event ) {
        const searchKey = event.target.value.toLowerCase();
        if ( searchKey ) {
            this.availableAccounts = this.initialRecords;            
            if ( this.availableAccounts ) {
                let recs = [];
                for ( let rec of this.availableAccounts ) {
                    let valuesArray = Object.values( rec );
                    for ( let val of valuesArray ) {
                        let strVal = String( val );
                        if ( strVal ) {
                            if ( strVal.toLowerCase().includes( searchKey ) ) {
                                recs.push( rec );
                                break;
                            }

                        }

                    }
                    
                }
                this.availableAccounts = recs;
             }
 
        }  else {

            this.availableAccounts = this.initialRecords;

        }        

    }

}

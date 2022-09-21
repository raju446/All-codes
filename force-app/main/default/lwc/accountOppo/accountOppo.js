import { LightningElement ,api, wire, track} from 'lwc';
import getAccountList from '@salesforce/apex/Opportunutyhelp.getAccountList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ACCOUNT_OBJECT from '@salesforce/schema/Opportunity';
import NAME_FIELD from '@salesforce/schema/Opportunity.Name';
import CloseDate_FIELD from '@salesforce/schema/Opportunity.CloseDate';
import Stage_FIELD from '@salesforce/schema/Opportunity.StageName';
import Account_FIELD from '@salesforce/schema/Opportunity.Account__c';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
export default class accountoppo extends  NavigationMixin(LightningElement) {

    @track columns = [{
            label: 'Opportunity name',
            fieldName: 'Name',
            type: 'text',
            sortable: true
        },
        {
            label: 'Close Date',
            fieldName: 'CloseDate',
            type: 'Date',
            sortable: true
        },
        {
            label: 'Stage',
            fieldName: 'StageName',
            type: 'Picklist',
            sortable: true
        },
    ];
 
    @track error;
    @track accList ;
    @wire(getAccountList)
    wiredAccounts({
        error,
        data
    }) {
        if (data) {
            this.accList = data;
        } else if (error) {
            this.error = error;
        }
    }

    @track Form = false;
      handleClick(event){
        this.Form = true;
      }
        // objectApiName is "Account" when this component is placed on an account record page
        accountObject = ACCOUNT_OBJECT;
        nameField = NAME_FIELD
        CloseDateField = CloseDate_FIELD 
        StageField = Stage_FIELD
        AccountField = Account_FIELD
        handleAccountCreated(event) {
            const evt = new ShowToastEvent({
                title: "Opportunity created",
                message: "Record ID: " + event.detail.id,
                variant: "success"
            });
            this.dispatchEvent(evt);
            location.reload();
        }
        createRecordWithDefaultValues() {
            //Object will be having field names and values 
             const defaultValues = encodeDefaultFieldValues({
                 FirstName: 'TechDicer',
                 LastName: 'KeepLearning',
                 LeadSource: 'Web',
                 Email:'test@g.com',
                 Title:'Techdicer'
             });
      
             this[NavigationMixin.Navigate]({
                 type: 'standard__objectPage',
                 attributes: {
                     objectApiName: 'Contact',
                     actionName: 'new'
                 },
                 state: {
                     defaultFieldValues: defaultValues
                 }
             });
         }
}
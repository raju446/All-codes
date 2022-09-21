import { LightningElement, api } from "lwc";
import LightningConfirm from 'lightning/confirm';

export default
class recordCardQuickFiles extends LightningElement {
    @api
    recordId;
    onDeleteAllFilesButtonClick() {
        const confirmation = LightningConfirm.open({
            Message: 'Are you sure you want to delete all files?',
            Variant: 'headerless',
            Label: 'Are you sure you want to delete all files?'
        });
        console.log('Result: '+ confirmation);
    }
}
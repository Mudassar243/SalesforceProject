import { LightningElement, track, wire } from 'lwc';
import getPendingFollowUps from '@salesforce/apex/FollowUpController.getPendingFollowUps';
import markCompleted from '@salesforce/apex/FollowUpController.markCompleted';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';

export default class ContactList extends NavigationMixin(LightningElement) {
    contacts = [];
    notesMap = {};
    isLoading = false;
    wiredResult; 

    @wire(getPendingFollowUps)
    wiredContacts(result){
        this.wiredResult = result;

        if(result.data){
            this.contacts = result.data;
        } else if(result.error){
            console.error(result.error);
            this.contacts = [];
        }
    }
    handleNavigate(event){
    const recordId = event.target.dataset.id;

    this[NavigationMixin.GenerateUrl]({
        type: 'standard__recordPage',
        attributes: {
            recordId: recordId,
            objectApiName: 'Contact',
            actionName: 'view'
        }
    }).then(url => {
        window.open(url, '_blank'); 
    });
}

    handleNotes(event){
        const id = event.target.dataset.id;
        this.notesMap[id] = event.target.value;
    }

    handleComplete(event){
        const contactId = event.target.dataset.id;
        this.isLoading = true; 

        markCompleted({ contactId })
            .then(() => refreshApex(this.wiredResult))
            .catch(error => console.error(error))
            .finally(() => {
                this.isLoading = false; 
            });
    }
    handleRefresh() {
        refreshApex(this.wiredResult);
    }
}
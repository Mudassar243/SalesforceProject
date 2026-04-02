import { LightningElement, track, wire } from 'lwc';
import getPendingFollowUps from '@salesforce/apex/FollowUpController.getPendingFollowUps';
import markCompleted from '@salesforce/apex/FollowUpController.markCompleted';
import { refreshApex } from '@salesforce/apex';

export default class ContactList extends LightningElement {

    @track contacts = [];
    notesMap = {};
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

    handleNotes(event){
        const id = event.target.dataset.id;
        this.notesMap[id] = event.target.value;
    }

    handleComplete(event){
        const id = event.target.dataset.id;

        markCompleted({ 
            contactId: id, 
            notes: this.notesMap[id] || '' 
        })
        .then(() => refreshApex(this.wiredResult)) 
        .catch(error => console.error(error));
    }
}
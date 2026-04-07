import { LightningElement, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getWeatherData from '@salesforce/apex/WeatherCallout.getWeatherData';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

export default class WeatherButton extends LightningElement {

    @api recordId;

    isLoading = false;
   

    handleWeatherCheck() {

        this.isLoading = true;

        getWeatherData({ leadId: this.recordId })
            .then(() => {
                this.isLoading = false;

                getRecordNotifyChange([{ recordId: this.recordId }]);

                const toastEvent = new ShowToastEvent({
                    title: 'Success!',
                    message: 'Weather data fetched and Lead updated!',
                    variant: 'success',
                    mode: 'dismissable' 
                });
                this.dispatchEvent(toastEvent);

                setTimeout(() => {
                    const toastEl = this.template.querySelector('lightning-toast');
                    if(toastEl) {
                        toastEl.close();
                    }
                }, 3000);

            })
            .catch(error => {
                this.isLoading = false;

                const toastEvent = new ShowToastEvent({
                    title: 'Error!',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(toastEvent);

                setTimeout(() => {
                    const toastEl = this.template.querySelector('lightning-toast');
                    if(toastEl) toastEl.close();
                }, 3000);
            });
    }
}
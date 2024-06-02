import { LightningElement, track,wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import generateAuthUrl from '@salesforce/apex/GoogleDriveAuthController.generateAuthUrl';
import getAccessToken from '@salesforce/apex/GoogleDriveAuthController.getAccessToken';

export default class AuthenticationComp extends LightningElement {
    @track authUrl; // Property to store the URL

    /*@wire(CurrentPageReference)
    currentPageReference;

    connectedCallback() {      
        //console.log(`c__myParam = ${this.currentPageReference.state.c__myParam}`);
        const param = "code";
        const paramValue = this.getUrlParamValue(window.location.href, param);
        console.log("to show my parm :: " + paramValue);
    }*/

    handleAuthClick() {
        generateAuthUrl()
            .then((url) => {
                this.authUrl = url;  // Store the URL in the property
                //window.open(url, '_blank');
                window.location.href = url;

                window.addEventListener('message', this.handleMessage.bind(this), false);
            })
            .catch((error) => {
                console.error('Error generating auth URL: ', error);
            });
    }

    handleMessage(event) {
        if (event.origin !== window.location.origin) {
            return;
        }
        
        const code = event.data.code;
        if (code) {
            getAccessToken({ code: code })
                .then((result) => {
                    if (result) {
                        alert('Authorization successful');
                    } else {
                        alert('Authorization failed');
                    }
                })
                .catch((error) => {
                    console.error('Error getting access token: ', error);
                });
        }
    }
}
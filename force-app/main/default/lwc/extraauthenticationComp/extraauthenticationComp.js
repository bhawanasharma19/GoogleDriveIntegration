import { LightningElement, track } from 'lwc';
import generateAuthUrl from '@salesforce/apex/GoogleDriveAuthController.generateAuthUrl';
import getAccessToken from '@salesforce/apex/GoogleDriveAuthController.getAccessToken';

export default class ExtraauthenticationComp extends LightningElement {
    @track authUrl; // Property to store the URL

    connectedCallback() {
        // Check if there is a code in the URL
        const urlParams = new URLSearchParams(window.location.search);
        const code = urlParams.get('code');

        if (code) {
            this.handleAuthorizationCode(code);
        }
    }

    handleAuthorizationCode(code) {
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

    handleAuthClick() {
        generateAuthUrl()
            .then((url) => {
                this.authUrl = url;  // Store the URL in the property
                window.location.href = url;  // Redirect the current window to the URL
            })
            .catch((error) => {
                console.error('Error generating auth URL: ', error);
            });
    }

}
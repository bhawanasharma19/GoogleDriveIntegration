import { LightningElement, api, track , wire} from 'lwc';
import createUserMetadata from '@salesforce/apex/googleDriveFinalCompController.createUserMetadata';
import handleAuthenticateUser from '@salesforce/apex/googleDriveFinalCompController.handleAuthenticateUser';
import handleAccessTokenFirstTime from '@salesforce/apex/googleDriveFinalCompController.handleAccessTokenFirstTime';
import checkExpiryTime from '@salesforce/apex/googleDriveFinalCompController.checkExpiryTime';
import getFileIdNameMap2 from '@salesforce/apex/GoogleDrive.getFileIdNameMap2';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from "@salesforce/user/Id";
import getGDFiles2 from '@salesforce/apex/GoogleDriveApi2.getGDFiles2';
import { refreshApex } from '@salesforce/apex';
import getFolderfiles from '@salesforce/apex/googleDriveFinalCompController.getFolderfiles';
import checkNewUser from '@salesforce/apex/googleDriveFinalCompController.checkNewUser';
import authenticateUser from '@salesforce/apex/googleDriveFinalCompController.authenticateUser';
import deleteFileContentMethod from '@salesforce/apex/GoogleDriveApi2.deleteFileContentMethod';
import ReNameFileContentMethod from '@salesforce/apex/GoogleDriveApi2.ReNameFileContentMethod';

export default class Demo extends LightningElement {
    getdrivedataagain(userId){
        getGDFiles2({userId})
            .then(result => {
                if (result && Object.keys(result).length > 0) {
                    this.filesData = Object.keys(data).map(item => {
                        let fileData = {
                            "Id": item,  
                            ...data[item]  
                        };
                        console.log('fileData for item ' + item + ':', fileData); 
                        console.log('fileData demo: '+fileData);
                        return fileData;  
                    });
                    console.log('Files data:', this.filesData);
                }
            })
            .catch(error => {
                // Handle error if any
                console.log('error is in files data' + error);
            });
    }
}
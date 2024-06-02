import { LightningElement, api, track, wire } from 'lwc';
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

const INTERVAL = 5 * 60 * 1000; // 5 minutes

export default class GoogleDriveFinalComp extends LightningElement {
    //for checking
    @api userId = Id;// Property to store the User ID
    @track isModalOpen = false;
    @track clientKey = '';// Property to store the clientKey
    @track clientSecret = '';// Property to store the clientSecret
    @track isSaveDisabled = false;
    @track authUrl; // Property to store the URL
    @track code;
    isAuthorizationHandled = false;
    @track isAuthenticate = false;
    @track isNewUser = false;
    @track isPreview = false;
    @track isdelete = false;
    //google drive properties
    @track filesData = [];
    fileId;
    @track mimeType;
    @track foldersData = [];
    name;
    folderSize;
    breadCrumb = [];
    pageSize = 5;
    @track currentPage;
    @track index = 0;
    @track pages = [];
    error;
    intervalId;
    @track closefolderbread  = false;
    @track breadcrumbcount = [];
    //New property to store the current folder name
    @track currentFolderName = 'Root';
    @track isViewingFiles = true;
    @track isViewingFolders = false;
    //Upload Properties
    @track acceptedFormats = ['.pdf', '.png', '.jpg', '.jpeg', '.doc', '.docx', '.xls', '.xlsx'];

    connectedCallback() {
        // Check if there is a code in the URL
        const urlParams = new URLSearchParams(window.location.search);
        this.code = urlParams.get('code');
        console.log('my code: ' + this.code);
        console.log('New User: '+this.isNewUser);
        console.log('authenticated: '+this.isAuthenticate);

        if (this.code && !this.isAuthorizationHandled) {
            console.log('handleAuthorizationCode my code: ' + this.code);
            this.handleAuthorizationCode(this.code);
            this.isAuthorizationHandled = true; // Set the flag to true
        }
        
        this.intervalId = setInterval(() => {
            this.checkExpiryTime();
        }, INTERVAL);

        // Call initially when component is connected
        this.checkExpiryTime();
    }
    
    disconnectedCallback() {
        // Clear the interval when component is removed
        clearInterval(this.intervalId);
    }
    
    //here we are handling the access code regeneration
    checkExpiryTime() {
        checkExpiryTime({ userId: this.userId })
            .then(result => {
                console.log('Expiry time checked successfully:', result);
            })
            .catch(error => {
                console.error('Error checking expiry time:', error);
            });
    }

    

//From here all the New User Data is Handled*********************************************************
    
    @wire(checkNewUser, { userId: '$userId' })
    handleUser({ data, error }) {
        if (data) {
            console.log('data from handleUser: '+data);
            this.isNewUser = data;
        } else if (error) {
            console.error('Error checking new user:', error);
        }
    }
    handleNewUser() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    handleClientIdChange(event) {
        this.clientKey = event.target.value;
        console.log('clientKey: '+this.clientKey);

    }

    handleClientSecretChange(event) {
        this.clientSecret = event.target.value;
        console.log('clientSecret: '+this.clientSecret);

    }

    
    handleSaveDetails() {
        // Call Apex method
        
        if((this.clientKey!=null && this.clientKey!='')&&(this.userId!=null && this.userId!='')&&(this.clientSecret!=null && this.clientSecret!='')){
            createUserMetadata({ userId: this.userId, clientKey: this.clientKey, clientSecret: this.clientSecret })
            
            .then(result => {
                if (result === true) {
                    // Show success toast
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success',
                        message: 'Details saved successfully!',
                        variant: 'success'
                    }));
                    this.isSaveDisabled = true;
                    this.isNewUser = false;
                    this.closeModal();
                    window.location.reload();
                    
                }
                else if (result === false) {
                    // Show toast indicating user already exists
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Warning',
                        message: 'User already Exist!',
                        variant: 'warning'
                    }));
                    this.isSaveDisabled = true;
                    this.closeModal();
                    window.location.reload();
                    
                }

            })
            .catch(error => {
                // Handle error
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: 'Failed to save details: ' + error.body.message,
                    variant: 'error'
                }));
            });
        }
        else{
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Please provide all the required details!',
                variant: 'error'
            }));
        }
        
    }

    //From here all the authentication data is handled

    /*handleAuthenticate() {
        // Handle the Authenticate action
        console.log('Authenticating with Client ID:', this.clientId, 'and Client Secret:', this.clientSecret);
        // Add your authentication logic here
        this.closeModal();
    }*/
    //new auth
    @wire(authenticateUser, { userId: '$userId' })
    handleauth({ data, error }) {
        if (data) {
            console.log('data from handleUser: '+data);
            this.isAuthenticate = data;
        } else if (error) {
            console.error('Error checking new user:', error);
        }
    }

    handleAuthClick() {
        if (this.userId != null && this.userId != '') {
            handleAuthenticateUser({ userId: this.userId })
                .then((result) => {
                    if (result === 'alreadyauthorized') {
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Warning',
                            message: 'User already authorized!',
                            variant: 'warning'
                        }));
                    } 
                    else if (result === null) {
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Error',
                            message: 'User does not exist!',
                            variant: 'error'
                        }));
                    }
                    else if (typeof result === 'string' && result !== '') {
                        this.authUrl = result;  // Store the URL in the property
                        window.location.href = result;  // Redirect the current window to the URL
                        //this.authUrl = url;  // Store the URL in the property
                        //window.location.href = url;
                    }
                    else {
                        console.error('Unexpected result: ', result);
                    }
                })
                .catch((error) => {
                    console.error('Error generating auth URL: ', error);
                });
        }
    }

    handleAuthorizationCode(code) {
        handleAccessTokenFirstTime({ code: code,userId : this.userId })
            .then((result) => {
                if (result === true) {
                    alert('Authorization successful');
                    this.isAuthenticate = false;
                    window.location.href = 'https://algoworks16-dev-ed.develop.my.site.com/gdintegration/s/';
                    
                } else {
                    alert('Authorization failed');
                }
            })
            .catch((error) => {
                console.error('Error getting access token: ', error);
            });
    }

 /********************************************************************************************************************
  * ******************************************************************************************************************
  * ******************************************************************************************************************
  * 
  * 
  */   
    //From here all the Google Drive Methods are handled
    
    @wire(getGDFiles2, { userId: '$userId' })
    wiredFileIdNameMap2({ data, error }) {
        if (data) {
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
        if (error) {
            console.log('error is in files data' + error);
        }
    }
    /*
    @wire(getFileIdNameMap2, { userId: '$userId' })
    wiredFileIdNameMap2({ data, error }) {
        if (data) {
            this.filesData = Object.keys(data).map(item => ({
                "Id": item,
                "Name": data[item]
            }));
            console.log('Files data:', this.filesData);
        }
        if (error) {
            console.log('error is in files data' + error);
        }
    }*/
    handleDelete(event) {
        this.fileId = event.target.dataset.id;
        this.deleteFile(this.fileId);
        console.log('fileId: ' + this.fileId);
    }
    handledeletemodal(){
        this.isdelete = true;
    }
    //new
    handlePreview(event) {
        this.fileId = event.target.dataset.id;
        this.mimeType = event.target.dataset.mimetype;
        this.currentFolderName = event.target.dataset.name;

        if (this.mimeType !== 'application/vnd.google-apps.folder') {
            const googleDriveUrl = `https://drive.google.com/open?id=${this.fileId}`;
            window.open(googleDriveUrl, '_blank');
        } else if (this.mimeType === 'application/vnd.google-apps.folder') {
            this.getFoldermethod(this.fileId, this.userId);
            this.isPreview = true;
            this.closefolderbread = true;
            this.isViewingFolders = true;

            // Breadcrumb logic
            let breadcrumbExists = this.breadcrumbcount.some(breadcrumb => breadcrumb.id === this.fileId);
            if (!breadcrumbExists) {
                this.breadcrumbcount.push({
                    id: this.fileId,
                    name: this.currentFolderName,
                    mimeType: this.mimeType,
                    count: this.breadcrumbcount.length + 1
                });
            }

            console.log('breadcrumbcount: ', JSON.stringify(this.breadcrumbcount));
        }
    }
    
    //folder data
    getFoldermethod(folderId, userId) {
        getFolderfiles({ folderId, userId })
            .then(result => {
                console.log('Result object:', result);
                this.filesData = Object.keys(result).map(key => {
                    let fileData = {
                        "Id": key,  
                        ...result[key]  
                    };
                    console.log('fileData for item ' + key + ':', fileData); 
                    console.log('fileData demo: '+fileData);
                    return fileData;  
                });
        
                console.log('Folder data:', this.filesData);
            })
            .catch(error => {
                // Handle error if any
                console.error('Error from getFolderfiles:', error);
            });
    }
    
    


    closePreview(){
        this.isPreview = false;
    }
    //old
    /*handlePreview(event) {
        this.fileId = event.target.dataset.id;
        console.log('fileId: ' + this.fileId);
    }*/

    deleteFile(fileId) {
        deleteFileContentMethod({ fileId: fileId, userId: this.userId })
            .then((result) => {
                if (result) {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success',
                        message: 'files deleted successfully',
                        variant: 'success'
                    }));
                    console.log('File deleted successfully');
                    window.location.reload();
                } else {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: 'Error deleting file: File not deleted.',
                        variant: 'error'
                    }));
                    console.error('Error deleting file: File not deleted.');
                }
            })
            .catch((error) => {
                console.error('Error deleting file:', error);
            });
    }
    

    refreshFiles() {
        return refreshApex(this.filesData);
    }
    //new 
    async handleRenameMode(event) {
        console.log("handleRenameMode method invoked.");
        const fileId = event.target.dataset.id;
        
        try {
            const name = await this.openPromptModal();
            console.log('newName in handleRenameMode:', name);
            
            if (name !== null && name.trim() !== '') {
                this.renameFile(fileId, name);
            } else {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: 'Error renaming file: Empty file name entered.',
                    variant: 'error'
                }));
                console.error('Error renaming file: Empty file name entered.');
            }
        } catch (error) {
            console.error('Error renaming file:', error);
        }
    }
    
    renameFile(fileId, name) {
        ReNameFileContentMethod({ fileId: fileId, name: name, userId: this.userId })
            .then(result => {
                if (result) {
                    console.log('File renamed successfully');
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success',
                        message: 'files deleted successfully',
                        variant: 'success'
                    }));
                    console.log('File renamed successfully');
                    window.location.reload();
                } else {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: 'Error renaming file: File not renamed.',
                        variant: 'error'
                    }));
                    console.error('Error renaming file: File not renamed.');
                }
            })
            .catch(error => {
                console.error('Error renaming file:', error);
            });
    }
    

    //old
    /*async handleRenameMode(event) {
        console.log("handleRenameMode method invoked.");
        const fileId = event.target.dataset.id;
        
            const name = await this.openPromptModal();
            console.log('newName in handleRenameMode:', name);
            
            if (name !== null && name.trim() !== '') {
                ReNameFileContentMethod({ fileId: fileId, name: name })
                    .then(result => {
                        if (result) {
                            console.log('File renamed successfully');
                            this.refreshFiles();
                        } else {
                            console.error('Error renaming file: File not renamed.');
                        }
                    })
                    .catch(error => {
                        console.error('Error renaming file:', error);
                    });
            } else {
                console.error('Error renaming file: Empty file name entered.');
            }
        
    }*/

    openPromptModal() {
        console.log('Inside Prompt');
        return new Promise((resolve, reject) => {
            try {
                const name = window.prompt('Enter new name:', '');
                console.log('User entered:', name);
                resolve(name);
            } catch (error) {
                reject(error);
            }
        });
    }
    //Upload Functionality
    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.jpeg', '.doc', '.docx', '.xls', '.xlsx'];
    }
    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        if (uploadedFiles.length > 0) {
            // Assuming only one file is uploaded at a time
            const fileId = uploadedFiles[0].documentId;
            
            // Call the Apex method to upload the file content to Google Drive
            this.uploadFileToGoogleDrive(fileId);
        }
    }

    //Navigation functionality
    handleNavigateToRoot(event) {
        // prevent default navigation by href
        event.preventDefault();
        this.closefolderbread = false;
        const caseDiv = this.template.querySelector('.container .case');
        this.hide(caseDiv);

        const accountDiv = this.template.querySelector('.container .account');
        this.show(accountDiv);
        this.breadcrumbcount = [];
        this.getdrivedataagain(this.userId);

    }
    getdrivedataagain(userId){
        getGDFiles2({userId})
            .then(result => {
                if (result && Object.keys(result).length > 0) {
                    this.filesData = Object.keys(result).map(item => {
                        let fileData = {
                            "Id": item,  
                            ...result[item]  
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
    
    handleNavigateToFolder(event) {
        this.fileId = event.target.dataset.id;
        this.mimeType = event.target.dataset.mimetype;
        this.currentFolderName = event.target.dataset.name;
        console.log('fileid in handleNavigateToFolder: '+this.fileId);
        console.log('mimeType in handleNavigateToFolder: '+this.mimeType);
        // prevent default navigation by href
        event.preventDefault();

        const accountDiv = this.template.querySelector('.container .account');
        this.hide(accountDiv);

        const caseDiv = this.template.querySelector('.container .case');
        this.show(caseDiv);
        if (this.mimeType !== 'application/vnd.google-apps.folder') {
            const googleDriveUrl = `https://drive.google.com/open?id=${this.fileId}`;
            window.open(googleDriveUrl, '_blank');
        } else if (this.mimeType === 'application/vnd.google-apps.folder') {
            this.getFoldermethod(this.fileId, this.userId);
            this.isPreview = true;
            this.closefolderbread = true;
            this.isViewingFolders = true;

            // Breadcrumb logic
            let matchingBreadcrumb = this.breadcrumbcount.find(breadcrumb => breadcrumb.id === this.fileId);
            if (matchingBreadcrumb) {
            // Get the count value of the matching breadcrumb
            const matchingCount = matchingBreadcrumb.count;
            // Remove breadcrumbs with a count value greater than the matching count
            this.breadcrumbcount = this.breadcrumbcount.filter(breadcrumb => breadcrumb.count <= matchingCount);
        } else {
            // If no matching breadcrumb is found, add a new breadcrumb
            this.breadcrumbcount.push({
                id: this.fileId,
                name: this.currentFolderName,
                mimeType: this.mimeType,
                count: this.breadcrumbcount.length + 1
            });
        }

            console.log('breadcrumbcount: ', JSON.stringify(this.breadcrumbcount));
        }
    }

    close(event) {
        const name = event.target.value;
        const elmToClose = this.template.querySelector(`.${name}`);
        this.hide(elmToClose);
    }

    show(elm) {
        elm.classList.remove('slds-hide');
        elm.classList.add('slds-show');
    }

    hide(elm) {
        elm.classList.add('slds-hide');
        elm.classList.remove('slds-show');
    }




}
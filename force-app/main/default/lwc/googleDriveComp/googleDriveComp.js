// googleDriveComp.js
import { LightningElement, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getFolderContent from '@salesforce/apex/GoogleDriveFolderController.getFolderContent';
import getGoogleDriveFiles from '@salesforce/apex/GoogleDrive.getFileIdNameMap';
import deleteFileContentMethod from '@salesforce/apex/GoogleDriveApi.deleteFileContentMethod';
import ReNameFileContentMethod from '@salesforce/apex/GoogleDriveApi.ReNameFileContentMethod';

export default class GoogleDriveComp extends LightningElement {
    @track filesData = [];
    fileId;
    name;
    folderSize;
    breadCrumb = [];
    pageSize = 5;
    @track currentPage;
    @track index = 0;
    @track pages = [];
    error;

    @wire(getGoogleDriveFiles)
    filesDataMethod({ data, error }) {
        if (data) {
            this.filesData = Object.keys(data).map(item => ({
                "Id": item,
                "Name": data[item]
            }));
            console.log('Files data:', this.filesData);
        }
        if (error) {
            console.log('error is' + error);
        }
    }

    handleDelete(event) {
        this.fileId = event.target.dataset.id;
        this.deleteFile(this.fileId);
        console.log('fileId: ' + this.fileId);
    }

    handlePreview(event) {
        this.fileId = event.target.dataset.id;
        console.log('fileId: ' + this.fileId);
    }

    deleteFile(fileId) {
        deleteFileContentMethod({ fileId: fileId })
            .then((result) => {
                if (result) {
                    console.log('File deleted successfully');
                    eval("$A.get('e.force:refreshView').fire();");
                } else {
                    console.error('Error deleting file: File not deleted.');
                }
            })
            .catch(() => {
                this.refreshFiles();
            });
    }

    refreshFiles() {
        return refreshApex(this.filesData);
    }

    
    async handleRenameMode(event) {
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
        
    }

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
    


    loadFolderEvent(event) {
        const selectedFolder = event.detail;
        this.loadFolder(selectedFolder);
    }

    loadFolder(selectedFolder) {
        getFolderContent({ folderId: selectedFolder })
            .then(result => {
                console.log(result.files);
                this.folderSize = result.files.length;
                this.breadCrumb.push(result.files);
                this.createPagination(result.files);
            })
            .catch(error => {
                this.error = error;
            });
    }
}
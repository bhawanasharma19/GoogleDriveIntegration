public class GoogleDriveFolderController {
    @AuraEnabled(cacheable=true)
    public static GoogleDriveApi_FolderFilesResult getFolderContent(String folderId){
        
        return GoogleDrive.getFolderFiles(folderId);

    }
}
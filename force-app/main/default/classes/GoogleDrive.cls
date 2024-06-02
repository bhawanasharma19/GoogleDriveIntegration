/*
*********************************************************
Apex Class Name    : GoogleDrive
Created Date       : May 14, 2024
@description       : This class is used as service class to get data from GoogleDriveApi2 and use it in LWC Component.
@author            : Bhawana Sharma
Modification Log:
Ver   Date         Author                      Modification
2.0   22-05-2024   Bhawana Sharma              Second Version
*********************************************************
*/
public class GoogleDrive {
/*
    *********************************************************
    @Method Name    : getFileIdNameMap
    @author         : Bhawana Sharma
    @description    : getFileIdNameMap method is used to fetch Google Drive and use it in GoogleDriveFinalComp. 
    @param          :
    @return         : Map<String, String> - fileIdNameMap
    ********************************************************
*/
@AuraEnabled(Cacheable=true)
    // Method to retrieve file names from Google Drive API
    public static Map<String, String> getFileIdNameMap(){
        Map<String, String> fileIdNameMap;
        fileIdNameMap = GoogleDriveApi.getFilesCallout();
        return fileIdNameMap;
    }
/*
    *********************************************************
    @Method Name    : getFileIdNameMap2
    @author         : Bhawana Sharma
    @description    : getFileIdNameMap2 method is used to fetch Google Drive and use it in GoogleDriveFinalComp. 
    @param          :
    @return         : Map<String, String> - fileIdNameMap
    ********************************************************
*/
@AuraEnabled(Cacheable=true)
    // Method to retrieve file names from Google Drive API
    public static Map<String, String> getFileIdNameMap2(String userId){
		System.debug('method getFileIdNameMap2 started');
        Map<String, String> fileIdNameMap;
        fileIdNameMap = GoogleDriveApi2.getGDFiles(userId);
        System.debug('method getFileIdNameMap2 ended');
        return fileIdNameMap;
    }

    
}
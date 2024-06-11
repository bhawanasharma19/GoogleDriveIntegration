/*
*********************************************************
Apex Class Name    : GoogleDriveApi2
Created Date       : May 15, 2024
@description       : This class is used for making Callout from Salesforce to Google Drive APIs using acess token.
@author            : Bhawana Sharma
Modification Log:
Ver   Date         Author                               Modification
2.0   21-05-2024   Bhawana Sharma                      Second Version
*********************************************************
*/
public class GoogleDriveApi2 {
/*
    *********************************************************
    @Method Name    : getGDFiles2
    @author         : Bhawana Sharma
    @description    : getGDFiles2 method is used to fetch Google Drive files with Id,file information. 
    @param          :
    @return         : Map<String, Object> - fileIdNameMap
    ********************************************************
*/	@AuraEnabled(Cacheable = true)
	public static Map<String, Object> getGDFiles2(String userId) {
        Map<String, Object> googleDriveDataMap = new Map<String, Object>();
        Map<String, Object> filesDataMap = new Map<String, Object>();
        Map<String, String> fileIdNameMap = new Map<String, String>();
        String accessToken;
        List<GD_User_Data__mdt> userRecordList = [
            									 SELECT 
            										Id, MasterLabel, DeveloperName, clientId__c, clientSecretKey__c, RefreshToken__c, AccessToken__c, UserId__c, UserName__c 
            									 FROM
            									 	GD_User_Data__mdt 
            									 WHERE 
            										UserId__c = :userId 
            									 LIMIT 1
        										 ];

        if (!userRecordList.isEmpty()) {
            String ac = userRecordList[0].AccessToken__c;
            accessToken = EncodingUtil.urlEncode(ac, 'UTF-8');
        }

        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        //request.setEndpoint('https://www.googleapis.com/drive/v3/files');
        request.setEndpoint('https://www.googleapis.com/drive/v3/files?q=%27root%27+in+parents');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');
        Http http = new Http();
        HttpResponse response = http.send(request);
		System.debug('Response filefolders: '+response.getbody());
        if (response.getStatusCode() == 200 && response.getBody() != null) {
            googleDriveDataMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

            if (googleDriveDataMap != null && googleDriveDataMap.containsKey('files')) {
                List<Object> filesList = (List<Object>) googleDriveDataMap.get('files');

                if (filesList != null) {
                    // Iterate through each file object
                    for (Object file : filesList) {
                        Map<String, Object> fileInfo = (Map<String, Object>) file;
                        // Check if 'id' and 'name' attributes exist
                        if (fileInfo.containsKey('id') && fileInfo.containsKey('name')) {
                            // Get the ID and name values
                            String id = (String) fileInfo.get('id');
                            String name = (String) fileInfo.get('name');

                            // Store ID-name pair in the map
                            filesDataMap.put(id, file);
                            System.debug('filesDataMap each item: '+id+file);
                        }
                    }
                }
            }
        }
		System.debug('filesDataMap file/folder info: '+filesDataMap);
        return filesDataMap;
    }
/*
    *********************************************************
    @Method Name    : getGDFiles
    @author         : Bhawana Sharma
    @description    : getGDFiles method is used to fetch Google Drive files with Id,Name information. 
    @param          :
    @return         : Map<String, String> - fileIdNameMap
    ********************************************************
*/
	public static Map<String, String> getGDFiles(String userId) {
        Map<String, Object> googleDriveDataMap = new Map<String, Object>();
        Map<String, Object> filesDataMap = new Map<String, Object>();
        Map<String, String> fileIdNameMap = new Map<String, String>();
        String accessToken;
        List<GD_User_Data__mdt> userRecordList = [
            									 SELECT 
            										Id, MasterLabel, DeveloperName, clientId__c, clientSecretKey__c, RefreshToken__c, AccessToken__c, UserId__c, UserName__c 
            									 FROM
            									 	GD_User_Data__mdt 
            									 WHERE 
            										UserId__c = :userId 
            									 LIMIT 1
        										 ];

        if (!userRecordList.isEmpty()) {
            String ac = userRecordList[0].AccessToken__c;
            accessToken = EncodingUtil.urlEncode(ac, 'UTF-8');
        }

        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint('https://www.googleapis.com/drive/v3/files');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');
        Http http = new Http();
        HttpResponse response = http.send(request);
		System.debug('Response filefolders: '+response.getbody());
        if (response.getStatusCode() == 200 && response.getBody() != null) {
            googleDriveDataMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

            if (googleDriveDataMap != null && googleDriveDataMap.containsKey('files')) {
                List<Object> filesList = (List<Object>) googleDriveDataMap.get('files');

                if (filesList != null) {
                    // Iterate through each file object
                    for (Object file : filesList) {
                        Map<String, Object> fileInfo = (Map<String, Object>) file;
                        // Check if 'id' and 'name' attributes exist
                        if (fileInfo.containsKey('id') && fileInfo.containsKey('name')) {
                            // Get the ID and name values
                            String id = (String) fileInfo.get('id');
                            String name = (String) fileInfo.get('name');

                            // Store ID-name pair in the map
                            fileIdNameMap.put(id, name);
                        }
                    }
                }
            }
        }

        return fileIdNameMap;
    }
	
/*
    *********************************************************
    @Method Name    : deleteFileContentMethod
    @author         : Bhawana Sharma
    @description    : deleteFileContentMethod method is used to delete Google Drive files. 
    @param          :
    @return         : Boolean
    ********************************************************
*/	
	@AuraEnabled(cacheable = true)
    public static Boolean deleteFileContentMethod(String fileId, String userId) {
        Boolean isDeleted = false;
        Map<String, Object> googleDriveDataMap = new Map<String, Object>();
        String accessToken;
        List<GD_User_Data__mdt> userRecordList = [
                                                 SELECT 
            										Id, MasterLabel, DeveloperName, clientId__c, clientSecretKey__c, RefreshToken__c, AccessToken__c, UserId__c, UserName__c 
                                                 FROM 
            										GD_User_Data__mdt 
                                                 WHERE 
            										UserId__c = :userId 
                                                 LIMIT 1
                                            	 ];

        if (!userRecordList.isEmpty()) {
            String ac = userRecordList[0].AccessToken__c;
            accessToken = EncodingUtil.urlEncode(ac, 'UTF-8');
        }

        HttpRequest request = new HttpRequest();
        request.setMethod('DELETE');
        request.setEndpoint('https://www.googleapis.com/drive/v3/files/' + fileId);
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');
        Http http = new Http();
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 204) {
            isDeleted = true;
        }

        return isDeleted;
    }
/*
    *********************************************************
    @Method Name    : uploadFolderMethod
    @author         : Bhawana Sharma
    @description    : uploadFolderMethod method is used to upload folders on Google Drive 
    @param          :
    @return         : 
    ********************************************************
*/	@AuraEnabled(Cacheable = true)
    public static Boolean uploadFolderMethod(String userId,String folderName) {
        System.debug('folderName: '+folderName);
        Map<String, Object> googleDriveDataMap = new Map<String, Object>();
        Boolean isAddFolder = false;
        String accessToken;
        List<GD_User_Data__mdt> userRecordList = [
                                                 SELECT 
            										Id, MasterLabel, DeveloperName, clientId__c, clientSecretKey__c, RefreshToken__c, AccessToken__c, UserId__c, UserName__c 
                                                 FROM 
            										GD_User_Data__mdt 
                                                 WHERE 
            										UserId__c = :userId 
                                                 LIMIT 1
                                            	 ];

        if (!userRecordList.isEmpty()) {
            String ac = userRecordList[0].AccessToken__c;
            accessToken = EncodingUtil.urlEncode(ac, 'UTF-8');
        }
        
		system.debug('accesst0ken: '+accessToken);
        String body = '{"name" : "'+ folderName +'","mimeType" : "application/vnd.google-apps.folder"}';
		system.debug('body: '+body);
        if(folderName!=null&&folderName!=''){
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://www.googleapis.com/drive/v3/files');
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer ' + accessToken);
            request.setHeader('Content-Type', 'application/json');
            request.setBody(body);
            Http http = new Http();
            HttpResponse response = http.send(request);
            /*String body = JSON.serialize(new Map<String, Object>{
                'name' => folderName,
                'mimeType' => 'application/vnd.google-apps.folder'
            });*/
            
            system.debug('response: '+response.getbody());
            if (response.getBody() != null) {
                isAddFolder = true;
            }
            else{
                isAddFolder = false;
            }
            }
        
        return isAddFolder;
    }
/*
    *********************************************************
    @Method Name    : uploadSpecificFolderMethod
    @author         : Bhawana Sharma
    @description    : uploadSpecificFolderMethod method is used to upload folders on individual folders in Google Drive 
    @param          :
    @return         : 
    ********************************************************
*/
    @AuraEnabled(Cacheable = true)
    public static Boolean uploadSpecificFolderMethod(String userId,String fileId,String folderName) {
        Map<String, Object> googleDriveDataMap = new Map<String, Object>();
        String accessToken;
        Boolean isAddFolder = false;
        List<GD_User_Data__mdt> userRecordList = [
                                                 SELECT 
            										Id, MasterLabel, DeveloperName, clientId__c, clientSecretKey__c, RefreshToken__c, AccessToken__c, UserId__c, UserName__c 
                                                 FROM 
            										GD_User_Data__mdt 
                                                 WHERE 
            										UserId__c = :userId 
                                                 LIMIT 1
                                            	 ];

        if (!userRecordList.isEmpty()) {
            String ac = userRecordList[0].AccessToken__c;
            accessToken = EncodingUtil.urlEncode(ac, 'UTF-8');
        }
        
		system.debug('accesst0ken: '+accessToken);
        String body = '{"title" : "'+ folderName +'","mimeType" : "application/vnd.google-apps.folder","parents" : [{"kind" : "drive#file","id" : "'+fileId+'"}]}';
		system.debug('body: '+body);
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://www.googleapis.com/drive/v2/files');
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');
        request.setBody(body);
        Http http = new Http();
        HttpResponse response = http.send(request);
            /*String body = JSON.serialize(new Map<String, Object>{
                'name' => folderName,
                'mimeType' => 'application/vnd.google-apps.folder'
            });*/
            
            system.debug('response: '+response.getbody());
            if (response.getBody() != null) {
                isAddFolder = true;
            }
            else{
                isAddFolder = false;
            }
        return isAddFolder; 
    }
/*
    *********************************************************
    @Method Name    : ReNameFileContentMethod
    @author         : Bhawana Sharma
    @description    : ReNameFileContentMethod method is used to rename files on Google Drive 
    @param          :
    @return         : Boolean
    ********************************************************
*/
	@AuraEnabled(Cacheable = true)
    public static Boolean ReNameFileContentMethod(String fileId, String name, String userId) {
        Boolean isRename = false;
        String newName = '{"name":"' + name + '",';
        String body = newName + '"canRename":true}';
        Map<String, Object> googleDriveDataMap = new Map<String, Object>();
        String accessToken;
        List<GD_User_Data__mdt> userRecordList = [
                                                 SELECT 
            										Id, MasterLabel, DeveloperName, clientId__c, clientSecretKey__c, RefreshToken__c, AccessToken__c, UserId__c, UserName__c 
                                                 FROM 
            										GD_User_Data__mdt 
                                                 WHERE 
            										UserId__c = :userId 
                                                 LIMIT 1
                                            	 ];

        if (!userRecordList.isEmpty()) {
            String ac = userRecordList[0].AccessToken__c;
            accessToken = EncodingUtil.urlEncode(ac, 'UTF-8');
        }

        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://www.googleapis.com/drive/v3/files/' + fileId);
        request.setMethod('PATCH');
        request.setBody(body);
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');
        Http http = new Http();
        HttpResponse response = http.send(request);
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

        if (responseMap != null) {
            isRename = true;
        }

        return isRename;
    }
/*
    *********************************************************
    @Method Name    : previewFileContentMethod
    @author         : Bhawana Sharma
    @description    : previewFileContentMethod method is used to preview files on Google Drive in Salesforce
    @param          :
    @return         : Boolean
    ********************************************************
*/
	@AuraEnabled(cacheable = true)
    public static Boolean previewFileContentMethod(String fileId, String userId) {
        Boolean isfilePreview = false;
        Map<String, Object> googleDriveDataMap = new Map<String, Object>();
        String accessToken;
        List<GD_User_Data__mdt> userRecordList = [
                                                 SELECT 
            										Id, MasterLabel, DeveloperName, clientId__c, clientSecretKey__c, RefreshToken__c, AccessToken__c, UserId__c, UserName__c 
                                                 FROM 
            										GD_User_Data__mdt 
                                                 WHERE 
            										UserId__c = :userId 
                                                 LIMIT 1
                                            	 ];

        if (!userRecordList.isEmpty()) {
            String ac = userRecordList[0].AccessToken__c;
            accessToken = EncodingUtil.urlEncode(ac, 'UTF-8');
        }

        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint('https://www.googleapis.com/drive/v3/files/' + fileId);
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');
        Http http = new Http();
        HttpResponse response = http.send(request);

        isfilePreview = true;
        return isfilePreview;
    }
/*
    *********************************************************
    @Method Name    : getFolderContentMethod
    @author         : Bhawana Sharma
    @description    : getFolderContentMethod method is used to fetch folder data from Google Drive in Salesforce
    @param          :
    @return         : List<String>
    ********************************************************
*/
    @AuraEnabled(cacheable = true)
    public static List<String> getFolderContentMethod(String folderId, String userId) {
        Boolean isfilePreview = false;
        Map<String, Object> googleDriveDataMap = new Map<String, Object>();
        Map<String, Object> filesDataMap = new Map<String, Object>();
        List<String> childFileIdList = new List<String>();
        String accessToken;
        List<GD_User_Data__mdt> userRecordList = [
                                                 SELECT 
            										Id, MasterLabel, DeveloperName, clientId__c, clientSecretKey__c, RefreshToken__c, AccessToken__c, UserId__c, UserName__c 
                                                 FROM 
            										GD_User_Data__mdt 
                                                 WHERE 
            										UserId__c = :userId 
                                                 LIMIT 1
                                            	 ];

        if (!userRecordList.isEmpty()) {
            String ac = userRecordList[0].AccessToken__c;
            accessToken = EncodingUtil.urlEncode(ac, 'UTF-8');
        }

        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint('https://www.googleapis.com/drive/v2/files/'+folderId+'/children');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setHeader('Content-length', '0');
        request.setTimeout(60*1000);
        Http http = new Http();
        HttpResponse response = http.send(request);
		System.debug('Response folder is:'+response.getBody());
        if (response.getStatusCode() == 200 && response.getBody() != null) {
            googleDriveDataMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

            if (googleDriveDataMap != null && googleDriveDataMap.containsKey('items')) {
                List<Object> filesList = (List<Object>) googleDriveDataMap.get('items');
				System.debug('filesList is: '+filesList);
                if (filesList != null) {
                    // Iterate through each file object
                    for (Object file : filesList) {
                        Map<String, Object> fileInfo = (Map<String, Object>) file;
                        // Check if 'id' and 'name' attributes exist
                        if (fileInfo.containsKey('id') && fileInfo.containsKey('childLink')) {
                            // Get the ID and name values
                            String id = (String) fileInfo.get('id');
                            String childLink = (String) fileInfo.get('childLink');

                            // Store ID-name pair in the map
                            childFileIdList.add(id);
                            //filesDataMap.put(id, file);
                            //System.debug('filesDataMap each item: '+id+file);
                        }
                    }
                }
            }
        }
		//System.debug('filesDataMap file/folder info: '+filesDataMap);
        return childFileIdList;
        
    }
/*
    *********************************************************
    @Method Name    : getFileContentMethod
    @author         : Bhawana Sharma
    @description    : getFileContentMethod method is used to fetch files data of the specific folder from
					  Google Drive in Salesforce
    @param          :
    @return         : GoogleDriveFile
    ********************************************************
*/    
    public static GoogleDriveFile getFileContentMethod(String fileId,String userId){
        GoogleDriveFile googleDriveFile = new GoogleDriveFile();
        List<Object> googleDriveDataList = new List<Object>();
        Map<String, Object> googleDriveDataMap = new Map<String, Object>();
        Map<String, Object> filesDataMap = new Map<String, Object>();
        Map<String, String> fileIdNameMap = new Map<String, String>();
        String accessToken;
        List<GD_User_Data__mdt> userRecordList = [
            									 SELECT 
            										Id, MasterLabel, DeveloperName, clientId__c, clientSecretKey__c, RefreshToken__c, AccessToken__c, UserId__c, UserName__c 
            									 FROM
            									 	GD_User_Data__mdt 
            									 WHERE 
            										UserId__c = :userId 
            									 LIMIT 1
        										 ];

        if (!userRecordList.isEmpty()) {
            String ac = userRecordList[0].AccessToken__c;
            accessToken = EncodingUtil.urlEncode(ac, 'UTF-8');
        }

        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint('https://www.googleapis.com/drive/v3/files/'+fileId);
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');
        Http http = new Http();
        HttpResponse response = http.send(request);
		System.debug('Response filefolders: '+response.getbody());
        if (response.getStatusCode() == 200 && response.getBody() != null) {
             GoogleDriveFile = (GoogleDriveFile) JSON.deserialize(response.getBody(), GoogleDriveFile.class);            
        }
        System.debug('googleDriveFile: '+googleDriveFile);
        return googleDriveFile;
    }
/*
    *********************************************************
    @Method Name    : GoogleDriveFile
    @author         : Bhawana Sharma
    @description    : GoogleDriveFile class is a wrapper class used to store files data of the specific folder from
					  Google Drive in Salesforce
    @param          :
    @return         : 
    ********************************************************
*/     
    public class GoogleDriveFile {
        
        public String kind { get; set; }
        public String id { get; set; }
        public String name { get; set; }
        public String mimeType { get; set; }
    }

}
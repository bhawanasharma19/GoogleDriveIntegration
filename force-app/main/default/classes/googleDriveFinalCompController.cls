/*
*********************************************************
Apex Class Name    : googleDriveFinalCompController
Created Date       : May 16, 2024
@description       : This class is used for getting propertes from LWC Component and call GoogleDriveApi2 and GoogleDriveAuthCode2 classes..
@author            : Bhawana Sharma
Modification Log:
Ver   Date         Author                               Modification
2.0   21-05-2024   Bhawana Sharma                      Second Version
*********************************************************
*/
public class googleDriveFinalCompController {
/*
    *********************************************************
    @Method Name    : checkNewUser
    @author         : Bhawana Sharma
    @description    : checkNewUser method is used to check User Record in GD_User_Data__mdt Custom Metadata. 
    @param          :
    @return         : Boolean
    ********************************************************
*/
    @AuraEnabled(Cacheable=true)
	public static Boolean checkNewUser(String userId){
    	Boolean isNewUser = false;
		List<GD_User_Data__mdt> userRecordList = [
                                                 SELECT 
                									Id, MasterLabel, DeveloperName, clientId__c, clientSecretKey__c, RefreshToken__c, AccessToken__c, UserId__c, UserName__c 
                                                 FROM 
                									GD_User_Data__mdt 
                                                 WHERE
                									UserId__c = :userId 
                                                 LIMIT 1
                                                 ];
        if((userRecordList.isEmpty())||(!userRecordList.isEmpty()&&(userRecordList[0].clientId__c==null)&&(userRecordList[0].clientSecretKey__c==null))){
        	isNewUser = true;
            }
            else {
                isNewUser = false;
            }
        return isNewUser;
    }
/*
    *********************************************************
    @Method Name    : authenticateUser
    @author         : Bhawana Sharma
    @description    : authenticateUser method is used to authenticate User Record in GD_User_Data__mdt Custom Metadata. 
    @param          :
    @return         : Map<String, String> - fileIdNameMap
    ********************************************************
*/
    @AuraEnabled(Cacheable=true)
	public static Boolean authenticateUser(String userId){
    	Boolean isauthenticate = false;
		List<GD_User_Data__mdt> userRecordList = [
                                                 SELECT 
                									Id, MasterLabel, DeveloperName, clientId__c, clientSecretKey__c, RefreshToken__c, AccessToken__c, UserId__c, UserName__c 
                                                 FROM 
                									GD_User_Data__mdt 
                                                 WHERE
                									UserId__c = :userId 
                                                 LIMIT 1
                                                 ];
        if(!userRecordList.isEmpty()&&(userRecordList[0].clientId__c!=null)&&(userRecordList[0].clientSecretKey__c!=null)&&(userRecordList[0].AccessToken__c==null)&&(userRecordList[0].RefreshToken__c==null)){
        	isauthenticate = true;
            }
            else{
                isauthenticate = false;
            }
        return isauthenticate;
    }
/*
    *********************************************************
    @Method Name    : createUserMetadata
    @author         : Bhawana Sharma
    @description    : createUserMetadata method is used to create User Record in GD_User_Data__mdt Custom Metadata. 
    @param          :
    @return         : Boolean
    ********************************************************
*/
	@AuraEnabled(Cacheable=true)
    public static Boolean createUserMetadata(String userId, String clientKey, String clientSecret) {
        Boolean isNewUser = false;
        try {
            List<GD_User_Data__mdt> userRecordList = [
                                                      SELECT 
                											Id, MasterLabel, DeveloperName, clientId__c, clientSecretKey__c, RefreshToken__c, AccessToken__c, UserId__c, UserName__c 
                                                      FROM 
                											GD_User_Data__mdt 
                                                      WHERE
                											UserId__c = :userId 
                                                      LIMIT 1
                                                     ];

            String randomNumber = String.valueOf(Math.round(Math.random() * 100000));

            // New User Scenario
            if (userRecordList.isEmpty() && (userId != null && clientKey != null && clientSecret != null)) {
                // Create a new instance of CustomMetadata
                Metadata.CustomMetadata mdataInstance = new Metadata.CustomMetadata();
                mdataInstance.fullName = 'GD_User_Data__mdt.unique' + randomNumber;
                mdataInstance.label = userId;

                // Create metadata fields and set their values
                Metadata.CustomMetadataValue userIdField = new Metadata.CustomMetadataValue();
                userIdField.field = 'UserId__c';
                userIdField.value = userId;

                Metadata.CustomMetadataValue clientKeyField = new Metadata.CustomMetadataValue();
                clientKeyField.field = 'clientId__c';
                clientKeyField.value = clientKey;

                Metadata.CustomMetadataValue clientSecretField = new Metadata.CustomMetadataValue();
                clientSecretField.field = 'clientSecretKey__c';
                clientSecretField.value = clientSecret;

                // Add fields to the custom metadata record
                mdataInstance.values.add(userIdField);
                mdataInstance.values.add(clientKeyField);
                mdataInstance.values.add(clientSecretField);

                // Deploy the metadata
                Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
                mdContainer.addMetadata(mdataInstance);

                Metadata.Operations.enqueueDeployment(mdContainer, null);

                isNewUser = true;
            }
            // Existing User
            else if (!userRecordList.isEmpty() && (userId != null && clientKey != null && clientSecret != null) && 
                     (userRecordList[0].clientId__c==null && userRecordList[0].clientSecretKey__c==null)) {
                // Create a new instance of CustomMetadata
                Metadata.CustomMetadata mdataInstance = new Metadata.CustomMetadata();
                mdataInstance.fullName = 'GD_User_Data__mdt.' + userRecordList[0].DeveloperName; // Update
                mdataInstance.label = userRecordList[0].MasterLabel;

                // Create metadata fields and set their values
                Metadata.CustomMetadataValue accessTokenField = new Metadata.CustomMetadataValue();
                accessTokenField.field = 'AccessToken__c';
                accessTokenField.value = null;

                Metadata.CustomMetadataValue refreshTokenField = new Metadata.CustomMetadataValue();
                refreshTokenField.field = 'RefreshToken__c';
                refreshTokenField.value = null;

                Metadata.CustomMetadataValue clientKeyField = new Metadata.CustomMetadataValue();
                clientKeyField.field = 'clientId__c';
                clientKeyField.value = clientKey;

                Metadata.CustomMetadataValue clientSecretField = new Metadata.CustomMetadataValue();
                clientSecretField.field = 'clientSecretKey__c';
                clientSecretField.value = clientSecret;

                // Add fields to the custom metadata record
                mdataInstance.values.add(accessTokenField);
                mdataInstance.values.add(refreshTokenField);
                mdataInstance.values.add(clientKeyField);
                mdataInstance.values.add(clientSecretField);

                // Deploy the metadata
                Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
                mdContainer.addMetadata(mdataInstance);

                Metadata.Operations.enqueueDeployment(mdContainer, null);
                isNewUser = true; // user already exists 
            }
            else{
                isNewUser = false;
            }
            return isNewUser;
            
        } catch (Exception e) {
            if(!test.isRunningTest()) {
                throw new AuraHandledException('Failed to create user metadata: ' + e.getMessage());
            }
            return isNewUser;
        }
    }
/*
    *********************************************************
    @Method Name    : handleAuthenticateUser
    @author         : Bhawana Sharma
    @description    : handleAuthenticateUser method is used to Authenticate user first Time using its Client_Id and Client_Secret Stored in Custom Metadata. 
    @param          :
    @return         : String
    ********************************************************
*/    
    @AuraEnabled(Cacheable=true)
    public static String handleAuthenticateUser(String userId) {
        String authURL;
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
            if ((userRecordList[0].clientId__c != null && userRecordList[0].clientSecretKey__c != null) && 
                (userRecordList[0].AccessToken__c == null && userRecordList[0].RefreshToken__c == null)) {
                authURL = GoogleDriveAuthCode2.createAuthURL(userRecordList[0].clientId__c);
            } else if ((userRecordList[0].clientId__c != null && userRecordList[0].clientSecretKey__c != null) && 
                       (userRecordList[0].RefreshToken__c != null)) {
                authURL = 'alreadyauthorized';
            }
        } else if (userRecordList.isEmpty()) {
            authURL = null;
        }
        return authURL;
    }
    
    @AuraEnabled(Cacheable=true)
    public static Boolean handleAccessTokenFirstTime(String code, String userId) {
        Boolean isAuthorized = false;
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
            if ((userRecordList[0].clientId__c != null && userRecordList[0].clientSecretKey__c != null) && 
                (userRecordList[0].AccessToken__c == null && userRecordList[0].RefreshToken__c == null)) {
                isAuthorized = GoogleDriveAuthCode2.getFirstAccessToken(code, userId, userRecordList[0].clientId__c, userRecordList[0].clientSecretKey__c);
            }
        }
        return isAuthorized;
    }
/*
    *********************************************************
    @Method Name    : checkExpiryTime
    @author         : Bhawana Sharma
    @description    : checkExpiryTime method is used to Compare Expiry time with Current time and if it is about to expire then it will call regenerateAccessToken to change it.
    @param          :
    @return         : 
    ********************************************************
*/
    @AuraEnabled(Cacheable = true)
    public static void checkExpiryTime(String userId) {
        // Query the records for the specified userId
        List<GD_User_Data__mdt> userRecordList = [
                                                 SELECT
            										Id, MasterLabel, DeveloperName, clientId__c, clientSecretKey__c, Expiry_time__c, RefreshToken__c, AccessToken__c, UserId__c, UserName__c 
                                                 FROM
            										GD_User_Data__mdt 
                                                 WHERE
            										UserId__c = :userId
                                                 LIMIT 1
                                            	];

        // Get the current system time
        Datetime currentTime = Datetime.now();
        Datetime expiryTime = Datetime.valueOf(userRecordList[0].Expiry_time__c);

        // Check if the expiry time is equal to the current system time
        if (!userRecordList.isEmpty() && expiryTime != null && expiryTime <= currentTime) {
            GoogleDriveAuthCode2.regenerateAccessToken(userId);        
        }
    }
    @AuraEnabled(cacheable = true)
    public static Map<String, Object> getFolderfiles(String folderId, String userId) {
        Map<String, Object> folderfileIdfiledataMap = new Map<String, Object>();
        List<String> fileIdList = GoogleDriveApi2.getFolderContentMethod(folderId, userId);
        
        for (String fileId : fileIdList) {
            GoogleDriveApi2.GoogleDriveFile eachFile = GoogleDriveApi2.getFileContentMethod(fileId, userId);
            if (eachFile != null) {
                Map<String, String> fileData = new Map<String, String>();
            	fileData.put('id', eachFile.id);
            	fileData.put('kind', eachFile.kind);
            	fileData.put('mimeType', eachFile.mimeType);
            	fileData.put('name', eachFile.name);
                
                folderfileIdfiledataMap.put(fileId, fileData);
            }
        }
        
        System.debug('folderfileIdfiledataMap: ' + folderfileIdfiledataMap);
        return folderfileIdfiledataMap;
    }

	
}
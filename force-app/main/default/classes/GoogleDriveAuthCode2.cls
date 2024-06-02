/*
*********************************************************
Apex Class Name    : GoogleDriveAuthCode2
Created Date       : May 17, 2024
@description       : This class is used for getting Authorization URL from Google Drive and getting Access Token.
@author            : Bhawana Sharma
Modification Log:
Ver   Date         Author                               Modification
2.0   22-05-2024   Bhawana Sharma                      Second Version
*********************************************************
*/
public class GoogleDriveAuthCode2 {
    private static String redirectUri = 'https://algoworks16-dev-ed.develop.my.site.com/gdintegration/s/';
    private static String authUrl = 'https://accounts.google.com/o/oauth2/v2/auth';
    private static String scope = 'https://www.googleapis.com/auth/drive https://www.googleapis.com/auth/drive.apps.readonly https://www.googleapis.com/auth/drive.file https://www.googleapis.com/auth/drive.metadata https://www.googleapis.com/auth/drive.metadata.readonly https://www.googleapis.com/auth/drive.photos.readonly https://www.googleapis.com/auth/drive.readonly';
    private static String tokenUrl = 'https://accounts.google.com/o/oauth2/token';
    
    /*@testVisible 
    public static GD_User_Data__mdt[] getAllMetadata() {
        return [ SELECT 
                       Id, MasterLabel, DeveloperName, clientId__c, clientSecretKey__c, RefreshToken__c, AccessToken__c, UserId__c, UserName__c 
                 FROM 
                       GD_User_Data__mdt ]; 
        ];
    }*/
/*
    *********************************************************
    @Method Name    : createAuthURL
    @author         : Bhawana Sharma
    @description    : createAuthURL method is used to generate Authorization URL. 
    @param          :
    @return         : String
    ********************************************************
*/
    public static String createAuthURL(String clientKey) {
        String key = EncodingUtil.urlEncode(clientKey, 'UTF-8');
        String uri = EncodingUtil.urlEncode(redirectUri, 'UTF-8');
        String encodedScope = EncodingUtil.urlEncode(scope, 'UTF-8');

        String authuri = '';
        authuri = authUrl + '?' +
            'client_id=' + key +
            '&response_type=code' +
            '&scope=' + encodedScope +
            '&redirect_uri=' + uri +
            '&access_type=offline' +
            '&prompt=consent';
        return authuri;
    }
/*
    *********************************************************
    @Method Name    : getFirstAccessToken
    @author         : Bhawana Sharma
    @description    : getFirstAccessToken method is used to get Access Token. 
    @param          :
    @return         : boolean
    ********************************************************
*/
    public static boolean getFirstAccessToken(String code, String userId, String clientKey, String clientSecret) {
        Datetime expiryTime = Datetime.now().addMinutes(50);

        String mycode = EncodingUtil.urlDecode(code, 'UTF-8');
        Boolean isAccessToken = false;

        // Getting access token from Google
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(tokenUrl);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        String messageBody = 'code=' + mycode + '&client_id=' + clientKey +
            '&client_secret=' + clientSecret +
            '&redirect_uri=' + redirectUri +
            '&grant_type=authorization_code';
        req.setHeader('Content-Length', String.valueOf(messageBody.length()));
        req.setBody(messageBody);
        req.setTimeout(60 * 1000);

        Http callout = new Http();
        HttpResponse response = callout.send(req);
        String responseText = response.getBody();
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseText);
        String token = String.valueOf(responseMap.get('access_token'));
        String refreshToken = String.valueOf(responseMap.get('refresh_token'));

        // Update token in custom metadata
        List<GD_User_Data__mdt> userRecordList = [
                                                 SELECT 
            										Id, MasterLabel, DeveloperName, clientId__c, clientSecretKey__c, Expiry_time__c, RefreshToken__c, AccessToken__c, UserId__c, UserName__c 
                                                 FROM
            										GD_User_Data__mdt 
                                                 WHERE	
            										UserId__c = :userId
                                                 LIMIT 1
                                             	 ];
        
        if (!userRecordList.isEmpty() && (userId != null && clientKey != null && clientSecret != null) && (token != null && refreshToken != null)) {
            // Create a new instance of CustomMetadata
            Metadata.CustomMetadata mdataInstance = new Metadata.CustomMetadata();
            mdataInstance.fullName = 'GD_User_Data__mdt.' + userRecordList[0].DeveloperName;
            mdataInstance.label = userRecordList[0].MasterLabel;

            // Create metadata fields and set their values
            Metadata.CustomMetadataValue accessTokenField = new Metadata.CustomMetadataValue();
            accessTokenField.field = 'AccessToken__c';
            accessTokenField.value = token;

            Metadata.CustomMetadataValue refreshTokenField = new Metadata.CustomMetadataValue();
            refreshTokenField.field = 'RefreshToken__c';
            refreshTokenField.value = refreshToken;

            Metadata.CustomMetadataValue expiryTimeField = new Metadata.CustomMetadataValue();
            expiryTimeField.field = 'Expiry_time__c';
            expiryTimeField.value = expiryTime;

            // Add fields to the custom metadata record
            mdataInstance.values.add(accessTokenField);
            mdataInstance.values.add(refreshTokenField);
            mdataInstance.values.add(expiryTimeField);

            isAccessToken = true;

            // Deploy the metadata
            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            mdContainer.addMetadata(mdataInstance);

            Metadata.Operations.enqueueDeployment(mdContainer, null);
        }
        
        return isAccessToken;
    }
/*
    *********************************************************
    @Method Name    : regenerateAccessToken
    @author         : Bhawana Sharma
    @description    : regenerateAccessToken method is used to get Access Token once it is expired. 
    @param          :
    @return         : 
    ********************************************************
*/
  public static void regenerateAccessToken(String userId) {
        String refreshToken;
        String clientKey;
        String clientSecret;
        Datetime expiryTime = Datetime.now().addMinutes(50);

        List<GD_User_Data__mdt> userRecordList = [
                                                 SELECT
            										Id, MasterLabel, DeveloperName, clientId__c, clientSecretKey__c, Expiry_time__c, RefreshToken__c, AccessToken__c, UserId__c, UserName__c 
                                                 FROM
            										GD_User_Data__mdt 
                                                 WHERE
            										UserId__c = :userId
                                                 LIMIT 1
                                            	];

        if (!userRecordList.isEmpty()) {
            refreshToken = userRecordList[0].RefreshToken__c;
            clientKey = userRecordList[0].clientId__c;
            clientSecret = userRecordList[0].clientSecretKey__c;
        }

        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(tokenUrl);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        String messageBody = 'client_id=' + EncodingUtil.urlEncode(clientKey, 'UTF-8') +
            '&client_secret=' + EncodingUtil.urlEncode(clientSecret, 'UTF-8') +
            '&redirect_uri=' + EncodingUtil.urlEncode(redirectUri, 'UTF-8') +
            '&refresh_token=' + EncodingUtil.urlEncode(refreshToken, 'UTF-8') +
            '&grant_type=refresh_token';

        req.setBody(messageBody);
        req.setTimeout(60 * 1000);

        Http callout = new Http();
        HttpResponse response = callout.send(req);
        String responseText = response.getBody();
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseText);
        String token = (String) responseMap.get('access_token');

        // Update token in custom metadata
        if (!userRecordList.isEmpty() && (userId != null && clientKey != null && clientSecret != null) && (refreshToken != null)) {
            // Create a new instance of CustomMetadata
            Metadata.CustomMetadata mdataInstance = new Metadata.CustomMetadata();
            mdataInstance.fullName = 'GD_User_Data__mdt.' + userRecordList[0].DeveloperName;
            mdataInstance.label = userRecordList[0].MasterLabel;

            // Create metadata fields and set their values
            Metadata.CustomMetadataValue accessTokenField = new Metadata.CustomMetadataValue();
            accessTokenField.field = 'AccessToken__c';
            accessTokenField.value = token;

            Metadata.CustomMetadataValue expiryTimeField = new Metadata.CustomMetadataValue();
            expiryTimeField.field = 'Expiry_time__c';
            expiryTimeField.value = expiryTime;

            // Add fields to the custom metadata record
            mdataInstance.values.add(accessTokenField);
            mdataInstance.values.add(expiryTimeField);

            // Deploy the metadata
            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            mdContainer.addMetadata(mdataInstance);

            Metadata.Operations.enqueueDeployment(mdContainer, null);
        }
    }
}
global class GoogleDriveAuthCode {
    /*
    private static String key = '1074699021479-oip60sqcr4m2ue14ki36ai9451e9s3j1.apps.googleusercontent.com';
    private static String clientSecret = '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';
    //private static String redirectUri = 'https://algoworks16-dev-ed--c.develop.vf.force.com/apex/RedirectHandler';
    //private static String redirectUri = 'https://algoworks16-dev-ed.develop.lightning.force.com';
    private static String redirectUri = 'https://algoworks16-dev-ed.develop.my.site.com/gdintegration/s/';
    
    private static String authUrl = 'https://accounts.google.com/o/oauth2/v2/auth';
    private static String scope = 'https://www.googleapis.com/auth/drive https://www.googleapis.com/auth/drive.apps.readonly https://www.googleapis.com/auth/drive.file https://www.googleapis.com/auth/drive.metadata https://www.googleapis.com/auth/drive.metadata.readonly https://www.googleapis.com/auth/drive.photos.readonly https://www.googleapis.com/auth/drive.readonly';
    //private static String scope = 'https://www.googleapis.com/auth/drive https://www.googleapis.com/auth/drive.file https://www.googleapis.com/auth/drive.metadata.readonly https://www.googleapis.com/auth/drive.readonly';
    private static string tokenUrl='https://accounts.google.com/o/oauth2/token';
    
    public static String createAuthURL(){
        String key = EncodingUtil.urlEncode(key,'UTF-8');
        String uri = EncodingUtil.urlEncode(redirectUri,'UTF-8');
        String encodedScope = EncodingUtil.urlEncode(scope, 'UTF-8');
        
        String authuri = '';
        authuri = authUrl+'?'+
            'client_id='+key+
            '&response_type=code'+
            '&scope='+encodedScope+
            '&redirect_uri='+uri+
            '&access_type=offline'+
           	'&prompt=consent';
        System.debug('authuri: '+authuri);
        return authuri;
    }
    @AuraEnabled
    public static boolean getAccessToken(String code)
    {
            //Getting access token from google
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint(tokenUrl);
            req.setHeader('content-type', 'application/x-www-form-urlencoded');
            
            String messageBody ='code='+code+'&client_id='+key+
                '&client_secret='+clientSecret+
                '&redirect_uri='+redirectUri+
                '&grant_type=authorization_code';
            req.setHeader('Content-length', String.valueOf(messageBody.length()));
            req.setBody(messageBody);
            req.setTimeout(60*1000);
            system.debug('messageBody:'+messageBody);
            
            Http callout = new Http();
            String responseText;
            HttpResponse response = callout.send(req);
            responseText = response.getBody();
            system.debug('responseBody:'+responseText);
            Map<String,object> responseMap =(Map<String,object>)JSON.deserializeUntyped(responseText) ;  
            String token =  String.valueOf(responseMap.get('access_token'));
            system.debug('token:'+token);
            
            //Update token in custom metadata 
            return true;
        }
      */ 
}
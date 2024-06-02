public class GoogleAuthService {
    private static string key = '1074699021479-oip60sqcr4m2ue14ki36ai9451e9s3j1.apps.googleusercontent.com';
    private Static string secert = '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';
    private Static string redirect_uri = 'https://algoworks16-dev-ed.develop.my.salesforce.com/services/authcallback/Google_Drive_Auth';    
    private static string authUrl='https://accounts.google.com/o/oauth2/v2/auth';
    private static string scope='https://www.googleapis.com/auth/drive';
    private static string tokenUrl='https://accounts.google.com/o/oauth2/token';
    private string authcode;
    private string access_token;
    public GoogleAuthService(){
        
    }
    public PageReference DriveAuth(){
        PageReference pg = new PageReference(new AuthURICodeget(key,redirect_uri).AuthorizationURI);
        return pg;
    }
    
    @AuraEnabled
    public static String createAuthURL() {
        String key = EncodingUtil.urlEncode(key,'UTF-8');
        String uri = EncodingUtil.urlEncode(redirect_uri,'UTF-8');
        String authuri = '';
        authuri = authUrl+'?'+
            'client_id='+key+
            '&response_type=code'+
            '&scope='+scope+
            '&redirect_uri='+uri+
            '&access_type=offline';
        system.debug('Authorization uri: '+authuri);
        return authuri;
    }
    
    @AuraEnabled
    public static void getAccessToken(String code)
    {
        //Getting access token from google
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(tokenUrl);
        req.setHeader('content-type', 'application/x-www-form-urlencoded');
        
        String messageBody ='code='+code+
            '&client_id='+key+
            '&client_secret='+secert+
            '&redirect_uri='+redirect_uri+
            '&grant_type=authorization_code';
        req.setHeader('Content-length', String.valueOf(messageBody.length()));
        req.setBody(messageBody);
        req.setTimeout(60*1000);
        
        Http callout = new Http();
        String responseText;
        HttpResponse response = callout.send(req);
        responseText = response.getBody();
        Map<String,object> responseMap =(Map<String,object>)JSON.deserializeUntyped(responseText) ;  
        String token =  String.valueOf(responseMap.get('access_token'));
        
        System.debug('token: '+token);
    }
}
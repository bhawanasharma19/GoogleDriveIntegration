global class AuthURICodeget {
    global string AuthorizationURI='';
    global AuthURICodeget(String Clientkey,String redirect_uri){
        String key = EncodingUtil.urlEncode(Clientkey,'UTF-8');
        String uri = EncodingUtil.urlEncode(redirect_uri,'UTF-8');
        String authuri = 'https://accounts.google.com/o/oauth2/v2/auth?'+
            'client_id'+key+
            '&response_type=code'+
            '&scope=https://www.googleapis.com/auth/drive'+
            '&redirect_uri='+redirect_uri+
            '&state=security_token%3D138r5719ru3e1%26url%3Dhttps%3A%2F%2Foauth2-login-demo.example.com%2FmyHome&'+
            '&login_hint=jsmith@example.com&'+
            'access_type=offline';
 
    }

}
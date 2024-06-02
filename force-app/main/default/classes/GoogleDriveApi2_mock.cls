@isTest
public class GoogleDriveApi2_mock implements HttpCalloutMock {


    
    public HTTPResponse respond(HTTPRequest req){    
        
    	// Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"code":"ascwfsd","files":[{"Name":"testname","id":"sndkcnskjb"}]}');
        res.setStatusCode(200);
        return res;
    }

}
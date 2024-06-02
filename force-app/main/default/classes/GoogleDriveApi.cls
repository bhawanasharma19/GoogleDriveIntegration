//API Class
public class GoogleDriveApi {
    public static String MIME_TYPE_FOLDER = 'application/vnd.google-apps.folder';
    //variables
    private static String fields{get;set;}
    private static Integer maxResults{get;set;}
    private static String orderBy{get;set;}
    

    public static Map<String, String> getFilesCallout(){
        Map<String,Object> googleDriveDataMap = new Map<String,Object>();
        Map<String,Object> filesDataMap = new Map<String,Object>();
        Map<String, String> fileIdNameMap = new Map<String, String>();
        
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndPoint('callout:GD_credential'+'/drive/v3/files');
        request.setHeader('Content-Type','application/json');
        Http http = new Http();
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200 && response.getBody()!=null){
            //System.debug('response.getBody: '+response.getBody());
            googleDriveDataMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
            //System.debug('googleDriveDataMap is: '+googleDriveDataMap);
            
            if (googleDriveDataMap != null && googleDriveDataMap.containsKey('files')){
                List<Object> filesList = (List<Object>) googleDriveDataMap.get('files');
                //System.debug('filesList is: '+filesList);
                
                if(filesList!=null){
                    // Iterate through each file object
                    for(Object file : filesList){
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
                    //System.debug('fileIdNameMap is: '+fileIdNameMap);
            	}
        	}
    	}
        return fileIdNameMap;
	}
    
    @AuraEnabled(cacheable=true)
    public static Boolean deleteFileContentMethod(String fileId){
        Boolean isDeleted = false;
        System.debug('fileId: '+fileId);
        Map<String,Object> googleDriveDataMap = new Map<String,Object>();
        HttpRequest request = new HttpRequest();
        request.setMethod('DELETE');
        request.setEndpoint('callout:GD_credential'+'/drive/v3/files/'+fileId);
        request.setHeader('Content-Type','application/json');
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('Response is: '+response);
        if(response.getstatusCode()==204){
            isDeleted = true;
        }
        return isDeleted;
    }
    public static void uploadFileContentMethod(String fileId){
        Map<String,Object> googleDriveDataMap = new Map<String,Object>();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:GD_credential'+'/drive/v3/files/'+fileId+'?uploadType=media');
        request.setMethod('PATCH');
        request.setHeader('Content-Type', 'application/vnd.ms-excel');
        //request.setHeader('Authorization', 'Bearer' + accessToken);
        Http http = new Http();
        HttpResponse response = http.send(request);
        if(response.getstatusCode()==200 && response.getBody()!=null){
            System.debug('response.getBody: '+response.getBody());
            googleDriveDataMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
            System.debug('googleDriveDataMap is: '+googleDriveDataMap);

            
        }
    }
    @AuraEnabled(Cacheable=true)
    public static void ReNameFileContentMethod(String fileId,String name){
        System.debug('New Name is: '+name);
        String newName = '{"name":"' + name + '",';
        String body = newName + '"canRename":true}';
        Map<String,Object> googleDriveDataMap = new Map<String,Object>();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:GD_credential'+'/drive/v3/files/'+fileId);
        request.setMethod('PATCH');
        request.setBody(body);
         request.setHeader('Content-Type', 'application/json');
        //request.setHeader('Authorization', 'Bearer' + accessToken);
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('response.getBody: '+response.getBody());
        /*if(response.getstatusCode()==200 && response.getBody()!=null){
            System.debug('response.getBody: '+response.getBody());
            googleDriveDataMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
            System.debug('googleDriveDataMap is: '+googleDriveDataMap);
          }*/
        
    }
    
}
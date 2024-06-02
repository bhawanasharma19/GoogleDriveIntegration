public class AnimalLocator {
    public static String getAnimalNameById(Integer Id){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://th-apex-http-callout.herokuapp.com/animals/'+Id);
        request.setMethod('GET');
		HttpResponse response = Http.send(request);
        Map<String,Object> animals = new Map<String,Object>();
        If(response.getStatusCode()==200){
            Map<String,Object> results = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
            animals = (Map<String,Object>)results.get('animal');
        }
		return (String)animals.get('name');        
    }
}
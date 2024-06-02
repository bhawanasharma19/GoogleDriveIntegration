@RestResource(URLMapping='/Accounts/*/contacts')
global class AccountManager {
    @HttpGet
    global static Account getAccount(){
        RestRequest request = RestContext.request;
        String AccountId = request.requestURI.substringBetween('Accounts','/contacts');
        Account result = [
            			SELECT 
            				Id,Name,
                        	(
                                Select 
                                	Id,Name 
                                FROM Contacts
                            )
                        FROM Account
                        WHERE 
            				Id = :AccountId
        				];
        return result;
    }
}
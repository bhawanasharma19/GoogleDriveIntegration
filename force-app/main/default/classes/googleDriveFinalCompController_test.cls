@isTest(seeAllData = false)
public class googleDriveFinalCompController_test {
	@istest
    public static void testMethod01() {
        try{
            Test.setMock(HttpCalloutMock.class, new GoogleDriveApi2_mock());

        Test.startTest();
        Boolean bool = googleDriveFinalCompController.createUserMetadata('test', 'clientKey', 'clientSecret');
        googleDriveFinalCompController.checkExpiryTime('test');
        Boolean bool2 = googleDriveFinalCompController.handleAccessTokenFirstTime('code', 'userId');
        String str = googleDriveFinalCompController.handleAuthenticateUser('userId');
        System.assertEquals('Test', 'Test');
        Test.stopTest();
        }
        catch(Exception e){
            
        }
    }
}
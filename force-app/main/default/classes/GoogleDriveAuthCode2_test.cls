@isTest(seeAllData = false)
public class GoogleDriveAuthCode2_test {
    /*@testsetup
    public static void testMethod02() {
    GoogleDriveAuthCode2.customMetadata = (List<GD_User_Data__mdt>) JSON.deserialize(
        '[{"AccessToken__c":"dummyValue", "clientId__c":"dummyValue", "clientSecretKey__c":"dummyValue", "UserId__c":"dummyValue", "UserName__c":"dummyValue"}]', 
        List<GD_User_Data__mdt>.class
    );
    }*/
    @istest
	public static void testMethod01() {
        Test.setMock(HttpCalloutMock.class, new GoogleDriveApi2_mock());
        test.starttest();
        String str = GoogleDriveAuthCode2.createAuthURL('sndkcnskjb?code=bcjbwejdb');
        Boolean bool = GoogleDriveAuthCode2.getFirstAccessToken('code', 'userId', 'clientKey', 'clientSecret');
        //GoogleDriveAuthCode2.regenerateAccessToken('userId');
		test.stoptest();        
    }
}
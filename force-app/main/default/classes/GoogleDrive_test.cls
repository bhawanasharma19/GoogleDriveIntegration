@isTest(seeAllData = false)
public class GoogleDrive_test {
    @istest
    public static void testmethod01(){
        Test.setMock(HttpCalloutMock.class, new GoogleDriveApi2_mock());
        test.starttest();
        Map<String, String> mymap = GoogleDrive.getFileIdNameMap();
        Map<String, String> mymap2 = GoogleDrive.getFileIdNameMap2('userId');
        GoogleDrive.getFolderFiles('folderId');
        test.stoptest();
    }
}
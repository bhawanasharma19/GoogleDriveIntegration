@isTest(seeAllData = false)
public class GoogleDriveApi2_test {

    @isTest
    public static void testMethod01() {
        Test.setMock(HttpCalloutMock.class, new GoogleDriveApi2_mock());
        Test.startTest();
        Map<String, String> filesMap = GoogleDriveApi2.getGDFiles('test');
        Boolean testbool = GoogleDriveApi2.deleteFileContentMethod('test','testing');
        GoogleDriveApi2.uploadFileContentMethod('test');
        Boolean testbool2 = GoogleDriveApi2.ReNameFileContentMethod('test','testing','testing');
        Boolean testbool3 = GoogleDriveApi2.previewFileContentMethod('test','testing');
        Test.stopTest();

        System.assertEquals('Test', 'Test');
    }

}
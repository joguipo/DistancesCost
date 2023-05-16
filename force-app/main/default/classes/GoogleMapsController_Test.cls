@isTest
private class GoogleMapsController_Test {


    @isTest
    static void GetAutocompleteResults_Test_Ok(){
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GoogleMapAutocomplete');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);

        List<Object> result = new List<Object>();
        Test.startTest();
            result = GoogleMapsController.getAutocompleteResults('3480');
        Test.stopTest();
    }


    
    @isTest
    static void GetDistancesResults_Test_Ok(){
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GoogleMapDistance');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);

        String origin       = EncodingUtil.urlEncode('5789 Southfork Drive North, Royse City, TX, USA', 'UTF-8');
        String destination  = EncodingUtil.urlEncode('5790 Southfork Drive North, Royse City, TX, USA', 'UTF-8');
        String mode         = 'driving';

        String result;
        Test.startTest();
            result = GoogleMapsController.getDistancesResults(origin, destination, mode);
        Test.stopTest();

        // validate response
        System.debug('* * *  getDistancesResults_Test_Ok - resutl -> ' + result);
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        String status       = (String) jsonMap.get('status');
        System.debug('* * *  getDistancesResults_Test_Ok - status -> ' + status);
        System.assertEquals('OK', status, 'The status not match'); 
    }



    @isTest
    static void GetDistancesResults_Test_Invalid(){
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GoogleMapDistance_Invalid');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);

        String origin       = EncodingUtil.urlEncode('5', 'UTF-8');
        String destination  = EncodingUtil.urlEncode('5', 'UTF-8');
        String mode         = 'driving';

        String result;
        Test.startTest();
            result = GoogleMapsController.getDistancesResults(origin, destination, mode);
        Test.stopTest();

        // validate response
        System.debug('* * *  GetDistancesResults_Test_Invalid - resutl -> ' + result);
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        String status       = (String) jsonMap.get('status');
        System.debug('* * *  GetDistancesResults_Test_Invalid - status -> ' + status);
        System.assertEquals('INVALID_REQUEST', status, 'The status not match'); 
    }



    @isTest
    static void SetMilesCostByMode_Test_Ok(){
        Decimal miles = 10;

        Test.startTest();
        Decimal totalWalking   = GoogleMapsController.setMilesCostByMode(miles, 'walking'  );
        Decimal totalBicycling = GoogleMapsController.setMilesCostByMode(miles, 'bicycling');
        Decimal totalTransit   = GoogleMapsController.setMilesCostByMode(miles, 'transit'  );
        Decimal totalDriving   = GoogleMapsController.setMilesCostByMode(miles, 'driving'  );
        Test.stopTest();

        // validate result
        System.debug('setMilesCostByMode_Test_Ok - total -> ' + totalWalking);
        System.assertEquals(50, totalWalking,   'totalWalking is wrong' );
        System.assertEquals(40, totalBicycling, 'totalBicycling is wrong');
        System.assertEquals(30, totalTransit,   'totalTransit is wrong');
        System.assertEquals(20, totalDriving,   'totalDriving is wrong');
    }
    

}
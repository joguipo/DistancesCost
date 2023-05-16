public with sharing class GoogleMapsController {
    
    // GOOGLE MAPS ENDPOINTS
    private static final String AUTOCOMPLETE_API_URL    = Google_Map__mdt.getInstance('GoogleMaps')?.Autocomplete_Endpoint__c; // 'https://maps.googleapis.com/maps/api/place/autocomplete/json?'
    private static final String DISTANCES_API_URL       = Google_Map__mdt.getInstance('GoogleMaps')?.Distances_Enpoint__c;     //'https://maps.googleapis.com/maps/api/distancematrix/json?'

    // vHash
    private static final String vHash                   = 'Sm9obiBHdWlsbGVu';
    
    
    /**
     * Name: getAutocompleteResults
     * Description: Get addresses suggestions
     * @param input : String : snippets of addresses
     * @return List<Object>  results 
     * Author: John Guillen
     */
    @AuraEnabled(cacheable=true)
    public static List<Object> getAutocompleteResults(String input) {

        String apiKey       = '&key=' + Google_Map__mdt.getInstance('GoogleMaps')?.API_Key__c;
        String apiUrl       = AUTOCOMPLETE_API_URL + 'input=' + input + apiKey;
        System.debug('* getAutocompleteResults - apiUrl --> '          + apiUrl);

        Http http       = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');
        req.setTimeout(30000);
        req.setEndpoint( Test.isRunningTest() ? 'https://maps.googleapis.com' : apiUrl);
        HTTPResponse response = http.send(req);
        System.debug('* * getAutocompleteResults - response -->' + response.getBody());


        if (response.getStatusCode() == 200) {
            Map<String, Object> autocompleteData = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> predictions = (List<Object>) autocompleteData.get('predictions');
            List<Object> results = new List<Object>();
            System.debug('autocompleteData -->' + autocompleteData);

            for (Object prediction : predictions) {
                Map<String, Object> jsonMap = (Map<String, Object>) prediction;
                String description = (String) jsonMap.get('description');
                results.add(description);
            }
            System.debug('results -->' + results);
            return results;
        } else {
            // Handle error response
            throw new AuraHandledException('Autocomplete request failed with status code: ' + response.getStatusCode());
        }
    }


    /**
     * Name: getDistancesResults
     * Description: Get distances between two addresses
     * @param origins       : String : entire origin address
     * @param destinations  : String : entire destination address
     * @param mode          : String : specify the transportation mode
     * @return String  resultObj  (serialize)
     * Author: John Guillen
     */
    @AuraEnabled(cacheable=true)
    public static String getDistancesResults(String origins, String destinations, String mode) {
        String apiKey       = '&key='   + Google_Map__mdt.getInstance('GoogleMaps')?.API_Key__c; 
        String units        = '&units=' + 'imperial';
        String travelmode   = '&mode='  + mode;
        String apiUrl       = DISTANCES_API_URL + 'origins=' + origins + '&destinations=' + destinations + units + travelmode + apiKey;
        System.debug('getDistancesResults - origins --> '       + origins);
        System.debug('getDistancesResults - destinations --> '  + destinations);
        System.debug('getDistancesResults - mode --> '          + mode);
        System.debug('getDistancesResults - apiUrl --> '        + apiUrl);

        Http http       = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');
        req.setTimeout(30000);
        req.setEndpoint( Test.isRunningTest() ? 'https://maps.googleapis.com' : apiUrl);
        HTTPResponse response = http.send(req);
        System.debug('response -->' + response.getBody());


        if (response.getStatusCode() == 200) {
            String results = response.getBody();
            Map<String, Object> resultObj = new Map<String, Object>();
            String miles;
            Decimal milesCost;
            String travelTime;

            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String status               = (String) jsonMap.get('status');
            if (status == 'OK') {
                List<Object> jsonRows       = (List<Object>) jsonMap.get('rows');
                for (Object r : jsonRows) {
                    Map<String, Object> jsonRowMap = (Map<String, Object>) r;
                    List<Object> lElem = (List<Object>) jsonRowMap.get('elements');
                    System.debug('lEle -->' + lElem);
                    for (Object e : lElem) {
                        Map<String, Object> jsonElem = (Map<String, Object>) e;
                        Map<String, Object> distance = (Map<String, Object>) jsonElem.get('distance');
                        Map<String, Object> duration = (Map<String, Object>) jsonElem.get('duration');
                        miles       = (String)distance.get('text');
                        milesCost   = Decimal.valueOf(miles.split(' ')[0].replace(',', ''));
                        milesCost   = setMilesCostByMode(milesCost, mode);
                        travelTime  = (String)duration.get('text');
                    }
                }
                // SET RESULTS
                resultObj.put('status',       status);
                resultObj.put('origins',      origins);
                resultObj.put('destinations', destinations);
                resultObj.put('miles',        miles);
                resultObj.put('milesCost',    milesCost);
                resultObj.put('travelTime',   travelTime);
                resultObj.put('travelMode',   mode);
            }else{
                resultObj.put('status',       status);
                resultObj.put('origins',      origins);
                resultObj.put('destinations', destinations);
                resultObj.put('travelMode',   mode);
            }

            System.debug('resultObj -->' + resultObj);
            return JSON.serialize(resultObj);
        } else {
            // Handle error response
            throw new AuraHandledException('Distances request failed with status code: ' + response.getStatusCode());
        }

    }

    /**
     * Name: setMilesCostByMode
     * Description: Calculate the cost per mile, using custom metadata to stored the rates
     * @param miles : Decimal : number of miles
     * @param mode  : String  : transportation mode to specify the rates
     * @return String  resultObj  (serialize)
     * Author: John Guillen
     */
    @testVisible
    private static Decimal setMilesCostByMode(Decimal miles, String mode){
        Decimal cost;
        switch on mode {
            when 'walking' {
                cost = Test.isRunningTest() ? 5 : Google_Map__mdt.getInstance('GoogleMaps')?.walking__c;
            }
            when 'bicycling' {
                cost = Test.isRunningTest() ? 4 : Google_Map__mdt.getInstance('GoogleMaps')?.bicycling__c;
            }
            when 'transit' {
                cost = Test.isRunningTest() ? 3 : Google_Map__mdt.getInstance('GoogleMaps')?.transit__c;
            }
            when else {
                cost = Test.isRunningTest() ? 2 : Google_Map__mdt.getInstance('GoogleMaps')?.driving__c;
            }
        }
        return miles * cost;
    }
    
}
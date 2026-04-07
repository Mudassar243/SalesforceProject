public class WeatherCallout {
    
    @AuraEnabled
    public static void getWeatherData(Id leadId) {
        
        Weather_Config__mdt config = [
            SELECT API_Key__c
            FROM Weather_Config__mdt
            WHERE DeveloperName = 'OpenWeatherMap'
            LIMIT 1
        ];
        String API_KEY = config.API_Key__c;
        
        Lead lead = [
            SELECT Id, City 
            FROM Lead 
            WHERE Id = :leadId 
            LIMIT 1
        ];
        
        if(lead.City == null || lead.City == '') {
            throw new AuraHandledException(
                'Lead does not have a City. Please add city first!'
            );
        }
        
        String city = EncodingUtil.urlEncode(lead.City, 'UTF-8');
        String endpoint = 'callout:OpenWeatherMap'
                        + '/data/2.5/weather'
                        + '?q=' + city
                        + '&appid=' + API_KEY
                        + '&units=metric';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setTimeout(10000);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if(res.getStatusCode() == 200) {
            
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

            List<Object> weatherList = (List<Object>) result.get('weather');
            Map<String, Object> weatherMap = (Map<String, Object>) weatherList[0];
            String condition = (String) weatherMap.get('main');
            Map<String, Object> mainMap = (Map<String, Object>) result.get('main');
            Decimal temperature = (Decimal) mainMap.get('temp');
            
            String priority = getPriority(condition);
            
            lead.Weather_Condition__c = condition;
            lead.Temperature__c       = temperature;
            lead.Weather_Priority__c  = priority;
            update lead;
            
        } else {
            throw new AuraHandledException(
                'API Error: ' + res.getStatusCode() + ' ' + res.getStatus()
            );
        }
    }
    
    private static String getPriority(String condition) {
        if(condition == 'Clear') {
            return 'High';
        } else if(condition == 'Clouds') {
            return 'Medium';
        } else if(condition == 'Rain' || condition == 'Drizzle') {
            return 'Low';
        } else if(condition == 'Thunderstorm' || 
                  condition == 'Tornado'       || 
                  condition == 'Snow') {
            return 'Urgent';
        } else {
            return 'Medium';
        }
    }
}

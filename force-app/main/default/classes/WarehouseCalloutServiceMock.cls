@isTest
global class WarehouseCalloutServiceMock implements HttpCalloutMock {

    public String body;

    // implement http mock callout
    global HttpResponse respond(HttpRequest request){

        String body = this.body != null ? this.body : '[{"_id":"55d66226726b611100aaf741","replacement":true,"quantity":5,"name":"Generator 1000 kW","maintenanceperiod":365,"lifespan":120,"cost":5000,"sku":"220000"}]';

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(body);
        response.setStatusCode(200);
        return response; 

    }

}
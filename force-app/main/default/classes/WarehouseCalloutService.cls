public with sharing class WarehouseCalloutService implements Queueable, Database.AllowsCallouts {

    public List<Product2> equipaments = new List<Product2>();

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';

    public void execute(QueueableContext context) {

        Http h = new Http();

        HttpRequest httpReq = new HttpRequest();

        httpReq.setMethod('GET');
        httpReq.setHeader('Content-Type','application/json'); 
        httpReq.setEndpoint(WAREHOUSE_URL);

        HttpResponse res = h.send(httpReq);

        List<Object> results = (List<Object>) JSON.deserializeUntyped(res.getBody());
        
        for(Object equipament : results){
            Map<String, Object> mEquipamentByField = (Map<String,Object>)equipament;

            equipaments.add(new Product2(
                Warehouse_SKU__c = String.valueOf(mEquipamentByField.get('_id')+''),
                Cost__c = Decimal.valueOf(mEquipamentByField.get('cost')+''), 
                Lifespan_Months__c = Decimal.valueOf(mEquipamentByField.get('lifespan')+'') , 
                Maintenance_Cycle__c = Decimal.valueOf(mEquipamentByField.get('maintenanceperiod')+''),
                Name = String.valueOf(mEquipamentByField.get('name')+''),
                QuantityUnitOfMeasure = String.valueOf(mEquipamentByField.get('quantity')+'') , 
                Replacement_Part__c = Boolean.valueOf(mEquipamentByField.get('replacement') +''), 
                StockKeepingUnit = String.valueOf(mEquipamentByField.get('sku')+'')
            ));
        } 

        if(equipaments.isEmpty()){
            return;
        }

        Database.upsert(equipaments, Product2.Warehouse_SKU__c, true);
    }
    
}
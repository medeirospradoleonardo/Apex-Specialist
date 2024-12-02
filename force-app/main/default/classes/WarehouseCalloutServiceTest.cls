@IsTest
private class WarehouseCalloutServiceTest {

    // implement your mock callout test here
    @isTest 
    static void verifySuccess(){    

        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        Test.startTest();

        Id jobID = System.enqueueJob(new WarehouseCalloutService());

        Test.stopTest();

        AsyncApexJob asyncApexJob = [SELECT Id, Status, NumberOfErrors FROM AsyncApexJob WHERE Id = :jobID];
        Assert.areEqual('Completed', asyncApexJob.status);
        Assert.areEqual(0, asyncApexJob.NumberOfErrors);
    }

    @isTest 
    static void verifyEmpty(){    

        WarehouseCalloutServiceMock warehouseCalloutServiceMock = new WarehouseCalloutServiceMock();
        warehouseCalloutServiceMock.body = '[]';

        Test.setMock(HttpCalloutMock.class, warehouseCalloutServiceMock);
        Test.startTest();

        Id jobID = System.enqueueJob(new WarehouseCalloutService());

        Test.stopTest();

        AsyncApexJob asyncApexJob = [SELECT Id, Status, NumberOfErrors FROM AsyncApexJob WHERE Id = :jobID];
        Assert.areEqual('Completed', asyncApexJob.status);
        Assert.areEqual(0, asyncApexJob.NumberOfErrors);
    }

}
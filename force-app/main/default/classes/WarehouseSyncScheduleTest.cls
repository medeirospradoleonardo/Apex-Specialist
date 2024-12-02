@isTest
public with sharing class WarehouseSyncScheduleTest {

    public static string CRON_EXP = '0 0 1 * * ?';
    
    // implement scheduled code here
    @isTest 
    public static void verifySuccess(){

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        String jobId = System.schedule('WarehouseSyncScheduleTest', CRON_EXP, new WarehouseSyncSchedule());
        
        Test.stopTest();

        CronTrigger cronTrigger = [SELECT Id FROM CronTrigger WHERE Id = :jobId] ?? null;

       Assert.isNotNull(cronTrigger);
        
    }

}
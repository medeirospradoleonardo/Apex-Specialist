@isTest
public with sharing class MaintenanceRequestHelperTest {
    // implement scheduled code here

    @isTest
    public static void verifyList_success(){
        Product2 product = new Product2(Name = 'Test name', Maintenance_Cycle__c = 100, Replacement_Part__c = true);

        insert product; 
        
        List<Case> lCase = new List<Case>();

        for(Integer i=0; i<200; i++){
            lCase.add(new Case(
                Type = 'Routine Maintenance',
                Status = 'Open',
                Subject = 'testing',
                Date_Reported__c = Date.today(),
                ProductId = product.id
            ));
        }

        if(!lCase.isEmpty()){   
            insert lCase;
        } 
        
        List<Equipment_Maintenance_Item__c> lEMI = new List<Equipment_Maintenance_Item__c>();

        for(Integer i=0; i<200; i++){
            lEMI.add(new Equipment_Maintenance_Item__c(
                        Equipment__c = product.id,
                        Maintenance_Request__c = lCase[i].id,
                        Quantity__c = 10
                    )
            );
        }

        if(!lEMI.isEmpty()){
            insert lEMI;
        }
        
        for(Case c :lCase){
            c.Subject = 'Subject';
            c.Status = 'Closed';
        } 

        update lCase;

        Case caseResult = [SELECT Id FROM Case WHERE ParentId = :lCase?.get(0).id] ?? null;
        Assert.isNotNull(caseResult);
        
    }
    
    @isTest 
    public static void verifyOne_Success(){
        Product2 product = new Product2(Name = 'Test Name', Maintenance_Cycle__c = 100);
        insert product;
        
        Case cParent = new Case(Type = 'Repair', Status = 'Open', Date_Reported__c = Date.today(), ProductId = product.id);
        insert cParent;

        Case cChild = new Case(Type = 'Repair', Status = 'Open', Date_Reported__c = Date.today(), ProductId = product.id, ParentId = cParent.ParentId);
        insert cChild;
        
        cParent.subject = 'Subject';
        cParent.Status = 'Closed';
        update cParent;
        
        Case caseResult = [SELECT Id FROM Case WHERE ParentId = :cParent.id] ?? null;
        Assert.isNotNull(caseResult);
        
    }

    @isTest public static void verifyOne_Fail(){
        Product2 product = new Product2(Name = 'Test Name', Maintenance_Cycle__c = 100);
        insert product;
        
        Case c = new Case(Type = 'Repair', Status = 'New', Date_Reported__c = Date.today(), ProductId = product.id);
        insert c;
        
        c.Status = 'Working';
        update c;
        
        Case caseResult = [SELECT Id FROM Case WHERE ParentId = :c.id] ?? null;
        Assert.isNull(caseResult);
    }
    
    
    
    
}
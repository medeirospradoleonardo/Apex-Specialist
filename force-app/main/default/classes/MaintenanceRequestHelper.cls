public with sharing class MaintenanceRequestHelper {

  public static void updateworkOrders(Map<Id, Case> pmOldCases, List<Case> plNewCases) {
    // TODO: Complete the method to update workorders

    Set<Id> sIds = new Set<Id>();

    for (Case c : plNewCases) {
      if (pmOldCases.get(c.Id).Status != 'Closed' && c.Status == 'Closed') {
        if (c.Type == 'Repair' || c.Type == 'Routine Maintenance') {
          sIds.add(c.Id);
        }
      }
    }

    if (!sIds.isEmpty()) {

      List<Case> lNewCases = new List<Case>();

      Map<Id, Case> mClosedCaseById = new Map<Id, Case>(
        [
          SELECT
            Id,
            Vehicle__c,
            Equipment__c,
            Equipment__r.Maintenance_Cycle__c,
            (
              SELECT Id, Equipment__c, Quantity__c
              FROM Equipment_Maintenance_Items__r
            )
          FROM Case
          WHERE Id IN :sIds
        ]
      );

      Map<Id, Decimal> mMaintenanceCyclesById = new Map<ID, Decimal>();

      AggregateResult[] results = [
        SELECT
          Maintenance_Request__c,
          MIN(Equipment__r.Maintenance_Cycle__c) cycle
        FROM Equipment_Maintenance_Item__c
        WHERE Maintenance_Request__c IN :sIds
        GROUP BY Maintenance_Request__c
      ];

      for (AggregateResult ar : results) {
        mMaintenanceCyclesById.put((Id) ar.get('Maintenance_Request__c'), (Decimal) ar.get('cycle'));
      }

      for (Case c : mClosedCaseById.values()) {
        Case newCase = new Case(
          ParentId = c.Id,
          Status = 'New',
          Subject = 'Routine Maintenance',
          Type = 'Routine Maintenance',
          Vehicle__c = c.Vehicle__c,
          Equipment__c = c.Equipment__c,
          Origin = 'Web',
          Date_Reported__c = Date.Today()
        );

        if (mMaintenanceCyclesById.containskey(c.Id)) {
          newCase.Date_Due__c = Date.today().addDays((Integer) mMaintenanceCyclesById.get(c.Id));
        }

        lNewCases.add(newCase);
      }

      insert lNewCases;

      List<Equipment_Maintenance_Item__c> lClonedEquipmentMaintenanceItem = new List<Equipment_Maintenance_Item__c>();

      for (Case c : lNewCases) {
        for (Equipment_Maintenance_Item__c equipmentMaintenanceItem : mClosedCaseById.get(c.ParentId).Equipment_Maintenance_Items__r) {

          Equipment_Maintenance_Item__c cloneEquipmentMaintenanceItem = equipmentMaintenanceItem.clone();
          cloneEquipmentMaintenanceItem.Maintenance_Request__c = c.Id;
          lClonedEquipmentMaintenanceItem.add(cloneEquipmentMaintenanceItem);
        }
      }

      insert lClonedEquipmentMaintenanceItem;
    }
  }
}

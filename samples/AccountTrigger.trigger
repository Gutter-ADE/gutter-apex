trigger AccountTrigger on Account (before insert, before update, after delete, after undelete) {
    if (Trigger.isBefore && Trigger.isInsert) {
        for (Account a : Trigger.new) {
            a.Description = 'New: ' + a.Name; // set on create
        }
    }
    Set<Id> ids = new Set<Id>();
    for (Account a : [SELECT Id FROM Account WHERE CreatedDate = LAST_N_DAYS:7 AND OwnerId = :UserInfo.getUserId()]) {
        ids.add(a.Id);
    }
    Database.upsert(Trigger.new, false);
    merge Trigger.new[0] Trigger.new[1];
}

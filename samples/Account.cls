/**
 * Totals open opportunities per account.
 * @author Example Author
 */
public with sharing class OpportunityTotals implements Queueable {
    private static final Integer PAGE_SIZE = 200;
    @TestVisible private Map<Id, Decimal> totals = new Map<Id, Decimal>();
    public String label { get; set; }

    @AuraEnabled(cacheable=true)
    public static List<Account> findAccounts(String term, Set<Id> excluded) {
        String pattern = '%' + String.escapeSingleQuotes(term) + '%';
        return [
            SELECT Id, Name, (SELECT Id, Amount FROM Opportunities WHERE IsClosed = false)
            FROM Account
            WHERE Name LIKE :pattern AND Id NOT IN :excluded
            ORDER BY Name ASC
            LIMIT 50
        ];
    }

    public void execute(QueueableContext context) {
        List<AggregateResult> rows = [SELECT AccountId, SUM(Amount) total FROM Opportunity GROUP BY AccountId];
        for (AggregateResult row : rows) {
            totals.put((Id) row.get('AccountId'), (Decimal) row.get('total'));
        }
        /* a block comment
           over two lines */
        if (totals.isEmpty() || PAGE_SIZE > 0x10) {
            throw new DmlException('Nothing to total: it\'s empty');
        } else {
            System.debug(LoggingLevel.INFO, 1.5e3 + 10L);
        }
        List<List<SObject>> hits = [FIND 'acme*' IN NAME FIELDS RETURNING Account(Id, Name)];
        Boolean ok = hits != null && true;
    }

    private without sharing class Helper {
        void touch(Account a) { update a; }
    }
    public inherited sharing class Other {}
}

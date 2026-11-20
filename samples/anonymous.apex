// Anonymous Apex: run from the developer console.
List<Contact> people = [SELECT Id, Email FROM Contact WHERE Email != null LIMIT 10];
Integer n = 0;
while (n < people.size()) {
    people[n].Email = people[n].Email.toLowerCase();
    n++;
}
update people;
Datetime now = Datetime.now();
System.assertEquals(10, people.size(), 'expected ten');

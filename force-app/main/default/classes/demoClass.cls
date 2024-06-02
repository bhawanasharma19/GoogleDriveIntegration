public class demoClass {
    @AuraEnabled(Cacheable=true)
    public static Account addAccount(String ac){
        Account acc = new Account();
        acc.Name = ac;
        insert acc;
        System.debug('Account inserted');
        return acc;
    }
    @AuraEnabled(Cacheable=true)
    public static void deleteAccount(String ac){
        Account acc = [SELECT Id,Name from Account Where Name =: ac];
        Delete acc;
        System.debug('Account deleted');

    }
}
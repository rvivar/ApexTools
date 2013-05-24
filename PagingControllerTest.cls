/*
 * This class provides the test methods for PagingController class
 */
@isTest(SeeAllData=false OnInstall=false)
private class PagingControllerTest 
{
    /** Page size */ 
    private static Integer PAGE_SIZE = 5;
    
    private static void SetupEnvironment()
    {
        List<Account> accountsList = new List<Account>();
        for (Integer i = 0 ; i < 10 ; i++)
        {
            accountsList.add(new Account(Name = 'Account '+String.valueOf(i)));
        }
        try
        {
            insert accountsList;
        }
        catch(System.DmlException dmlException)
        {
            system.debug(dmlException.getMessage());
        }
    }
    
    static testMethod void First()
    {
        SetupEnvironment();
        PagingController pagingController = new PagingController('SELECT Id, Name FROM Account', PAGE_SIZE);
        pagingController.First();
        system.assert(!pagingController.RecordsList.isEmpty());
    }
    
    static testMethod void Last()
    {
        SetupEnvironment();
        PagingController pagingController = new PagingController('SELECT Id, Name FROM Account', PAGE_SIZE);
        pagingController.Last();
        system.assert(!pagingController.RecordsList.isEmpty());
    }
    
    static testMethod void Next()
    {
        SetupEnvironment();
        PagingController pagingController = new PagingController('SELECT Id, Name FROM Account', PAGE_SIZE);
        pagingController.First();
        pagingController.Next();
        system.assert(!pagingController.RecordsList.isEmpty());
    }
    
    static testMethod void Previous()
    {
        SetupEnvironment();
        PagingController pagingController = new PagingController('SELECT Id, Name FROM Account', PAGE_SIZE);
        pagingController.First();
        pagingController.Next();
        pagingController.Previous();
        system.assert(!pagingController.RecordsList.isEmpty());
    }
    
    static testMethod void Flags()
    {
        SetupEnvironment();
        PagingController pagingController = new PagingController('SELECT Id, Name FROM Account', PAGE_SIZE);
        pagingController.First();
        system.assert(pagingController.HasNext != null);
        system.assert(pagingController.HasPrevious != null);
    }
}
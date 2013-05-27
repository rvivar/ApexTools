/*
 * This class provides the functionality to do paging similar to StandardSetController but using offset
 * SOQL feature
 */
public with sharing class PagingController
{
    public class IlegalArgumentException extends Exception
    {
    
    }
    /** Stores the base query parameter it should not contain LIMIT and OFFSET clauses */
    private String baseQuery;
    
    /** Stores the number of the current page */
    private Integer currentPageNumber;
    
    /** Stores the total records that the baseQuery will generate */
    private Integer totalRecords;
    
    /** Gets the OffsetValue that will be added to the base query */
    private Integer OffsetValue
    {
        get
        {
            return ((this.currentPageNumber - 1) * this.PageSize); 
        }
    }
    
    /** Returns true if has next, otherwise false */
    public Boolean HasNext
    {
        get
        {
           return (this.currentPageNumber < this.TotalPages);
        }
    }
    
    /** Returns true if has previous, otherwise false */
    public Boolean HasPrevious
    {
        get
        {
           return (this.currentPageNumber != 1);
        }
    }
    
    /** Stores the page size value, by default is 10 */
    public Integer PageSize
    {
        get;
        private set;
    }
    
    /** Stores the list of records generated according to the base query and page number */
    public List<SObject> RecordsList
    {
        get;
        private set;
    }
    
    /** Gets the total number of pages */
    public Integer TotalPages
    {
        get
        {
            if (this.totalRecords > 0)
            {
                return Integer.valueOf(Math.ceil((this.totalRecords / this.PageSize) + 0.5));
            }
            else
            {
                return 0;
            }
        }
    }
    
    /**
     * Constructor
     *
     * @param baseQuery the query that will be used for the paging it SHOULD NOT contains LIMIT and OFFSET clauses
     */
    public PagingController(String baseQuery, Integer pageSize)
    {
        if (pageSize < 0)
        {
            throw new IlegalArgumentException('The page size cannot be negative.');
        }
        if (baseQuery == null || baseQuery.trim() == '')
        {
            throw new IlegalArgumentException('The query cannot be null or empty.');
        }
        this.baseQuery = baseQuery;
        this.PageSize = pageSize;
        try
        {
            this.totalRecords = Database.query(baseQuery).size();
        }
        catch(Exception queryException)
        {
            this.totalRecords = 0;
        }
    }
    
    /**
     * Constructor
     *
     * @param baseQuery the query that will be used for the paging it SHOULD NOT contains LIMIT and OFFSET clauses
     */
    public PagingController(String sobjectName, Set<String> additionalFields, Integer pageSize)
    {
        if (pageSize <= 0)
        {
            throw new IlegalArgumentException('The page size cannot be negative.');
        }
        if (sobjectName == null || sobjectName.trim() == '')
        {
            throw new IlegalArgumentException('The SObject name cannot be null or empty.');
        }
        if (!Schema.getGlobalDescribe().containsKey(sobjectName))
        {
            throw new IlegalArgumentException('The SObject name does not exist.');
        }
        String queryFields = this.GetQueryFields(sobjectName, additionalFields);
        this.baseQuery = 'SELECT ' + queryFields + ' FROM ' + sobjectName;
        this.PageSize = pageSize;
        try
        {
            this.totalRecords = Database.query(baseQuery).size();
        }
        catch(Exception queryException)
        {
            this.totalRecords = 0;
        }
    }
    
    /**
     * Gets the query fields string according to the additional fields and the SObject describe
     */
    private String GetQueryFields(String sobjectName, Set<String> additionalFields)
    {
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(sobjectName).getDescribe().fields.getMap();
        Schema.DescribeFieldResult fieldDescribe;
        String queryFields = '';
        for (Schema.SObjectField field : fieldsMap.values())
        {
            fieldDescribe = field.getDescribe();
            if (fieldDescribe.isAccessible() && fieldDescribe.isCreateable() && fieldDescribe.isUpdateable())
            {
                if (queryFields.trim() == '')
                {
                    queryFields += String.escapeSingleQuotes(fieldDescribe.getName());
                }
                else
                {
                    queryFields += ', ' + String.escapeSingleQuotes(fieldDescribe.getName());
                }
            }
        }
        for (String additionalField : additionalFields)
        {
            queryFields += ', '  + String.escapeSingleQuotes(additionalField);
        }
        queryFields = String.escapeSingleQuotes(queryFields);
        return queryFields;
    }
    /**
     * Sets the records of the first page
     */
    public void First()
    {
        this.currentPageNumber = 1;
        String finalQuery = baseQuery + ' LIMIT ' + String.valueOf(this.PageSize) + ' OFFSET ' + String.valueOf(this.OffsetValue);
        this.RecordsList = Database.query(finalQuery);
    }
    
    /**
     * Sets the records of the next page
     */
    public void Next()
    {
        ++this.currentPageNumber;
        String finalQuery = baseQuery + ' LIMIT ' + String.valueOf(this.PageSize) + ' OFFSET ' + String.valueOf(this.OffsetValue);
        this.RecordsList = Database.query(finalQuery);
    }
    
    /**
     * Sets the records of the previous page
     */
    public void Previous()
    {
        --this.currentPageNumber;
        String finalQuery = baseQuery + ' LIMIT ' + String.valueOf(this.PageSize) + ' OFFSET ' + String.valueOf(this.OffsetValue);
        this.RecordsList = Database.query(finalQuery);
    }
    
    /**
     * Sets the records of the last page
     */
    public void Last()
    {
        this.currentPageNumber = this.TotalPages - 1;
        String finalQuery = baseQuery + ' LIMIT ' + String.valueOf(this.PageSize) + ' OFFSET ' + String.valueOf(this.OffsetValue);
        this.RecordsList = Database.query(finalQuery);
    }

}
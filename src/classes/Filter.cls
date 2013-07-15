global class Filter
{
    /////////////////////////////////////////////////////////////////
    // standard filter types
    /////////////////////////////////////////////////////////////////

    global static Filter fieldChanged( Schema.SObjectField field )
    {
        return new Filter( new FieldChangedPredicate( field ) );
    }

    global static Filter fieldNull( Schema.SObjectField field )
    {
        return new Filter( new FieldNullPredicate( field ) );
    }

    global static Filter fieldNotNull( Schema.SObjectField field )
    {
        return new Filter( new FieldNotNullPredicate( field ) );
    }

    global static Filter fieldEquals( Schema.SObjectField field, Object value )
    {
        return new Filter( new FieldEqualsPredicate( field, value ) );
    }

    /////////////////////////////////////////////////////////////////
    // Filter instance methods
    /////////////////////////////////////////////////////////////////

    global List<sObject> filter( List<sObject> newRecords )
    {
        List<sObject> filteredRecords = new List<sObject>();

        for ( sObject record : newRecords )
        {
            if ( predicate.evaluate( record ) )
            {
                filteredRecords.add( record );
            }
        }

        return filteredRecords;
    }

    global List<sObject> filter( List<sObject> newRecords, Map<Id, sObject> oldRecords )
    {
        List<sObject> filteredRecords = new List<sObject>();

        for ( sObject record : newRecords )
        {
            sObject oldRecord = oldRecords.get( record.Id );

            if ( predicate.evaluate( record, oldRecord ) )
            {
                filteredRecords.add( record );
            }
        }

        return filteredRecords;
    }

    /////////////////////////////////////////////////////////////////
    // Filter class glue
    /////////////////////////////////////////////////////////////////

    global Filter( Predicate predicate )
    {
        this.predicate = predicate;
    }

    @TestVisible Predicate predicate;

    /////////////////////////////////////////////////////////////////
    // Predicate interface
    /////////////////////////////////////////////////////////////////

    global interface Predicate
    {
        Boolean evaluate( sObject newRecord );
        Boolean evaluate( sObject newRecord, sObject oldRecord );
    }

    global abstract class InsertPredicate implements Predicate
    {
        global Boolean evaluate( sObject newRecord, sObject oldRecord )
        {
            return ((Predicate)this).evaluate( newRecord );
        }
    }

    /////////////////////////////////////////////////////////////////
    // standard Predicates
    /////////////////////////////////////////////////////////////////

    global class FieldChangedPredicate implements Predicate
    {
        @TestVisible Schema.SObjectField field;

        global FieldChangedPredicate( Schema.SObjectField field )
        {
            this.field = field;
        }

        global Boolean evaluate( sObject newRecord )
        {
            return newRecord.get( field ) != null;
        }

        global Boolean evaluate( sObject newRecord, sObject oldRecord )
        {
            return newRecord.get( field ) != oldRecord.get( field );
        }
    }

    global class FieldNullPredicate extends InsertPredicate
    {
        @TestVisible Schema.SObjectField field;

        global FieldNullPredicate( Schema.SObjectField field )
        {
            this.field = field;
        }

        global Boolean evaluate( sObject newRecord )
        {
            return newRecord.get( field ) == null;
        }
    }

    global class FieldNotNullPredicate extends InsertPredicate
    {
        @TestVisible Schema.SObjectField field;

        global FieldNotNullPredicate( Schema.SObjectField field )
        {
            this.field = field;
        }

        global Boolean evaluate( sObject newRecord )
        {
            return newRecord.get( field ) != null;
        }
    }

    global class FieldEqualsPredicate extends InsertPredicate
    {
        @TestVisible Schema.SObjectField field;
        @TestVisible Object value;

        global FieldEqualsPredicate( Schema.SObjectField field, Object value )
        {
            this.field = field;
            this.value = value;
        }

        global Boolean evaluate( sObject newRecord )
        {
            return newRecord.get( field ) == value;
        }
    }
}
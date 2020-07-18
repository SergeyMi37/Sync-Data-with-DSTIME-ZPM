/// This sample persistent class represents a person. 
/// <p>Maintenance note: This class is used by some of the bindings samples.
Class OBJ.Person Extends (%Persistent, %Populate, %XML.Adaptor)
{

Parameter EXTENTQUERYSPEC = "Name,SSN,Home.City,Home.State";

Parameter DSTIME = "AUTO";

// define indices for this class

/// Define a unique index for <property>SSN</property>.
Index SSNKey On SSN [ Type = index, Unique ];

/// Define an index for <property>Name</property>.
Index NameIDX On Name [ Data = Name ];

/// Define an index for embedded object property <b>ZipCode</b>.
Index ZipCode On Home.Zip [ Type = bitmap ];

// define properties for this class

/// Person's name.
Property Name As %String(POPSPEC = "Name()") [ Required ];

/// Person's Social Security number. This is validated using pattern match.
Property SSN As %String(PATTERN = "3N1""-""2N1""-""4N") [ Required ];

/// Person's Date of Birth.
Property DOB As %Date(POPSPEC = "Date()");

/// Person's home address. This uses an embedded object.
Property Home As Sample.Address;

/// Person's office address. This uses an embedded object.
Property Office As Sample.Address;

/// Person's spouse. This is a reference to another persistent object.
Property Spouse As Person;

/// A collection of strings representing the person's favorite colors.
Property FavoriteColors As list Of %String(JAVATYPE = "java.util.List", POPSPEC = "ValueList("",Red,Orange,Yellow,Green,Blue,Purple,Black,White""):2");

/// Person's age.<br>
/// This is a calculated field whose value is derived from <property>DOB</property>.
Property Age As %Integer [ Calculated, SqlComputeCode = { Set {Age}=##class(OBJ.Person).CurrentAge({DOB})
}, SqlComputed, SqlComputeOnChange = DOB ];

/// This class method calculates a current age given a date of birth <var>date</var>.
ClassMethod CurrentAge(date As %Date = "") As %Integer [ CodeMode = expression ]
{
$Select(date="":"",1:($ZD($H,8)-$ZD(date,8)\10000))
}

/// Prints the property <property>Name</property> to the console.
Method PrintPerson()
{
    Write !, "Name: ", ..Name
    Quit
}

/// A simple, sample method: add two numbers (<var>x</var> and <var>y</var>) 
/// and return the result.
Method Addition(
    x As %Integer = 1,
    y As %Integer = 1) As %Integer
{
    Quit x + y // comment
}

/// A simple, sample expression method: returns the value 99.
Method NinetyNine() As %Integer [ CodeMode = expression ]
{
99
}

/// Invoke the <method>PrintPerson</method> on all <class>Person</class> objects 
/// within the database.
ClassMethod PrintPersons()
{
    // use the extent result set to find all person
    Set extent = ##class(%ResultSet).%New("OBJ.Person:Extent")
    Do extent.Execute()
    
    While (extent.Next()) {
        Set person = ..%OpenId(extent.GetData(1))
        Do person.PrintPerson()
    }
    
    Quit
}

/// Prints out data on all persons within the database using SQL to 
/// iterate over all the person data.
ClassMethod PrintPersonsSQL()
{
    // use dynamic SQL result set to find person data
    Set query = ##class(%ResultSet).%New("%DynamicQuery:SQL")
    Do query.Prepare("SELECT ID, Name, SSN FROM Sample.Person ORDER BY Name")
    Do query.Execute()
    
    While (query.Next()) {
        Write !,"Name: ", query.Get("Name"), ?30, query.Get("SSN")
    }
    
    Quit
}

/// This is a sample of how to define an SQL stored procedure using a 
/// class method. This method can be called as a stored procedure via 
/// ODBC or JDBC.<br>
/// In this case this method returns the concatenation of a string value.
ClassMethod StoredProcTest(
    name As %String,
    ByRef response As %String) As %Integer [ SqlName = Stored_Procedure_Test, SqlProc ]
{
    // Set response to the concatenation of name.
    Set response = name _ "||" _ name
    QUIT 29
}

/// This is a sample of how to define an SQL stored procedure using a 
/// class method. This method can be called as a stored procedure via 
/// ODBC or JDBC.<br>
/// This method performs an SQL update operation on the database 
/// using embedded SQL. The update modifies the embedded properties 
/// <var>Home.City</var> and <var>Home.State</var> for all rows whose 
/// <var>Home.Zip</var> is equal to <var>zip</var>.
ClassMethod UpdateProcTest(
    zip As %String,
    city As %String,
    state As %String) As %Integer [ SqlProc ]
{
    New %ROWCOUNT,%ROWID
    
    &sql(UPDATE Sample.Person 
    SET Home_City = :city, Home_State = :state 
    WHERE Home_Zip = :zip)
    
    // Return context information to client via %SQLProcContext object
    If ($g(%sqlcontext)'=$$$NULLOREF) { 
        Set %sqlcontext.SQLCode = SQLCODE
        Set %sqlcontext.RowCount = %ROWCOUNT
    }
    QUIT 1
}

/// A sample class query that defines a result set that returns Person data 
/// ordered by <property>Name</property>.<br>
/// This query can be used within another Cach&eacute; method (using the
/// <class>%ResultSet</class> class), from Java, or from ActiveX.<br>
/// This query is also accessible from ODBC and/or JDBC as the SQL stored procedure 
/// <b>SP_Sample_By_Name</b>.
Query ByName(name As %String = "") As %SQLQuery(CONTAINID = 1, SELECTMODE = "RUNTIME") [ SqlName = SP_Sample_By_Name, SqlProc ]
{
SELECT ID, Name, DOB, SSN
FROM Sample.Person
WHERE (Name %STARTSWITH :name)
ORDER BY Name
}

Storage Default
{
<Data name="PersonDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>SSN</Value>
</Value>
<Value name="4">
<Value>DOB</Value>
</Value>
<Value name="5">
<Value>Home</Value>
</Value>
<Value name="6">
<Value>Office</Value>
</Value>
<Value name="7">
<Value>Spouse</Value>
</Value>
<Value name="8">
<Value>FavoriteColors</Value>
</Value>
</Data>
<DataLocation>^OBJ.PersonD</DataLocation>
<DefaultData>PersonDefaultData</DefaultData>
<ExtentSize>15</ExtentSize>
<IdLocation>^OBJ.PersonD</IdLocation>
<IndexLocation>^OBJ.PersonI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>1.4</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Age">
<AverageFieldSize>1.8</AverageFieldSize>
<Selectivity>7.1429%</Selectivity>
</Property>
<Property name="DOB">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>6.6667%</Selectivity>
</Property>
<Property name="FavoriteColors">
<AverageFieldSize>8.4</AverageFieldSize>
<Selectivity>10.0000%</Selectivity>
</Property>
<Property name="Home">
<AverageFieldSize>36.6,City:7.2,State:2,Street:17.2,Zip:5</AverageFieldSize>
<Selectivity>6.6667%,City:7.1429%,State:7.1429%,Street:6.6667%,Zip:6.6667%</Selectivity>
</Property>
<Property name="Name">
<AverageFieldSize>15.13</AverageFieldSize>
<Selectivity>6.6667%</Selectivity>
</Property>
<Property name="Office">
<AverageFieldSize>35.93,City:6.8,State:2,Street:16.6,Zip:5</AverageFieldSize>
<Selectivity>6.6667%,City:10.0000%,State:7.1429%,Street:6.6667%,Zip:6.6667%</Selectivity>
</Property>
<Property name="SSN">
<AverageFieldSize>11</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Spouse">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<SQLMap name="$Person">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="NameIDX">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="SSNKey">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="ZipCode">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^OBJ.PersonS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
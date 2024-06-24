/*  
    Author: Zane Alberts
    Description: This script is a basic template of a object class using c#. The class itself was not my main concern but the intellisense. I was curious how I could get my code to show messages when hovering over fields or messages.
    Source: Personal Experience
    Date: 1-03-2017T11:34 */

class Person
{
    //*Fields
    private string? strFirstName;
    private string? strLastName;
    private int intAge;

    //*Properties. All are set to read and write.
    public string? FirstName
    {
        get { return strFirstName; }                //Read.
        set { strFirstName = value; }               //Write.
    }

    public string? LastName
    {
        get { return strLastName; }                 //Read.
        set { strLastName = value; }                //Write.
    }

    public int Age
    {
        get { return intAge; }                      //Read.
        set { intAge = value; }                     //Write.
    }

    //*Constructor
    /// <summary>
    /// This is a constructor with parameters for the Person class. You have to provide the credentials as parameters.
    /// </summary>
    /// <param name="strFirstnameParam"> The first name of the person.</param>
    /// <param name="strLastnameParam"> The last name of the person.</param>
    /// <param name="iAgeParam"> The age of person.</param>

    public Person(string? strFirstnameParam, string? strLastnameParam, int iAgeParam)
    {
        //Assign the fields.
        this.FirstName = strFirstnameParam;
        this.LastName = strLastnameParam;
        this.Age = iAgeParam;
    }

    //  *The emptry Constructor.
    /// <summary>
    /// This is an emptry constructor for the Person class. You can fill in details as you go.
    /// </summary>
    public Person()
    {

    }

    //*This will capture it as a object in the Paramaters.
    /// <summary>
    /// This method will verify if the provided fields pass the requirement checks.
    /// </summary>
    /// <param name="personParam"> The person class with the necessary details for verification.</param>
    public static bool Verify_Person(Person personParam)
    {
        //Variables.
        bool bVerified = true;                                          //*This variable will be used to return the value (True = verified, False = unverified).
        Field_Details fieldDetails1 = new Field_Details("Firstname","String", personParam.FirstName);
        Field_Details fieldDetails2 = new Field_Details("Lastname","String", personParam.LastName);
        Field_Details fieldDetails3 = new Field_Details("Age","Int", personParam.Age);
        Field_Details[] arrFields = new Field_Details[3] {fieldDetails1 , fieldDetails2, fieldDetails3};               //This will be used to prepare the fields.

        //Verifying the fields.
        bVerified = Verify_Variables.Verify_Fields(arrFields);          //Check the Field.

        //Return the value.
        return bVerified;
    }


}

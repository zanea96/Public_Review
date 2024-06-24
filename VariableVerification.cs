/*  
    Author: Zane Alberts
    Description: I wrote these methods to verify variable fields.
    Source: Personal Experience
    Date: 1-03-2017T09:34 */

//TODO You need to add a method that will verify a Double.
//TODO You need to add a method that will verify a Boolean.
//TODO You need to add a method that will verify a Email.
class Verify_Variable
{
    //*Verify a single field.
    public static bool Verify_Field(Field_Details fieldDetailsParam)
    {
        //Variables.
        bool bVerified = true;

        //Do verification based on field type.
        switch (fieldDetailsParam.VariableType)
        {
            case "string":      //It's a string.
                bVerified = Verify_String(fieldDetailsParam.FieldValue.ToString());
                break;

            case "int":         //It's a integer.
                bVerified = Verify_Integer(fieldDetailsParam.FieldValue);
                break;

            case "bool":        //It's a boolean.
                break;
        }

        return bVerified;
    }

    //*Verify an array of fields.
    public static bool Verify_Fields(Field_Details[] arrField_Details)
    {
        //Variables.
        bool bVerified = true;

        //Loop through the fields.
        foreach (var field in arrField_Details)
        {
            if (!Verify_Field(field)) bVerified = false;
        }

        //Return the status of the verification.
        return bVerified;
    }

    //*Verifiy a string field.
    public static bool Verify_String(string strStringParam)
    {
        //The necessary varialbles for this method.
        bool bVerified = true;                                              //This variable will be used to return the end result. True = Verified, False = Unverified.

        //Monitor for errors.
        try
        {
            if (strStringParam.Length == 0) bVerified = false;              //*Check if its a blank value or null.
        }
        catch (System.Exception ex)                                         //!Something serious went wrong when trying to verify the string.
        {
            bVerified = false;
            System.Console.WriteLine("Critical Error when verifying a string.");
            System.Console.WriteLine("Error: " + ex.Message);

            Error_Report error_report = new Error_Report();
            //TODO Check if you can supply values for these that have N/A as a value.
            error_report.ErrorCode = "NA";
            error_report.Correction = "NA";
            error_report.ErrorType = "NA";
            error_report.ErrorMessage = ex.Message;
            error_report.Source = ex.Source;
            error_report.HelpLink = ex.HelpLink;
            error_report.StackTrace = ex.StackTrace;

            Error_Report.Submit_Error_Report(error_report);
        }

        //Return the verification status.
        return bVerified;
    }

    //*Verify a integer field.
    public static bool Verify_Integer(object iIntegerParam)
    {
        //The variables.
        bool bVerified = true;
        int iOutputInteger = 0;

        //Monitor for errors.
        try
        {
            //Try to parse the value. If it fails it will be caught by the error.
            int.TryParse(iIntegerParam.ToString(), out iOutputInteger);
        }
        catch (System.Exception ex)                                         //!Something serious went wrong when trying to verify the integer.
        {
            bVerified = false;
            System.Console.WriteLine("Critical Error when verifying a string.");
            System.Console.WriteLine("Error: " + ex.Message);

            Error_Report error_report = new Error_Report();
            //TODO Check if you can supply values for these that have N/A as a value.
            error_report.ErrorCode = "NA";
            error_report.Correction = "NA";
            error_report.ErrorType = "NA";
            error_report.ErrorMessage = ex.Message;
            error_report.Source = ex.Source;
            error_report.HelpLink = ex.HelpLink;
            error_report.StackTrace = ex.StackTrace;

            Error_Report.Submit_Error_Report(error_report);
        }

        //Return the value.
        return bVerified;
    }

}

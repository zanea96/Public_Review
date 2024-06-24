/*  
    Author: Zane Alberts
    Description: This script is a basic template on searching for values in an array.
    Source: Personal Experience
    Date: 1-03-2017T09:34 */


//*We put the methods in a class to make them easily callable.
class LINQExample
{
    //*Check a list for a specific value that is specified in the parameters field for the method. Needs work on the Linq section.
    public static string[] CheckForValue(string sSearchForParam)
    {
        //*Variables.
        string[] arrNames = { "ALEX",
                              "BOB",
                              "CHET" };
        string[] sNameResult = { "Nothing" };

        //*Now do a LINQ search for the specified values. Notice how its almost like a SQL query but the SELECT comes last.
        var varSearchResult = from a in arrNames where a.Contains(sSearchForParam) select a;

        //*This is to display the output.
        System.Console.WriteLine("Total entries: " + arrNames.Length);
        System.Console.WriteLine("Total entries matching result: " + varSearchResult.Count());

        //*Assign the values if they found a value.
        if (varSearchResult.Count() > 0)
        {
            sNameResult = varSearchResult.ToArray<string>();
        }

        //*Return the value.
        return sNameResult;
    }
}

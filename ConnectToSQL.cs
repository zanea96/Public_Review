/*  
    *Author: Zane Alberts
    *Description: This is a basic template for connecting to a SQL database.
    *Date: 12-04-2019

    *Patch Notes
    12-04-2019
    [+] The software is completed.

    02-02-2020
    [+] Updated the connection string to work with SQLExpress.
    [+] Created a class to store the connection details and automatically create the connection string.
*/

// Allocated Libraries
using System;
using System.Data.SqlClient;

class Program
{
    // Main entry point for the code.
    static void Main()
    {
        // *Here is an example of how to connect to the database.

        // Variables for database connection.
        string server = "your_server_address";              // The SQL server address.
        int port = 1433;                                    // Default SQL Server port. The default is usually 1433.
        string username = "your_username";                  // The username in SQL.
        string password = "your_password";                  // The password for the username in SQL.
        string databaseName = "your_database_name";         // What is the name of the database you want to connect to.

        // Connect to the database.
        Connection_Details cd = new Connection_Details();
        cd.Server = server;
        cd.Port = port;
        cd.Username = username;
        cd.Password = password;
        cd.DatabaseName = databaseName;

        cd.Test_Connection();

        Console.ReadLine(); // Keep the console window open, Remove this if you arent using a console application.
    }
}

// A class for the Database connection.
class Connection_Details
{
    // Fields.
    private string server;              // The server to connect to.
    private int port;                   // The port to connect to.
    private string username;            // The username to use for the connection.
    private string password;            // The password to use for the username.
    private string databaseName;        // The name of the database to connect to.

    // Properties of each field.
    public string Server                // Server
    {
        get { return server; }          // Reading rights.
        set { server = value; }         // Writing rights.
    }

    public string Port                  // Ports
    {
        get { return port; }            // Reading rights.
        set { port = value; }           // Writing rights.
    }

    public string Username              // Username
    {
        get { return username; }        // Reading rights.
        set { username = value; }       // Writing rights.
    }

    public string Password              // Password
    {
        get { return password; }        // Reading rights.
        set { password = value; }       // Writing rights.
    }

    public string DatabaseName          // Database name.
    {
        get { return databaseName; }    // Reading rights.
        set { databaseName = value; }   // Writing rights.
    }


    // This is the constructor that will be used to connect to the SQL Database.
    public Connection_Details()
    {

    }

    // This method will connect to the database, If credentials were not provided then the connection will fail.
    public void Connect()
    {
        // Local variables.
        bool Verified = false;
        string connectionString = $"Server={this.server},{this.port};Database={this.databaseName};User Id={this.username};Password={this.password};";
                
        // First we need to make sure the details are verified.
        Verified = Verify_Details();

        if(Verified)                            // * The verification check was a success.
        {
            try
            {
                // You need to use the using statement because when manually closing the connection, It does not always release all of the resources. The using statement does release all of the resources when it reaches
                // the end of the code block.
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    // Open the connection.
                    connection.Open();

                    // Connection opened successfully.
                    Console.WriteLine($"Connected to {cd.DatabaseName}.");

                    //* Perform your database operations here.

                    // Close the connection. The end of the using statement will do it but its better to be safe than sorry here.
                    connection.Close();
                }
            }
            catch (SqlException ex)
            {
                Console.WriteLine($"Database - Error: {ex.Message}");
            }
        }
        else                                    // ! The verification check failed.
        {
            Console.WriteLine("Verification Failed!\nPlease enter the server details using the fields in the Connection_Details class.\n");
        }
    }

    // This method will verify the details.
    public bool Verify_Details()
    {
        // Local variables.
        bool Verified = false;                  // This variable stores the status of the verification. True = Verified and False = Unverified, As a rule it is set to false until the verification check is complete.

        // Verify that credentials were provided. Check the length of each field. 
        if(server.Length > 0                    // Verify the server.
        && port.ToString().Length > 0           // Verify the port
        && username.Length > 0                  // Verify the username.
        && password.Length > 0                  // Verify the password.
        && databaseName.Length > 0) Verified = true;    // Verify the database name.
        
        return Verified;                        // Return the verification status.
    }

    // Here is a method to test the connection to the database.
    public void Test_Connection()
    {
        Connect();
    }
}
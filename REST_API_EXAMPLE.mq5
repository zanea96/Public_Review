//+------------------------------------------------------------------+
//|                                                     REST_API.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//|                           LIBRARIES                              |
//+------------------------------------------------------------------+
#include <Jason.mqh>                                                                      // Check the Include folder if you have this library.

//+------------------------------------------------------------------+
//|                        Global Variables                          |
//+------------------------------------------------------------------+
CJAVal jv;


//+------------------------------------------------------------------+
//|                       API RESPONSE CODES                         |
//+------------------------------------------------------------------+
enum Response_Codes
{
//Name                          Value                                                     Description  
  Continue                      = 100,                                                    // The server has received the request headers and the client should proceed to send the request body
  Switching_Protocols           = 101,                                                    // The requester has asked the server to switch protocols and the server has agreed to do so
  Processing                    = 102,                                                    // This code indicates that the server has received and is processing the request, but no response is available yet
  OK                            = 200,                                                    // The request has succeeded
  Created                       = 201,                                                    // The request has been fulfilled and resulted in a new resource being created
  Accepted                      = 202,                                                    // The request has been accepted for processing, but the processing has not been completed
  No_Content                    = 204,                                                    // The server has fulfilled the request but does not need to return an entity-body
  Moved_Permanently             = 301,                                                    // The requested resource has been permanently moved to a new location
  Found                         = 302,                                                    // The requested resource resides temporarily under a different URI
  Not_Modified                  = 304,                                                    // The resource has not been modified since the version specified by the request headers
  Bad_Request                   = 400,                                                    // The server cannot or will not process the request due to an apparent client error
  Unauthorized                  = 401,                                                    // Similar to 403 Forbidden, but specifically for use when authentication is required and has failed or has not yet been provided
  Forbidden                     = 403,                                                    // The client does not have access rights to the content; that is, it is unauthorized
  Not_Found                     = 404,                                                    // The server cannot find the requested resource
  Method_Not_Allowed            = 405,                                                    // The method specified in the request is not allowed for the resource identified by the request URI
  Internal_Server_Error         = 500,                                                    // A generic error message, given when an unexpected condition was encountered and no more specific message is suitable
  Not_Implemented               = 501,                                                    // The server either does not recognize the request method, or it lacks the ability to fulfill the request
  Service_Unavailable           = 503,                                                    // The server is currently unavailable
};


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
  Login_Example();
  return(INIT_SUCCEEDED);

}


//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{

}


//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
  
}


//+------------------------------------------------------------------+
//|                      GET_EXAMPLE                                 |
//+------------------------------------------------------------------+
void Get_Example()
{
  string  url = "https://reqres.in/api/users/2",                                          // The URL. 
          headers = "Content-Type: application/json",                                     // Header of the payload.
          result_headers;                                                                 // String to store the result header.
  char    data[] = {},                                                                    // This char array will store the body of the payload.
          result[];                                                                       // This variable will store the result.


  int request = WebRequest( "GET", url, headers, 5000, data, result, result_headers );    // The request is sent and the response is stored as a integer.
  Response_Codes Response = request;
  
    
  if( Response == "OK" )                                                                  //* The request was a success.
  {
      // Success
      string result_string = CharArrayToString( result, 0, WHOLE_ARRAY, CP_UTF8 );            // Convert the response from a character array to a string.
      Print( "API call successful. Response: ", result_string );                              // Print the result.    
      // Parse the response data here
  }
  else                                                                                    //! The request was a failure.
  {
      // Error
      Print( "API call failed. Error code: ", request );                                      // Print the result. 
      
      // Success
      string result_string = CharArrayToString( result, 0, WHOLE_ARRAY, CP_UTF8 );            // Convert the response from a character array to a string.
      Print( "API Response: ", result_string );                                               // Print the error message.
  };
}


//+------------------------------------------------------------------+
//|                     POST EXAMPLE                                 |
//+------------------------------------------------------------------+
void Post_Example()
{
  // Variables
  string  url = "https://reqres.in/api/users",                                            // The URL. 
          headers = "Content-Type: application/json",                                     // Header of the payload.
          result_headers,                                                                 // String to store the result header.
          payload,                                                                        // This string stores the payload.
          name = "morphues",                                                              // Name of the user.
          job = "leader";                                                                 // The role of the user.
  char    data[],
          result[];                                                                       // This variable will store the result.
  
  //* JSON Serialization
  CJAVal jv;
  jv["name"]      = name; // Name
  jv["job"]       = job;  // Job
  ArrayResize(data, StringToCharArray(jv.Serialize(), data, 0, WHOLE_ARRAY)-1);


  //* Handling the request.
  int request = WebRequest( "POST", url, headers, 5000, data, result, result_headers );   // The request is sent and the response is stored as a integer.

  
  //* Success
  if( request == 201 )                                                                    //* The request was a success.
  {
    string result_string = CharArrayToString( result, 0, WHOLE_ARRAY, CP_UTF8 );            // Convert the response from a character array to a string.
    Print( "API call successful. Response: ", result_string );                              // Print the result.    

    // Parse the response data here. Lets assume the response is the comment below.
    // {"name": "morpheus","job": "leader","id": "838","createdAt": "2024-02-29T20:11:13.922Z"}

    //* JSON Deserialization
    jv.Deserialize(result);
    string id = jv["id"].ToStr();
    string createdAt = jv["createdAt"].ToStr();
    Print("User ID:", id, " created at ", createdAt);
  }
  //! Error
  else                                                                                    //! The request was a failure.
  {
    Print( "API call failed. Error code: ", request );                                      // Print the result. 
    
    // Response
    string result_string = CharArrayToString( result, 0, WHOLE_ARRAY, CP_UTF8 );            // Convert the response from a character array to a string.                                                               // Get the code.
    Print( "API Response: ", result_string );                                               // Print the error message.
  };

}


//+------------------------------------------------------------------+
//|                     LOGIN EXAMPLE                                |
//+------------------------------------------------------------------+
void Login_Example()
{
  // Variables
  string  url = "https://reqres.in/api/login",                                            // The URL. 
          headers = "Content-Type: application/json",                                     // Header of the payload.
          result_headers,                                                                 // String to store the result header.
          payload,                                                                        // This string stores the payload.
          email = "eve.holt@reqres.in",                                                   // Email of the user.
          password = "cityslicka";                                                        // The password of the user.
  char    data[],
          result[];                                                                       // This variable will store the result.
  
  //* JSON Serialization
  jv["email"]          = email;                                                           // Email
  jv["password"]       = password;                                                        // PW
  ArrayResize(data, StringToCharArray(jv.Serialize(), data, 0, WHOLE_ARRAY)-1);


  //* Handling the request.
  int request = WebRequest( "POST", url, headers, 5000, data, result, result_headers );   // The request is sent and the response is stored as a integer.

  
  //* Success
  if( request == 200 )                                                                    //* The request was a success.
  {
    Print("Response: 200 - OK ");                                                         // Print the result.    

    //* JSON Deserialization    
    // Parse the response data here. Lets assume the response is the comment below.
    // {"token": "QpwL5tke4Pnpja7X4"}
    jv.Deserialize(result);
    string token = jv["token"].ToStr();

    Print(" Session started - Token: ", token);
  }
  //! Error
  else                                                                                    //! The request was a failure.
  {
    Print( "Login Failed. Error code: ", request );                                       // Print the result. 
    
    // Response
    //* JSON Deserialization
    // Parse the response data here. Lets assume the response is the comment below.
    // {"error": "User does not exist"}
    jv.Deserialize(result);
    string error = jv["error"].ToStr();                                                   // Print the error message.
    Print(" Error: ", error);
  };

}

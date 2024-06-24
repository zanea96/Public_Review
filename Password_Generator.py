# Author: Zane Alberts
# Description: This script should generate a password based on parameters given.
# Source: Own attempt
# Date: 09-05-2021T12:03


#* What parameters should be given?
#*  -Total characters
#*  -Include numbers
#*  -Include special characters

# *Import libraries
import os
import random

# *Global Variables
global TotalCharacters                 # The amount of characters for the password.
global ContainNumbers                  # Should the password contain numbers.
global ContainCharacters               # Should special characters be included.

# *Switches
Alphabet_Switch = {
    1 : "A",
    2 : "B",
    3 : "C",
    4 : "D",
    5 : "E",
    6 : "F",
    7 : "G",
    8 : "H",
    9 : "I",
    10 : "J",
    11 : "K",
    12 : "L",
    13 : "M",
    14 : "N",
    15 : "O",
    16 : "P",
    17 : "Q",
    18 : "R",
    19 : "S",
    20 : "T",
    21 : "U",
    22 : "V",
    23 : "W",
    24 : "X",
    25 : "Y",
    26 : "Z"
}

SpecialChar_Switch = {
    0:")",
    1:"!",
    2:"@",
    3:"#",
    4:"$",
    5:"%",
    6:"^",
    7:"&",
    8:"*",
    9:"("
}

# This method will prompt for the password requirements.
def GeneratePassword():
    global TotalCharacters     
    TotalCharacters = input("\t1. How many characters does the password need?\n\t")         # Capture the amount of characters.
    
    global ContainNumbers      
    ContainNumbers = input("\t2. Should the password contain numbers?(Y/N)\n\t")            # Should the password contain numbers.
    
    global ContainCharacters   
    ContainCharacters = input("\t3. Should special characters be included?(Y/N)\n\t")       # Should the password contain special characters.

    # Verification process.
    if VerifyDetails():                                                                     # Verify the inputs.
        print("\n\t\t***PARAMETERS ACCEPTED***\n")                                              #* Verification passed.
        CreatePassword()                                                                        #* Create the password.
    else: print("\n\t\t***PARAMETERS REJECTED***")                                          #! Verification failed.

# This method will generate the header for the terminal.
def GenerateHeader():
    os.system('cls')                                                                        # Clear the terminal script.
    print("\n\t\t***  PASSWORD GENERATOR  ***\n\t\t    Author: Zane Alberts\n")             # The header text.
    
# Verify the details that were entered.
def VerifyDetails():
    
    # Variables
    IsVerified = True                                                                       # Declare the IsVerified variable.
    ContainNumbersVerification = False                                                      # Declare the ContainNumbersVerification variable.
    ContainCharactersVerification = False                                                   # Declare the ContaintCharacterVerification variable.

    # print("Total Characters: " + TotalCharacters)
    # print("Contain Numbers : " + ContainNumbers)
    # print("Contain Special Char: " + ContainCharacters)

    # Check if the Total Characters can actually be converted to string.
    try: ConvertedTotalCharactersInt = int(TotalCharacters)                                 # Prepare the total characters as a int
    except: print("The number of characters you entered is not valid number, Please try again")

    test_string = isinstance(ContainNumbers, str)
    test_string2 = isinstance(ContainCharacters, str)
    test_int1 = isinstance(ConvertedTotalCharactersInt, int)


    # print("Contain Numbers Is String: " , test_string)
    # print("Contain Characters Is String: " , test_string2)
    # print("Total Characters Is Int: " , test_int1)


    # Verify the variable types.
    if isinstance(ConvertedTotalCharactersInt, int) == False: IsVerified = False             # Verify that the Total Characters variable is an int variable.
    if isinstance(ContainNumbers, str) == False: IsVerified = False                          # Verify that the Contain Numbers variable is a string. 
    if isinstance(ContainCharacters, str) == False: IsVerified = False                       # Verify that the Contain Special Characters variable is a string.

    # Verify that the ContainNumbers has a valid answer if it is a string.
    if isinstance(ContainNumbers, str) == True: 
        if ContainNumbers.lower() == "y" or ContainNumbers.lower() == "n":
            ContainNumbersVerification = True
            #print("Contain Numbers Verification: ", ContainNumbersVerification)

    # Verify that the ContainCharacters has a valid answer if it is a string.
    if isinstance(ContainCharacters, str) == True: 
        if ContainNumbers.lower() == "y" or ContainNumbers.lower() == "n":
            ContainCharactersVerification = True
            #print("Contain Characters Verification: ", ContainCharactersVerification)


    # Return the final result.
    if IsVerified == True and ContainCharactersVerification == True and ContainNumbersVerification == True: return True
    else: return False 

# Create the password.
def CreatePassword():
    # Variables
    global TotalCharacters
    global ContainNumbers
    global ContainCharacters
    tempPassword = ""
    tempCharacter = ""

    # The total options available to generate the password.
    Options = 1                                                         # 1 = Characters included
    if ContainNumbers.lower() == 'y': Options = Options + 1             # 2 = Numbers included

    if ContainCharacters.lower() == 'y': Options = Options + 1          # 3 = Special Characters included
    
    ConvertedTotalCharactersInt = int(TotalCharacters)                  # Convert the Total characters to string.
    security_level = (Options * 100 / 3)                                # Calculate the security level.

    ConvertedTotalCharactersInt = int(TotalCharacters)

    #print("Total options : " , Options)

    # Loop through each amount of total characters.
    for Character in range(ConvertedTotalCharactersInt):
        Random_Type = random.randint(1, Options)        # Choose the option path.
        tempCharacter = ""

        # Which path should be used.
        if Random_Type == 1:                            # Pick a character.
            #print("Option 1")
            tempCharacter = RandomCharacter()
            tempPassword = tempPassword + tempCharacter # Update the password.

        if Random_Type == 2:                            # Pick a number or special character.
            #print("Option 2")
            # Number was chosen.
            if ContainNumbers.lower() == "y":
                tempCharacter = RandomNumber()
                tempPassword = tempPassword + tempCharacter # Add the character to the password.
            else:
                tempCharacter = RandomSpecial_Char()        # Get the special character.
                tempPassword = tempPassword + tempCharacter # Update the password.

        if Random_Type == 3:                            # Pick a special or special character.
            #print("Option 3")
            Random_Type_Sub_1 = random.randint(1,2)

            if Random_Type_Sub_1 == 1:                        # 
                tempCharacter = RandomNumber()
                tempPassword = tempPassword + tempCharacter

            if Random_Type_Sub_1 == 2:
                tempCharacter = RandomSpecial_Char()
                tempPassword = tempPassword + tempCharacter

    
    print("\t\tPassword: " + tempPassword)
    print("\t\tSecurity estimate: " , security_level, "%\n\n")

# Generate a random character.
def RandomCharacter():
    #print("Character picked")
    Random_Char = random.uniform(1,26)          # Generate a random number between 1 and 26.
    Random_Char = int(Random_Char)              # Get a random character.
    Random_Case = random.uniform(1,3)           # Decide if it should be uppercase or lowercase.
    Random_Case = int(Random_Case)              # Convert it to an integer.

    tempCharacter = Alphabet_Switch.get(Random_Char,"*")# Get the character from the alphabet.

    # Decide the case
    if Random_Case == 1:
        tempCharacter = tempCharacter.lower()   # Convert to lower case.
    else: tempCharacter = tempCharacter.upper() # Convert to upper case.

    return tempCharacter

# Generate a random number.
def RandomNumber():
    #print("Number selected")
    tempRandomNumber = random.randint(0,9)      # Generate a number between 0 and 9.
    tempCharacter = str(tempRandomNumber)       # Convert it to a string.
    return tempCharacter                        # Return the number.

# Get a special character.
def RandomSpecial_Char():
    #print("SChar picked")
    tempRandomSChar = random.randint(0,9)       # Get a random number for the special character.
    tempCharacter = SpecialChar_Switch.get(tempRandomSChar) # Get the special character.
    tempCharacter = str(tempCharacter)          # Convert the special character to a string.
    return tempCharacter                        # Return the number.

# The main method that calls all the necessary functions/methods.
def Main():
    GenerateHeader()                                                                        # Generate the header.
    GeneratePassword()                                                                      # Capture the password details.

# This is where the main method is called, The code starts here.
Main()

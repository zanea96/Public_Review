/*  
    Author: Zane Alberts
    Description: This method adds an element to another element. Like adding a span element to label.
    Date: 17-01-2022T09:34 */ 

//In order simplify this script we will declare it as a method.
function addToElement(strElementIdParam, strAddElementParam, strElementClassParam, strNodeValueParam) {
    //Monitor for errors.
    try {
        //Create a variable to store the Target Element.
        let TargetElement = strElementIdParam;
        if (TargetElement.match("#") === null) TargetElement = "#" + TargetElement;

        //Create the element and assign a class.
        const span = document.createElement(strAddElementParam);
        span.className = strElementClassParam;

        //Create the text node for the element. This will be the text you want see appear on the front end. It has to be assigned to the node using the appendChild() function.
        const node = document.createTextNode(strNodeValueParam);
        span.appendChild(node);

        //Get the element DOM object using jQuery.
        const element = jq(TargetElement).get(0);

        //Update the element with the new span.
        element.appendChild(span);
    } catch (error) { //!An error occurred.
        alert("Failed to update an element: " + strElementIdParam + " because " + error.message);
    }
}

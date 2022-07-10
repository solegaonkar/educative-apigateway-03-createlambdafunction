/**
 * This code is deployed as the Lambda function in AWS. 
 * It just returns the simple string Hello World.
 */

exports.handler = async(event, context) => {
  return "Hello World";
};


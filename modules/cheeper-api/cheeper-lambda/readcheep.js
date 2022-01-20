var AWS = require('aws-sdk');
var ddb = new AWS.DynamoDB({apiVersion: '2012-08-10'});
let cheeperTable = process.env.cheeperTable

exports.handler = async (event) => {
  try {
    var data;
    var params = {
      TableName: cheeperTable,
    };
  
    try{
      data = await ddb.scan(params).promise();
      console.log("Item read successfully:", data);
    } catch(err){
      console.log("Error: ", err);
      data = err;
    }
    
    var response = {
      'statusCode': 200,
      'body': JSON.stringify({
        message: data
      })
    };
  } catch (err) {
    console.log(err);
    return err;
  }
  return response;
};

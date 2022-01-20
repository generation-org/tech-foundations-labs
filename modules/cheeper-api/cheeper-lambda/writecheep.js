var AWS = require('aws-sdk');
var ddb = new AWS.DynamoDB({apiVersion: '2012-08-10'});
let cheeperTable = process.env.cheeperTable

exports.handler = async (event) => {
    try {
	    var obj = JSON.parse(event.body);
	    var message = obj.message;
	    var params = {
		    TableName: cheeperTable,
		    Item: {
			    message : {S: message}
		    }
	    };
	    var data;
	    var msg;
	    try{
		    data = await ddb.putItem(params).promise();
		    console.log("Item entered successfully:", data);
		    msg = 'Item entered successfully';
	    } catch(err){
		    console.log("Error: ", err);
		    msg = err;
	    }
	    var response = {
		    'statusCode': 200,
		    'body': JSON.stringify({
			    message: msg
		    })
	    };
    } catch (err) {
	    console.log(err);
	    return err;
    }
	
    return response;
};

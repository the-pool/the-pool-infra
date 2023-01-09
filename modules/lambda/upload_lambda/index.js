const multipart = require('parse-multipart');
const AWS = require('aws-sdk');
const REGION = "ap-northeast-2"
const S3 = new AWS.S3({ region: REGION })

exports.handler = async (event, context, callback) => {
  // Get metadata
  const request = event.Records[0].cf.request;
  const method = request.method;
  const contentType = request.headers['content-type'][0].value;
  const bucketName = request.origin.s3.customHeaders['x-env-bucket'][0].value;

  if (method != 'POST' && !contentType.startsWith('multipart/form-data')) {
    callback(null, {
      status: '404',
      body: JSON.stringify({
        'message': 'wrong access'
      })
    });
    return;
  }

  // Get Multipart
  const bodyBuffer = Buffer.from(request.body.data, 'base64');
  const boundary = multipart.getBoundary(contentType);
  const parts = multipart.Parse(bodyBuffer, boundary);
  const fileData = parts[0];
  console.log(`Get Data Info ${fileData.filename} ${fileData.type} ${bucketName}`);

  // Set Upload Params
  let uploadParams = {
    Bucket: bucketName,
    Key: `uploads/${fileData.filename}`,
    Body: fileData.data,
    ContentEncoding: 'base64',
    ContentType: fileData.type
  };

  // Upload & Callback
  let response;
  try {
    const s3Response = await S3.putObject(uploadParams).promise();
    console.log('Get Response');
    console.log(s3Response);
    response = {
      status: '200',
      statusDescription: 'OK',
      body: JSON.stringify({ message: 'upload success' }),
    };
  } catch (error) {
    console.log('Get Error');
    console.log(error);
    response = {
      status: '404',
      statusDescription: 'OK',
      body: JSON.stringify({ message: error }),
    };
  } finally {
    callback(null, response);
  }
};
// const AWS = require("aws-sdk");
// const REGION = "ap-northeast-2"
// const S3 = new AWS.S3({ region: REGION })
const multipart = require('parse-multipart');

exports.handler = async (event, context, callback) => {
  const request = event.Records[0].cf.request;
  const method = request.method;
  const contentType = request.headers['content-type'][0].value;

  if (method != 'POST' && !contentType.startsWith('multipart/form-data')) {
    callback(null, {
      status: '404',
      body: JSON.stringify({
        'message': 'wrong access'
      })
    })
    return;
  }

  console.log(`Get ContentType ${contentType}`);
  console.log(`Get headers ${request.headers}`);
  const bodyBuffer = Buffer.from(request.body.data, 'base64');
  const boundary = multipart.getBoundary(contentType);
  const parts = multipart.Parse(bodyBuffer, boundary);

  console.log(`Get Part ${parts[0].data.toString()}`);
  console.log(request.headers);

  const response = {
    status: '200',
    statusDescription: 'OK',
    body: JSON.stringify({ data: parts[0].data.toString() }),
  };

  callback(null, response);
};

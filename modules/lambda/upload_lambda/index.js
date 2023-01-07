// const AWS = require("aws-sdk");
// const REGION = "ap-northeast-2"
// const S3 = new AWS.S3({ region: REGION })

exports.handler = async (event, context, callback) => {
  console.log("Lambda Execute");
  console.log("Request Event:" + JSON.stringify(event, null, 2));
  const requestHeaders = event.Records[0].cf.request.headers;
  const response = {
    status: '200',
    statusDescription: 'OK',
    headers: {
      'cache-control': [{
        key: 'Cache-Control',
        value: 'max-age=100'
      }],
      'content-type': [{
        key: 'Content-Type',
        value: 'text/html'
      }],
      'content-encoding': [{
        key: 'Content-Encoding',
        value: 'UTF-8'
      }],
    },
    body: JSON.stringify({
      code: 200,
      message: "list data test",
      data: "Get Get Get"
    }),
  };

  callback(null, response);
};

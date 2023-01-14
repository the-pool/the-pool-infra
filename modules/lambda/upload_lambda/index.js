const multipart = require('parse-multipart');
const { v4 } = require('uuid');
const AWS = require('aws-sdk');
const jwt = require('jsonwebtoken');
const sharp = require('sharp');

const REGION = "ap-northeast-2";
const S3 = new AWS.S3({ region: REGION });

const PROFILE_IMAGE_SIZE = 640;
const ERRORSTATE = Object.freeze({
  WRONG_ACCESS: 'wrong access',
  TOKEN_EXPIRED: 'token expired',
  TOKEN_INVALID: 'token invalid',
  AUTH_FAIL: 'auth fail',
  UPLOAD_FAIL: 'upload fail'
});

/*
  역할
  - Request 확인
  - Auth 확인
  - Before Upload 원본이미지 리사이징
  - S3 Upload
*/

// Request 확인
const checkRequest = (request) => {
  const method = request.method;
  const contentType = request.headers['content-type'][0].value;

  if (method != 'POST' && !contentType.startsWith('multipart/form-data')) {
    throw new Error(ERRORSTATE.WRONG_ACCESS);
  }
}

// Auth 확인
const checkAuth = (headers, customHeaders) => {
  try {
    const auth = headers['Authorization'][0].value;
    const jwtSecretKey = customHeaders['x-env-jwt'][0].value;
    jwt.verify(auth, jwtSecretKey);
  } catch (error) {
    if (error.message === "jwt expired") {
      throw new Error(ERRORSTATE.TOKEN_EXPIRED);
    } else {
      throw new Error(ERRORSTATE.TOKEN_INVALID);
    }
  }
}

// 이미지 리사이징
const resizingImage = () => {

}

// 이미지 업로드
const uploadImage = async (uploadParams) => {
  try {
    const s3Response = await S3.putObject(uploadParams).promise();
    return {
      status: '200',
      statusDescription: 'OK',
      body: JSON.stringify({ url: 'upload success' }),
    };
  } catch (error) {
    throw new Error(ERRORSTATE.UPLOAD_FAIL);
  }
}

exports.handler = async (event, context, callback) => {
  try {
    const request = event.Records[0].cf.request;
    const customHeaders = request.origin.s3.customHeaders;
    const bucketName = customHeaders['x-env-bucket'][0].value;

    checkRequest(request);
    checkAuth(request.headers, customHeaders);

    // Get Multipart
    const bodyBuffer = Buffer.from(request.body.data, 'base64');
    const boundary = multipart.getBoundary(contentType);
    const parts = multipart.Parse(bodyBuffer, boundary);
    const fileData = parts[0];
    const uploadPath = `uploads/${v4()}/${fileData.filename}`;
    console.log(`Get Data Info ${fileData.filename} ${fileData.type} ${bucketName}`);
    const uploadParams = {
      Bucket: bucketName,
      Key: uploadPath,
      Body: fileData.data,
      ContentEncoding: 'base64',
      ContentType: fileData.type
    };
    const response = await uploadImage(uploadParams);

    callback(null, response);
  } catch (error) {
    switch (error.message) {
      case ERRORSTATE.WRONG_ACCESS:
        break;
      case ERRORSTATE.AUTH_FAIL:
        break;
      case ERRORSTATE.UPLOAD_FAIL:
        break;
      default:
        console.log(error);
    }

    callback(null, {
      status: '404',
      body: JSON.stringify({
        'message': error.message
      })
    });
  }
};
const multipart = require('parse-multipart');
const { v4 } = require('uuid');
const AWS = require('aws-sdk');
const jwt = require('jsonwebtoken');
// npm install --platform=linux --arch=x64 sharp
const sharp = require('sharp');

const REGION = "ap-northeast-2";
const S3 = new AWS.S3({ region: REGION });

const BASE_DOMAIN = "https://api.thepool.kr";
const PROFILE_IMAGE_SIZE = 640;
const ERRORSTATE = Object.freeze({
  WRONG_ACCESS: 'wrong access',
  TOKEN_EXPIRED: 'token expired',
  TOKEN_INVALID: 'token invalid',
  FILE_INVALID: 'file invalid',
  RESIZING_FAIL: 'resizing fail',
  UPLOAD_FAIL: 'upload fail'
});

/*
  역할
  - Request 확인
  - Auth 확인
  - Image 리사이징
  - Image S3 Upload
*/

exports.handler = async (event, context, callback) => {
  try {
    const request = event.Records[0].cf.request;
    const contentType = request.headers['content-type'][0].value;
    const customHeaders = request.origin.s3.customHeaders;
    const bucketName = customHeaders['x-env-bucket'][0].value;

    checkRequest(request);
    checkAuth(request.headers, customHeaders);

    // 문자열 데이터를 base64로 인코딩된 데이터로 변환, 파싱
    const bodyBuffer = Buffer.from(request.body.data, 'base64');
    const boundary = multipart.getBoundary(contentType);
    const fileData = multipart.Parse(bodyBuffer, boundary)[0];

    const resizedImage = await resizingImage(fileData.data);
    const uploadPath = `uploads/${v4()}/${fileData.filename}`;
    const uploadParams = {
      Bucket: bucketName,
      Key: uploadPath,
      Body: resizedImage,
      ContentEncoding: 'base64',
      ContentType: fileData.type
    };
    const uploadResponse = await uploadImage(uploadParams);

    callback(null, uploadResponse);

  } catch (error) {
    let statusCode = 400
    switch (error.message) {
      case ERRORSTATE.WRONG_ACCESS:
      case ERRORSTATE.TOKEN_EXPIRED:
      case ERRORSTATE.TOKEN_INVALID:
        statusCode = 402
        break;
      case ERRORSTATE.RESIZING_FAIL:
      case ERRORSTATE.UPLOAD_FAIL:
        statusCode = 403
        break;
      default:
        statusCode = 403
    }
    console.log(error.message);
    callback(null, {
      status: statusCode,
      body: JSON.stringify({
        'message': error.message
      })
    });
  }
};


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
    const jwtSecretKey = customHeaders['x-env-jwt'][0].value;
    const auth = headers['authorization'][0].value.split(' ')[1];

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
const resizingImage = async (imageBuffer) => {
  try {
    return await sharp(imageBuffer)
      .resize({ width: PROFILE_IMAGE_SIZE })
      .withMetadata()
      .toBuffer();
  } catch (error) {
    throw new Error(ERRORSTATE.RESIZING_FAIL);
  }
}

// 이미지 업로드
const uploadImage = async (uploadParams) => {
  try {
    const s3Response = await S3.putObject(uploadParams).promise();

    if (s3Response.$response.httpResponse.statusCode < 300) {
      return {
        status: '200',
        statusDescription: 'OK',
        body: JSON.stringify({ url: `${BASE_DOMAIN}/${uploadParams.Key}` }),
      };
    } else {
      throw new Error(ERRORSTATE.UPLOAD_FAIL);
    }
  } catch (error) {
    throw new Error(ERRORSTATE.UPLOAD_FAIL);
  }
}
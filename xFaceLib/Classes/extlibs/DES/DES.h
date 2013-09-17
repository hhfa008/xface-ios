#ifndef _DES_H_
#define _DES_H_


#ifdef __cplusplus
extern "C" {
#endif

int XDES_DataDecrypt(int type,char *key,char *indata,char *outdata);

int XDES_DataEncrypt(int type, char *key,char *indata,char *outdata);


/**
 * @brief
 *   用指定密钥对数据进行DES解密
 * @param[in]：	key[8] - 单倍长解密密钥
 *		indata - 需要解密的密文数据，长度为8Byte
 *
 * @param[out]： outdata- 解密后的明文数据，长度为8Byte
 *
 * @Return：	0 - 失败,1 - 成功
 */
int XDes_Decrypt ( char key[8], char* indata,char *outdata);

/**
 * @brief
 *   用指定密钥对数据进行DES加密
 * @param[in]：	key[8] - 单倍长加密密钥
 *		indata - 加密数据明文，长度为8Byte
 *
 * @param[out]： outdata- 加密数据密文，长度为8Byte
 *
 * @Return：	0 - 失败,1 - 成功
 */
int XDes_Encrypt ( char key[8], char*indata,char *outdata);

/**
 * @brief
 *   用指定密钥对数据进行3DES解密
 * @param[in]：	key[16] - 双倍长解密密钥
 *		indata - 需要解密的密文数据，长度为8Byte
 *
 * @param[out]： outdata- 解密后的明文数据，长度为8Byte
 *
 * @Return：	0 - 失败,1 - 成功
 */
int XDes_TripleDecrypt(char key[16],char *indata,char *outdata);

/**
 * @brief
 *   用指定密钥对数据进行3DES加密
 * @param[in]：	key[16] - 双倍长加密密钥
 *		indata - 加密数据明文，长度为8Byte
 *
 * @param[out]： outdata- 加密数据密文，长度为8Byte
 *
 * @Return：	0 - 失败,1 - 成功
 */
int XDes_TripleEncrypt(char key[16],char *indata,char*outdata);


#ifdef __cplusplus
}
#endif

#endif

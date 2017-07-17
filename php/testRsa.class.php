<?php
/**
 * Created by PhpStorm.
 * User: ian
 * Date: 2017/7/7
 * Time: 上午10:03
 */
class testRSA {

    public $rsaPublicKey = '-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCpXOMTRiRKmnjK8sD0I785RH25
rltHMLFO3J3SUzZ2rrDeCCRcETMT+KVJEnsVTnN0IHB5hlnkLXfxFp05E8/ESQT8
Qt0xqeVbzXkX8jQjnq0GgE3biuUsHOMZNLhzIne9/PbIRhi+E/WM3JVc3VBNzYLV
jIi3Iu+eX/avSLwv3QIDAQAB
-----END PUBLIC KEY-----';

    public $rsaPrivateKey = '-----BEGIN RSA PRIVATE KEY-----
MIICXAIBAAKBgQCCbQ6dCdhDpN7gDhIfzBMM2+QhYRexKNoQevbFLqhhqHbb28L/
LktHlTPMWhGiYJroFyrC8vK+oxws/fE7oMIlN0HMpdciQqYLa8g7ihf7H+LsYdVe
nU5yFslwJmVfkXFvKf5QI3Onp2dHk2aLQ7Fa3VyhqUNt8ej9j19z8dta1QIDAQAB
AoGATqUwMKVlELTz56rUZvQJcLGPSElhneQCSfm7n37Y7bpFoaFMXc8ueYWQbGLL
S1xxTA3cLR2OHkIAlWiy87+mESpzmzJoJXDi+RRtmH0F0kML8NDzCut607FA0/Fu
ywVjgGhVAIbCjvh1rBu49dFfjW0qz5kETBKYuFzzlq4AlukCQQC5Mecn4+sMME0u
hpO0gdalOIkwZWOX4Qdg+uxO5hCAJZjbC1Y6Jx0TnAEMH+4O426dVkfhb8yI/j2a
ib7itGPzAkEAtEqaWK33WGb8f1C7CAJ8eLU4PODrfxL2al9vNsWXxrEGmNDYH5Ct
5u3nTgqumqtjvV+tnul0Wwktc2CmrjggFwJAb0zRisTMr4+b4zlYLeTWdoeq054r
o8zHHX7QZH6aLhnqasK+eManD/DzJDFQZjxDb2W6X39MYozBw03DngYiBwJABhzZ
atRLJJYpTW/BR5499iG+zGGb2m0cKbMepC7C3Ju364p5KWjQXJoIU58NGHVjJlKO
Imsr5MJE5jqKrDF+9QJBAPSoQxE+RUELjTvCGL0HyOhWtdO0xeLAk868rQn5Lj/X
omAt7b9atfkQH8Q/xQSOKydrm7oOYERIIdOiwJoJuC0=
-----END RSA PRIVATE KEY-----';

    // 加解密
    public function encode($src, $isEncode) {
        if ($isEncode) {
            return $this->encrypt($src);
        } else {
            return $this->decrypt($src);
        }

    }

    protected function urlsafe_b64encode($string) {
        $data = base64_encode($string);
        $data = str_replace(array('+','/','='),array('-','_',''),$data);
        return $data;
    }


    protected function urlsafe_b64decode($string) {
        $data = str_replace(array('-','_'),array('+','/'),$string);
        $mod4 = strlen($data) % 4;
        if ($mod4) {
            $data .= substr('====', $mod4);
        }
        return base64_decode($data);
    }

    protected function encrypt($originalData){

        $crypto = '';

        foreach (str_split($originalData, 117) as $chunk) {

            openssl_public_encrypt($chunk, $encryptData, $this->rsaPublicKey);

            $crypto .= $encryptData;
        }

        return $this->urlsafe_b64encode($crypto);
    }

    protected function decrypt($encryptData){

        $crypto = '';

        foreach (str_split($this->urlsafe_b64decode($encryptData), 128) as $chunk) {

            openssl_private_decrypt($chunk, $decryptData, $this->rsaPrivateKey);

            $crypto .= $decryptData;
        }

        return $crypto;
    }

}
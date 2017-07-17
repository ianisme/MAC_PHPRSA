<?php
/**
 * Created by PhpStorm.
 * User: ian
 * Date: 2017/7/7
 * Time: 上午10:03
 */
header("Content-Type:text/html; charset=utf8");
require_once("./testRsa.class.php");

$dataRequest = MyGetRequest::getRequest();
$dataRequest['testData'] = '哎呀你填的是：' . $dataRequest['testData'];
MyResponse::json(0,'成功',$dataRequest);

class MyResponse{
    public static function json($code,$message="",$data=array()){
        $result=array(
            'code'=>$code,
            'msg'=>$message,
            'data'=>$data
        );
        $jsonResult = json_encode($result);
        // 加密拉 哈哈
        $rsa = new testRSA();
        $encode = $rsa->encode($jsonResult, true);
        $outputResult = array(
            'data' => $encode,
        );
        //输出json
        echo json_encode($outputResult);
        exit;
    }
}

class MyGetRequest {
    public static function getRequest() {
        $data = null;
        if (isset($_POST['data'])) {
            $data = $_POST["data"];
        }
        if (!$data) {
            MyResponse::json(-1, 'data参数为空', null);
        }
        $rsa = new testRSA();
        $decode = $rsa->encode($data, false);
        $arr = json_decode($decode,true);
        return $arr;
    }
}

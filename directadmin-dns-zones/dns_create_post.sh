#!/usr/bin/php
<?php

const MASTER_IP = '<your-master-ip>';
const API_KEY = '<your-api-key>';

class RestClient {
    public $conn_handle;

    private function do_request($method, $uri, $json=NULL) {
        if (!isset($conn_handle)) {
            $this->conn_handle = curl_init();
        }

        $options = [
            CURLOPT_URL => "https://api.yoursrs.com/v2/" . $uri,
            CURLOPT_CUSTOMREQUEST => $method,
            CURLOPT_POSTFIELDS => $json,
            CURLOPT_HTTPAUTH => CURLAUTH_ANY,
            CURLOPT_RETURNTRANSFER => 1,
            CURLOPT_HTTPHEADER => [
                'Content-Type: application/json',
                'Authorization: ApiKey ' . API_KEY,
                'Content-Length: ' . strlen($json)
            ]
        ];

        curl_setopt_array($this->conn_handle, $options);

        $response = curl_exec($this->conn_handle);
        $httpcode = curl_getinfo($this->conn_handle, CURLINFO_HTTP_CODE);
        if ($httpcode >= 400 && $httpcode < 500) {
            $json = json_decode($response, 1);

            throw new Exception( $json['type'] . ': ' . $json['message']);
        }
        if ($httpcode >= 500) {
            throw new Exception('ERROR: ' . $response);
        }
        if (curl_errno($this->conn_handle)) {
            throw new Exception(curl_error($this->conn_handle));
        }

        return json_decode($response, 1);
    }

    public function create_zone($domain_name, $master_ip) {
        $body = [
            'name' => $domain_name,
            'service' => 'PREMIUM',
            'master' => $master_ip
        ];
        return $this->do_request("POST", "dns/zones", json_encode($body));
    }
}

$client = new RestClient;
$client->create_zone(getenv('domain'), MASTER_IP);

exit(0);
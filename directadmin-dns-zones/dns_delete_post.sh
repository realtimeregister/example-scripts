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

    public function find_zone($domain_name) {
        $query = http_build_query([
            'name' => $domain_name,
            'service' => 'PREMIUM',
            'master' => MASTER_IP,
        ]);
        $result = $this->do_request("GET", "dns/zones?" . $query, json_encode($body));

        if (isset($result['entities']) && count($result['entities']) === 1) {
            return $result['entities'][0];
        }
        return null;
    }
    public function delete_zone($zone_id) {
        return $this->do_request("DELETE", "dns/zones/" . $zone_id);
    }
}

$client = new RestClient;
$zone = $client->find_zone(getenv('domain'));

if ($zone) {
    $client->delete_zone($zone['id']);
}

exit(0);
<?php

class RealtimeRegisterDNSManager implements EventListener
{

    // Your Realtime Register API key
    private $apiKey = '';
    // The primary IP address of your Plesk server
    private $masterIp = '';

    private $conn_handle;

    public function handleEvent($objectType, $objectId, $action, $oldValues, $newValues)
    {
        if ($this->apiKey == '') {
            error_log('RealtimeRegister apiKey empty!');
            return;
        }
        if ($this->masterIp == '') {
            error_log('RealtimeRegister masterIp empty!');
            return;
        }

        if ($objectType == 'domain_alias') {
            if ($action == 'domain_alias_create') {
                $this->createZone($newValues['Domain Alias Name']);
            } elseif ($action == 'domain_alias_delete') {
                $this->deleteZone($oldValues['Domain Alias Name']);
            }
        } elseif ($objectType == 'domain') {
            if ($action == 'domain_create') {
                $this->createZone($newValues['Domain Name']);
            } elseif ($action == 'domain_delete') {
                $this->deleteZone($oldValues['Domain Name']);
            }
        } elseif ($objectType == 'site') {
            if ($action == 'site_create') {
                $this->createZone($newValues['Domain Name']);
            } elseif ($action == 'site_delete') {
                $this->deleteZone($oldValues['Domain Name']);
            }
        }
    }

    private function createZone($domainName) {
        $body = [
            'name' => $domainName,
            'service' => 'PREMIUM',
            'master' => $this->masterIp
        ];
        $this->doRequest("POST", "dns/zones", json_encode($body));
    }

    private function deleteZone($domainName) {
        $zone = $this->findZone($domainName);
        if ($zone) {
            $this->doRequest("DELETE", "dns/zones/" . $zone['id']);
        }
    }

    private function findZone($domainName) {
        $query = http_build_query([
            'name' => $domainName,
            'service' => 'PREMIUM',
            'master' => $this->masterIp,
        ]);
        $result = $this->doRequest("GET", "dns/zones?" . $query);

        if (isset($result['entities']) && count($result['entities']) === 1) {
            return $result['entities'][0];
        }
        return null;
    }

    private function doRequest($method, $uri, $json=NULL) {
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
                'Authorization: ApiKey ' . $this->apiKey,
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
}

return new RealtimeRegisterDNSManager();

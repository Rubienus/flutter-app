<?php
require_once 'api_helper.php'; // Include the API helper file

class User {
    // replace URL with your own depending where it is deployed
    private $api_url = 'http://localhost/shopper/api/kitkat.php';
    // use your old API to test or create a new one here https://devlab.helioho.st/api/
    private $api_key = 'API KEY';

    public function list_users() {
        $postData = [
            'api_key' => $this->api_key,
            'load' => 'listing'
        ];

        // Call the helper function to fetch from API
        $response = fetch_from_api($this->api_url, $postData);

        if (isset($response['users'])) {
            return $response['users'];
        }

        return [];
    }

	// New method for creating a user
    public function create_user($first_name, $last_name, $password, $email, $role_id, $status) {
        $postData = [
            'api_key' => $this->api_key,
			'load' => 'create',
            'first_name' => $first_name,
            'last_name' => $last_name,
			'password' => $password,
            'email' => $email,
            'role_id' => $role_id,
            'status' => $status
        ];

        // Call the helper function to send the POST request to the API
        $response = push_to_api($this->api_url, $postData);

        // Check the response from the API
        if (isset($response['message']) && $response['message'] == 'User created successfully') {
            return ['status' => 'success', 'message' => 'User created successfully'];
        }

        return ['status' => 'error', 'message' => 'Error creating user'];
    }

    public function list_roles() {
        $postData = [
            'api_key' => $this->api_key,
            'load' => 'roles'
        ];

        // Call the helper function to fetch from API
        $response = fetch_from_api($this->api_url, $postData);

        if (isset($response['roles'])) {
            return $response['roles'];
        }

        return [];
    }

    public function list_permissions() {
        $postData = [
            'api_key' => $this->api_key,
            'load' => 'permissions'
        ];

        // Call the helper function to fetch from API
        $response = fetch_from_api($this->api_url, $postData);

        if (isset($response['permissions'])) {
            return $response['permissions'];
        }

        return [];
    }
}
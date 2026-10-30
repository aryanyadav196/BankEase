const API_BASE_URL = "http://localhost:8082/api";

async function readResponseBody(response) {
    const text = await response.text();

    if (!text.trim()) {
        return null;
    }

    if (response.headers.get("content-type")?.includes("application/json")) {
        try {
            return JSON.parse(text);
        } catch {
            return text;
        }
    }

    return text;
}

function getResponseError(data, status, fallback) {
    if (data && typeof data === "object") {
        return data.message || data.error || `${fallback} HTTP ${status}`;
    }

    if (typeof data === "string" && data.trim()) {
        return data;
    }

    return `${fallback} HTTP ${status}`;
}

async function apiRequest(endpoint, options = {}) {

    const storedAuth =
        localStorage.getItem("bankease_auth");

    let auth = null;

    if (storedAuth) {
        try {
            auth = JSON.parse(storedAuth);
        } catch {
            localStorage.removeItem("bankease_auth");
        }
    }

    const headers = {
        "Content-Type": "application/json",
        ...(options.headers || {}),
    };

    if (auth?.token) {
        headers.Authorization =
            `Bearer ${auth.token}`;
    }

    const response = await fetch(
        `${API_BASE_URL}${endpoint}`,
        {
            ...options,
            headers,
        }
    );

    const data = await readResponseBody(response);

    if (!response.ok) {
        throw new Error(getResponseError(data, response.status, "Request failed."));
    }

    return data;
}

export async function loginUser(
    email,
    password
) {

    const response = await fetch(
        `${API_BASE_URL}/auth/login`,
        {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify({
                email,
                password,
            }),
        }
    );

    const data = await readResponseBody(response);

    if (!response.ok) {
        throw new Error(getResponseError(data, response.status, "Login failed."));
    }

    if (!data || typeof data !== "object") {
        throw new Error("Login failed. The server returned an unexpected response.");
    }

    return data;
}

export async function registerCustomer(
    registrationData
) {
    return apiRequest(
        "/auth/register",
        {
            method: "POST",
            body: JSON.stringify(registrationData),
        }
    );
}

export async function registerStaff(
    role,
    registrationData
) {
    return apiRequest(
        `/auth/register/${role.toLowerCase()}`,
        {
            method: "POST",
            body: JSON.stringify(registrationData),
        }
    );
}

export async function getMyAccounts(customerId) {

    return apiRequest(
        `/accounts/customer/${customerId}`
    );
}

export async function getMyTransactions() {

    return apiRequest(
        "/transactions/my"
    );
}

export async function getMyServiceRequests(
    customerId
) {

    return apiRequest(
        `/service-requests/customer/${customerId}`
    );
}

export async function deposit(
    accountNumber,
    amount
) {

    return apiRequest(
        "/transactions/deposit",
        {
            method: "POST",
            body: JSON.stringify({
                accountNumber,
                amount: Number(amount),
            }),
        }
    );
}

export async function withdraw(
    accountNumber,
    amount
) {

    return apiRequest(
        "/transactions/withdraw",
        {
            method: "POST",
            body: JSON.stringify({
                accountNumber,
                amount: Number(amount),
            }),
        }
    );
}

export async function transfer(
    sourceAccountNumber,
    destinationAccountNumber,
    amount
) {

    return apiRequest(
        "/transactions/transfer",
        {
            method: "POST",
            body: JSON.stringify({
                sourceAccountNumber,
                destinationAccountNumber,
                amount: Number(amount),
            }),
        }
    );
}

export async function createServiceRequest(
    customerId,
    type,
    description
) {

    return apiRequest(
        `/service-requests?customerId=${customerId}`,
        {
            method: "POST",
            body: JSON.stringify({
                type,
                description,
            }),
        }
    );
}

export async function getMyProfile() {

    return apiRequest(
        "/customers/me"
    );
}

export async function getAllServiceRequests() {
    return apiRequest(
        "/service-requests"
    );
}

export async function startServiceRequest(
    requestId
) {
    return apiRequest(
        `/service-requests/${requestId}/start`,
        {
            method: "PATCH",
        }
    );
}

export async function resolveServiceRequest(
    requestId
) {
    return apiRequest(
        `/service-requests/${requestId}/resolve`,
        {
            method: "PATCH",
        }
    );
}

export async function rejectServiceRequest(
    requestId
) {
    return apiRequest(
        `/service-requests/${requestId}/reject`,
        {
            method: "PATCH",
        }
    );
}

export async function getAdminOverview() {
    return apiRequest(
        "/admin/overview"
    );
}

export async function getAdminCustomers() {
    return apiRequest(
        "/employee/customers"
    );
}

export async function getAdminAccounts() {
    return apiRequest(
        "/admin/accounts"
    );
}

export async function getAdminTransactions() {
    return apiRequest(
        "/admin/transactions"
    );
}

export async function getAdminAutomationRules() {
    return apiRequest(
        "/admin/automation-rules"
    );
}

export async function getAdminAuditLogs() {
    return apiRequest(
        "/admin/audit-logs"
    );
}

export async function getPendingUsers() {
    return apiRequest(
        "/admin/pending-users"
    );
}

export async function approvePendingUser(userId) {
    return apiRequest(
        `/admin/pending-users/${userId}/approve`,
        {
            method: "PATCH",
        }
    );
}

export async function rejectPendingUser(userId) {
    return apiRequest(
        `/admin/pending-users/${userId}`,
        {
            method: "DELETE",
        }
    );
}

import { useCallback, useEffect, useMemo, useState } from "react";
import { useAuth } from "../../context/useAuth";
import { getAllServiceRequests, startServiceRequest, resolveServiceRequest, rejectServiceRequest } from "../../services/api";
import "./EmployeeDashboard.css";

const API_BASE_URL = "http://localhost:8082/api";

function formatDate(value) {
    if (!value) return "—";
    const date = new Date(value);
    return Number.isNaN(date.getTime()) ? value : date.toLocaleString([], { dateStyle: "medium", timeStyle: "short" });
}

function label(value) {
    return value ? value.toLowerCase().split("_").map((part) => part[0].toUpperCase() + part.slice(1)).join(" ") : "—";
}

function EmployeeDashboard() {
    const { auth, logout } = useAuth();
    const [customers, setCustomers] = useState([]);
    const [selectedCustomer, setSelectedCustomer] = useState(null);
    const [customerQuery, setCustomerQuery] = useState("");
    const [accountType, setAccountType] = useState("SAVINGS");
    const [loading, setLoading] = useState(true);
    const [creating, setCreating] = useState(false);
    const [error, setError] = useState("");
    const [success, setSuccess] = useState("");
    const [serviceRequests, setServiceRequests] = useState([]);
    const [serviceRequestLoading, setServiceRequestLoading] = useState(true);
    const [serviceRequestError, setServiceRequestError] = useState("");
    const [serviceRequestActionId, setServiceRequestActionId] = useState(null);

    const loadCustomers = useCallback(async function loadCustomers() {
        try {
            setLoading(true);
            setError("");
            const response = await fetch(`${API_BASE_URL}/employee/customers`, { headers: { Authorization: `Bearer ${auth.token}` } });
            const text = await response.text();
            const data = text.trim() ? JSON.parse(text) : null;
            if (!response.ok) throw new Error(data?.message || `Unable to load customers. HTTP ${response.status}`);
            if (!Array.isArray(data)) throw new Error("Backend returned an unexpected customer response.");
            setCustomers(data);
        } catch (loadError) {
            setError(loadError.message || "Unable to load customers.");
        } finally {
            setLoading(false);
        }
    }, [auth]);

    const loadServiceRequests = useCallback(async function loadServiceRequests() {
        try {
            setServiceRequestLoading(true);
            setServiceRequestError("");
            const data = await getAllServiceRequests();
            if (!Array.isArray(data)) throw new Error("Backend returned an unexpected service request response.");
            setServiceRequests(data);
        } catch (loadError) {
            setServiceRequestError(loadError.message || "Unable to load service requests.");
        } finally {
            setServiceRequestLoading(false);
        }
    }, []);

    useEffect(() => {
        if (!auth?.token) return;
        async function initializeWorkspace() {
            await Promise.all([
                loadCustomers(),
                loadServiceRequests(),
            ]);
        }

        initializeWorkspace();
    }, [auth, loadCustomers, loadServiceRequests]);

    async function handleCreateAccount() {
        if (!selectedCustomer) return setError("Please select a customer.");
        if (!auth?.token) return setError("Your session has expired. Please login again.");
        try {
            setCreating(true); setError(""); setSuccess("");
            const response = await fetch(`${API_BASE_URL}/accounts?customerId=${selectedCustomer.id}`, { method: "POST", headers: { "Content-Type": "application/json", Authorization: `Bearer ${auth.token}` }, body: JSON.stringify({ accountType }) });
            const text = await response.text();
            const data = text.trim() ? JSON.parse(text) : null;
            if (!response.ok) throw new Error(data?.message || `Unable to create account. HTTP ${response.status}`);
            setSuccess(`Account ${data.accountNumber} created for ${selectedCustomer.fullName}.`);
        } catch (createError) {
            setError(createError.message || "Unable to create account.");
        } finally {
            setCreating(false);
        }
    }

    async function handleServiceRequestAction(requestId, action) {
        const actionHandlers = { start: startServiceRequest, resolve: resolveServiceRequest, reject: rejectServiceRequest };
        try {
            setServiceRequestActionId(requestId); setServiceRequestError("");
            await actionHandlers[action](requestId);
            setSuccess(`Service request ${action === "start" ? "started" : `${action}d`} successfully.`);
            await loadServiceRequests();
        } catch (actionError) {
            setServiceRequestError(actionError.message || `Unable to ${action} service request.`);
        } finally {
            setServiceRequestActionId(null);
        }
    }

    const visibleCustomers = useMemo(() => customers.filter((customer) => {
        const query = customerQuery.trim().toLowerCase();
        return !query || [customer.fullName, customer.email, customer.phone].some((value) => value?.toLowerCase().includes(query));
    }), [customers, customerQuery]);
    const pendingRequests = serviceRequests.filter((request) => request.status === "PENDING");
    const highPriorityRequests = serviceRequests.filter((request) => request.priority === "HIGH" && ["PENDING", "IN_PROGRESS"].includes(request.status));

    if (loading) return <div className="employee-loading">Loading operations workspace...</div>;

    return (
        <div className="employee-app">
            <header className="employee-topbar"><div className="employee-brand"><span> B </span><strong>BankEase</strong><small>Operations</small></div><div className="employee-user"><span>{auth?.email}</span><button onClick={logout}>Log out</button></div></header>
            <main className="employee-main">
                <section className="employee-command"><div><span className="employee-kicker">TODAY'S WORK</span><h1>What needs your attention?</h1><p>Work through requests, then help customers with their next banking action.</p></div><div className="work-counts"><div><strong>{highPriorityRequests.length}</strong><span>High priority</span></div><div><strong>{pendingRequests.length}</strong><span>Waiting</span></div><div><strong>{customers.length}</strong><span>Customers</span></div></div></section>
                {error && <div className="employee-message error">{error}</div>}
                {success && <div className="employee-message success">{success}</div>}
                <section className="attention-strip"><div><span className="employee-kicker">ATTENTION FIRST</span><h2>Priority queue</h2></div><div className="attention-items">{highPriorityRequests.slice(0, 3).map((request) => <button key={request.id} onClick={() => document.getElementById(`request-${request.id}`)?.scrollIntoView({ behavior: "smooth", block: "center" })}><span className="priority-dot" /><div><strong>{request.customerName}</strong><small>{label(request.type)} · {label(request.status)}</small></div><span>→</span></button>)}{!highPriorityRequests.length && <p>No high-priority requests require attention.</p>}</div></section>
                <div className="employee-layout">
                    <section className="work-queue"><div className="queue-heading"><div><span className="employee-kicker">SERVICE DESK</span><h2>Request queue</h2><p>Process the next customer request from here.</p></div><span className="queue-count">{serviceRequests.length} total</span></div>{serviceRequestError && <div className="employee-inline-error">{serviceRequestError}</div>}{serviceRequestLoading ? <div className="employee-state">Loading queue...</div> : !serviceRequests.length ? <div className="employee-state">The queue is clear.</div> : <div className="queue-list">{serviceRequests.map((request) => { const acting = serviceRequestActionId === request.id; return <article className={`queue-item ${request.priority === "HIGH" ? "urgent" : ""}`} id={`request-${request.id}`} key={request.id}><div className="queue-marker">{request.priority === "HIGH" ? "!" : "•"}</div><div className="queue-body"><div className="queue-item-top"><div><strong>{request.customerName || "Unknown customer"}</strong><span>{label(request.type)} · opened {formatDate(request.createdAt)}</span></div><span className={`queue-status ${request.status?.toLowerCase()}`}>{label(request.status)}</span></div><p>{request.description || "No description provided."}</p><div className="queue-item-bottom"><span className={request.priority === "HIGH" ? "high-label" : "muted-label"}>{label(request.priority)} priority</span><div className="queue-actions">{request.status === "PENDING" && <button className="queue-primary" disabled={acting} onClick={() => handleServiceRequestAction(request.id, "start")}>{acting ? "Starting..." : "Start processing"}</button>}{request.status === "IN_PROGRESS" && <><button className="queue-primary" disabled={acting} onClick={() => handleServiceRequestAction(request.id, "resolve")}>{acting ? "Updating..." : "Resolve"}</button><button className="queue-secondary" disabled={acting} onClick={() => handleServiceRequestAction(request.id, "reject")}>Reject</button></>}</div></div></div></article>; })}</div>}</section>
                    <aside className="customer-workbench"><div className="queue-heading"><div><span className="employee-kicker">CUSTOMER LOOKUP</span><h2>Find a customer</h2><p>Select one to prepare an account action.</p></div></div><input className="customer-search" type="search" placeholder="Name, email, or phone" value={customerQuery} onChange={(event) => setCustomerQuery(event.target.value)} /><div className="lookup-list">{visibleCustomers.slice(0, 8).map((customer) => <button className={selectedCustomer?.id === customer.id ? "selected" : ""} key={customer.id} onClick={() => setSelectedCustomer(customer)}><span className="customer-initial">{customer.fullName?.[0]}</span><span><strong>{customer.fullName}</strong><small>{customer.email}</small></span><b>→</b></button>)}{!visibleCustomers.length && <div className="employee-state">No matching customers.</div>}</div>{selectedCustomer && <div className="account-workbench"><span className="employee-kicker">ACCOUNT ACTION</span><h3>{selectedCustomer.fullName}</h3><p>{selectedCustomer.email}</p><label>New account type<select value={accountType} onChange={(event) => setAccountType(event.target.value)}><option value="SAVINGS">Savings account</option><option value="CURRENT">Current account</option></select></label><button className="queue-primary full" onClick={handleCreateAccount} disabled={creating}>{creating ? "Creating account..." : "Create account"}</button></div>}</aside>
                </div>
            </main>
            <nav className="employee-nav"><a href="#request-queue">Queue</a><a href="#customer-lookup">Customers</a><a href="#account-workbench">Account action</a></nav>
        </div>
    );
}

export default EmployeeDashboard;

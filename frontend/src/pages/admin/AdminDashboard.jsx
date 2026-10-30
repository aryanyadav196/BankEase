import { useCallback, useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../../context/useAuth";
import { approvePendingUser, getAdminAccounts, getAdminAuditLogs, getAdminAutomationRules, getAdminCustomers, getAdminOverview, getAdminTransactions, getAllServiceRequests, getPendingUsers, rejectPendingUser } from "../../services/api";
import "./AdminDashboard.css";

function label(value) { return value ? value.toLowerCase().split("_").map((part) => part[0].toUpperCase() + part.slice(1)).join(" ") : "—"; }
function date(value) { if (!value) return "—"; const parsed = new Date(value); return Number.isNaN(parsed.getTime()) ? value : parsed.toLocaleString([], { dateStyle: "medium", timeStyle: "short" }); }
function money(value) { return value === null || value === undefined ? "—" : Number(value).toLocaleString([], { style: "currency", currency: "INR" }); }

function LoadState({ loading, error, empty, children }) {
    if (loading) return <div className="admin-control-state">Loading...</div>;
    if (error) return <div className="admin-control-state error">{error}</div>;
    if (empty) return <div className="admin-control-state">Nothing to show here yet.</div>;
    return children;
}

function AdminDashboard() {
    const { auth, logout } = useAuth();
    const navigate = useNavigate();
    const [overview, setOverview] = useState(null);
    const [overviewLoading, setOverviewLoading] = useState(true);
    const [overviewError, setOverviewError] = useState("");
    const [customers, setCustomers] = useState([]);
    const [customerSearch, setCustomerSearch] = useState("");
    const [customersLoading, setCustomersLoading] = useState(true);
    const [customersError, setCustomersError] = useState("");
    const [accounts, setAccounts] = useState([]);
    const [accountsLoading, setAccountsLoading] = useState(true);
    const [accountsError, setAccountsError] = useState("");
    const [transactions, setTransactions] = useState([]);
    const [transactionsLoading, setTransactionsLoading] = useState(true);
    const [transactionsError, setTransactionsError] = useState("");
    const [requests, setRequests] = useState([]);
    const [requestsLoading, setRequestsLoading] = useState(true);
    const [requestsError, setRequestsError] = useState("");
    const [rules, setRules] = useState([]);
    const [rulesLoading, setRulesLoading] = useState(true);
    const [rulesError, setRulesError] = useState("");
    const [logs, setLogs] = useState([]);
    const [logsLoading, setLogsLoading] = useState(true);
    const [logsError, setLogsError] = useState("");
    const [pendingUsers, setPendingUsers] = useState([]);
    const [pendingUsersLoading, setPendingUsersLoading] = useState(true);
    const [pendingUsersError, setPendingUsersError] = useState("");
    const [pendingUserActionId, setPendingUserActionId] = useState(null);

    const loadPendingUsers = useCallback(async () => {
        try {
            setPendingUsersLoading(true);
            setPendingUsersError("");
            const data = await getPendingUsers();
            if (!Array.isArray(data)) throw new Error("Unexpected pending registration response.");
            setPendingUsers(data);
        } catch (loadError) {
            setPendingUsersError(loadError.message || "Unable to load pending registrations.");
        } finally {
            setPendingUsersLoading(false);
        }
    }, []);

    useEffect(() => {
        if (!auth?.token || auth.role !== "ADMIN") { navigate("/admin/login", { replace: true }); return; }
        async function load(loader, setData, setLoading, setError, name, object = false) {
            try { setLoading(true); setError(""); const data = await loader(); if (object ? !data || typeof data !== "object" : !Array.isArray(data)) throw new Error(`Unexpected ${name} response.`); setData(data); }
            catch (loadError) { setError(loadError.message || `Unable to load ${name}.`); }
            finally { setLoading(false); }
        }
        load(getAdminOverview, setOverview, setOverviewLoading, setOverviewError, "overview", true);
        load(getAdminCustomers, setCustomers, setCustomersLoading, setCustomersError, "customers");
        load(getAdminAccounts, setAccounts, setAccountsLoading, setAccountsError, "accounts");
        load(getAdminTransactions, setTransactions, setTransactionsLoading, setTransactionsError, "transactions");
        load(getAllServiceRequests, setRequests, setRequestsLoading, setRequestsError, "service requests");
        load(getAdminAutomationRules, setRules, setRulesLoading, setRulesError, "automation rules");
        load(getAdminAuditLogs, setLogs, setLogsLoading, setLogsError, "audit logs");
        async function initializePendingUsers() {
            await loadPendingUsers();
        }

        initializePendingUsers();
    }, [auth, navigate, loadPendingUsers]);

    async function handlePendingUserAction(userId, action) {
        try {
            setPendingUserActionId(userId);
            setPendingUsersError("");
            if (action === "approve") {
                await approvePendingUser(userId);
            } else {
                await rejectPendingUser(userId);
            }
            await loadPendingUsers();
        } catch (actionError) {
            setPendingUsersError(actionError.message || "Unable to update registration request.");
        } finally {
            setPendingUserActionId(null);
        }
    }

    const filteredCustomers = useMemo(() => customers.filter((customer) => { const query = customerSearch.trim().toLowerCase(); return !query || [customer.fullName, customer.email, customer.phone].some((value) => value?.toLowerCase().includes(query)); }), [customers, customerSearch]);
    const attention = [...requests.filter((request) => request.priority === "HIGH" && request.status !== "RESOLVED" && request.status !== "REJECTED").map((request) => ({ type: "Service request", title: request.customerName, detail: `${label(request.type)} · ${label(request.status)}`, tone: "high" })), ...transactions.filter((transaction) => transaction.status === "REJECTED").slice(0, 4).map((transaction) => ({ type: "Rejected transaction", title: transaction.transactionReference, detail: money(transaction.amount), tone: "danger" })), ...accounts.filter((account) => account.status === "BLOCKED").slice(0, 3).map((account) => ({ type: "Blocked account", title: account.accountNumber, detail: account.customerName, tone: "danger" }))];
    const activeRules = rules.filter((rule) => rule.active);

    return (
        <div className="admin-control-center">
            <header className="admin-control-topbar"><div className="admin-control-brand"><span>B</span><div><strong>BankEase</strong><small>System control centre</small></div></div><div className="admin-control-user"><span>{auth?.email}</span><button onClick={logout}>Log out</button></div></header>
            <main className="admin-control-main">
                <section className="control-intro"><div><span className="control-kicker">SYSTEM CONTROL</span><h1>Is BankEase healthy?</h1><p>A focused view of system condition, exceptions, activity, and controls.</p></div><div className="system-status"><span className="status-pulse" />Operational data centre<strong>Live monitoring</strong></div></section>

                <section className="health-panel"><div className="health-heading"><div><span className="control-kicker">SYSTEM HEALTH</span><h2>At a glance</h2></div><span>Live data</span></div><LoadState loading={overviewLoading} error={overviewError} empty={!overview}><div className="health-grid">{[["totalUsers", "Users"], ["totalCustomers", "Customers"], ["totalAccounts", "Accounts"], ["totalTransactions", "Transactions"], ["pendingServiceRequests", "Pending requests"], ["rejectedTransactions", "Rejected transactions"], ["blockedAccounts", "Blocked accounts"], ["activeAutomationRules", "Active rules"], ["totalAuditLogs", "Audit events"]].map(([key, name]) => <div key={key}><span>{name}</span><strong>{overview?.[key] ?? 0}</strong></div>)}</div></LoadState></section>

                <section className="attention-panel"><div className="panel-heading"><div><span className="control-kicker">ATTENTION REQUIRED</span><h2>Exceptions and intervention</h2></div><span>{attention.length} items</span></div><LoadState loading={transactionsLoading || accountsLoading || requestsLoading} error={requestsError || transactionsError || accountsError} empty={!attention.length}><div className="exception-list">{attention.slice(0, 8).map((item, index) => <div className={`exception-item ${item.tone}`} key={`${item.title}-${index}`}><span className="exception-symbol">{item.tone === "high" ? "!" : "×"}</span><div><small>{item.type}</small><strong>{item.title}</strong><span>{item.detail}</span></div><b>Review</b></div>)}</div></LoadState></section>

                <section className="pending-access-panel"><div className="panel-heading"><div><span className="control-kicker">ACCESS REVIEW</span><h2>Pending staff applications</h2></div><span>{pendingUsers.length} waiting</span></div><LoadState loading={pendingUsersLoading} error={pendingUsersError} empty={!pendingUsers.length}><div className="pending-access-list">{pendingUsers.map((user) => <div className="pending-access-item" key={user.id}><div><strong>{user.email}</strong><span>{label(user.role)} · {user.status}</span></div><div><button className="approve-user" disabled={pendingUserActionId === user.id} onClick={() => handlePendingUserAction(user.id, "approve")}>{pendingUserActionId === user.id ? "Updating..." : "Approve"}</button><button className="reject-user" disabled={pendingUserActionId === user.id} onClick={() => handlePendingUserAction(user.id, "reject")}>Reject</button></div></div>)}</div></LoadState></section>

                <section className="activity-layout"><div className="activity-feed"><div className="panel-heading"><div><span className="control-kicker">OPERATIONAL ACTIVITY</span><h2>Latest movement</h2></div><span>{logs.length} audit events</span></div><LoadState loading={logsLoading || transactionsLoading} error={logsError || transactionsError} empty={!logs.length && !transactions.length}><div className="feed-list">{logs.slice(0, 5).map((log) => <div className="feed-item" key={`log-${log.id}`}><span className="feed-marker audit">✓</span><div><strong>{label(log.action)}</strong><span>{log.description}</span><small>{date(log.createdAt)} · {log.user || "System"}</small></div></div>)}{transactions.slice(0, 3).map((transaction) => <div className="feed-item" key={`transaction-${transaction.id}`}><span className="feed-marker transaction">↗</span><div><strong>{label(transaction.type)} · {label(transaction.status)}</strong><span>{transaction.transactionReference} · {money(transaction.amount)}</span><small>{date(transaction.createdAt)}</small></div></div>)}</div></LoadState></div><div className="rules-summary"><div className="panel-heading"><div><span className="control-kicker">AUTOMATION</span><h2>Rules in force</h2></div><span>{activeRules.length} active</span></div><LoadState loading={rulesLoading} error={rulesError} empty={!rules.length}><div className="rule-list">{rules.slice(0, 5).map((rule) => <div key={rule.id}><span className={`rule-state ${rule.active ? "on" : "off"}`} /> <div><strong>{rule.name}</strong><small>{label(rule.type)}</small></div><b>{rule.active ? "On" : "Off"}</b></div>)}</div></LoadState><p className="control-note">Rule-based automation keeps decisions consistent and traceable.</p></div></section>

                <section className="admin-data-grid">
                    <details className="control-drawer" id="customers" open><summary><span>Customers</span><b>{customers.length}</b></summary><div className="drawer-content"><input type="search" placeholder="Search customers" value={customerSearch} onChange={(event) => setCustomerSearch(event.target.value)} /><LoadState loading={customersLoading} error={customersError} empty={!filteredCustomers.length}><div className="compact-list">{filteredCustomers.slice(0, 8).map((customer) => <div key={customer.id}><strong>{customer.fullName}</strong><span>{customer.email} · {customer.phone || "No phone"}</span></div>)}</div></LoadState></div></details>
                    <details className="control-drawer" id="accounts"><summary><span>Accounts</span><b>{accounts.length}</b></summary><div className="drawer-content"><LoadState loading={accountsLoading} error={accountsError} empty={!accounts.length}><div className="compact-list">{accounts.slice(0, 8).map((account) => <div key={account.id}><strong>{account.accountNumber} <em className={account.status?.toLowerCase()}>{label(account.status)}</em></strong><span>{account.customerName} · {label(account.accountType)} · {money(account.balance)}</span></div>)}</div></LoadState></div></details>
                    <details className="control-drawer" id="transactions"><summary><span>Transactions</span><b>{transactions.length}</b></summary><div className="drawer-content"><LoadState loading={transactionsLoading} error={transactionsError} empty={!transactions.length}><div className="compact-list">{transactions.slice(0, 8).map((transaction) => <div key={transaction.id}><strong>{transaction.transactionReference} <em className={transaction.status?.toLowerCase()}>{label(transaction.status)}</em></strong><span>{label(transaction.type)} · {money(transaction.amount)} · {date(transaction.createdAt)}</span></div>)}</div></LoadState></div></details>
                    <details className="control-drawer" id="service-requests"><summary><span>Service requests</span><b>{requests.length}</b></summary><div className="drawer-content"><LoadState loading={requestsLoading} error={requestsError} empty={!requests.length}><div className="compact-list">{requests.slice(0, 8).map((request) => <div key={request.id}><strong>{request.customerName || "Unknown customer"} <em className={request.status?.toLowerCase()}>{label(request.status)}</em></strong><span>{label(request.type)} · {label(request.priority)} priority · {date(request.updatedAt)}</span></div>)}</div></LoadState></div></details>
                    <details className="control-drawer" id="audit-logs"><summary><span>Audit trail</span><b>{logs.length}</b></summary><div className="drawer-content"><LoadState loading={logsLoading} error={logsError} empty={!logs.length}><div className="compact-list">{logs.slice(0, 8).map((log) => <div key={log.id}><strong>{label(log.action)}</strong><span>{label(log.ruleType)} · {label(log.result)} · {date(log.createdAt)}</span></div>)}</div></LoadState></div></details>
                </section>
            </main>
            <nav className="admin-control-nav"><a href="#customers">Users & customers</a><a href="#accounts">Accounts</a><a href="#service-requests">Service</a><a href="#audit-logs">Audit</a></nav>
        </div>
    );
}

export default AdminDashboard;

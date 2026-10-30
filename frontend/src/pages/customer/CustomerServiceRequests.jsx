import { useCallback, useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { createServiceRequest, getMyProfile, getMyServiceRequests } from "../../services/api";
import { useAuth } from "../../context/useAuth";
import "./CustomerDashboard.css";

const requestTypes = [
    ["ACCOUNT_ISSUE", "Account issue"],
    ["TRANSACTION_ISSUE", "Transaction issue"],
    ["ACCOUNT_BLOCK_REQUEST", "Block an account"],
    ["GENERAL_QUERY", "General query"],
];

const statusLabels = {
    PENDING: "Pending",
    IN_PROGRESS: "In progress",
    RESOLVED: "Resolved",
    REJECTED: "Rejected",
};

function CustomerServiceRequests() {
    const { logout } = useAuth();
    const navigate = useNavigate();
    const [profile, setProfile] = useState(null);
    const [requests, setRequests] = useState([]);
    const [type, setType] = useState("");
    const [description, setDescription] = useState("");
    const [loading, setLoading] = useState(true);
    const [submitting, setSubmitting] = useState(false);
    const [error, setError] = useState("");
    const [success, setSuccess] = useState("");

    const loadRequests = useCallback(async (customerId) => {
        const customerRequests = await getMyServiceRequests(customerId);
        setRequests(Array.isArray(customerRequests) ? customerRequests : []);
    }, []);

    useEffect(() => {
        async function initialize() {
            try {
                setLoading(true);
                setError("");
                const customer = await getMyProfile();
                setProfile(customer);
                await loadRequests(customer.id);
            } catch (loadError) {
                setError(loadError.message || "Unable to load service requests.");
            } finally {
                setLoading(false);
            }
        }

        initialize();
    }, [loadRequests]);

    async function handleSubmit(event) {
        event.preventDefault();
        setError("");
        setSuccess("");
        const trimmedDescription = description.trim();
        if (!type) return setError("Please choose a request category.");
        if (!trimmedDescription) return setError("Please describe what you need help with.");
        if (!profile?.id) return setError("Your customer profile could not be found. Please sign in again.");

        try {
            setSubmitting(true);
            await createServiceRequest(profile.id, type, trimmedDescription);
            await loadRequests(profile.id);
            setType("");
            setDescription("");
            setSuccess("Your service request was submitted successfully.");
        } catch (submitError) {
            setError(submitError.message || "Unable to submit service request.");
        } finally {
            setSubmitting(false);
        }
    }

    if (loading) return <div className="customer-loading">Loading your service requests...</div>;
    if (error && !profile) return <div className="customer-load-error"><h2>Unable to load service requests</h2><p>{error}</p><button className="primary-action" onClick={() => navigate("/customer")}>Back to dashboard</button></div>;

    return (
        <div className="customer-app">
            <header className="customer-topbar"><div className="customer-brand"><span className="brand-mark">B</span><strong>BankEase</strong></div><div className="customer-user"><span>Personal banking</span><button onClick={logout}>Log out</button></div></header>
            <main className="customer-main service-requests-page">
                <button className="back-action" onClick={() => navigate("/customer")}>← Back to dashboard</button>
                <section className="customer-greeting"><div><span className="customer-kicker">CUSTOMER SUPPORT</span><h1>Service requests</h1><p>Ask for help and keep track of your support requests.</p></div></section>
                {error && <div className="customer-message error" role="alert">{error}</div>}
                {success && <div className="customer-message success" role="status">{success}</div>}
                <div className="service-request-layout">
                    <section className="service-request-form-panel"><span className="customer-kicker">GET SUPPORT</span><h2>Create a service request</h2><p>Tell us what you need and our team will review it.</p><form className="money-form" onSubmit={handleSubmit} noValidate><label htmlFor="request-type">Request category<select id="request-type" value={type} onChange={(event) => setType(event.target.value)} disabled={submitting}><option value="">Select a category</option>{requestTypes.map(([value, label]) => <option key={value} value={value}>{label}</option>)}</select></label><label htmlFor="request-description">Description<textarea id="request-description" rows="6" maxLength="1000" placeholder="Describe your request..." value={description} onChange={(event) => setDescription(event.target.value)} disabled={submitting} /><small className="field-hint">{description.length}/1000 characters</small></label><button className="primary-action" disabled={submitting}>{submitting ? "Submitting request..." : "Submit service request"}</button></form></section>
                    <section className="service-request-list-panel"><div className="customer-section-title"><div><span className="customer-kicker">YOUR HISTORY</span><h2>Request history</h2></div><span>{requests.length} total</span></div>{!requests.length ? <div className="customer-empty">You have not submitted any service requests yet.</div> : <div className="service-request-list">{requests.map((request) => <article className="service-request-item" key={request.id}><div className="service-request-item-heading"><strong>{requestTypes.find(([value]) => value === request.type)?.[1] || request.type}</strong><span className={`request-status ${request.status?.toLowerCase()}`}>{statusLabels[request.status] || request.status}</span></div><p>{request.description}</p><small>{request.createdAt ? new Date(request.createdAt).toLocaleDateString() : "Recently submitted"}</small></article>)}</div>}</section>
                </div>
            </main>
        </div>
    );
}

export default CustomerServiceRequests;

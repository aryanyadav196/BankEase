import { useCallback, useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import {
    getMyAccounts,
    getMyProfile,
    getMyTransactions,
    getMyServiceRequests,
    deposit,
    withdraw,
    transfer,
} from "../../services/api";
import { useAuth } from "../../context/useAuth";
import "./CustomerDashboard.css";

function CustomerDashboard() {
    const { logout } = useAuth();
    const navigate = useNavigate();
    const [destinationAccount, setDestinationAccount] = useState("");
    const [transferAmount, setTransferAmount] = useState("");
    const [profile, setProfile] = useState(null);
    const [accounts, setAccounts] = useState([]);
    const [transactions, setTransactions] = useState([]);
    const [requests, setRequests] = useState([]);
    const [selectedAccount, setSelectedAccount] = useState("");
    const [transactionAmount, setTransactionAmount] = useState("");
    const [transactionType, setTransactionType] = useState("DEPOSIT");
    const [loading, setLoading] = useState(true);
    const [processing, setProcessing] = useState(false);
    const [error, setError] = useState("");
    const [transactionMessage, setTransactionMessage] = useState("");

    const loadDashboard = useCallback(async function loadDashboard() {
        try {
            setLoading(true);
            setError("");
            const customer = await getMyProfile();
            const [customerAccounts, customerTransactions, customerRequests] = await Promise.all([
                getMyAccounts(customer.id),
                getMyTransactions(),
                getMyServiceRequests(customer.id),
            ]);
            setProfile(customer);
            setAccounts(customerAccounts);
            setTransactions(customerTransactions);
            setRequests(customerRequests);
            if (customerAccounts.length > 0) {
                setSelectedAccount((currentAccount) => currentAccount || customerAccounts[0].accountNumber);
            }
        } catch (loadError) {
            setError(loadError.message || "Unable to load dashboard.");
        } finally {
            setLoading(false);
        }
    }, []);

    useEffect(() => {
        async function initializeDashboard() {
            await loadDashboard();
        }

        initializeDashboard();
    }, [loadDashboard]);

    async function handleTransaction(event) {
        event.preventDefault();
        setError("");
        setTransactionMessage("");
        if (!selectedAccount) return setError("Please select an account.");
        if (!transactionAmount || Number(transactionAmount) <= 0) return setError("Transaction amount must be greater than zero.");
        try {
            setProcessing(true);
            const response = transactionType === "DEPOSIT"
                ? await deposit(selectedAccount, transactionAmount)
                : await withdraw(selectedAccount, transactionAmount);
            if (response.status === "REJECTED") {
                setError(response.description || "Transaction was rejected.");
            } else {
                setTransactionMessage(`${transactionType === "DEPOSIT" ? "Deposit" : "Withdrawal"} completed successfully.`);
                setTransactionAmount("");
                await loadDashboard();
            }
        } catch (transactionError) {
            setError(transactionError.message || "Transaction failed.");
        } finally {
            setProcessing(false);
        }
    }

    async function handleTransfer(event) {
        event.preventDefault();
        setError("");
        setTransactionMessage("");
        if (!selectedAccount) return setError("Please select a source account.");
        if (!destinationAccount.trim()) return setError("Please enter the destination account number.");
        if (!transferAmount || Number(transferAmount) <= 0) return setError("Transfer amount must be greater than zero.");
        if (selectedAccount.trim() === destinationAccount.trim()) return setError("Source and destination accounts must be different.");
        try {
            setProcessing(true);
            const response = await transfer(selectedAccount, destinationAccount.trim(), transferAmount);
            if (response.status === "REJECTED") {
                setError(response.description || "Transfer was rejected.");
            } else {
                setTransactionMessage("Fund transfer completed successfully.");
                setDestinationAccount("");
                setTransferAmount("");
                await loadDashboard();
            }
        } catch (transferError) {
            setError(transferError.message || "Transfer failed.");
        } finally {
            setProcessing(false);
        }
    }

    if (loading) return <div className="customer-loading">Loading your banking space...</div>;
    if (error && !profile) return <div className="customer-load-error"><h2>Unable to load your banking space</h2><p>{error}</p></div>;

    const totalBalance = accounts.reduce((total, account) => total + Number(account.balance || 0), 0);
    const accountOptions = accounts.map((account) => <option key={account.id} value={account.accountNumber}>{account.accountType} · •••• {account.accountNumber?.slice(-4)}</option>);

    return (
        <div className="customer-app" id="top">
            <header className="customer-topbar">
                <div className="customer-brand"><span className="brand-mark">B</span><strong>BankEase</strong></div>
                <div className="customer-user"><span>Personal banking</span><button onClick={logout}>Log out</button></div>
            </header>
            <main className="customer-main">
                <section className="customer-greeting"><div><span className="customer-kicker">GOOD TO SEE YOU</span><h1>{profile?.fullName}</h1><p>Your money, clearly organised.</p></div><div className="customer-date">{new Date().toLocaleDateString([], { weekday: "long", month: "long", day: "numeric" })}</div></section>
                {error && <div className="customer-message error">{error}</div>}
                {transactionMessage && <div className="customer-message success">{transactionMessage}</div>}
                <section className="money-overview"><div><span>Total across accounts</span><strong>₹{totalBalance.toLocaleString("en-IN", { minimumFractionDigits: 2 })}</strong><small>{accounts.length} account{accounts.length === 1 ? "" : "s"} · {requests.length} service request{requests.length === 1 ? "" : "s"}</small></div><div className="balance-mark">₹</div></section>
                <section className="quick-actions" aria-label="Quick actions"><a href="#move-money"><span>↕</span><strong>Deposit / withdraw</strong></a><a href="#transfer"><span>→</span><strong>Transfer money</strong></a><a href="#activity"><span>↗</span><strong>View activity</strong></a><a href="#help"><span>?</span><strong>Get help</strong></a></section>
                <section className="account-strip"><div className="customer-section-title"><div><span className="customer-kicker">YOUR MONEY</span><h2>Accounts</h2></div><span>{accounts.length} total</span></div><div className="account-scroller">{accounts.map((account) => <button className={`account-tile ${selectedAccount === account.accountNumber ? "active" : ""}`} key={account.id} onClick={() => setSelectedAccount(account.accountNumber)}><span>{account.accountType} account</span><strong>₹{Number(account.balance || 0).toLocaleString("en-IN", { minimumFractionDigits: 2 })}</strong><small>•••• {account.accountNumber?.slice(-4)} · {account.status}</small></button>)}{!accounts.length && <div className="customer-empty">No accounts available yet.</div>}</div></section>
                <div className="customer-workspace">
                    <section className="money-action-panel" id="move-money"><div className="customer-section-title"><div><span className="customer-kicker">MOVE MONEY</span><h2>Make a transaction</h2></div></div><form onSubmit={handleTransaction} className="money-form"><div className="segmented-control"><button type="button" className={transactionType === "DEPOSIT" ? "selected" : ""} onClick={() => setTransactionType("DEPOSIT")}>Deposit</button><button type="button" className={transactionType === "WITHDRAWAL" ? "selected" : ""} onClick={() => setTransactionType("WITHDRAWAL")}>Withdraw</button></div><label>Account<select value={selectedAccount} onChange={(event) => setSelectedAccount(event.target.value)} disabled={!accounts.length}>{accountOptions}</select></label><label>Amount<input type="number" min="0.01" step="0.01" placeholder="0.00" value={transactionAmount} onChange={(event) => setTransactionAmount(event.target.value)} disabled={!accounts.length} /></label><button className="primary-action" disabled={!accounts.length || processing}>{processing ? "Processing..." : transactionType === "DEPOSIT" ? "Deposit money" : "Withdraw money"}</button></form>{!accounts.length && <p className="customer-note">An account is needed before you can move money.</p>}</section>
                    <section className="transfer-panel" id="transfer"><div className="customer-section-title"><div><span className="customer-kicker">SEND MONEY</span><h2>Transfer to a BankEase account</h2></div></div><form onSubmit={handleTransfer} className="money-form"><label>From account<select value={selectedAccount} onChange={(event) => setSelectedAccount(event.target.value)} disabled={!accounts.length}>{accountOptions}</select></label><label>Destination account<input type="text" placeholder="Account number" value={destinationAccount} onChange={(event) => setDestinationAccount(event.target.value)} disabled={!accounts.length} /></label><label>Amount<input type="number" min="0.01" step="0.01" placeholder="0.00" value={transferAmount} onChange={(event) => setTransferAmount(event.target.value)} disabled={!accounts.length} /></label><button className="primary-action" disabled={!accounts.length || processing}>{processing ? "Processing..." : "Transfer money"}</button></form></section>
                </div>
                <div className="customer-lower-grid">
                    <section className="activity-panel" id="activity"><div className="customer-section-title"><div><span className="customer-kicker">RECENT ACTIVITY</span><h2>What happened</h2></div><span>{transactions.length} total</span></div>{transactions.slice(0, 5).map((transaction) => <div className="activity-item" key={transaction.id}><span className={`activity-icon ${transaction.status?.toLowerCase()}`}>{transaction.type === "TRANSFER" ? "→" : transaction.type === "DEPOSIT" ? "+" : "−"}</span><div><strong>{transaction.type}</strong><small>{transaction.transactionReference}</small></div><div className="activity-amount"><strong>₹{Number(transaction.amount || 0).toLocaleString("en-IN", { minimumFractionDigits: 2 })}</strong><small className={transaction.status?.toLowerCase()}>{transaction.status}</small></div></div>)}{!transactions.length && <div className="customer-empty">No transactions yet.</div>}</section>
                    <section className="help-panel" id="help"><div className="help-icon">?</div><span className="customer-kicker">NEED A HAND?</span><h2>Service and support</h2><p>Track requests and get help with your banking needs.</p><div className="request-preview">{requests.slice(0, 3).map((request) => <div key={request.id}><strong>{request.type}</strong><span className={`request-status ${request.status?.toLowerCase()}`}>{request.status}</span></div>)}{!requests.length && <span>No service requests yet.</span>}</div><div className="support-actions"><button className="primary-action" onClick={() => navigate("/customer/service-requests/new")}>Create service request</button><button className="text-action" onClick={() => navigate("/customer/service-requests")}>View service requests →</button></div></section>
                </div>
            </main>
            <nav className="customer-bottom-nav"><a href="#top">Home</a><a href="#activity">Activity</a><a href="#move-money">Move money</a><a href="#help">Support</a></nav>
        </div>
    );
}

export default CustomerDashboard;

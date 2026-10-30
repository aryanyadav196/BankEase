import { useState } from "react";
import { Link, useNavigate, useSearchParams } from "react-router-dom";
import { loginUser } from "../../services/api";
import { useAuth } from "../../context/useAuth";
import "./Login.css";

const loginContent = {
    CUSTOMER: {
        eyebrow: "PERSONAL BANKING",
        title: "Welcome back",
        description: "Manage your accounts and transactions.",
        submit: "Sign in to banking",
        accent: "customer",
        fieldLabel: "Email",
        placeholder: "you@example.com",
        contextTitle: "Your everyday banking, in one place.",
        contextText: "See what you have, what happened, and what you can do next.",
        contextItems: ["Account balances", "Quick money movement", "Recent activity"],
    },
    EMPLOYEE: {
        eyebrow: "EMPLOYEE OPERATIONS",
        title: "Welcome back",
        description: "Manage customer services and daily banking operations.",
        submit: "Sign in to operations",
        accent: "employee",
        fieldLabel: "Work Email",
        placeholder: "name@bankease.com",
        contextTitle: "Keep customer operations moving.",
        contextText: "Keep the work that matters moving with a focused operations workspace.",
        contextItems: ["Customer service", "Account operations", "Service requests"],
    },
    ADMIN: {
        eyebrow: "ADMINISTRATION",
        title: "Administration access",
        description: "Monitor banking operations, automation and system activity.",
        submit: "Enter control center",
        accent: "admin",
        fieldLabel: "Admin Email",
        placeholder: "admin@bankease.com",
        contextTitle: "Monitor, control and audit banking operations.",
        contextText: "A controlled entry point for system health, automation and activity.",
        contextItems: ["System monitoring", "Automation", "Audit activity"],
    },
};

const roleOptions = ["CUSTOMER", "EMPLOYEE", "ADMIN"];

function normalizeRole(value) {
    const role = value?.toUpperCase();
    return roleOptions.includes(role) ? role : "CUSTOMER";
}

function displayRole(role) {
    return role.charAt(0) + role.slice(1).toLowerCase();
}

function Login() {
    const navigate = useNavigate();
    const [searchParams, setSearchParams] = useSearchParams();
    const { login } = useAuth();
    const role = normalizeRole(searchParams.get("role"));
    const content = loginContent[role];
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [error, setError] = useState("");
    const [loading, setLoading] = useState(false);

    function selectRole(nextRole) {
        setError("");
        setSearchParams({ role: nextRole.toLowerCase() });
    }

    async function handleSubmit(event) {
        event.preventDefault();
        setError("");
        setLoading(true);

        try {
            const response = await loginUser(email, password);

            if (response.role !== role) {
                setError(`These credentials belong to a ${displayRole(response.role)} account. Please select ${displayRole(response.role)}.`);
                return;
            }

            login(response);
            navigate(`/${response.role.toLowerCase()}`);
        } catch (loginError) {
            setError(loginError.message || "Unable to login.");
        } finally {
            setLoading(false);
        }
    }

    return (
        <div className={`login-page login-${content.accent}`}>
            <div className="login-shell">
                <aside className="login-context">
                    <div className="login-brand"><div className="brand-icon" aria-hidden="true">B</div><div><h1>BankEase</h1><p>{content.eyebrow}</p></div></div>
                    <div className="login-context-copy"><span className="login-context-kicker">{content.eyebrow}</span><h2>{content.contextTitle}</h2><p>{content.contextText}</p><ul>{content.contextItems.map((item) => <li key={item}>{item}</li>)}</ul></div>
                    <span className="login-context-foot">Secure role-based access</span>
                </aside>

                <section className="login-card">
                    <div className="login-role-selector" aria-label="Choose sign-in role">
                        <span>Sign in as</span>
                        <div className="login-role-options">
                            {roleOptions.map((option) => (
                                <button
                                    key={option}
                                    type="button"
                                    className={option === role ? "active" : ""}
                                    aria-pressed={option === role}
                                    onClick={() => selectRole(option)}
                                >
                                    {displayRole(option)}
                                </button>
                            ))}
                        </div>
                    </div>
                    <div className="login-heading"><span className="login-eyebrow">{content.eyebrow}</span><h2>{content.title}</h2><p>{content.description}</p></div>
                    <form className="login-form" onSubmit={handleSubmit}>
                        <div className="form-group"><label htmlFor="login-email">{content.fieldLabel}</label><input id="login-email" type="email" placeholder={content.placeholder} value={email} onChange={(event) => setEmail(event.target.value)} autoComplete="username" required /></div>
                        <div className="form-group"><label htmlFor="login-password">Password</label><input id="login-password" type="password" placeholder="Enter your password" value={password} onChange={(event) => setPassword(event.target.value)} autoComplete="current-password" required /></div>
                        {error && <div className="login-error" role="alert">{error}</div>}
                        <button type="submit" className="login-button" disabled={loading}>{loading ? "Signing in..." : content.submit}</button>
                    </form>
                    <p className="login-register-link">{role === "CUSTOMER" ? "Don't have an account?" : role === "EMPLOYEE" ? "Need an employee account?" : "Need administrator access?"}{" "}<Link to={`/${role.toLowerCase()}/register`}>Register</Link></p>
                    <div className="login-footer"><span>Use the portal assigned to your role.</span></div>
                </section>
            </div>
        </div>
    );
}

export default Login;

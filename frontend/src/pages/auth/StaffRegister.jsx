import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { registerStaff } from "../../services/api";
import "./StaffRegister.css";

const staffContent = {
    EMPLOYEE: {
        eyebrow: "EMPLOYEE OPERATIONS",
        title: "Employee account request",
        description: "Submit your work email and password. Your request will be reviewed by an administrator before access is activated.",
        formDescription: "Employee access is intended for customer services, accounts and daily banking operations.",
        fieldLabel: "Work Email",
        contextTitle: "Keep customer operations moving.",
        login: "/employee/login",
        submit: "Submit employee application",
    },
    ADMIN: {
        eyebrow: "ADMINISTRATION",
        title: "Administrator access request",
        description: "Submit your email and password. An existing administrator must approve access before activation.",
        formDescription: "Administrator registration requires approval from an existing administrator.",
        fieldLabel: "Admin Email",
        contextTitle: "Monitor. Control. Audit.",
        login: "/admin/login",
        submit: "Submit administrator application",
    },
};

function StaffRegister({ role }) {
    const navigate = useNavigate();
    const content = staffContent[role];
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [confirmPassword, setConfirmPassword] = useState("");
    const [error, setError] = useState("");
    const [success, setSuccess] = useState("");
    const [loading, setLoading] = useState(false);

    async function handleSubmit(event) {
        event.preventDefault();
        setError("");
        setSuccess("");

        if (!email.trim() || !password || !confirmPassword) {
            setError("Please complete all required fields.");
            return;
        }

        if (!/^\S+@\S+\.\S+$/.test(email)) {
            setError("Please enter a valid email address.");
            return;
        }

        if (!/^(?=.*[A-Za-z])(?=.*\d).{8,}$/.test(password)) {
            setError("Password must be at least 8 characters and include a letter and a number.");
            return;
        }

        if (password !== confirmPassword) {
            setError("Passwords do not match.");
            return;
        }

        try {
            setLoading(true);
            await registerStaff(role, {
                email: email.trim(),
                password,
            });
            setSuccess("Your registration request has been submitted and requires administrator approval.");
            window.setTimeout(() => navigate(content.login), 1500);
        } catch (registrationError) {
            setError(registrationError.message || "Unable to submit registration request.");
        } finally {
            setLoading(false);
        }
    }

    return (
        <div className={`staff-register-page staff-${role.toLowerCase()}`}>
            <div className="staff-register-panel">
                <aside className="staff-register-aside">
                    <div className="staff-brand"><span>B</span><strong>BankEase</strong></div>
                    <span className="staff-kicker">{content.eyebrow}</span>
                    <h1>{content.contextTitle}</h1>
                    <p>{content.description}</p>
                </aside>
                <main className="staff-register-form-panel">
                    <div className="staff-heading"><span className="staff-kicker">ACCESS APPLICATION</span><h2>{content.title}</h2><p>{content.formDescription}</p></div>
                    <form className="staff-form" onSubmit={handleSubmit}>
                        <label>{content.fieldLabel}<input type="email" value={email} onChange={(event) => setEmail(event.target.value)} autoComplete="email" required /></label>
                        <label>Password<input type="password" value={password} onChange={(event) => setPassword(event.target.value)} autoComplete="new-password" required /><small>8+ characters, with a letter and number.</small></label>
                        <label>Confirm password<input type="password" value={confirmPassword} onChange={(event) => setConfirmPassword(event.target.value)} autoComplete="new-password" required /></label>
                        {error && <div className="staff-message error">{error}</div>}
                        {success && <div className="staff-message success">{success}</div>}
                        <button type="submit" disabled={loading || Boolean(success)}>{loading ? "Submitting..." : content.submit}</button>
                    </form>
                    <p className="staff-login-link">Already have access? <Link to={content.login}>Sign in</Link></p>
                </main>
            </div>
        </div>
    );
}

export default StaffRegister;

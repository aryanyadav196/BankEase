import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { registerCustomer } from "../../services/api";
import "./CustomerRegister.css";

function CustomerRegister() {
    const navigate = useNavigate();
    const [form, setForm] = useState({
        fullName: "",
        email: "",
        phone: "",
        address: "",
        password: "",
        confirmPassword: "",
    });
    const [error, setError] = useState("");
    const [success, setSuccess] = useState("");
    const [loading, setLoading] = useState(false);

    function updateField(event) {
        setForm((current) => ({
            ...current,
            [event.target.name]: event.target.value,
        }));
    }

    async function handleSubmit(event) {
        event.preventDefault();
        setError("");
        setSuccess("");

        if (!form.fullName.trim() || !form.email.trim() || !form.phone.trim() || !form.password) {
            setError("Please complete all required fields.");
            return;
        }

        if (!/^\S+@\S+\.\S+$/.test(form.email)) {
            setError("Please enter a valid email address.");
            return;
        }

        if (!/^(?=.*[A-Za-z])(?=.*\d).{8,}$/.test(form.password)) {
            setError("Password must be at least 8 characters and include a letter and a number.");
            return;
        }

        if (form.password !== form.confirmPassword) {
            setError("Passwords do not match.");
            return;
        }

        try {
            setLoading(true);
            await registerCustomer({
                fullName: form.fullName.trim(),
                email: form.email.trim(),
                phone: form.phone.trim(),
                address: form.address.trim(),
                password: form.password,
            });
            setSuccess("Your customer account is ready. Redirecting to sign in...");
            window.setTimeout(() => navigate("/customer/login"), 1200);
        } catch (registrationError) {
            setError(registrationError.message || "Unable to create your account.");
        } finally {
            setLoading(false);
        }
    }

    return (
        <div className="register-page">
            <div className="register-panel">
                <div className="register-aside">
                    <div className="register-brand"><span>B</span><strong>BankEase</strong></div>
                    <span className="register-kicker">PERSONAL BANKING</span>
                    <h1>Your everyday banking, together.</h1>
                    <p>Create your customer profile first. You can open and manage accounts after signing in.</p>
                </div>

                <div className="register-form-panel">
                    <div className="register-heading"><span className="register-kicker">PERSONAL BANKING</span><h2>Create your BankEase account</h2><p>Set up your customer profile to get started.</p></div>
                    <form onSubmit={handleSubmit} className="register-form">
                        <div className="register-field full"><label htmlFor="fullName">Full name</label><input id="fullName" name="fullName" value={form.fullName} onChange={updateField} autoComplete="name" required /></div>
                        <div className="register-field"><label htmlFor="email">Email</label><input id="email" name="email" type="email" value={form.email} onChange={updateField} autoComplete="email" required /></div>
                        <div className="register-field"><label htmlFor="phone">Phone</label><input id="phone" name="phone" type="tel" value={form.phone} onChange={updateField} autoComplete="tel" required /></div>
                        <div className="register-field full"><label htmlFor="address">Address <span>Optional</span></label><input id="address" name="address" value={form.address} onChange={updateField} autoComplete="street-address" /></div>
                        <div className="register-field"><label htmlFor="password">Password</label><input id="password" name="password" type="password" value={form.password} onChange={updateField} autoComplete="new-password" required /><small>8+ characters, with a letter and number.</small></div>
                        <div className="register-field"><label htmlFor="confirmPassword">Confirm password</label><input id="confirmPassword" name="confirmPassword" type="password" value={form.confirmPassword} onChange={updateField} autoComplete="new-password" required /></div>
                        {error && <div className="register-message error">{error}</div>}
                        {success && <div className="register-message success">{success}</div>}
                        <button className="register-submit" type="submit" disabled={loading || Boolean(success)}>{loading ? "Creating account..." : "Create customer account"}</button>
                    </form>
                    <p className="register-login-link">Already have an account? <Link to="/customer/login">Sign in</Link></p>
                </div>
            </div>
        </div>
    );
}

export default CustomerRegister;
